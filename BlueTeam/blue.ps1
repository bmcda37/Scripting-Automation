#Define the error log
$ErrorLog = ".\error.log"
$ActionLog= ".\action.log"
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

#Check if the script is being ran as an administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script is not being ran as an administrator. Please exit PowerShell and re-run script as an administrator..."
    exit
}


#Known bad services based on common misspellings or malicious names
$BadProcess = "expl0rer", "xrat", "badguy", "mimi", "mssecsvc2.0", "Isass"
#New Administrator Account Name changed from default
$newAdmin = "HeavyHitter"
#New Guest Account Name changed from default
$newGuest = "Mystic"
#Check for Vulnerabilities: Insecure services/protocols being usedfunction Get-Insecure {

function Get-Insecure {

    $insec = Get-Service | Where-Object {
        $_.Status -eq 'Running' -and 
        ($_.Name -like 'Telnet*' -or 
         $_.Name -like 'RemoteRegistry*' -or 
         $_.Name -like 'FTPSVC*' -or 
         $_.Name -like 'SMB1*')
    }

    if ($insec) {
        Write-Output "$currentDateTime : Insecure services found:" | Out-File -FilePath $ActionLog -Append
        $insec | ForEach-Object { Write-Output "$currentDateTime : $_" | Out-File -FilePath $ActionLog -Append }
    } else {
        Write-Output "$currentDateTime : No insecure services found." | Out-File -FilePath $ActionLog -Append
    }
    
}

#Check for Vulnerabilities: Unnecessary processes with known badnames or common mispellings
function Get-Proc {

    # Get the list of running processes
    $RunningProcess = Get-Process | Select-Object -ExpandProperty ProcessName
    
    # Check if any of the bad processes are running
    foreach ($BadProcess in $BadProcess) {
        if ($RunningProcess -contains $BadProcess) {
            Write-Host "$curentDateTime :WARNING: Suspicious process found - $BadServices"  Out-File -FilePath $ActionLog -Append
            Remove-BadProcess -ProcessName $BadProcess
        }
        else {
            Write-Output "$currentDateTime :No suspicious process '$BadProcess' found" | Out-File -FilePath $ActionLog -Append
        }
    }
}

#Check for Vulnerabilities: Unnecessary services & Remove them
function Remove-BadProcess{
    #Pass in my bad process name from Get-Process method
    param (
        [string]$ProcessName
    )
    try {
        Stop-Process -Name "$ProcessName" -Force
        Write-Output " $currentDateTime :Process '$ProcessName' has been removed" |  Out-File -FilePath $ActionLog -Append
    }
    catch {
        $ErrorMsg = " $currentDateTime :Error stopping process '$ProcessName': $($_.Exception.Message)"
        Write-Output $ErrorMsg | Out-File -FilePath $ErrorLog -Append
    }
}

#Configure Windows Defender: Basic Hardening CIS Level 1 Workstation 
$defendConfig = @{
    "DisableRealtimeMonitoring" = $False
    "EnableCloudProtection" = $True
    "SubmitSampleConsent" = 1
    "EnableControlledFolderAccess" = 0
    "DisableTamperProtection" =  $False
    "SignatureScheduleTime" = "02:00:00"
}

function Get-Defender {
    #$currentProf = Get-MpPreference
    foreach ($key in $defendConfig.Keys) {
        $currentValue = (Get-MpPreference).$key

        if ($currentValue -ne $defendConfig[$key]) {
            switch ($key) {
                "DisableRealtimeMonitoring" { 
                    #Set-MpPreference -DisableRealtimeMonitoring $False
                    Write-Output "$currentDateTime : Windows Defender setting $key has been set to $($defendConfig[$key]). CIS Level 1 Workstation: 3.1" | Out-File -FilePath $ActionLog -Append
                }
                "EnableCloudProtection" { 
                    #Set-MpPreference -EnableCloudProtection $True
                    Write-Output "$currentDateTime : Windows Defender setting $key has been set to $($defendConfig[$key]). CIS Level 1 Workstation: 3.1" | Out-File -FilePath $ActionLog -Append
                }
                "SubmitSampleConsent" { 
                    #Set-MpPreference -SubmitSampleConsent 1
                    Write-Output "$currentDateTime : Windows Defender setting $key has been set to $($defendConfig[$key]). CIS Level 1 Workstation: 3.1" | Out-File -FilePath $ActionLog -Append
                }
                "EnableControlledFolderAccess" { 
                    #Set-MpPreference -EnableControlledFolderAccess 0
                    Write-Output "$currentDateTime : Windows Defender setting $key has been set to $($defendConfig[$key]). CIS Level 1 Workstation: 3.2" | Out-File -FilePath $ActionLog -Append
                }
                "DisableTamperProtection" { 
                    #Set-MpPreference -DisableTamperProtection $False
                    Write-Output "$currentDateTime : Windows Defender setting $key has been set to $($defendConfig[$key]). CIS Level 1 Workstation: 3.1" | Out-File -FilePath $ActionLog -Append
                }
                "SignatureScheduleTime" { 
                    #Check the SignatureScheduleTime and set it to 02:00:00 if it is not already set
                    Set-MpPreference -SignatureScheduleTime "02:00:00"
                    Write-Output "$currentDateTime : Windows Defender setting $key has been set to $($defendConfig[$key]). CIS Level 1 Workstation: 3.3" | Out-File -FilePath $ActionLog -Append
                }
            }
        }
        else {
            Write-Output "$currentDateTime : Windows Defender setting $key is already the correct value. $($defendConfig[$key])" | Out-File -FilePath $ActionLog -Append
        }
    }
}

function Get-AccName {
    # Get local user accounts and log current date and time
    $AcctNames = Get-LocalUser | Select-Object Name 

    foreach ($AcctName in $AcctNames) {
        if ($AcctName.Name -eq "Administrator") {
            Write-Output "$currentDateTime : Administrator account is listed. Renaming & Disabling..." | Out-File -FilePath $ActionLog -Append
            try {
                Rename-LocalUser -Name "Administrator" -NewName "$newAdmin"
                Write-Output "$currentDateTime : Administrator account has been successfully renamed. CIS Level 1 Workstation: 4.2" | Out-File -FilePath $ActionLog -Append

                # Check if the previous command was successful
                if ($?) {
                    Disable-LocalUser -Name "$newAdmin"
                    Write-Output "$currentDateTime : Administrator account has been successfully disabled. CIS Level 1 Workstation: 4.2" | Out-File -FilePath $ActionLog -Append
                } else {
                    Write-Output "$currentDateTime : Failed to rename Administrator account. CIS Level 1 Workstation: 4.2" | Out-File -FilePath $ActionLog -Append
                }
            }
            catch {
                $ErrorMsg = "$currentDateTime : Error disabling Administrator account: $($_.Exception.Message)"
                Write-Output $ErrorMsg | Out-File -FilePath $ErrorLog -Append
            }
        }

        if ($AcctName.Name -eq "Guest") {
            # Call the Disable-Guest function and pass the current account
            Disable-Guest -guest $AcctName
        }
        else {
            Write-Output "$currentDateTime : Default Guest and Adminstrator account is not found. CIS Level 1 Workstation: 4.2" | Out-File -FilePath $ActionLog -Append
        }
    }
}

# Disable the Guest account: Basic Hardening CIS Level 1 Workstation
function Disable-Guest {
    param (
        [PSObject]$guest  # Pass the entire account object
    )
        try {
            #Rename the Guest account
            Rename-LocalUser -Name "Guest" -NewName "$newGuest"
            Write-Output "$currentDateTime : Guest account has been successfully renamed. CIS Level 1 Workstation: 4.2" | Out-File -FilePath $ActionLog -Append
            if ($?) {
                #If Rename was successful, disable the account
                Disable-LocalUser -Name "$newGuest"
                Write-Output "$currentDateTime : Guest Account has been successfully disabled. CIS Level 1 Workstation: 4.2" | Out-File -FilePath $ActionLog -Append
            } else {
                Write-Output "$currentDateTime : Failed to rename Guest account." | Out-File -FilePath $ActionLog -Append
            }
        }
        catch {
            $ErrorMsg = "$currentDateTime : Error disabling guest account: $($_.Exception.Message)"
            Write-Output $ErrorMsg | Out-File -FilePath $ErrorLog -Append
        }
}


$uacSettings = @{
    "ConsentPromptBehaviorAdmin" = 5
    "ConsentPromptBehaviorUser" = 3
    "EnableInstallerDetection" = 1
    "EnableLUA" = 1
    "EnableVirtualization" = 1
    "PromptOnSecureDesktop" = 1
    "ValidateAdminCodeSignatures" = 0
    "FilterAdministratorToken" = 0
}

#UAC: Basic Hardening CIS Level 1 Workstation
function Set-UAC {
    # Registry path for UAC settings
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    #For each key in my UAC HashTable
    foreach ($key in $uacSettings.Keys) {
        $currentValue = Get-ItemProperty -Path $uacPath -Name $key -ErrorAction SilentlyContinue
        #If the current value is not equal to the value in my UAC HashTable, set the value to the value in my UAC HashTable
        if ($currentValue.$key -ne $uacSettings[$key]) {
            Set-ItemProperty -Path $uacPath -Name $key -Value $uacSettings[$key]
            Write-Output "$currentDateTime : UAC setting $key has been set to $($uacSettings[$key]). CIS Level 1 Workstation: 16.6" | Out-File -FilePath $ActionLog -Append  }
        #If the current value is equal to the value in my UAC HashTable, do nothing
        else {
            Write-Output "$currentDateTime : No UAC settings needed to be changed for $key. CIS Level 1 Workstation: 16.6" | Out-File -FilePath $ActionLog -Append
            }
        }
}

#Basic Hardening CIS Level 1 Workstation
function Set-PassPolicy {

    # Create a temporary file for my security settings
    try {
        Start-Process cmd -ArgumentList "/c net accounts /maxpwage:90 /minpwlen:12 /minpwage:5 /uniquepw:10" -NoNewWindow -Wait
    }
    catch {
        Write-Output "$currentDateTime : Failed to set password age/length policy settings. Error: $_" | Out-File -FilePath $ActionLog -Append
    }
    
    try {
        Start-Process cmd -ArgumentList "/c net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30" -NoNewWindow -Wait
        Write-Output "$currentDateTime : Password policy has been set as /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30" | Out-File -FilePath $ActionLog -Append
    }
    catch {
        Write-Output "$currentDateTime : Failed to import policy lockout settings. Error: $_" | Out-File -FilePath $ActionLog -Append
    }

    Write-Output "$currentDateTime : Policies have applied and set. CIS Level 1 Workstation: 5.2, 5.3, 5.1, 5.4, 5.5, 5.6, 5.7, 5.8 , 4.4, 4.3, 4.2, 4.1, 3.7" | Out-File -FilePath $ActionLog -Append

}


#Basic Hardening CIS Level 1 Workstation
function Enable-Firewall {
try {
        Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True
        Set-NetFirewallProfile -Profile Domain,Private,Public -DefaultInboundAction Block
        Set-NetFirewallProfile -Profile Domain,Private,Public -LogAllowed True -LogMaxSizeKilobytes 4096
        Write-Output "$currentDateTime : Firewall has been enabled and configured. CIS Level 1 Workstation: 9.1, 9.2, 9.3, 9.4" | Out-File -FilePath $ActionLog -Append
}
catch {
    Write-Output "$currentDateTime :Error configuring firewall: $($_.Exception.Message)" | Out-File -FilePath $ErrorLog -Append
}
}


#Basic Hardening CIS Level 1 Workstation
function Enable-AutoUpdate {
    try {
        Set-Service -Name wuauserv -StartupType Automatic
        Start-Service -Name wuauserv
        Write-Output "$currentDateTime : Windows Update service has been set to automatic and started. CIS Level 1 Workstation: 7.1" | Out-File -FilePath $ActionLog -Append
    }
    catch {
        $ErrorMsg = "$currentDateTime :Error enabling Windows Update service: $($_.Exception.Message)"
        Write-Output $ErrorMsg | Out-File -FilePath $ErrorLog -Append
    }
}

#Call the functions

#VulnerabiltityCheck: Unnecessary services, Weak Password Policy, Defender turned off, Disabled Auto Updates
#Basic Hardening Mapped to CIS Level 1 Workstation: Defender, UAC, Firewall, Auto Updates, Guest Account, Password Policy

Get-Insecure
Get-Proc
Get-Defender
Get-AccName
Set-UAC
Set-PassPolicy
Enable-Firewall
Enable-AutoUpdate