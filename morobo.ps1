#===============================================================#
# Script: Morobo                             #
# Written: Atla-Dev                                             #
# Description: This script copies multiple files via robocopy   #
#===============================================================#

param(
    [switch]$Mass
)


# --- Config --- #
$destination = "\\path\to\destination\folder\"

if($Mass) {
    Write-Host "Running in mass destination mode..." -ForegroundColor Cyan

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
        $logPath="E:\logs"
        robocopy $src $dest /S /R:5 /W:5 /Z /TEE /LOG+:"$logPath\morobolog.txt"
    }
}
else {
    Write-Host "Running Standard Copy Mode..." -ForegroundColor Yellow

    # Put the folders you want to copy here, if device is on the network use \\assetnumber\path\to\destinationfolder\
    $sources = "C:\folder1","C:\folder2","C:\folder3"

    # Change the switches to suit your preference /S copies all directories but ignores empty ones /R:5 retries 5 times /W:5 waits 5 seconds between retries /Z restartable after a network issue
    foreach( $src in $sources ) {
    robocopy $src $destination /S /R:5 /W:5 /Z /LOG+:"$logPath/morobolog.txt" /TEE
    }
}