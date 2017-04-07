##############################################################################
#
# backs up attendant to a folder, defaulting to the log folder
# Setup as scheduled task listening to event 21000 on Interaction Center app
#
##############################################################################
# Settings
##############################################################################
$Overridefolder = "D:\Backup\Attendant\" 
$user = "*AttendantBackupUser"
$password = "XXXXX"
##############################################################################
# Do Not Edit below this line
##############################################################################
if($Overridefolder.Length -eq 0) { $folder = $env:ININ_TRACE_ROOT + '\AttendantBackup'}
else{$folder = $Overridefolder}

if(-Not (Test-Path $folder)) {New-Item $folder -ItemType directory}

$file = $folder + 'Attendant Backup ' + (get-date -f yyyyMMddhhmmss) + '.att'
$argv = @('/oe',"/u=$user", "/p=$password",'/fullexport='+$file+'')

InteractionAttendantU.exe $argv | out-null