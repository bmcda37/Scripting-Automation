$file = "C:\Windows\System32\curl.exe"
$acl = Get-Acl $file
$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$owner = $identity.User
$acl.SetOwner($owner)
Set-Acl -Path $file -AclObject $acl

$packageName = "curl.curl"
$installPath = "C:\Windows\SysWOW64\curl.exe"

# Check if curl is already installed
if (!(Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    # Install curl using winget
    winget install -e --id $packageName

    # Wait for the installation to complete
    Start-Sleep -Seconds 10

    # Set the owner of the installed curl.exe file
    $acl = Get-Acl $installPath
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $owner = $identity.User
    $acl.SetOwner($owner)
    Set-Acl -Path $installPath -AclObject $acl
}

# Set the new version of curl to the Path environment variable
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newCurlPath = "C:\Path\to\new\curl.exe"

# Remove the old curl.exe from the Path environment variable
$envPath = $envPath -replace ";C:\\Windows\\SysWOW64", ""
[Environment]::SetEnvironmentVariable("Path", $envPath, "Machine")

# Add the new curl.exe to the Path environment variable
$envPath += ";$newCurlPath"
[Environment]::SetEnvironmentVariable("Path", $envPath, "Machine")

# Delete the old curl.exe
Remove-Item -Path "C:\Windows\SysWOW64\curl.exe" -Force

# Restart the shell
Restart-Shell

