# myPosh_Write-Log

## Beschreibung (Deutsch)

`myPosh_Write-Log` ist ein PowerShell-Modul, das eine einfache und flexible Möglichkeit bietet, Log-Nachrichten in einer Datei zu speichern und optional auf der Konsole auszugeben. Es unterstützt verschiedene Schweregrade wie `Information`, `Warning`, `Error` und `Debug`.

### Funktionen
- Speichert Log-Nachrichten in einer Datei unter `C:\tmp\myPosh_Log`.
- Gibt Nachrichten optional farblich hervorgehoben auf der Konsole aus.
- Unterstützt verschiedene Schweregrade (`Information`, `Warning`, `Error`, `Debug`).
- Fügt automatisch Zeitstempel und Benutzernamen zu den Log-Einträgen hinzu.

### Beispiel
```powershell
Write-Log -Message "Testnachricht" -Severity Error -console $true
```

### Installation
1. Kopiere das Modul in ein Verzeichnis, das im `$env:PSModulePath` enthalten ist.
2. Importiere das Modul mit:
   ```powershell
   Import-Module myPosh_Write-Log
   ```
4. Alternative Installation
    ```powershell
   Install-Module -Name myPosh_write-log -Force -Scope AllUsers -AllowClobber
   ```

### Autor
- **Name:** Torben Inselmann
- **E-Mail:** support@inselmann.it
- **GitHub:** [nox309](https://github.com/nox309)

---

## Description (English)

`myPosh_Write-Log` is a PowerShell module that provides a simple and flexible way to log messages to a file and optionally display them on the console. It supports various severity levels such as `Information`, `Warning`, `Error`, and `Debug`.

### Features
- Logs messages to a file located at `C:\tmp\myPosh_Log`.
- Optionally displays messages on the console with color-coded severity levels.
- Supports various severity levels (`Information`, `Warning`, `Error`, `Debug`).
- Automatically adds timestamps and usernames to log entries.

### Example
```powershell
Write-Log -Message "Test message" -Severity Error -console $true
```

### Installation
1. Copy the module to a directory included in `$env:PSModulePath`.
2. Import the module using:
   ```powershell
   Import-Module myPosh_Write-Log
   ```
4. Alternative Installation
    ```powershell
   Install-Module -Name myPosh_write-log -Force -Scope AllUsers -AllowClobber
   ```

### Author
- **Name:** Torben Inselmann
- **Email:** support@inselmann.it
- **GitHub:** [nox309](https://github.com/nox309)S