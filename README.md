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

### How to install

```
Import-Module .\dotnet-new\dual-projects.psm1
```

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
