$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$tomcat = 'C:\Users\DOCENTE\Documents\Universidad\tools\apache-tomcat-9.0.87'

& "$project\build_local.ps1"
Copy-Item -LiteralPath "$project\target\proyecto.war" -Destination "$tomcat\webapps\englishkids.war" -Force

Write-Host 'WAR deployed to local Tomcat 9 as englishkids.war'

