[CmdletBinding()]


param (
    [Parameter(Mandatory = $true)]
    [string]$tenantId, 
    [Parameter(Mandatory =$true)]
    [string]$client_id, 
    [Parameter(Mandatory=$true)]
    [string]$client_secret
)

#$rootLocation =  $env:BUILD_ARTIFACTSTAGINGDIRECTORY
$rootLocation = $env:Build_SourcesDirectory
Write-Host "Working Directory is " + $rootLocation

Write-Host "PSScriptRoot is" $PSScriptRoot

#$Functions = @(gci -Path  $rootLocation\Functions\*.ps1 -ErrorAction SilentlyContinue)

# Source Functions

$Functions = @(Get-ChildItem -Path $rootLocation\Functions\*.ps1 -ErrorAction SilentlyContinue)
foreach ($f in $Functions){
    try {
        Write-Host "Importing function "  $($f.FullName)
        . $($f.FullName)

    }
    catch{
        Write-Error -Message "Failed to import function " + $($f.FullName)
    }
}

#################################
####### Create Token  ###########
################################# 



Write-Host "Getting Token"
$global:authToken = Get-AuthToken -client $($client_id) -secret $($client_secret) -tenant $($tenantId)
Write-Host "Token is " $global:authToken.Authorization

$baseUrl = "https://graph.microsoft.com/beta/deviceAppManagement/"

$logRequestUris = $true;
$logHeaders = $false;
$logContent = $true;

$azureStorageUploadChunkSizeInMb = 6l;

$sleep = 30


#################################
####### Create win32 apps  ######
################################# 

$apps = @(Get-ChildItem -Path $rootLocation\win32apps -Directory )

foreach ($appItem in $apps){
    Write-Host "Creating Application " $appItem
    $appInfofile = (Get-ChildItem -Path "$rootLocation\win32apps\$appItem\$appItem.json").FullName
    $sourceFile = (Get-ChildItem -Path "$rootLocation\win32apps\$appItem\$appItem.intunewin").FullName

    $appData = Get-Content $appInfoFile -Raw | ConvertFrom-Json

    Write-Host "AppinfoFile is " $appInfofile
    Write-Host "SourceFile is " $sourceFile
    Write-Host "Application DisplayName is " $($appData.displayName)

    # Defining Detection Rules
    if ($($appData.DetectionRules.type) -eq "#microsoft.graph.win32LobAppFileSystemDetection"){
        $FileRule = New-DetectionRule -File -Path ($($appData.DetectionRules.path)) -FileOrFolderName ($($appData.DetectionRules.fileOrFolderName)) -FileDetectionType ($($appData.DetectionRules.detectionType)) -check32BitOn64System ($($appData.DetectionRules.check32BitOn64System))
    }
    
    $DetectionRule = @($FileRule)

    $ReturnCodes = Get-DefaultReturnCodes

    Upload-Win32Lob -SourceFile "$SourceFile" -publisher $($appData.publisher) `
    -displayName $($appData.displayName) `
    -description $($appData.description) -detectionRules $DetectionRule -returnCodes $ReturnCodes `
    -installCmdLine "$($appData.installCommandLine)" `
    -uninstallCmdLine "$($appData.uninstallCommandLine)"


}

#########################################
#### Import Configuration Policies ######
#########################################

$Configs = (Get-ChildItem -Path "$rootLocation\ConfigurationPolicies\*.json").FullName
foreach ($uniqueConfig in $Configs) {
    Write-Host "Importing Configuration " $uniqueConfig
    Import_DeviceConfigurationPolicy -ImportPath $uniqueConfig
}

#########################################
#### Import Compliance Policies ######
#########################################

$Compliances = (Get-ChildItem -Path "$rootLocation\CompliancePolicies\*.json").FullName
foreach ($uniqueCompliance in $Compliances) {
    Write-Host "Importing Compliance " $uniqueCompliance
    Import_DeviceCompliancePolicy -ImportPath $uniqueCompliance
}

