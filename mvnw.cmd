@echo off
setlocal
where mvn >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    mvn %*
    exit /b %ERRORLEVEL%
)

set "MAVEN_LOCAL=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9\apache-maven-3.9.9\bin\mvn.cmd"
if exist "%MAVEN_LOCAL%" (
    call "%MAVEN_LOCAL%" %*
    exit /b %ERRORLEVEL%
)

echo Downloading Apache Maven 3.9.9 via PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$z=\"$env:TEMP\maven.zip\"; $d=\"$env:USERPROFILE\.m2\wrapper\dists\apache-maven-3.9.9\"; New-Item -ItemType Directory -Force -Path $d | Out-Null; Invoke-WebRequest -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip' -OutFile $z; Expand-Archive -Path $z -DestinationPath $d -Force"
call "%MAVEN_LOCAL%" %*
endlocal
