<# 
.NAME
    Write-Log
.SYNOPSIS
    Provides a logging function in PowerShell.
.DESCRIPTION
    This module provides a flexible logging function that stores log messages in a file located at `$env:SystemDrive\tmp\myPosh_Log`.
    It supports severity levels such as `Information`, `Warning`, `Error`, and `Debug`. Optionally, messages can also be displayed on the console
    with color-coded severity levels. The module includes error handling for directory and file creation and allows specifying a custom log path
    using the `-CustomLogPath` parameter.
.OUTPUTS
    Outputs log messages to a file (e.g., `C:\tmp\myPosh_Log\20230209_logfile.txt`) or to the console (e.g., `20230209-21:34:42 | Error | Test message`).
.EXAMPLE
    # Log an error message and display it on the console
    Write-Log -Message "Test message" -Severity Error -console $true

    # Log an informational message to a custom log path
    Write-Log -Message "Test message" -Severity Information -CustomLogPath "D:\Logs"
.NOTES
    Author: Torben Inselmann
    Email: support@inselmann.it
    Git: https://github.com/nox309
    DateCreated: 2022/12/23
#>

# Define the current date and log file name
$date = (get-date -Format yyyyMMdd)
$filename = $date + "_logfile.txt"
$logpath = "$env:SystemDrive\tmp\myPosh_Log\"
$log = $logpath + $filename

# Ensure the log directory and file exist, with error handling
try {
    if (!(Test-Path $logpath)) {
        mkdir $logpath -ErrorAction Stop
    }
    if (!(Test-Path $log)) {
        "Timestamp | Severity | Username | Message" | Out-File -FilePath $log -Append -Encoding utf8
        "$(get-date -Format yyyyMMdd-HH:mm:ss) | Information | $env:username | Log started" | Out-File -FilePath $log -Append -Encoding utf8
    }
} catch {
    Write-Error "Error creating the log directory or file: $_"
    return
}

function Write-Log {
    [CmdletBinding()]
    param(
        # The log message to be written
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        # Whether to display the message on the console
        [Parameter(Mandatory=$false)]
        [bool]$console = $false,

        # The severity level of the log message
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error','Debug')]
        [string]$Severity = 'Information',

        # Optional custom log path
        [Parameter(Mandatory=$false)]
        [string]$CustomLogPath
    )

    # Override the log path if a custom path is provided
    if ($CustomLogPath) {
        $log = Join-Path -Path $CustomLogPath -ChildPath $filename
    }

    # Get the current timestamp
    $time = (get-date -Format yyyyMMdd-HH:mm:ss)

    # Define colors for each severity level
    $severityColors = @{
        "Information" = "Gray"
        "Warning"     = "Yellow"
        "Error"       = "Red"
        "Debug"       = "Green"
    }

    # Display the message on the console if the -console parameter is true
    if ($console) {
        $color = $severityColors[$Severity]
        Write-Host -ForegroundColor $color "$Time | $Severity | $Message"
    }

    # Write the log message to the log file
    "$Time | $Severity | $env:username | $Message" | Out-File -FilePath $log -Append -Encoding utf8
}
