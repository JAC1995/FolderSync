# FolderSync

The Test Brief is also contained within the repository.


**Powershell comment header**


    .SYNOPSIS
        The FolderSync.ps1 provides a one-way synchronization of two folders.

    .DESCRIPTION
        The script will ensure that a destination folder carries the exact replica of the source folder
        When the destination folder matches the source folder, the script will compare file modification times,
        this allows for the content to match, even when say, for example, the contents of a file is altered.
        The script also outputs all creation/deletion/alteration methods and outputs them to console as well as a log file.

    .EXAMPLE
        to run the script, simply run:
        .\FolderSync.ps1 -sourceFileLocation [Directory] -replicaFileLocation [Directory] -OutputLocation [Directory]/logname.txt
