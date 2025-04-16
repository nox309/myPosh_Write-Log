# Changelog

## [1.2.2]
### Added
- Added error handling for directory and file creation to prevent potential issues.
- Set a default value for the `-console` parameter to `$false` for easier usage.
- Defined colors for console output in a Hashtable to reduce redundancy and improve maintainability.
- Added an optional `-CustomLogPath` parameter to allow specifying a custom log path.

### Changed
- Log file now includes the username (`$env:username`) in log entries.
- Improved inline comments and documentation for better clarity.

### Fixed
- No known bugs fixed.

## [2022-12-23]
### Added
- Initial version of the `myPosh_Write-Log` module.