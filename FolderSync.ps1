<#
    .SYNOPSIS
        The FolderSync.ps1 provides a one-way synchronization of two folders.

    .DESCRIPTION
        The script will ensure that a destination folder carries the exact replica of the source folder
        When the destination folder matches the source folder, the script will compare file modification times,
        this allows for the content to match, even when say, for example, the contents of a file is altered.
        The script also outputs all creation/deletion/alteration methods and outputs them to console as well as a log file.

    .EXAMPLE
        to run the script, simply run:
        .\FolderSync.ps1 -sourceFileLocation [Directory] -replicaFileLocation [Directory] -LogOutputLocation [Directory]/logname.txt

    #>

param(
    [Parameter(Mandatory)][string]$sourceFileLocation,
    [Parameter(Mandatory)][string]$replicaFileLocation,
    [Parameter(Mandatory)][string]$LogOutputLocation
)

# LogAndWrite-Message allows for output to be both output to the console, as well as written to
# the desired log file
Function LogAndWrite-Message([String]$Message)
{
    Add-Content -Path $LogOutputLocation $Message
    Write-Host $Message
}

if (Test-Path $LogOutputLocation) { Clear-Content $LogOutputLocation }

#creating placeholder files because Compare-Object gets very unhappy when you try use it on empty directories
New-Item -Path $sourceFileLocation -Name 'initial.initial' | Out-Null
New-Item -Path $replicaFileLocation -Name 'initial.initial' | Out-Null

$SFFiles = Get-ChildItem -Path $sourceFileLocation -Recurse
$RFFiles = Get-ChildItem -Path $replicaFileLocation -Recurse

$filedifferences = Compare-Object -ReferenceObject $SFFiles -DifferenceObject $RFFiles
 
foreach($d in $filedifferences)
{
    if ($d.SideIndicator -eq "<=")
    {
        Copy-Item -Path ($d.InputObject.FullName) -Destination ($d.InputObject.FullName.Replace($sourceFileLocation, $replicaFileLocation)) -Force
        if ($d.InputObject.GetType() -eq [System.IO.DirectoryInfo])
        {
            LogAndWrite-Message ("Creating Directory " + $d.InputObject.Name + " at " + $d.InputObject.FullName)
        }
        else
        {
            LogAndWrite-Message ("Copying " + $d.InputObject.Name + " to " + $d.InputObject.FullName)
        }
    }
    if ($d.SideIndicator -eq "=>")
    {
        Remove-Item -Path $d.InputObject.FullName -Force -Recurse
        if ($d.InputObject.GetType() -eq [System.IO.DirectoryInfo])
        {
            LogAndWrite-Message ("Removing Directory " + $d.InputObject.Name + " at " + $d.InputObject.FullName) 
        }
        else
        {
            LogAndWrite-Message ("Removing " + $d.InputObject.Name + " from " + $d.InputObject.FullName)
        }
    }
}

#Reinitialisation of the file structures is necessary after initial filename-based syncronisation
$SFFiles = Get-ChildItem -Path $sourceFileLocation -Recurse -File
$RFFiles = Get-ChildItem -Path $replicaFileLocation -Recurse -File

$cdifferences = Compare-Object -ReferenceObject $SFFiles -DifferenceObject $RFFiles -Property LastWriteTime, Name -PassThru

foreach ($c in $cdifferences)
{
    if (($c.SideIndicator -eq '<=') -and ($c.Name -ne 'initial.initial'))
    {
        LogAndWrite-Message ("Found difference in " + ($c.Directory.ToString() + "\"+ $c.Name)+ " | Resynchronizing file contents")
        Copy-Item -Path ($c.Directory.ToString() + "\"+ $c.Name) -Destination ($replicaFileLocation) -Force
    }
}

#removing the placeholder files
remove-item -Path "$sourceFileLocation/initial.initial"
remove-item -Path "$replicaFileLocation/initial.initial"
