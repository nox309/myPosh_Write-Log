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

$script:DefaultLogPath = Join-Path -Path $env:SystemDrive -ChildPath 'tmp\myPosh_Log'

function Initialize-LogTarget {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath,

        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        if (-not (Test-Path -Path $DirectoryPath)) {
            New-Item -Path $DirectoryPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }

        if (-not (Test-Path -Path $FilePath)) {
            'Timestamp | Severity | Username | Message' | Out-File -FilePath $FilePath -Append -Encoding utf8 -ErrorAction Stop
            "$(Get-Date -Format yyyyMMdd-HH:mm:ss) | Information | $env:username | Log started" | Out-File -FilePath $FilePath -Append -Encoding utf8 -ErrorAction Stop
        }
    } catch {
        throw "Error creating the log directory or file: $_"
    }
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
        [string]$Severity,

        # Optional custom log path
        [Parameter(Mandatory=$false)]
        [string]$CustomLogPath
    )

    # Get the current timestamp
    $time = Get-Date -Format yyyyMMdd-HH:mm:ss
    $date = Get-Date -Format yyyyMMdd
    $filename = "${date}_logfile.txt"

    $logPath = $script:DefaultLogPath
    if ($CustomLogPath) {
        $logPath = $CustomLogPath
    }

    $log = Join-Path -Path $logPath -ChildPath $filename

    try {
        Initialize-LogTarget -DirectoryPath $logPath -FilePath $log
    } catch {
        Write-Error $_
        return
    }

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
    try {
        "$Time | $Severity | $env:username | $Message" | Out-File -FilePath $log -Append -Encoding utf8 -ErrorAction Stop
    } catch {
        Write-Error "Error writing to log file '$log': $_"
    }
}
