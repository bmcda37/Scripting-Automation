# Path to Google Update executable
$GoogleUpdatePath = "C:Program Files (x86)\Google\Update\GoogleUpdate.exe"

# Check if the Google Update executable exists
if (Test-Path $GoogleUpdatePath) {
    Write-Output "Google Update executable found. Initiating update check..."

    # Start the Google Update process to check for updates and apply them
    Start-Process -FilePath $GoogleUpdatePath -ArgumentList "/ua" -Wait

    Write-Output "Google Chrome update check initiated."
} else {
    Write-Output "Google Update executable not found. Ensure Google Chrome is installed correctly."
}
