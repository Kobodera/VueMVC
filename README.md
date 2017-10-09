# VueMVC
A powershell script that will set up a Vue and .Net Core MVC project

I have read a number of tutorials on how to set up Vue as well as combining it with .Net Core. I have had some serious issues with those tutorials where I got more and more annoyed.

Finally I found a tutorial that worked... sort of... but it was not a perfect match for me.

What I wanted was:

1. Vue client and .Net Core MVC project separated in different folders
2. Interaction between Vue and .Net Core MVC app
3. Hot updates so that saving the Vue file would cause an instant update in the MVC project without reload
4. A Visual Studio Solution containing the two projects

This script does exactly that.

In essence the script does this
1. Checks if you have Node Packet Manager (NPM) installed. Since this is required in the script it will redirect you to the Node.js website where you can download and install it.
2. Checks if you have .Net Core API 2.0.0 (or later). Since this is required in the script it will redirect you to the Microsoft website where you can download and install it.
3. Checks if vue-cli is installed. If not it will install it for you (with global parameter)
4. Checks if webpack is installed. If not it will install it for you (with global parameter)
5. Creates two folders, one for the client and one for the server part of the script
6. Initializes the client folder with vue init webpack-simple and scaffolds it to point to the server
7. Initializes the server folder with dotnet new mvc and scaffolds it to use the client
8. Creates a Solution file (optional) in the parent directory and includes the client and server into it

Usage

Command prompt (Must be run as administrator to work)
powershell -File "<Path to VueMVC2.ps1>" -ClientName <ClientName> -ServerName <ServerName> -SolutionName <SolutionName>

Parameters
ClientName: Optional, the name of the client folder. Default: Client
ServerName: Optional, the name of the server folder and project name. Default: Server
SolutionName: Optional, the name of the .sln file. If not used the solution file will not be generated.
