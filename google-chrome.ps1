# Path to Google Update executable
$GoogleUpdatePath = "C:Program Files (x86)\Google\Update\GoogleUpdate.exe"

$ChromePath = "C:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"

# If Chrome is running, close it
if ($ChromeRunning) {
    Write-Output "Google Chrome is running. Closing it..."
    Stop-Process -Name "chrome" -Force
    Write-Output "Google Chrome closed."
}


# Check if the Google Update executable exists
if (Test-Path $GoogleUpdatePath) {
    Write-Output "Google Update executable found. Initiating update check..."

    # Start the Google Update process to check for updates and apply them
    Start-Process -FilePath $GoogleUpdatePath -ArgumentList "/ua" -Wait

    Write-Output "Google Chrome update check initiated."
} else {
    Write-Output "Google Update executable not found. Ensure Google Chrome is installed correctly."
}


# If Chrome was running before, relaunch it
if ($ChromeRunning) {
    Write-Output "Relaunching Google Chrome..."
    Start-Process -FilePath $ChromePath
    Write-Output "Google Chrome relaunched."
}