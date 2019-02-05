function Add-Solution {
    [CmdletBinding()]
    param(
        [string] $solutionName,
        [bool] $mkdir = $false,
        [string] $projectName = $null
    )

    # Create the solution
    if ($solutionName) {
        $noExtensionSolutionName = $solutionName -replace ".sln", ""
        Write-Verbose "noExtensionSolutionName: $noExtensionSolutionName"

        # Create and move to solution directory
        if ($mkdir) {
            Write-Verbose "Creating solution diretory using command: mkdir $noExtensionSolutionName"
            mkdir $noExtensionSolutionName

            Write-Verbose "Navigating to diretory using command: Set-Location $noExtensionSolutionName"
            Set-Location $noExtensionSolutionName
        }
    
        Write-Verbose "Creating a solution named $noExtensionSolutionName"
        dotnet new sln -n $noExtensionSolutionName
    }
    else {
        # Create and move to solution directory
        if ($mkdir) {
            Write-Verbose "Creating solution diretory using command: mkdir $projectName"
            mkdir $projectName

            Write-Verbose "Navigating to diretory using command: Set-Location $projectName"
            Set-Location $projectName
        }
    
        Write-Verbose "Creating a new solution using command: dotnet new sln "
        dotnet new sln    
    }
}

function Add-Project {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $projectDirectory,
        [Parameter(Mandatory = $true)][string] $projectName,
        [Parameter(Mandatory = $true)][string] $projectTemplate,
        [string]$solutionName = $null
    )
    Write-Debug "projectDirectory: $projectDirectory"
    Write-Debug "projectName: $projectName"
    Write-Debug "projectTemplate: $projectTemplate"

    # Create the src/test dir if they don't exist
    if (!(Test-Path $projectDirectory)) {
        Write-Verbose "Creating $projectDirectory diretory using command: mkdir $projectDirectory"
        mkdir $projectDirectory
    }

    # Create the project
    Set-Location $projectDirectory
    Write-Verbose "Creating project using command: dotnet new $projectTemplate -n $projectName"
    dotnet new $projectTemplate -n $projectName --no-restore
    Set-Location ..
        
    # Add the project to the solution
    $projectPath = GetProjectPath $projectDirectory $projectName
    Write-Debug "projectPath: $projectPath"
    if ($solutionName) {
        Write-Verbose "Adding project to solution using command: dotnet sln $solutionName add $projectPath"
        dotnet sln $solutionName add $projectPath
    }
    else {
        Write-Verbose "Adding project to solution using command: dotnet sln add $projectPath"
        dotnet sln add $projectPath
    }
}

function Add-DualProjects {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][Alias("p")][string]$projectName,
        [Alias("t")][string]$projectTemplate = "web",
        [Alias("create-sln")][switch]$createSolution = $false,
        [Alias("s")][string]$solutionName = $null,
        [bool]$mkdir = $true,
        [Alias("no-build")][switch]$noBuild,
        [Alias("add-functional-tests")][switch]$addFunctionalTests,
        [Alias("tests-props")][string]$customTestsPropsFile = $null,
        [Alias("functional-tests-props")][string]$customFunctionalTestsPropsFile = $null
    )
    
    Write-Debug "projectName: $projectName"
    Write-Debug "projectTemplate: $projectTemplate"
    Write-Debug "createSolution: $createSolution"
    Write-Debug "solutionName: $solutionName"
    Write-Debug "mkdir: $mkdir"
    Write-Debug "noBuild: $noBuild"
    Write-Debug "addFunctionalTests: $addFunctionalTests"
    Write-Debug "customTestsPropsFile: $customTestsPropsFile"
    Write-Debug "customFunctionalTestsPropsFile: $customFunctionalTestsPropsFile"
    
    if ($createSolution) {
        Add-Solution $solutionName $mkdir $projectName
    }
    
    # Create the project
    Add-Project src $projectName $projectTemplate $solutionName
    
    # Create the test project
    Add-Project test "$projectName.Tests" xunit $solutionName
    
    # Add Reference to test project
    $srcProjectPath = GetProjectPath src $projectName
    $testProjectPath = GetProjectPath test "$projectName.Tests"
    ReferenceSourceFromTest $srcProjectPath $testProjectPath

    # Update the RootNamespace to the test project
    UpdateRootNamespace $projectName $testProjectPath $customTestsPropsFile

    # Create a functional test project
    if ($addFunctionalTests) {
        Add-FunctionalTests $projectName $solutionName -no-build -props $customFunctionalTestsPropsFile
    }

    # Execute post-creation actions
    if (!$noBuild) {
        BuildSolution $solutionName
    }
}

function Add-FunctionalTests {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][Alias("p")][string]$projectName,
        [Alias("s")][string]$solutionName = $null,
        [Alias("no-build")][switch]$noBuild,
        [Alias("props")][string]$customPropsFile = $null #"..\FunctionalTests.Build.props"
    )
    Write-Debug "projectName: $projectName"
    Write-Debug "solutionName: $solutionName"
    Write-Debug "noBuild: $noBuild"

    # Create the functional test project
    Add-Project test "$projectName.FunctionalTests" xunit $solutionName
    
    # Add Reference to test project
    $srcProjectPath = GetProjectPath src $projectName
    $testProjectPath = GetProjectPath test "$projectName.FunctionalTests"
    ReferenceSourceFromTest $srcProjectPath $testProjectPath

    # Add Microsoft.AspNetCore.Mvc.Testing
    dotnet add $testProjectPath package Microsoft.AspNetCore.App
    dotnet add $testProjectPath package Microsoft.AspNetCore.Mvc.Testing

    # Include the RootNamespace and optionally a custom .props file to the project
    UpdateRootNamespace $projectName $testProjectPath $customPropsFile
    
    # Execute post-creation actions
    if (!$noBuild) {
        BuildSolution $solutionName
    }
}

function UpdateRootNamespace($projectName, $testProjectPath, $customPropsFile = $null) {
    $i = 0;
    $tmpFile = "$testProjectPath.tmp"        
    foreach ($line in [System.IO.File]::ReadLines($testProjectPath)) {
        if ($i -eq 1) {
            if ($customPropsFile) {
                Write-Verbose "Adding '$customPropsFile' to '$testProjectPath'."
                Add-Content -Path $tmpFile -Value "  <Import Project=""$customPropsFile"" />"
                Add-Content -Path $tmpFile -Value ""
            }

            # Set the RootNamespace
            Write-Verbose "Setting RootNamespace to '$projectName'."
            Add-Content -Path $tmpFile -Value "  <PropertyGroup>"
            Add-Content -Path $tmpFile -Value "    <RootNamespace>$projectName</RootNamespace>"
            Add-Content -Path $tmpFile -Value "  </PropertyGroup>"
        }
        Add-Content -Path $tmpFile -Value $line
        $i = $i + 1
    }

    # Delete original csproj
    Write-Verbose "Deleting '$testProjectPath'."
    Remove-Item –path $testProjectPath

    # Rename .csproj.tmp to .csproj
    Write-Verbose "Renaming '$tmpFile' to '$testProjectPath'."
    Move-Item -Path $tmpFile -Destination $testProjectPath
}
function BuildSolution($solutionName) {
    if ($solutionName) {
        Write-Verbose "Building solution using command: dotnet restore $solutionName"
        dotnet build $solutionName
    }
    else {
        Write-Verbose "Building solution using command: dotnet restore"
        dotnet build
    }
}

function GetProjectPath($projectDirectory, $projectName) {
    return "$projectDirectory\$projectName\$projectName.csproj";
}

function ReferenceSourceFromTest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$srcProjectPath,
        [Parameter(Mandatory = $true)][string]$testProjectPath
    )
    Write-Debug "srcProjectPath: $srcProjectPath"
    Write-Debug "testProjectPath: $testProjectPath"
    Write-Verbose "Adding reference to test project using command: dotnet add $testProjectPath reference $srcProjectPath"
    dotnet add $testProjectPath reference $srcProjectPath
}

Export-ModuleMember -Function Add-DualProjects, Add-FunctionalTests