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
$script:ModuleName = 'myPosh_write-log'
$script:UpdateCheckPerformed = $false

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

function Write-UpdateLogMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Information', 'Warning', 'Error', 'Debug')]
        [string]$Severity,

        [Parameter(Mandatory = $false)]
        [bool]$Console = $true,

        [Parameter(Mandatory = $false)]
        [string]$CustomLogPath
    )

    Write-Log -Message $Message -Severity $Severity -console $Console -CustomLogPath $CustomLogPath
}

function Normalize-ModulePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $normalizedPath = [System.IO.Path]::GetFullPath($Path)
    } catch {
        $normalizedPath = $Path
    }

    return $normalizedPath.TrimEnd('\').ToLowerInvariant()
}

function Get-ModuleInstallScopeFromPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $normalizedPath = Normalize-ModulePath -Path $Path
    $userDocumentsPath = [Environment]::GetFolderPath('MyDocuments')

    $currentUserRoots = @(
        (Join-Path -Path $userDocumentsPath -ChildPath 'WindowsPowerShell\Modules'),
        (Join-Path -Path $userDocumentsPath -ChildPath 'PowerShell\Modules'),
        (Join-Path -Path $HOME -ChildPath '.local\share\powershell\Modules')
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    $allUsersRoots = @(
        (Join-Path -Path $env:ProgramFiles -ChildPath 'WindowsPowerShell\Modules'),
        (Join-Path -Path $env:ProgramFiles -ChildPath 'PowerShell\Modules'),
        (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'WindowsPowerShell\Modules')
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($root in $currentUserRoots) {
        $normalizedRoot = Normalize-ModulePath -Path $root
        if ($normalizedPath -eq $normalizedRoot -or $normalizedPath.StartsWith("$normalizedRoot\")) {
            return 'CurrentUser'
        }
    }

    foreach ($root in $allUsersRoots) {
        $normalizedRoot = Normalize-ModulePath -Path $root
        if ($normalizedPath -eq $normalizedRoot -or $normalizedPath.StartsWith("$normalizedRoot\")) {
            return 'AllUsers'
        }
    }

    return $null
}

function Invoke-WithTls12 {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock
    )

    if ($PSVersionTable.PSEdition -ne 'Desktop') {
        return & $ScriptBlock
    }

    $originalSecurityProtocol = [Net.ServicePointManager]::SecurityProtocol

    try {
        [Net.ServicePointManager]::SecurityProtocol = $originalSecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        return & $ScriptBlock
    } finally {
        [Net.ServicePointManager]::SecurityProtocol = $originalSecurityProtocol
    }
}

function Get-PreferredLocalModuleInfo {
    function Get-ResolvedModuleVersion {
        param(
            [Parameter(Mandatory = $true)]
            [psmoduleinfo]$ModuleInfo
        )

        $moduleVersion = [version]$ModuleInfo.Version.ToString()

        if ($moduleVersion -ne [version]'0.0') {
            return $moduleVersion
        }

        $manifestPath = Join-Path -Path $ModuleInfo.ModuleBase -ChildPath "$($script:ModuleName).psd1"

        if (-not (Test-Path -Path $manifestPath)) {
            return $moduleVersion
        }

        try {
            $manifestData = Import-PowerShellDataFile -Path $manifestPath
            if ($manifestData.ModuleVersion) {
                return [version]$manifestData.ModuleVersion
            }
        } catch {
            return $moduleVersion
        }

        return $moduleVersion
    }

    $importedModule = Get-Module -Name $script:ModuleName | Sort-Object Version -Descending | Select-Object -First 1
    $isImported = $true

    if (-not $importedModule) {
        $importedModule = Get-Module -ListAvailable -Name $script:ModuleName | Select-Object -First 1
        $isImported = $false
    }

    if (-not $importedModule) {
        return $null
    }

    return [pscustomobject]@{
        Name         = $importedModule.Name
        Version      = Get-ResolvedModuleVersion -ModuleInfo $importedModule
        ModuleBase   = $importedModule.ModuleBase
        Path         = $importedModule.Path
        InstallScope = Get-ModuleInstallScopeFromPath -Path $importedModule.ModuleBase
        IsImported   = $isImported
    }
}

function Get-PowerShellGetInstalledModuleMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleBase
    )

    try {
        $installedModules = @(Get-InstalledModule -Name $script:ModuleName -AllVersions -ErrorAction Stop)
    } catch {
        return $null
    }

    if (-not $installedModules) {
        return $null
    }

    $normalizedModuleBase = Normalize-ModulePath -Path $ModuleBase

    return $installedModules |
        Where-Object {
            $_.PSObject.Properties.Name -contains 'InstalledLocation' -and
            (Normalize-ModulePath -Path $_.InstalledLocation) -eq $normalizedModuleBase
        } |
        Select-Object -First 1
}

function Get-PowerShellGalleryModuleInfo {
    $result = [pscustomobject]@{
        Success = $false
        Module  = $null
        Message = $null
    }

    if (-not (Get-Command -Name Find-Module -ErrorAction SilentlyContinue)) {
        $result.Message = 'PowerShellGet mit Find-Module ist in dieser Session nicht verfuegbar.'
        return $result
    }

    if (-not (Get-Command -Name Get-PSRepository -ErrorAction SilentlyContinue)) {
        $result.Message = 'Get-PSRepository ist in dieser Session nicht verfuegbar.'
        return $result
    }

    if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
        $result.Message = 'Der NuGet-PackageProvider ist nicht verfuegbar. Eine Abfrage der PSGallery ist derzeit nicht moeglich.'
        return $result
    }

    try {
        $null = Get-PSRepository -Name PSGallery -ErrorAction Stop
    } catch {
        $result.Message = 'PSGallery ist nicht registriert oder derzeit nicht erreichbar.'
        return $result
    }

    try {
        $result.Module = Invoke-WithTls12 -ScriptBlock {
            Find-Module -Name $script:ModuleName -Repository PSGallery -ErrorAction Stop
        }
        $result.Success = $true
    } catch {
        $result.Message = "Fehler bei der Abfrage der PSGallery: $($_.Exception.Message)"
    }

    return $result
}

function Get-UpdateModuleSuggestedCommand {
    param(
        [Parameter(Mandatory = $false)]
        [string]$Scope
    )

    $suggestedCommand = "Update-Module -Name $($script:ModuleName) -Force"
    $updateModuleCommand = Get-Command -Name Update-Module -ErrorAction SilentlyContinue

    if ($Scope -and $updateModuleCommand -and $updateModuleCommand.Parameters.ContainsKey('Scope')) {
        $suggestedCommand = "$suggestedCommand -Scope $Scope"
    }

    return $suggestedCommand
}

function Get-ModuleUpdateState {
    $state = [pscustomobject]@{
        Name             = $script:ModuleName
        InstalledVersion = $null
        GalleryVersion   = $null
        UpdateAvailable  = $false
        InstallType      = 'Unknown'
        InstallScope     = $null
        InstallPath      = $null
        CanAutoUpdate    = $false
        Updated          = $false
        SuggestedCommand = $null
        Status           = 'Unknown'
        Message          = $null
    }

    $localModule = Get-PreferredLocalModuleInfo

    if (-not $localModule) {
        $state.Status = 'NotInstalled'
        $state.Message = "Das Modul '$($script:ModuleName)' ist lokal nicht installiert oder nicht im PSModulePath verfuegbar."
        return $state
    }

    $state.InstalledVersion = $localModule.Version.ToString()
    $state.InstallScope = $localModule.InstallScope
    $state.InstallPath = $localModule.ModuleBase

    $installedModuleMatch = Get-PowerShellGetInstalledModuleMatch -ModuleBase $localModule.ModuleBase

    if ($installedModuleMatch) {
        $state.InstallType = 'PowerShellGet'
        if (-not $state.InstallScope -and $installedModuleMatch.PSObject.Properties.Name -contains 'InstalledLocation') {
            $state.InstallScope = Get-ModuleInstallScopeFromPath -Path $installedModuleMatch.InstalledLocation
        }
    } else {
        $state.InstallType = 'Manual'
    }

    $galleryModuleInfo = Get-PowerShellGalleryModuleInfo

    if (-not $galleryModuleInfo.Success) {
        $state.Status = 'GalleryQueryFailed'
        $state.Message = $galleryModuleInfo.Message
        return $state
    }

    $state.GalleryVersion = $galleryModuleInfo.Module.Version.ToString()

    if ($galleryModuleInfo.Module.Version -gt $localModule.Version) {
        $state.UpdateAvailable = $true

        if ($state.InstallType -eq 'PowerShellGet' -and $state.InstallScope) {
            $state.CanAutoUpdate = $true
            $state.SuggestedCommand = Get-UpdateModuleSuggestedCommand -Scope $state.InstallScope
            $state.Status = 'UpdateAvailable'
            $state.Message = "Update verfuegbar: $($script:ModuleName) $($state.InstalledVersion) -> $($state.GalleryVersion) | Befehl: $($state.SuggestedCommand)"
        } else {
            $state.SuggestedCommand = "Install-Module -Name $($script:ModuleName) -Repository PSGallery -Force -AllowClobber"
            $state.Status = 'UpdateAvailableManualInstall'
            $state.Message = "Update verfuegbar: $($script:ModuleName) $($state.InstalledVersion) -> $($state.GalleryVersion) | Automatisches Update ist fuer diese Installation nicht moeglich. Vorschlag: $($state.SuggestedCommand)"
        }

        return $state
    }

    if ($galleryModuleInfo.Module.Version -eq $localModule.Version) {
        $state.Status = 'UpToDate'
        $state.Message = "Kein Update verfuegbar. Installierte Version $($state.InstalledVersion) ist aktuell."
        return $state
    }

    $state.Status = 'LocalVersionNewer'
    $state.Message = "Die lokale Version $($state.InstalledVersion) ist neuer als die PSGallery-Version $($state.GalleryVersion)."
    return $state
}

function Get-myPoshWriteLogUpdate {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [switch]$Update,
        [switch]$Quiet,
        [switch]$PassThru,
        [bool]$Console = $true,
        [string]$CustomLogPath
    )

    $state = Get-ModuleUpdateState

    switch ($state.Status) {
        'NotInstalled' {
            if (-not $Quiet) {
                Write-UpdateLogMessage -Message $state.Message -Severity Warning -Console $Console -CustomLogPath $CustomLogPath
            }
        }
        'GalleryQueryFailed' {
            Write-UpdateLogMessage -Message $state.Message -Severity Warning -Console $Console -CustomLogPath $CustomLogPath
        }
        'UpdateAvailable' {
            Write-UpdateLogMessage -Message $state.Message -Severity Information -Console $Console -CustomLogPath $CustomLogPath

            if ($Update -and $PSCmdlet.ShouldProcess($script:ModuleName, "Update module in scope '$($state.InstallScope)'")) {
                try {
                    Invoke-WithTls12 -ScriptBlock {
                        $updateModuleParameters = @{
                            Name        = $script:ModuleName
                            Force       = $true
                            ErrorAction = 'Stop'
                        }

                        $updateModuleCommand = Get-Command -Name Update-Module -ErrorAction Stop

                        if ($state.InstallScope -and $updateModuleCommand.Parameters.ContainsKey('Scope')) {
                            $updateModuleParameters['Scope'] = $state.InstallScope
                        }

                        Update-Module @updateModuleParameters | Out-Null
                    }

                    $state.Updated = $true
                    $state.Message = "Neue Version installiert. Die Aktualisierung wird nach erneutem Import des Moduls oder in einer neuen PowerShell-Session wirksam."

                    Write-UpdateLogMessage -Message "Modul '$($script:ModuleName)' wurde fuer Scope '$($state.InstallScope)' erfolgreich aktualisiert." -Severity Information -Console $Console -CustomLogPath $CustomLogPath
                    Write-UpdateLogMessage -Message $state.Message -Severity Information -Console $Console -CustomLogPath $CustomLogPath
                } catch {
                    $state.Message = "Update fehlgeschlagen: $($_.Exception.Message)"
                    Write-UpdateLogMessage -Message $state.Message -Severity Error -Console $Console -CustomLogPath $CustomLogPath
                }
            }
        }
        'UpdateAvailableManualInstall' {
            Write-UpdateLogMessage -Message $state.Message -Severity Warning -Console $Console -CustomLogPath $CustomLogPath

            if ($Update) {
                Write-UpdateLogMessage -Message 'Automatisches Update ist fuer manuell installierte Modulpfade nicht moeglich.' -Severity Warning -Console $Console -CustomLogPath $CustomLogPath
            }
        }
        'UpToDate' {
            if (-not $Quiet) {
                Write-UpdateLogMessage -Message $state.Message -Severity Information -Console $Console -CustomLogPath $CustomLogPath
            }
        }
        'LocalVersionNewer' {
            if (-not $Quiet) {
                Write-UpdateLogMessage -Message $state.Message -Severity Information -Console $Console -CustomLogPath $CustomLogPath
            }
        }
        default {
            if (-not $Quiet) {
                Write-UpdateLogMessage -Message 'Der Update-Status konnte nicht eindeutig ermittelt werden.' -Severity Warning -Console $Console -CustomLogPath $CustomLogPath
            }
        }
    }

    if ($PassThru) {
        return $state
    }
}

function Test-InteractiveModuleSession {
    if (-not [Environment]::UserInteractive) {
        return $false
    }

    return $Host.Name -in @('ConsoleHost', 'Visual Studio Code Host', 'Windows PowerShell ISE Host')
}

function Invoke-ModuleImportUpdateNotice {
    if ($script:UpdateCheckPerformed) {
        return
    }

    $script:UpdateCheckPerformed = $true

    if (-not (Test-InteractiveModuleSession)) {
        return
    }

    try {
        $state = Get-ModuleUpdateState
    } catch {
        return
    }

    switch ($state.Status) {
        'UpdateAvailable' {
            Write-UpdateLogMessage -Message $state.Message -Severity Information -Console $true
        }
        'UpdateAvailableManualInstall' {
            Write-UpdateLogMessage -Message $state.Message -Severity Warning -Console $true
        }
    }
}

Export-ModuleMember -Function 'Write-Log', 'Get-myPoshWriteLogUpdate'

Invoke-ModuleImportUpdateNotice
