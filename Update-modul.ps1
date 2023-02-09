$Params = @{ 
    "Path" 				    = '.\src\myPosh_Write-log\myPosh_write-log.psd1' 
    "Author" 			    = 'Torben Inselmann'
    "CompanyName"           = ' '
    "Copyright"             = '(c) 2023 Torben Inselmann. All rights reserved.'
    "PowerShellVersion"     = '5.1'
    "RootModule" 			= 'myPosh_write-log.psm1'
    "ModuleVersion" 		= '1.2.1' 
    "CompatiblePSEditions" 	= @('Desktop','Core') 
    "FunctionsToExport" 	= @('Write-Log') 
    # "CmdletsToExport" 	= ''
    # "VariablesToExport" 	= '' 
    # "AliasesToExport" 	= @() 
    "Description"           = 'Provides a log function which stores a log under $env:SystemDrive\tmp\myPosh_Log, this function can be called by other scripts. Status levels can be information, warning, error and debug. If the parameter "-console $true" is passed, the corresponding message is also printed on the console and colored according to the status level. This module works both standalone and as part of the myPosh project'
    "HelpInfoURI"           = 'https://github.com/nox309/myPosh_Write-Log/issues'
    "ProjectUri"            = 'https://github.com/nox309/myPosh_Write-Log'
    "Tags"                  = @('Log','myPosh','logfile')
    "LicenseUri"            = 'https://github.com/nox309/myPosh_Write-Log/blob/main/LICENSE.md'
} 
#New-ModuleManifest @Params
Update-ModuleManifest @Params