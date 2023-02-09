$Params = @{ 
    "Path" 				    = '.\src\write-log\myPosh_write-log.psd1' 
    "Author" 			    = 'Torben Inselmann'
    "CompanyName"           = ' '
    "Copyright"             = '(c) 2023 Torben Inselmann. All rights reserved.'
    "PowerShellVersion"     = '5.1'
    "RootModule" 			= 'myPosh_write-log.psm1'
    "ModuleVersion" 		= '1.2.0' 
    "CompatiblePSEditions" 	= @('Desktop','Core') 
    "FunctionsToExport" 	= @('Write-Log') 
    # "CmdletsToExport" 	= ''
    # "VariablesToExport" 	= '' 
    # "AliasesToExport" 	= @() 
    "Description"           = 'Powershell log function for extended logs in txt form and optionally with output on the console'
    "HelpInfoURI"           = 'https://github.com/nox309/myPosh_Write-Log/issues'
    "ProjectUri"            = 'https://github.com/nox309/myPosh_Write-Log'
    "Tags"                  = @('Log','myPosh','logfile')
    "LicenseUri"            = 'https://github.com/nox309/myPosh_Write-Log/blob/main/LICENSE.md'
} 
#New-ModuleManifest @Params
Update-ModuleManifest @Params