$Params = @{ 
    "Path" 				    = '.\src\write-log\write-log.psd1' 
    "Author" 			    = 'nox309 | Torben Inselmann'
    "CompanyName"           = ' '
    "Copyright"             = '(c) 2023 nox309 | Torben Inselmann. All rights reserved.'
    "PowerShellVersion"     = '5.1'
    "RootModule" 			= 'write-log.psm1'
    "ModuleVersion" 		= '1.2.0' 
    "CompatiblePSEditions" 	= @('Desktop','Core') 
    "FunctionsToExport" 	= @('Write-Log') 
    # "CmdletsToExport" 		= ''
    # "VariablesToExport" 	= '' 
    # "AliasesToExport" 		= @() 
    "Description"           = 'Powershell log function for extended logs in txt form and optionally with output on the console'
    "HelpInfoURI"           = 'https://github.com/nox309/myPosh_Write-Log/issues'
    "ProjectUri"            = 'https://github.com/nox309/myPosh_Write-Log'
    "Tags"                  = @('Log','myPosh','logfile')
} 
#New-ModuleManifest @Params
Update-ModuleManifest @Params