

# Function to check if a process is running
function IsProcessRunning {
    param (
        [string]$ProcessName
    )
    $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    return $null -ne $process
}

# Path to Google Update executable
$GoogleUpdatePath = "C:\Program Files (x86)\Google\Update\GoogleUpdate.exe"

$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

$ChromeRunning = IsProcessRunning "chrome"

# If Chrome is running, close it
if ($ChromeRunning) {
    Write-Output "Google Chrome is running. Closing it..."
    Start-Sleep -Seconds 1
    Stop-Process -Name "chrome" -Force
    Start-Sleep -Seconds 1
    Write-Output "Google Chrome closed."
}


# Check if the Google Update executable exists
if (Test-Path $GoogleUpdatePath) {
    Write-Output "Google Update executable found. Initiating update check..."
    Start-Sleep -Seconds 1
    # Start the Google Update process to check for updates and apply them
    Start-Process -FilePath $GoogleUpdatePath -ArgumentList "/ua" -Wait

    Write-Output "Google Chrome update check initiated."
    Start-Sleep -Seconds 1
} else {
    Write-Output "Google Update executable not found. Ensure Google Chrome is installed correctly."
    Start-Sleep -Seconds 1
}


# If Chrome was running before, relaunch it
if ($ChromeRunning) {
    Write-Output "Relaunching Google Chrome..."
    Start-Sleep -Seconds 1
    Start-Process -FilePath $ChromePath
    Write-Output "Google Chrome relaunched."
    Start-Sleep -Seconds 1
}