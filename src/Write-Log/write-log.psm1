<# 
.NAME
    <Write-Log>
.SYNOPSIS
    <Providing a log function in Powershell>
.DESCRIPTION
    <Provides a log function which stores a log under $env:SystemDrive\tmp\myPosh_Log, this function can be called from other scripts.
    as status level 'Information', 'Warning', 'Error' and 'Debug' can be used.
    If the parameter "-console $true" is passed the corresponding message will also be printed on the console and colored according to the status level.>
.OUTPUTS
    <Output to e.g. the following file C:\tmp\myPosh_Log\20230209_logfile.txt or on the console "20230209-21:34:42 | Error | Test message".>
.FUNCTIONALITY
    <Takes information in a script and stores it with time stemple in a log file in addition, the -console $true parameter can also be used to display output in the console >
.EXAMPLE
    Write-Log -Message "Test Nachricht" -Severity Error -console $true
.NOTES
    Author: nox309
    Email: support@inselmann.it
    Git: https://github.com/nox309
    DateCreated: 2022/12/23
    #>
$date = (get-date -Format yyyyMMdd)
$filename = $date + "_logfile.txt"
$logpath = "$env:SystemDrive\tmp\myPosh_Log\"
$log = $logpath + $filename

if(!(Test-Path  $logpath)) 
{
    mkdir $logpath
}
if(!(Test-Path  $log))
{
    "Timestamp | Severity | Message" | Out-File -FilePath $log -Append -Encoding utf8
    "$(get-date -Format yyyyMMdd-HH:mm:ss) | Information | Log started" | Out-File -FilePath $log -Append -Encoding utf8
}


function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [parameter(Mandatory=$false)]
        [bool]$console, 

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error','Debug')]
        [string]$Severity = 'Information'
    )

    $time = (get-date -Format yyyyMMdd-HH:mm:ss)

    if ($console) {
        if ($Severity -eq "Information") {
            $color = "Gray"
        }

        if ($Severity -eq "Warning") {
            $color = "Yellow"
        }

        if ($Severity -eq "Error") {
            $color = "Red"
        }

        if ($Severity -eq "Debug") {
            $color = "Green"
        }

        Write-Host -ForegroundColor $color "$Time | $Severity | $Message"
    }

    "$Time | $Severity | $Message" | Out-File -FilePath $log -Append -Encoding utf8

}