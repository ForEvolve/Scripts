# Scripts

Some useful scripts.

## dotnet-new/dual-projects.ps1

Allows you to create a project of any type (possible with `dotnet new`) and its associated test project (using `xunit`).

The project structure is as follow:

```
(root)
src
  {project name}
test
  {project name}.Tests
(optional){solution name}.sln
```

### How to install

```
Import-Module .\dotnet-new\dual-projects.psm1
```

### Parameters

| Parameter          | Alias         | Switch? | Required | Default Value | Description                                                                      |
| ------------------ | ------------- | ------- | -------- | ------------- | -------------------------------------------------------------------------------- |
| `-projectName`     | `-p`          | No      | Yes      |               | The name of the project that you want to create, for exmaple: `SomeCoolProject`. |
| `-projectTemplate` | `-t`          | No      | No       | `web`         | The `dotnet new` template to use for the main project.                           |
| `-createSolution`  | `-create-sln` | Yes     | No       | `$false`      | Specify if you want to create a solution.                                        |
| `-solutionName`    | `-s`          | No      | No       |               | The name of the solution to create if it differs from the project name.          |
| `-mkdir`           |               | No      | No       | `$true`       | Specify if you want to make a new directoy for the solution.                     |
| `-noBuild`         | `-no-build`   | Yes     | No       |               | If specified, `dotnet build` will not be run after the projects creation.        |

### How to use

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

## Other info

Use a custom MyGet feed:

```
Import-Module PowerShellGet
$PSGalleryPublishUri = 'https://www.myget.org/F/forevolve/api/v2/package'
$PSGallerySourceUri = 'https://www.myget.org/F/forevolve/api/v2'
Register-PSRepository -Name MyGetFeed -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri
```

Install the module from that custom MyGet feed:

```
Install-Module -Name "dual-projects" -RequiredVersion "1.0.0" -Repository MyGetFeed -Scope CurrentUser
```

Publish to that custom MyGet feed:

```
$APIKey = 'YOUR-API-KEY'
Publish-Module -Path dotnet-new -NuGetApiKey $APIKey -Repository MyGetFeed -Verbose
```

Read feeds list: `Get-PSRepository`

Create a module manifest: `New-ModuleManifest -Path dual-projects.psd1`
