# Scripts

Some useful scripts.

## dotnet-new/dual-projects.ps1

Allows you to create a project, using any template available with `dotnet new`, and it associated xunit test project.
Optionally, you can also create a functional tests project which automatically import `Microsoft.AspNetCore.App` and `Microsoft.AspNetCore.Mvc.Testing`.

The project structure is as follow:

```
(root)
src
  {project name}
test
  {project name}.Tests
  (optional){project name}.FunctionalTests
(optional){solution name}.sln
```

### How to install from source code

From the source code directory, execute the following command:

To install it locally, using the source:

```powershell
Import-Module .\dotnet-new\dual-projects\dual-projects.psm1

# Example from a local directory to test scripts changes, you can load the module with absolute path:
# To unload the module, close the PowerShell console
Import-Module F:\Repos\ForEvolve.Scripts\dotnet-new\dual-projects\dual-projects.psm1
```

### How to install from MyGet

You can also use the published version, on MyGet, by executing the following commands:

Register ForEvolve NuGet feed as `ForEvolveFeed`:

```powershell
Import-Module PowerShellGet
$PSGalleryPublishUri = 'https://www.myget.org/F/forevolve/api/v2/package'
$PSGallerySourceUri = 'https://www.myget.org/F/forevolve/api/v2'
Register-PSRepository -Name ForEvolveFeed -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri

# If you trust my feed, you can run the following command to get rid of the anoying confirmation
# You will need an elevated PowerShell terminal
Set-PSRepository -Name "ForEvolveFeed" -InstallationPolicy Trusted
```

Install the module from that custom MyGet feed:

```powershell
# For all users (required an elevated terminal)
Install-Module -Name "dual-projects" -RequiredVersion "1.1.2" -Repository ForEvolveFeed

# Only for the current user
Install-Module -Name "dual-projects" -RequiredVersion "1.1.2" -Repository ForEvolveFeed -Scope CurrentUser
```

You may also have to import the module:

```powershell
Import-Module dual-projects
```

You may need to update your execution policy, with `Set-ExecutionPolicy`, to be able to run PowerShell script file using the following command:

```powershell
Set-ExecutionPolicy Unrestricted
```

> You need to run PowerShell in admin mode to execute that command.

### `Add-DualProjects` function

#### Parameters

| Parameter                         | Alias                     | Switch? | Required | Version | Default Value | Description                                                                                       |
| --------------------------------- | ------------------------- | ------- | -------- | ------- | ------------- | ------------------------------------------------------------------------------------------------- |
| `-projectName`                    | `-p`                      | No      | Yes      | 1.0.0   |               | The name of the project that you want to create, for exmaple: `SomeCoolProject`.                  |
| `-projectTemplate`                | `-t`                      | No      | No       | 1.0.0   | `web`         | The `dotnet new` template to use for the main project.                                            |
| `-createSolution`                 | `-create-sln`             | Yes     | No       | 1.0.0   | `$false`      | Specify if you want to create a solution.                                                         |
| `-solutionName`                   | `-s`                      | No      | No       | 1.0.0   |               | The name of the solution to create if it differs from the project name.                           |
| `-mkdir`                          |                           | No      | No       | 1.0.0   | `$true`       | Specify if you want to make a new directoy for the solution.                                      |
| `-noBuild`                        | `-no-build`               | Yes     | No       | 1.0.0   |               | If specified, `dotnet build` will not run after the projects creation.                            |
| `-addFunctionalTests`             | `-add-functional-tests`   | Yes     | No       | 1.1.0   |               | If specified, `Add-FunctionalTests` will be called to add a function tests project.               |
| `-customTestsPropsFile`           | `-tests-props`            | No      | No       | 1.1.0   | `$null`       | Allow specifying a `.props` file that will be imported at the top of the unit test project.       |
| `-customFunctionalTestsPropsFile` | `-functional-tests-props` | No      | No       | 1.1.0   | `$null`       | Allow specifying a `.props` file that will be imported at the top of the functional test project. |

#### How to use

How to create a project and a test project (named `SomeCoolProject`) in an existing solution:

```powershell
Add-DualProjects -projectName SomeCoolProject
```

How to create a project, a test project (named `SomeCoolProject`) and a solution:

```powershell
Add-DualProjects -projectName SomeCoolProject -createSolution
```

How to create a class library project and a test project (named `SomeCoolProject`) in an existing solution:

```powershell
Add-DualProjects -projectName SomeCoolProject -projectTemplate classlib
```

How to create a class library project, a test project (named `SomeCoolProject`) and a solution:

```powershell
Add-DualProjects -projectName SomeCoolProject -projectTemplate classlib -createSolution
```

How to create an MVC project and a test project (named `SomeCoolProject`) in an new solution named some-solution.sln in the current directory:

```powershell
Add-DualProjects -projectName SomeCoolProject -projectTemplate mvc -createSolution -solutionName some-solution.sln -mkdir $false
```

To tell the script not to build the solution, you can specify `-noBuild` or `-no-build`:

```powershell
Add-DualProjects -p SomeCoolProject -t mvc -s some-solution.sln -mkdir $false -no-build -create-sln
```

How to create a project named `SomeCoolProject`, a unit tests project, and a functional tests project in the default, existing, solution:

```powershell
Add-DualProjects -projectName SomeCoolProject -add-functional-tests
```

How to create a project named `SomeCoolProject`, a unit tests project, and a functional tests project in the default, existing, solution with each test project importing its own `props` file.
This command also includes the `-no-build` flag which can become handy when `GenerateDocumentationFile` is set to `true` and `TreatWarningsAsErrors` is also set to `true` (in a `Directory.Build.props` file for example).

```powershell
Add-DualProjects -projectName SomeCoolProject -add-functional-tests -functional-tests-props ..\FunctionalTests.Build.props -customTestsPropsFile ..\UnitTests.Build.props -no-build
```

### `Add-FunctionalTests` function

#### Parameters

| Parameter          | Alias       | Switch? | Required | Version | Default Value | Description                                                                                                  |
| ------------------ | ----------- | ------- | -------- | ------- | ------------- | ------------------------------------------------------------------------------------------------------------ |
| `-projectName`     | `-p`        | No      | Yes      | 1.1.0   |               | The name of the project that you want to create, for exmaple: `SomeCoolProject`.                             |
| `-solutionName`    | `-s`        | No      | No       | 1.1.0   |               | The name of the solution to add your functional tests project to if there is more than one in the directory. |
| `-noBuild`         | `-no-build` | Yes     | No       | 1.1.0   |               | If specified, `dotnet build` will not run after the projects creation.                                       |
| `-customPropsFile` | `-props`    | No      | No       | 1.1.0   | `$null`       | Allow specifying a `.props` file that will be imported at the top of the functional test project.            |

#### How to use

How to create a functional tests project for the project `SomeCoolProject`:

```powershell
Add-FunctionalTests -p SomeCoolProject
```

> This will create a xunit project into `test/SomeCoolProject.FunctionalTests` linked to `src/SomeCoolProject`.

How to create a functional tests project for the project `SomeCoolProject` and include a `props` file located into `test/FunctionalTests.Build.props`:

```powershell
Add-FunctionalTests -p SomeCoolProject -props ..\FunctionalTests.Build.props
```

> This will add `<Import Project="..\FunctionalTests.Build.props" />` at the top of the project file ( under `<Project Sdk="Microsoft.NET.Sdk.Web">`).

## Other info (notes to self)

Use a custom MyGet feed:

```powershell
Import-Module PowerShellGet
$PSGalleryPublishUri = 'https://www.myget.org/F/forevolve/api/v2/package'
$PSGallerySourceUri = 'https://www.myget.org/F/forevolve/api/v2'
Register-PSRepository -Name ForEvolveFeed -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri

# To unregister a source
Unregister-PSRepository -Name ForEvolveFeed

# To trust the source
Set-PSRepository -Name "ForEvolveFeed" -InstallationPolicy Trusted
```

Install the module from that custom MyGet feed:

```powershell
# Only for the current user
Install-Module -Name "dual-projects" -RequiredVersion "1.1.2" -Repository ForEvolveFeed -Scope CurrentUser

# For all users (required an elevated terminal)
Install-Module -Name "dual-projects" -RequiredVersion "1.1.2" -Repository ForEvolveFeed

# Update the module (force is required to overrite the old version)
Update-Module -Name "dual-projects" -RequiredVersion "1.1.2" -Force

# List installed modules
Get-InstalledModule -Name "dual-projects"

# Uninstall the module
Uninstall-Module -Name "dual-projects" -AllVersions
```

Publish to that custom MyGet feed:

```powershell
$APIKey = 'YOUR-API-KEY'
cd dotnet-new
Publish-Module -Path dual-projects -NuGetApiKey $APIKey -Repository ForEvolveFeed -Verbose
```

Read feeds list: `Get-PSRepository`

Create a module manifest: `New-ModuleManifest -Path dual-projects.psd1`

# Release Notes

## 1.1.2

-   Update the module description.
-   Specify `FunctionsToExport` at the module level.

## 1.1.1

-   Fix: Convert the _csproj_ file path to absolute before reading it to make sure it works everytime.

## 1.1.0

-   Add the `Add-FunctionalTests` function.
-   Add functional tests options to the `Add-DualProjects` function (which now act more like "add three projects" than "add two projects").
-   Unit tests and fucntional tests projects now adds the right `RootNamespace` in their `csproj` file.

## 1.0.0

-   Initial release of the `Add-DualProjects` function.
