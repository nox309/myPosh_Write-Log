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
    Author: Torben Inselmann
    Email: support@inselmann.it
    Git: https://github.com/nox309
    DateCreated: 2022/12/23
#>
$date = (get-date -Format yyyyMMdd)
$filename = $date + "_logfile.txt"
$logpath = "$env:SystemDrive\tmp\myPosh_Log\"
$log = $logpath + $filename

# Fehlerbehandlung für Verzeichnis- und Dateierstellung
try {
    if (!(Test-Path $logpath)) {
        mkdir $logpath -ErrorAction Stop
    }
    if (!(Test-Path $log)) {
        "Timestamp | Severity | Username | Message" | Out-File -FilePath $log -Append -Encoding utf8
        "$(get-date -Format yyyyMMdd-HH:mm:ss) | Information | $env:username | Log started" | Out-File -FilePath $log -Append -Encoding utf8
    }
} catch {
    Write-Error "Fehler beim Erstellen des Log-Verzeichnisses oder der Datei: $_"
    return
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [bool]$console = $false,  # Standardwert hinzugefügt

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error','Debug')]
        [string]$Severity = 'Information',

        [Parameter(Mandatory=$false)]
        [string]$CustomLogPath  # Optionaler Parameter für benutzerdefinierten Log-Pfad
    )

    # Log-Pfad überschreiben, falls angegeben
    if ($CustomLogPath) {
        $log = Join-Path -Path $CustomLogPath -ChildPath $filename
    }

    $time = (get-date -Format yyyyMMdd-HH:mm:ss)

    # Farben in einer Hashtable definieren
    $severityColors = @{
        "Information" = "Gray"
        "Warning"     = "Yellow"
        "Error"       = "Red"
        "Debug"       = "Green"
    }

    if ($console) {
        $color = $severityColors[$Severity]
        Write-Host -ForegroundColor $color "$Time | $Severity | $Message"
    }

    "$Time | $Severity | $env:username | $Message" | Out-File -FilePath $log -Append -Encoding utf8
}
