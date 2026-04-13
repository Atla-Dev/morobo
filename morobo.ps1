#===============================================================#
# Script: Robocopy Multiple Sources                             #
# Written: Atla-Dev                                             #
# Description: This script copies multiple files via robocopy   #
#===============================================================#

# Put the folders you want to copy here, if device is on the network use \\assetnumber\path\to\destinationfolder\
$sources = "C:\folder1","C:\folder2","C:\folder3"
$destination = "C:\destinationfolder"



# Change the switches to suit your preference /S copies all directories but ignores empty ones /R:5 retries 5 times /W:5 waits 5 seconds between retries /Z restartable after a network issue
foreach( $src in $sources ) {
    robocopy $src $destination /S /R:5 /W:5 /Z /LOG:"$destination/morobolog.txt" /TEE
}