
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday,Wednesday -At 9:55am
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "C:\scripts\google-chrome.ps1"'

Register-ScheduledTask -TaskName "GoogleRefresh" -TaskPath 'GoogleRefresh' -Action $action -Trigger $trigger 

