# Create packages directory on Dev Drive
$DevDrive = "D:"
New-Item -Path $DevDrive\ -Name "Packages" -ItemType "directory"

# Move npm packages
Move-Item -Path $env:LocalAppData\npm-cache* -Destination $DevDrive\Packages

# Move NuGet packages
Move-Item -Path $env:UserProfile\.nuget* -Destination $DevDrive\Packages

# Move Maven packages
Move-Item -Path $env:UserProfile\.m2* -Destination $DevDrive\Packages

# Move Gradle cache
Move-Item -Path $env:UserProfile\.gradle* -Destination $DevDrive\Packages

# Set configuration
[Environment]::SetEnvironmentVariable("npm_config_cache", "$DevDrive\Packages\npm_cache", "User")
[Environment]::SetEnvironmentVariable("NUGET_PACKAGES", "$DevDrive\Packages\.nuget\packages", "User")
[Environment]::SetEnvironmentVariable("MAVEN_OPTS", "-Dmaven.repo.local=$DevDrive\Packages\.m2 $env:MAVEN_OPTS", "User")
[Environment]::SetEnvironmentVariable("GRADLE_USER_HOME", "$DevDrive\Packages\.gradle", "User")