$ErrorActionPreference = 'Stop'

$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$javaHome = 'C:\Users\DOCENTE\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.11.v20260515-1531\jre'
$maven = 'C:\Users\DOCENTE\Documents\Universidad\tools\apache-maven-3.9.6\bin\mvn.cmd'

$env:JAVA_HOME = $javaHome
$env:Path = "$javaHome\bin;$env:Path"

Set-Location $project
& $maven clean package

