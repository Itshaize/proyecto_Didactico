$ErrorActionPreference = 'Stop'

$tomcat = 'C:\Users\DOCENTE\Documents\Universidad\tools\apache-tomcat-9.0.87'
$javaHome = 'C:\Users\DOCENTE\.p2\pool\plugins\org.eclipse.justj.openjdk.hotspot.jre.full.win32.x86_64_21.0.11.v20260515-1531\jre'

$env:JAVA_HOME = $javaHome
$env:JRE_HOME = $javaHome
$env:Path = "$javaHome\bin;$env:Path"

& "$tomcat\bin\catalina.bat" stop

