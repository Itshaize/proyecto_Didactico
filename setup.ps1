$ErrorActionPreference = 'Stop'

$workDir = "C:\Users\Ismal\tomcat_server"
if (!(Test-Path $workDir)) {
    New-Item -ItemType Directory -Path $workDir | Out-Null
}

cd $workDir

Write-Host "Downloading Maven..."
$mvnZip = "$workDir\maven.zip"
if (!(Test-Path "apache-maven-3.9.6")) {
    curl.exe -L "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip" -o $mvnZip
    Expand-Archive -Path $mvnZip -DestinationPath $workDir -Force
}

Write-Host "Downloading Tomcat 9..."
$tomcatZip = "$workDir\tomcat.zip"
if (!(Test-Path "apache-tomcat-9.0.87")) {
    curl.exe -L "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87-windows-x64.zip" -o $tomcatZip
    Expand-Archive -Path $tomcatZip -DestinationPath $workDir -Force
}

Write-Host "Building project..."
cd c:\Users\Ismal\eclipse-workspace\proyecto
$mvnCmd = "$workDir\apache-maven-3.9.6\bin\mvn.cmd"
& $mvnCmd clean package

if ($LASTEXITCODE -ne 0) {
    Write-Error "Maven build failed!"
    exit 1
}

Write-Host "Deploying WAR to Tomcat..."
$tomcatWebapps = "$workDir\apache-tomcat-9.0.87\webapps"
Copy-Item "target\proyecto.war" -Destination "$tomcatWebapps\englishkids.war" -Force

Write-Host "Starting Tomcat..."
cd "$workDir\apache-tomcat-9.0.87\bin"
& .\startup.bat

Write-Host "Tomcat started successfully! You can access it at http://localhost:8080/englishkids"
