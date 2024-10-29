   # Check if the script is running as an administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Output "Script is not being ran as an administrator. Please exit PowerShell and re-run script as an administrator..."
        exit
    }

    #Create a execution policy variable to check the current policy
    $policy = Get-ExecutionPolicy

    #Change the execution policy to Bypass temporarily for this process
    try{
     
        if ($policy -ne "Bypass") {
            Write-Output "Execution policy was $policy... Setting Execution Policy to Bypass"
            Set-ExecutionPolicy Bypass -Scope Process -Force
        }
        else{
            Write-Output "Policy is already set to Bypass, begining to gather information."
        }
    }
    catch{
        Write-Error "An error occured when setting the execution policy to Bypass. Error: $_"
    }
 
    #Import the needed modules for the .xlsx files so that I can have multiple worksheets.
    try{
     
        if (-not (Get-Module ImportExcel -ListAvailable)) {
            Write-Output "ImportExcel module not found, installing now..."
     
            Install-Module ImportExcel -Scope CurrentUser -Force
            Import-Module ImportExcel -Force
        }
    }
    catch{
        Write-Error "An error occured when importing the needed modules. Error: $_"
    }
 

    try{
        #Get my system information and save to excel worksheet.    
        Get-CimInstance -ClassName Win32_Product | Export-Excel -Path ".\asgn1.xlsx" -WorksheetName "System Information" 
        Write-Output "System Information has been collected and exported to asgn1.xlsx"
    }
    catch{
       #Print any error that occured from command above.
        Write-Error "Unable to collect system information. Error: $_"
    }

        #Get the process information and save to excel worksheet.
    try {
        Get-Process | Export-Excel -Path ".\asgn1.xlsx" -WorksheetName "ProcessInformation" -Append
        Write-Output "Process Information has been collected and exported to asgn1.xlsx"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect process information. Error: $_"
    }


    try {
       #Get the Network information and include any hidden 
        Get-NetAdapter -Name * -IncludeHidden | Export-Excel -Path ".\asgn1.xlsx" -WorksheetName "Network Information" -Append
        Write-Output "Network Information has been collected and exported to asgn1.xlsx"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect network information. Error: $_"
    }


    try {
       #Print the active network connections info
        Get-NetTCPConnection | Export-Excel -Path ".\asgn1.xlsx" -WorksheetName "TCPInformation" -Append
        Write-Output "TCP Information has been collected and exported to asgn1.xlsx"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect active network connection information. Error: $_"
    }


    try {
        Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" | Export-Csv -Path ".\HKLM_Run.csv" -NoTypeInformation
        Write-Output "HKLM information has been collected and exported to HKLM_Run.csv"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect Run keys from HKLM. Error: $_"
    }


    try {
        Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" | Export-Csv -Path ".\HKLM_RunOnce.csv" -NoTypeInformation
        Write-Output "HKLM RunOnce information has been collected and exported to HKLM_RunOnce.csv"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect RunOnce keys from HKLM. Error: $_"
    }


    try {
        Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Export-Csv -Path ".\HKCU_Run.csv" -NoTypeInformation
        Write-Output "HKCU Run information has been collected and exported to HKCU_Run.csv"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect Run keys from HKCU. Error: $_"
    }


    try {
        Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" | Export-Csv -Path ".\HKCU_RunOnce.csv" -NoTypeInformation
        Write-Output "HKCU RunOnce information has been collected and exported to HKCU_RunOnce.csv"
    }
    catch {
       #Print any error that occured from command above.
        Write-Error "Unable to collect RunOnce keys from HKCU. Error: $_"
    }
     
 
$comments =@"

 ---Comments for The Professor---
 The asgn1.xlsx contains the System, Process, and Network information seperated in different sheets.
 I created multiple csv files holding the Run/RunOnce key information to meet the rubric criteria.
---Comments for The Professor---
"@

Write-Output $comments