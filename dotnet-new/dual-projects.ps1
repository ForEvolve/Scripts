param (
    [Parameter(Mandatory = $true)][string]$projectName,
    [switch]$nosln = $false,
    [switch]$classlib = $false,
    [string]$projectTemplate = "web",
    [string]$solutionName = $null,
    [switch]$debug = $true
)
$createSolution = !$nosln
$debugColor = "magenta"

if ($debug) {
    Write-Host "createSolution: $createSolution" -foregroundcolor $debugColor
    Write-Host "solutionName: $solutionName" -foregroundcolor $debugColor
    Write-Host "condition1: ", ($createSolution -and $solutionName) -foregroundcolor $debugColor
    Write-Host "condition2: ", ($createSolution -and !$solutionName) -foregroundcolor $debugColor
}

if ($createSolution -and $solutionName) {
    # Create and move to project directory
    if ($debug) { Write-Host "Creating solution diretory using command: mkdir $projectName" -foregroundcolor $debugColor }
    mkdir $projectName
    Set-Location $projectName

    # Create the solution
    if ($debug) { Write-Host "Creating a new solution" -foregroundcolor $debugColor }
    dotnet new sln
}
elseif ($createSolution -and !$solutionName) {
    $noExtensionSolutionName = $solutionName -replace ".sln", ""
    if ($debug) { Write-Host "Creating a solution named $noExtensionSolutionName" -foregroundcolor $debugColor }
    dotnet new sln -n $noExtensionSolutionName
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