#---------------------------------
# License
#---------------------------------

# Copyright (c) 2017 Mikael Gustavsson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

#---------------------------------
# Usage
#---------------------------------
# This powershell script will create a VUE and .Net Core MVC project
# in the current folder and connects the two projects together
# Usage:
# Command prompt
# 1. Open an elevated (run as administrator) command prompt
# 2. Navigate to the folder where you wish to set the project up
# 3. Copy the VueMVC2.ps1 powershell file to the selected directory (or keep track of where the script is located
# 4. Run command: powershell -File .\VueMVC2.ps1 -ClientName [ClientName] -ServerName [ServerName] -SolutionName [SolutionName]
#	 Parameters
#	 ClientName (Optional, Default: Client) - The name of the client project
#	 ServerName (Optional, Default: Server) - The name of the server project
#	 SolutionName (Optional, Default: "" = No VS 2017 solution) - The name of the Visual Studio Solution file
#
param (
	[Parameter(Mandatory=$false)][String]$Template = "webpack-simple",
	[Parameter(Mandatory=$false)][String]$ClientName = "Client",
	[Parameter(Mandatory=$false)][String]$ServerName = "Server",
	[Parameter(Mandatory=$false)][String]$SolutionName = ""
)

Write-Host "Initialising..."
#If something goes wrong we do not wish to continue running the script
$ErrorActionPreference = "Stop"

#Keep the path to the current folder for future reference
$currentPath = (Get-Item -Path ".\" -Verbose).FullName
$splitPath = $currentPath.Split('\')
$name = $splitPath[$splitPath.Length - 1];

#If no project name have been supplied then use the current folder name as project name
# if ($SolutionName.Trim() -Eq "") {
	# $SolutionName = $name
# }

#Checks to see if the NPM packet installer is available
function CheckNpm {
	#Checking for NPM causes an error if NPM is not installed
	#This is to be expected so disregard this error
	$ErrorActionPreference = "SilentlyContinue"
	$version = npm --version
	$ErrorActionPreference = "Stop"
	if ($version -Eq $null -Or $version -Eq "") {
		$false
	}
	else {
		$true
	}
}

#Checks to see if vue-cli is available
function CheckVueCli {
	#Checking for vue-cli causes an error if vue-cli is not installed
	#This is to be expected so disregard this error
	$ErrorActionPreference = "SilentlyContinue"
	$version = vue --version
	$ErrorActionPreference = "Stop"
	if ($version -Eq $null -Or $version -Eq "") {
		$false
	}
	else {
		$true
	}
}

#Checks to see if webpack is available
function CheckWebpack {
	#Checking for vue-cli causes an error if vue-cli is not installed
	#This is to be expected so disregard this error
	$ErrorActionPreference = "SilentlyContinue"
	$version = webpack --version
	$ErrorActionPreference = "Stop"
	if ($version -Eq $null -Or $version -Eq "") {
		$false
	}
	else {
		$true
	}
}

#Checks to see if the .Net Core API is available
function CheckDotnetCore {
	#Checking for vue-cli causes an error if vue-cli is not installed
	#This is to be expected so disregard this error
	$ErrorActionPreference = "SilentlyContinue"
	$version = dotnet --version
	$ErrorActionPreference = "Stop"
	if ($version -Eq $null -Or $version -Eq "") {
		$false
	}
	else {
		$true
	}
}

#Checks the version of the installed .Net Core API if it is installed
function CheckDotnetCoreVersion {

	if ((CheckDotnetCore) -Eq $true) {
		$ErrorActionPreference = "SilentlyContinue"
		$version = dotnet --version
		$ErrorActionPreference = "Stop"
	
		$split = $version.Split('.')
	
		if ($split[0] -Ge 2) {
			$true
		}
		else {
			$false
		}
	}
}

Write-Host "Checking NPM installation..."

$installCheck = $true
if (-Not (CheckNpm) -Eq $true) {
	#Without NPM there is not much we can do to continue
	$installCheck = $false
	Write-Host "Node.js / NPM is not installed, this script require those to be installed."
	Write-Host "You will now be directed to the Node.js website to download the installer."
	Write-Host "Install Node.js and NPM and try again"
	start "https://nodejs.org/en/"
	Exit -1
}

Write-Host "Checking .Net Core installation..."

If (-Not (CheckDotnetCore) -Eq $true) {
	#Without .Net core there is not much we can do to continue
	Write-Host ".Net Core is not installed, this script require the .Net Core 2.0.0 API to be installed."
	Write-Host "You will now be directed to the .Net core website to allow you to download it."
	start "https://www.microsoft.com/net/download/core"
	Exit -1
}
else {
	Write-Host ".Net Core installation found. Checking version..."

	if (-Not (CheckDotnetCoreVersion) -Eq $true) {
		#If we have a version previous to 2.0.0 it is unclear if the script will work so abort
		Write-Host ".Net Core is installed but an older version. This script require you to have version 2.0.0 or later."
		Write-Host "You will now be directed to the .Net core website to allow you to download it."
		start "https://www.microsoft.com/net/download/core"
		Exit -1
	}
}

Write-Host "Checking vue-cli installation..."

if (-Not (CheckVueCli)) {
	Write-Host "Vue-Cli not installed or not in PATH"
	Write-Host "Installing Vue-Cli..."
	npm install -g vue-cli
}

Write-Host "Checking webpack installation..."

if (-Not (CheckWebpack)) {
	Write-Host "Webpack not installed or not in PATH"
	Write-Host "Installing Vue-Cli..."
	npm install -g webpack
}

Write-Host "Checks completed successfully!"

$clientPath = Join-Path -Path $currentPath $ClientName
$serverPath = Join-Path -Path $currentPath $ServerName

Write-Host "Creating Client and Server project folders"

New-Item $clientPath -type directory
New-Item $serverPath -type directory

#Install and modify client to integrate with the MVC server part of the project

Set-Location $clientPath

Write-Host "Initializeing Vue client project..."

vue init $Template

Write-Host "Installing NPM packages..."
npm install

#Extra packages that is not part of the Webpack-Simple template but is
#required to run the server in hot update mode
npm install --save-dev aspnet-webpack
npm install --save-dev webpack-hot-middleware

Write-Host "Modifying webpack.config.js..."

#Modify the webpack.config.js file to match the server
$webpackconfig = Get-Content -Raw -Path ".\webpack.config.js"
$webpackconfig = $webpackconfig.Replace("'./dist'", "'../$($ServerName)/wwwroot/dist'")
$webpackconfig = $webpackconfig.Replace("  entry: './src/main.js',", "  entry: { main: './src/main.js' },")
$webpackconfig = $webpackconfig.Replace("filename: 'build.js'", "filename: 'clientapp.js'")
$webpackconfig | Out-File ".\webpack.config.js" -Encoding ASCII

#Time to start working on the server
Set-Location $serverPath

#Create a new MVC project in the server folder
Write-Host "Initializing MVC Server project..."
dotnet new mvc

Write-Host "Bootstrapping MVC Server project..."

#Remove files and folders that have been created with the dotnet new mvc bootstrap
Remove-Item (Join-Path $serverPath "Views\Shared") -recurse
Remove-Item (Join-Path $serverPath "Views\_ViewStart.cshtml")
Remove-Item (Join-Path $serverPath "Views\Home\*")
Remove-Item (Join-Path $serverPath "Controllers\*")

#Very simple index page. The can be expanded to a full html page if nessessary
$indexPage = @"
<div id="app"></div>
<script src="~/dist/clientapp.js"></script>
"@

$indexPage | Out-File ".\Views\Home\Index.cshtml" -Encoding ASCII

#Bootstrap Home controller that only returns the index view
$homeController = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using $($ServerName).Models;

namespace $($ServerName).Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
"@

$homeController | Out-File ".\Controllers\HomeController.cs" -Encoding ASCII

Write-Host "Adding SpaServices to project"

#Modifying the project file to allow hot reloads
[Xml]$doc = Get-Content -Path ".\$($ServerName).csproj"
$element = $doc.Project.ItemGroup[0].AppendChild($doc.CreateElement("PackageReference"))
$element.SetAttribute("Include", "Microsoft.AspNetCore.SpaServices")
$element.SetAttribute("Version", "2.0.0")
$doc.Save((Join-Path -Path $currentPath "$($ServerName)\$($ServerName).csproj"))

#Restore the packages that has been added to the project file
dotnet restore

#Add code to the startup.cs file that allows for middleware interaction between server and client
$middlewareConfig = @"
`t`t`t`tapp.UseWebpackDevMiddleware(new WebpackDevMiddlewareOptions
`t`t`t`t{
`t`t`t`t`tHotModuleReplacement = true,
`t`t`t`t`tConfigFile = @"webpack.config.js",
`t`t`t`t`tProjectPath = Path.Combine(Directory.GetParent(Directory.GetCurrentDirectory()).FullName, "$($ClientName)")
`t`t`t`t});
"@

#Modify the Startup.cs file to allow hot reloads
$startup = Get-Content -Path ".\Startup.cs"
$startup[8] = $startup[8] += "using Microsoft.AspNetCore.SpaServices.Webpack;`r`n"
$startup[8] = $startup[8] += "using System.IO;`r`n"

$startup[31] = $startup[31] += "`r`n`r`n"
$startup[31] = $startup[31] += $middlewareConfig
$startup | Out-File (Join-Path -Path $serverPath "Startup.cs") -Encoding ASCII

Write-Host "Creating start script..."

#Running the server with "dotnet run" will start the server in production mode
#which will disable hot reloads. This scripts allows the user to start the
#server in either development, production or staging
#In order to do it manually the user will have to do the folowing steps
#1. Open elevated command prompt
#2. setx ASPNETCORE_ENVIRONMENT "Development"
#3. Exit command prompt
#4. Open elevated command prompt and navigate to the server folder
#5. dotnet run
$startscript = @"
param(
	[Parameter(Mandatory=`$false)][String]`$Environment = "Development"
)

`$temp = `$Environment.ToLower().Trim()

if (`$temp -Eq "development" -Or `$temp -Eq "staging" -Or `$temp -Eq "production" -Or `$temp -Eq "") {
	`$Env:ASPNETCORE_ENVIRONMENT = `$Environment
}
else {
	Write-Host "Unknown environment: `$Environment"
	Write-Host "Allowed envrionments are Development (Default), Production or Staging"
	`$Env:ASPNETCORE_ENVIRONMENT = ""
	Exit -1
}

Set-Location .\$($ServerName)

dotnet run

`$Env:ASPNETCORE_ENVIRONMENT = ""
Set-Location ..\
"@

$startscript | Out-File (Join-Path $currentPath "Start_$($ServerName).ps1") -Encoding ASCII

if (-Not ($SolutionName -Eq "")) {

Write-Host Setup Visual Studio Project...

$solutionGuid = [Guid]::NewGuid().Guid.ToUpper()
$clientProjectGuid = "E24C65DC-7377-472B-9ABA-BC803B73C61A"	#Web project
$serverProjectGuid = "9A19103F-16F7-4668-BE54-9A1E7A4F7556" #.Net Core 2.0 mvc project
$clientGuid = [Guid]::NewGuid().Guid.ToUpper()
$serverGuid = [Guid]::NewGuid().Guid.ToUpper()

$solution = @"
Microsoft Visual Studio Solution File, Format Version 12.00`r
# Visual Studio 15`r
VisualStudioVersion = 15.0.26730.8`r
MinimumVisualStudioVersion = 10.0.40219.1`r
Project("{$($clientProjectGuid)}") = "TimeKeeperClient", "TimeKeeperClient\", "{$($clientGuid)}"`r
	ProjectSection(WebsiteProperties) = preProject`r
		TargetFrameworkMoniker = ".NETFramework,Version%3Dv4.0"`r
		Debug.AspNetCompiler.VirtualPath = "/localhost_50972"`r
		Debug.AspNetCompiler.PhysicalPath = "TimeKeeperClient\"`r
		Debug.AspNetCompiler.TargetPath = "PrecompiledWeb\localhost_50972\"`r
		Debug.AspNetCompiler.Updateable = "true"`r
		Debug.AspNetCompiler.ForceOverwrite = "true"`r
		Debug.AspNetCompiler.FixedNames = "false"`r
		Debug.AspNetCompiler.Debug = "True"`r
		Release.AspNetCompiler.VirtualPath = "/localhost_50972"`r
		Release.AspNetCompiler.PhysicalPath = "TimeKeeperClient\"`r
		Release.AspNetCompiler.TargetPath = "PrecompiledWeb\localhost_50972\"`r
		Release.AspNetCompiler.Updateable = "true"`r
		Release.AspNetCompiler.ForceOverwrite = "true"`r
		Release.AspNetCompiler.FixedNames = "false"`r
		Release.AspNetCompiler.Debug = "False"`r
		VWDPort = "50972"`r
	EndProjectSection`r
EndProject`r
Project("{$($serverProjectGuid)}") = "TimeKeeperServer", "TimeKeeperServer\TimeKeeperServer.csproj", "{$($serverGuid)}"`r
EndProject`r
Global`r
	GlobalSection(SolutionConfigurationPlatforms) = preSolution`r
		Debug|Any CPU = Debug|Any CPU`r
		Release|Any CPU = Release|Any CPU`r
	EndGlobalSection`r
	GlobalSection(ProjectConfigurationPlatforms) = postSolution`r
		{$($clientGuid)}.Debug|Any CPU.ActiveCfg = Debug|Any CPU`r
		{$($clientGuid)}.Debug|Any CPU.Build.0 = Debug|Any CPU`r
		{$($clientGuid)}.Release|Any CPU.ActiveCfg = Debug|Any CPU`r
		{$($clientGuid)}.Release|Any CPU.Build.0 = Debug|Any CPU`r
		{$($serverGuid)}.Debug|Any CPU.ActiveCfg = Debug|Any CPU`r
		{$($serverGuid)}.Debug|Any CPU.Build.0 = Debug|Any CPU`r
		{$($serverGuid)}.Release|Any CPU.ActiveCfg = Release|Any CPU`r
		{$($serverGuid)}.Release|Any CPU.Build.0 = Release|Any CPU`r
	EndGlobalSection`r
	GlobalSection(SolutionProperties) = preSolution`r
		HideSolutionNode = FALSE`r
	EndGlobalSection`r
	GlobalSection(ExtensibilityGlobals) = postSolution`r
		SolutionGuid = {$($solutionGuid)}`r
	EndGlobalSection`r
EndGlobal`r
"@

$solution | Out-File (Join-Path $currentPath ($SolutionName + ".sln")) -Encoding ASCII
}

Write-Host ""
Write-Host "------------------------"
Write-Host "Initial install complete"
Write-Host "------------------------"

Set-Location $currentPath;
