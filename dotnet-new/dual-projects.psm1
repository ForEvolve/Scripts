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
        [Parameter(Mandatory = $true)][string]$projectName,
        [string]$projectTemplate = "web",
        [switch]$createSolution = $false,
        [string]$solutionName = $null,
        [bool]$mkdir = $true
    )
    
    Write-Debug "projectName: $projectName"
    Write-Debug "projectTemplate: $projectTemplate"
    Write-Debug "createSolution: $createSolution"
    Write-Debug "solutionName: $solutionName"
    Write-Debug "mkdir: $mkdir"
    
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

    # Execute post-creation actions
    ExecutePostCreationActions $solutionName
}

function ExecutePostCreationActions($solutionName) {
    if ($solutionName) {
        Write-Verbose "Restoring solution using command: dotnet restore $solutionName"
        #dotnet restore $solutionName
        dotnet build $solutionName
    }
    else {
        Write-Verbose "Restoring solution using command: dotnet restore"
        #dotnet restore
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
