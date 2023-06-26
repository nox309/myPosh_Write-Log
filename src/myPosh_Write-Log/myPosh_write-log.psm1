<# 
.NAME
    <Write-Log>
.SYNOPSIS
    <Providing a log function in Powershell>
.DESCRIPTION
    <Provides a log function which stores a log under $env:SystemDrive\tmp\myPosh_Log, this function can be called by other scripts.
    Status levels can be 'information', 'warning', 'error' and 'debug'.
    If the parameter "-console $true" is passed, the corresponding message is also printed on the console and colored according to the status level. This module works both standalone and as part of the myPosh project>
.OUTPUTS
    <Output to e.g. the following file C:\tmp\myPosh_Log\20230209_logfile.txt or on the console "20230209-21:34:42 | Error | Test message".>
.FUNCTIONALITY
    <Captures information in a script and stores it with a timestamp in a log file. Additionally, the -console $true parameter can be used to display the output on the console. The contents of variables can also be passed. >
.EXAMPLE
    Write-Log -Message "Test Message" -Severity Error -console $true
.NOTES
    Author: S
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

    "$Time | $Severity | $env:username | $Message" | Out-File -FilePath $log -Append -Encoding utf8

}