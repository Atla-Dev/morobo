#################################################################
# Name: MoRobo                                                  #
# Description: This script copies multiple files via robocopy   #
# Author: Atla-Dev                                              #
# Version: 1.4                                                  #
# Creation Date: 13/04/2026                                     #
#################################################################

param(
    [switch]$Mass,
    [switch]$Solo,
    [switch]$DryRun
)


# $appPassword can be set @ https://myaccount.google.com/apppasswords

# --- Config --- #
$destination = "E:\logs"
$logPath = "E:\logs" # Ensure this folder exists before running

# --- Email Config --- #

$username = "email account here"
$appPassword = "app-pass-goes-here"
$secPassword = ConvertTo-SecureString $appPassword -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential($username, $secPassword)

$emailBody = @"
The MoRobo script has completed.
The log file can be found at: $logPath
Timestamp: $(Get-Date)
"@

$sendMailMessageSplat =@{
    From = "Sender email"
    To = "Recipient email"
    Subject = "MoRobo Copy Complete"
    Body = $emailBody
    smtpServer = "smtp.gmail.com"
    Port = 587
    UseSSL = $true
    Credential = $creds
}


if($DryRun){
    $myArgs += "/L"
    Write-Host "DRY RUN: No files copied, deleted or changed" -ForegroundColor Yellow
}
if($Mass) {
    Write-Host "Running in mass destination mode..." -ForegroundColor Cyan
    Write-Host "If you change your mind press Ctrl+C now..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10

    Write-Host "Calculating size of source files... " -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    # Calculate total size of source files (in bytes)
    $totalSize = 0
    foreach ($src in $sources) {
        if (Test-Path $src) {
            $totalSize += (Get-ChildItem -Path $src -Recurse -File | Measure-Object -Property Length -Sum).Sum
        }
    }
    Write-Host "Getting destination drive letter... " -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    # Get destination drive letter
    $destDrive = ($destination -replace '^([A-Za-z]):.*','$1') + ':'
    $freeSpace = (Get-PSDrive $destDrive).Free

    if ($freeSpace -lt $totalSize) {
        Write-Host "WARNING: Not enough disk space on $destDrive. Required: $($totalSize/1GB) GB, Available: $($freeSpace/1GB) GB" -ForegroundColor Red
        # Optionally: exit the script
         exit 1
    } else {
        Write-Host "Sufficient disk space detected." -ForegroundColor Green
    }

    # Define your specific Mappings here (Source = Destination)
    $copyJobs = @{
        "\\NAS\path\to\source\folder1" = "E:\path\to\destination\folder1"
        "\\NAS\path\to\source\folder2" = "E:\path\to\destination\folder2"
        "\\NAS\path\to\source\folder3" = "E:\path\to\destination\folder3"
        "\\NAS\path\to\source\folder4" = "E:\path\to\destination\folder4"
        "\\NAS\path\to\source\folder5" = "E:\path\to\destination\folder5"
    }
        foreach ($src in $copyJobs.Keys) {
        $dest = $copyJobs[$src]
        $myArgs = @($src, $dest, "/S", "/R:5", "/W:5", "/Z", "/TEE", "/LOG+:$dest\morobolog.txt")
        robocopy @myArgs
    }
    Send-MailMessage @sendMailMessageSplat
}
elseif ($Solo) {
    Write-Host "Running Standard Copy Mode..." -ForegroundColor Yellow
    Write-Host "If you change your mind press Ctrl+C now..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10

    # Put the folders you want to copy here, if device is on the network use \\hostname\path\to\destinationfolder\
    $sources = "C:\folder1","C:\folder2","C:\folder3"
    
    Write-Host "Calculating size of source files... " -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    # Calculate total size of source files (in bytes)
    $totalSize = 0
    foreach ($src in $sources) {
        if (Test-Path $src) {
            $totalSize += (Get-ChildItem -Path $src -Recurse -File | Measure-Object -Property Length -Sum).Sum
        }
    }
    Write-Host "Getting destination drive letter... " -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    # Get destination drive letter
    $destDrive = ($destination -replace '^([A-Za-z]):.*','$1') + ':'
    $freeSpace = (Get-PSDrive $destDrive).Free

    if ($freeSpace -lt $totalSize) {
        Write-Host "WARNING: Not enough disk space on $destDrive. Required: $($totalSize/1GB) GB, Available: $($freeSpace/1GB) GB" -ForegroundColor Red
        # Optionally: exit the script
        # exit 1
    } else {
        Write-Host "Sufficient disk space detected." -ForegroundColor Green
    }

    # Change the switches to suit your preference /S copies all directories but ignores empty ones /R:5 retries 5 times /W:5 waits 5 seconds between retries /Z restartable after a network issue
    foreach( $src in $sources ) {
    $myArgs = @($src, $destination, "/S", "/R:5", "/W:5", "/Z", "/TEE", "/LOG+:$logPath\morobolog.txt")
    robocopy @myArgs
    }
    Send-MailMessage @sendMailMessageSplat
}
else {
    Write-Host "No switch detected. Use -Mass or -Solo." -ForegroundColor Red
}
