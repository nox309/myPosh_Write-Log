# Changelog

## [Unreleased]
### Added
- Neue Funktion `Get-myPoshWriteLogUpdate` zum Pruefen der installierten Modulversion gegen PSGallery.
- Optionale Aktualisierung der passenden `PowerShellGet`-Installation mit `-Update`.
- Defensiver Hinweis beim Modul-Import, wenn fuer die aktive Installation ein Update verfuegbar ist.
- Entwurfsdokument fuer die Update-Funktion unter `docs/Update-Funktion-Entwurf.md`.

### Changed
- README um Beispiele und Funktionsbeschreibung fuer die Update-Pruefung erweitert.
- Manifest exportiert jetzt `Get-myPoshWriteLogUpdate`.

## [1.2.4] - 2026-03-12
### Changed
- Initialisierung der Logdatei erfolgt erst beim Aufruf von `Write-Log` statt beim Modul-Import.
- Tagesbasierter Dateiname wird pro Aufruf neu berechnet.
- Der Default-Parameterwert für `-Severity` wurde entfernt; der Parameter ist jetzt verpflichtend.
- README an den aktuellen Modulstand angepasst.

### Fixed
- Zusätzliche Fehlerbehandlung beim Schreiben des eigentlichen Logeintrags ergänzt.
- Export-Definitionen im Manifest auf notwendige Inhalte reduziert (keine Wildcards für Cmdlets, Variablen, Aliase).

## [1.2.3] - 2025-05-05
### Changed
- Modulstruktur im Repository bereinigt.
- Paket `myPosh_Write-Log-1.2.3.zip` bereitgestellt.

## [1.2.2] - 2025-04-16
### Added
- Fehlerbehandlung für die Erstellung von Verzeichnissen und Dateien ergänzt.
- Standardwert für den Parameter `-console` auf `$false` gesetzt.
- Farben für die Konsolenausgabe in einer Hashtable zusammengefasst.
- Optionalen Parameter `-CustomLogPath` hinzugefügt.

### Changed
- Logeinträge enthalten den Benutzernamen (`$env:username`).
- Kommentare und Dokumentation verbessert.

## [2022-12-23]
### Added
- Initial version of the `myPosh_Write-Log` module.
