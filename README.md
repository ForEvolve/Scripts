# Scripts

Some useful scripts.

## dotnet-new/dual-projects.ps1

Allows you to create a project, using any template available with `dotnet new`, and it associated xunit test project.

The project structure is as follow:

```
(root)
src
  {project name}
test
  {project name}.Tests
(optional){solution name}.sln
```

### How to install from source code
From the source code directory, execute the following command:

To install it locally, using the source:

```
Import-Module .\dotnet-new\dual-projects\dual-projects.psm1

# Example from a local directory to test scripts changes, you can load the module with absolute path:
# To unload the module, close the PowerShell console
Import-Module F:\Repos\ForEvolve.Scripts\dotnet-new\dual-projects\dual-projects.psm1
```

### How to install from MyGet
You can also use my published version, on MyGet, by executing the following commands:

Register my NuGet feed as `ForEvolveFeed`:

```
Import-Module PowerShellGet
$PSGalleryPublishUri = 'https://www.myget.org/F/forevolve/api/v2/package'
$PSGallerySourceUri = 'https://www.myget.org/F/forevolve/api/v2'
Register-PSRepository -Name ForEvolveFeed -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri
```

Install the module from that custom MyGet feed:

```
# for all users/as admin
Install-Module -Name "dual-projects" -RequiredVersion "1.0.0" -Repository ForEvolveFeed

# only for the current user
Install-Module -Name "dual-projects" -RequiredVersion "1.0.0" -Repository ForEvolveFeed -Scope CurrentUser
```

Finally, import the module:

```
Import-Module dual-projects.psm1
```

You may need update your execution policy, with `Set-ExecutionPolicy`, to be able to run PowerShell script file using the following command:

```
Set-ExecutionPolicy Unrestricted
```

*You need to run PowerShell in admin mode to execute that command.*

### Parameters

| Parameter          | Alias         | Switch? | Required | Default Value | Description                                                                      |
| ------------------ | ------------- | ------- | -------- | ------------- | -------------------------------------------------------------------------------- |
| `-projectName`     | `-p`          | No      | Yes      |               | The name of the project that you want to create, for exmaple: `SomeCoolProject`. |
| `-projectTemplate` | `-t`          | No      | No       | `web`         | The `dotnet new` template to use for the main project.                           |
| `-createSolution`  | `-create-sln` | Yes     | No       | `$false`      | Specify if you want to create a solution.                                        |
| `-solutionName`    | `-s`          | No      | No       |               | The name of the solution to create if it differs from the project name. You must include the `.sln` extension; example: `My.sln`.         |
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

## Other info (notes to self)

Publish to that custom MyGet feed:

```
$APIKey = 'YOUR-API-KEY'
Publish-Module -Path dotnet-new -NuGetApiKey $APIKey -Repository ForEvolveFeed -Verbose
```

Read feeds list: `Get-PSRepository`

Create a module manifest: `New-ModuleManifest -Path dual-projects.psd1`
