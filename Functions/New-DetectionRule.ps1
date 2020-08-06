Function New-DetectionRule(){

[cmdletbinding()]

param
(
 [parameter(Mandatory=$true,ParameterSetName = "PowerShell",Position=1)]
 [Switch]$PowerShell,

 [parameter(Mandatory=$true,ParameterSetName = "MSI",Position=1)]
 [Switch]$MSI,

 [parameter(Mandatory=$true,ParameterSetName = "File",Position=1)]
 [Switch]$File,

 [parameter(Mandatory=$true,ParameterSetName = "Registry",Position=1)]
 [Switch]$Registry,

 [parameter(Mandatory=$true,ParameterSetName = "PowerShell")]
 [ValidateNotNullOrEmpty()]
 [String]$ScriptFile,

 [parameter(Mandatory=$true,ParameterSetName = "PowerShell")]
 [ValidateNotNullOrEmpty()]
 $enforceSignatureCheck,

 [parameter(Mandatory=$true,ParameterSetName = "PowerShell")]
 [ValidateNotNullOrEmpty()]
 $runAs32Bit,

 [parameter(Mandatory=$true,ParameterSetName = "MSI")]
 [ValidateNotNullOrEmpty()]
 [String]$MSIproductCode,
   
 [parameter(Mandatory=$true,ParameterSetName = "File")]
 [ValidateNotNullOrEmpty()]
 [String]$Path,
 
 [parameter(Mandatory=$true,ParameterSetName = "File")]
 [ValidateNotNullOrEmpty()]
 [string]$FileOrFolderName,

 [parameter(Mandatory=$true,ParameterSetName = "File")]
 [ValidateSet("notConfigured","exists","modifiedDate","createdDate","version","sizeInMB")]
 [string]$FileDetectionType,

 [parameter(Mandatory=$false,ParameterSetName = "File")]
 $FileDetectionValue = $null,

 [parameter(Mandatory=$true,ParameterSetName = "File")]
 [ValidateSet("True","False")]
 [string]$check32BitOn64System = "False",

 [parameter(Mandatory=$true,ParameterSetName = "Registry")]
 [ValidateNotNullOrEmpty()]
 [String]$RegistryKeyPath,

 [parameter(Mandatory=$true,ParameterSetName = "Registry")]
 [ValidateSet("notConfigured","exists","doesNotExist","string","integer","version")]
 [string]$RegistryDetectionType,

 [parameter(Mandatory=$false,ParameterSetName = "Registry")]
 [ValidateNotNullOrEmpty()]
 [String]$RegistryValue,

 [parameter(Mandatory=$true,ParameterSetName = "Registry")]
 [ValidateSet("True","False")]
 [string]$check32BitRegOn64System = "False"

)

    if($PowerShell){

        if(!(Test-Path "$ScriptFile")){
            
            Write-Host
            Write-Host "Could not find file '$ScriptFile'..." -ForegroundColor Red
            Write-Host "Script can't continue..." -ForegroundColor Red
            Write-Host
            break

        }
        
        $ScriptContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$ScriptFile"));
        
        $DR = @{ "@odata.type" = "#microsoft.graph.win32LobAppPowerShellScriptDetection" }
        $DR.enforceSignatureCheck = $false;
        $DR.runAs32Bit = $false;
        $DR.scriptContent =  "$ScriptContent";

    }
    
    elseif($MSI){
    
        $DR = @{ "@odata.type" = "#microsoft.graph.win32LobAppProductCodeDetection" }
        $DR.productVersionOperator = "notConfigured";
        $DR.productCode = "$MsiProductCode";
        $DR.productVersion =  $null;

    }

    elseif($File){
    
        $DR = @{ "@odata.type" = "#microsoft.graph.win32LobAppFileSystemDetection" }
        $DR.check32BitOn64System = "$check32BitOn64System";
        $DR.detectionType = "$FileDetectionType";
        $DR.detectionValue = $FileDetectionValue;
        $DR.fileOrFolderName = "$FileOrFolderName";
        $DR.operator =  "notConfigured";
        $DR.path = "$Path"

    }

    elseif($Registry){
    
        $DR = @{ "@odata.type" = "#microsoft.graph.win32LobAppRegistryDetection" }
        $DR.check32BitOn64System = "$check32BitRegOn64System";
        $DR.detectionType = "$RegistryDetectionType";
        $DR.detectionValue = "";
        $DR.keyPath = "$RegistryKeyPath";
        $DR.operator = "notConfigured";
        $DR.valueName = "$RegistryValue"

    }

    return $DR

}
