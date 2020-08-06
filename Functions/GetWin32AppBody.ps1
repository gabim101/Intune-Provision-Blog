function GetWin32AppBody(){

param
(

[parameter(Mandatory=$true,ParameterSetName = "MSI",Position=1)]
[Switch]$MSI,

[parameter(Mandatory=$true,ParameterSetName = "EXE",Position=1)]
[Switch]$EXE,

[parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string]$displayName,

[parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string]$publisher,

[parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string]$description,

[parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string]$filename,

[parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
[string]$SetupFileName,

[parameter(Mandatory=$true)]
[ValidateSet('system','user')]
$installExperience = "system",

[parameter(Mandatory=$true,ParameterSetName = "EXE")]
[ValidateNotNullOrEmpty()]
$installCommandLine,

[parameter(Mandatory=$true,ParameterSetName = "EXE")]
[ValidateNotNullOrEmpty()]
$uninstallCommandLine,

[parameter(Mandatory=$true,ParameterSetName = "MSI")]
[ValidateNotNullOrEmpty()]
$MsiPackageType,

[parameter(Mandatory=$true,ParameterSetName = "MSI")]
[ValidateNotNullOrEmpty()]
$MsiProductCode,

[parameter(Mandatory=$false,ParameterSetName = "MSI")]
$MsiProductName,

[parameter(Mandatory=$true,ParameterSetName = "MSI")]
[ValidateNotNullOrEmpty()]
$MsiProductVersion,

[parameter(Mandatory=$false,ParameterSetName = "MSI")]
$MsiPublisher,

[parameter(Mandatory=$true,ParameterSetName = "MSI")]
[ValidateNotNullOrEmpty()]
$MsiRequiresReboot,

[parameter(Mandatory=$true,ParameterSetName = "MSI")]
[ValidateNotNullOrEmpty()]
$MsiUpgradeCode

)

    if($MSI){

	    $body = @{ "@odata.type" = "#microsoft.graph.win32LobApp" };
        $body.applicableArchitectures = "x64,x86";
        $body.description = $description;
	    $body.developer = "";
	    $body.displayName = $displayName;
	    $body.fileName = $filename;
        $body.installCommandLine = "msiexec /i `"$SetupFileName`""
        $body.installExperience = @{"runAsAccount" = "$installExperience"};
	    $body.informationUrl = $null;
	    $body.isFeatured = $false;
        $body.minimumSupportedOperatingSystem = @{"v10_1607" = $true};
        $body.msiInformation = @{
            "packageType" = "$MsiPackageType";
            "productCode" = "$MsiProductCode";
            "productName" = "$MsiProductName";
            "productVersion" = "$MsiProductVersion";
            "publisher" = "$MsiPublisher";
            "requiresReboot" = "$MsiRequiresReboot";
            "upgradeCode" = "$MsiUpgradeCode"
        };
	    $body.notes = "";
	    $body.owner = "";
	    $body.privacyInformationUrl = $null;
	    $body.publisher = $publisher;
        $body.runAs32bit = $false;
        $body.setupFilePath = $SetupFileName;
        $body.uninstallCommandLine = "msiexec /x `"$MsiProductCode`""

    }

    elseif($EXE){

        $body = @{ "@odata.type" = "#microsoft.graph.win32LobApp" };
        $body.description = $description;
	    $body.developer = "";
	    $body.displayName = $displayName;
	    $body.fileName = $filename;
        $body.installCommandLine = "$installCommandLine"
        $body.installExperience = @{"runAsAccount" = "$installExperience"};
	    $body.informationUrl = $null;
	    $body.isFeatured = $false;
        $body.minimumSupportedOperatingSystem = @{"v10_1607" = $true};
        $body.msiInformation = $null;
	    $body.notes = "";
	    $body.owner = "";
	    $body.privacyInformationUrl = $null;
	    $body.publisher = $publisher;
        $body.runAs32bit = $false;
        $body.setupFilePath = $SetupFileName;
        $body.uninstallCommandLine = "$uninstallCommandLine"

    }

	$body;
}