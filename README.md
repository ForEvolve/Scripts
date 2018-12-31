# Scripts

Useful scripts

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

## How to install

```
Import-Module .\dotnet-new\dual-projects.psm1
```

## How to use

How to create a project and a test project (named booyaba) in an existing solution:

```powershell
./dotnet-new/dual-projects.ps1 -projectName booyaba -nosln
```

How to create a project, a test project (named booyaba) and a solution:

```powershell
./dotnet-new/dual-projects.ps1 -projectName booyaba
```

How to create a class library project and a test project (named booyaba) in an existing solution:

```powershell
./dotnet-new/dual-projects.ps1 -projectName booyaba -nosln -classlib
OR
./dotnet-new/dual-projects.ps1 -projectName booyaba -nosln -projectTemplate classlib
```

How to create a class library project, a test project (named booyaba) and a solution:

```powershell
./dotnet-new/dual-projects.ps1 -projectName booyaba -classlib
OR
./dotnet-new/dual-projects.ps1 -projectName booyaba -projectTemplate classlib
```

How to create an MVC project and a test project (named booyaba) in an new solution named some-solution.sln in the current directory:

```powershell
./dotnet-new/dual-projects.ps1 -projectName booyaba -projectTemplate mvc -solutionName some-solution.sln
```
