###########################################################################################################
#
# Logmover moves the PureConnect logs to a NAS from the app server.  
# Add as scheduled task after log compression for prior day is complete.
# Compression is done via RemocoServer subsystem, and no event trigger is written.  
# Topic = Remoco Log Processing in logs to estimate end time.
# Add 2 hours after last entry at minimum for starting time of this job.
#
###########################################################################################################
# logSource is where the log files live that need to be moved
# tempDrive is the destination folder where we will create the files
# When moveFiles = "Y" move the contents and not just copy them
###########################################################################################################
$logSource = "D:\I3\IC\Logs\"
$tempDrive = '\\NAS\' + $env:COMPUTERNAME + '\PureConnect logs\'
$MoveFiles = "Y"
###########################################################################################################
#
# DO NOT EDIT BELOW THIS LINE
#
###########################################################################################################
Start-Transcript -Path "c:\temp\log.txt"
$logDestination = '"' + $tempDrive + (get-Date (Get-Date).AddDays(-1) -Format {yyyy-MM-dd}) + '"'
$logFile = $logSource + 'ArchiveLog.txt'
$logSource = $logSource + (get-Date (Get-Date).AddDays(-1) -Format {yyyy-MM-dd})


If ($MoveFiles = "Y") {
	$cmdArgs = @("/S", "/NP", "/MOVE", "/R:5", "/W:5", "/LOG+:$logFile")
}
Else {
	$cmdArgs = @("/S", "/NP", "/R:5", "/W:5", "/LOG+:$logFile")
}


write-output  robocopy $logSource $logDestination $cmdArgs

New-EventLog -Source "PureConnect LogMover" -LogName "Application"
Start-Sleep -s 10 #make sure the source registered properly

robocopy $logSource $logDestination $cmdArgs

[int]$Retval = [convert]::ToInt32($LASTEXITCODE,10)

write-output "Process returned $Retval"

if ($Retval -ge 8) {
	Write-EventLog -LogName "Application" -Source "PureConnect LogMover" -EventID 1500 -EntryType Error -Message "Log move failed.`n`nSource: $logSource`nDestination: $logDestination`nMove-only: $MoveFiles`n`nCheck log file at $logFile for more details" -Category 1
}
else {
	Write-EventLog -LogName "Application" -Source "PureConnect LogMover" -EventID 2000 -EntryType Information -Message "Log move Complete.`n`nSource: $logSource`nDestination: $logDestination`nMove-only: $MoveFiles" -Category 1

}

Stop-Transcript