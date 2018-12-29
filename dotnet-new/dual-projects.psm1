function Add-Solution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
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

function Main-ASDF {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true)][string]$projectName,
        [string]$projectTemplate = "web",
        [switch]$classlib = $false,
        [switch]$createSolution = $false,
        [string]$solutionName = $null,
        [bool]$mkdir = $true
    )
    $debugColor = "magenta"
    
    if ($debug) {
        Write-Host "solutionName: $solutionName" -foregroundcolor $debugColor
    }
    
    if ($createSolution) {
        Add-Solution $solutionName $mkdir $projectName
    }
    
    # Create project paths
    $SrcProjectDir = "src\$projectName"
    $TestProjectDir = "test\$projectName.Tests"
    
    $SrcProjectName = "$projectName"
    $TestProjectName = "$projectName.Tests"
    
    $SrcProjectPath = "$SrcProjectDir\$projectName.csproj"
    $TestProjectPath = "$TestProjectDir\$projectName.Tests.csproj"
    
    # Create project
    if (!(Test-Path src)) {
        if ($debug) { Write-Host "Creating src diretory using command: mkdir src" -foregroundcolor $debugColor }
        mkdir src
    }
    Set-Location src
    if ($classlib -and $projectTemplate -eq "web") {
        $projectTemplate = "classlib";
    }
    if ($debug) { Write-Host "Creating project using command: dotnet new $projectTemplate -n $SrcProjectName" -foregroundcolor $debugColor }
    dotnet new $projectTemplate -n $SrcProjectName
    Set-Location ..
    
    # Create test project
    if (!(Test-Path test)) {
        if ($debug) { Write-Host "Creating test diretory using command: mkdir test" -foregroundcolor $debugColor }
        mkdir test
    }
    Set-Location test
    if ($debug) { Write-Host "Creating test project using command: dotnet new xunit -n $TestProjectName" -foregroundcolor $debugColor }
    dotnet new xunit -n $TestProjectName
    Set-Location ..
    
    # Add Reference to test project
    if ($debug) { Write-Host "Adding reference from src to test project using command: dotnet add $TestProjectPath reference $SrcProjectPath" -foregroundcolor $debugColor }
    dotnet add $TestProjectPath reference $SrcProjectPath
    
    # Add projects to solution
    if ($solutionName -eq $null) {
        if ($debug) { Write-Host "Adding projects to solution using command: dotnet sln add $SrcProjectPath $TestProjectPath" -foregroundcolor $debugColor }
        dotnet sln add $SrcProjectPath $TestProjectPath
    }
    else {
        if ($debug) { Write-Host "Adding projects to solution using command: dotnet sln $solutionName add $SrcProjectPath $TestProjectPath" -foregroundcolor $debugColor }
        dotnet sln $solutionName add $SrcProjectPath $TestProjectPath
    }
}