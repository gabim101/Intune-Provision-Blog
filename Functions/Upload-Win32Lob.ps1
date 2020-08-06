function Upload-Win32Lob(){

<#
.SYNOPSIS
This function is used to upload a Win32 Application to the Intune Service
.DESCRIPTION
This function is used to upload a Win32 Application to the Intune Service
.EXAMPLE
Upload-Win32Lob "C:\Packages\package.intunewin" -publisher "Microsoft" -description "Package"
This example uses all parameters required to add an intunewin File into the Intune Service
.NOTES
NAME: Upload-Win32LOB
#>

[cmdletbinding()]

param
(
    [parameter(Mandatory=$true,Position=1)]
    [ValidateNotNullOrEmpty()]
    [string]$SourceFile,

    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$displayName,

    [parameter(Mandatory=$true,Position=2)]
    [ValidateNotNullOrEmpty()]
    [string]$publisher,

    [parameter(Mandatory=$true,Position=3)]
    [ValidateNotNullOrEmpty()]
    [string]$description,

    [parameter(Mandatory=$true,Position=4)]
    [ValidateNotNullOrEmpty()]
    $detectionRules,

    [parameter(Mandatory=$true,Position=5)]
    [ValidateNotNullOrEmpty()]
    $returnCodes,

    [parameter(Mandatory=$false,Position=6)]
    [ValidateNotNullOrEmpty()]
    [string]$installCmdLine,

    [parameter(Mandatory=$false,Position=7)]
    [ValidateNotNullOrEmpty()]
    [string]$uninstallCmdLine,

    [parameter(Mandatory=$false,Position=8)]
    [ValidateSet('system','user')]
    $installExperience = "system"
)

	try	{

        $LOBType = "microsoft.graph.win32LobApp"

        Write-Host "Testing if SourceFile '$SourceFile' Path is valid..." -ForegroundColor Yellow
        Test-SourceFile "$SourceFile"

        $Win32Path = "$SourceFile"

        Write-Host
        Write-Host "Creating JSON data to pass to the service..." -ForegroundColor Yellow

        # Funciton to read Win32LOB file
        $DetectionXML = Get-IntuneWinXML "$SourceFile" -fileName "detection.xml"

        # If displayName input don't use Name from detection.xml file
        if($displayName){ $DisplayName = $displayName }
        else { $DisplayName = $DetectionXML.ApplicationInfo.Name }
        
        $FileName = $DetectionXML.ApplicationInfo.FileName

        $SetupFileName = $DetectionXML.ApplicationInfo.SetupFile

        $Ext = [System.IO.Path]::GetExtension($SetupFileName)

        if((($Ext).contains("msi") -or ($Ext).contains("Msi")) -and (!$installCmdLine -or !$uninstallCmdLine)){

		    # MSI
            $MsiExecutionContext = $DetectionXML.ApplicationInfo.MsiInfo.MsiExecutionContext
            $MsiPackageType = "DualPurpose";
            if($MsiExecutionContext -eq "System") { $MsiPackageType = "PerMachine" }
            elseif($MsiExecutionContext -eq "User") { $MsiPackageType = "PerUser" }

            $MsiProductCode = $DetectionXML.ApplicationInfo.MsiInfo.MsiProductCode
            $MsiProductVersion = $DetectionXML.ApplicationInfo.MsiInfo.MsiProductVersion
            $MsiPublisher = $DetectionXML.ApplicationInfo.MsiInfo.MsiPublisher
            $MsiRequiresReboot = $DetectionXML.ApplicationInfo.MsiInfo.MsiRequiresReboot
            $MsiUpgradeCode = $DetectionXML.ApplicationInfo.MsiInfo.MsiUpgradeCode
            
            if($MsiRequiresReboot -eq "false"){ $MsiRequiresReboot = $false }
            elseif($MsiRequiresReboot -eq "true"){ $MsiRequiresReboot = $true }

            $mobileAppBody = GetWin32AppBody `
                -MSI `
                -displayName "$DisplayName" `
                -publisher "$publisher" `
                -description $description `
                -filename $FileName `
                -SetupFileName "$SetupFileName" `
                -installExperience $installExperience `
                -MsiPackageType $MsiPackageType `
                -MsiProductCode $MsiProductCode `
                -MsiProductName $displayName `
                -MsiProductVersion $MsiProductVersion `
                -MsiPublisher $MsiPublisher `
                -MsiRequiresReboot $MsiRequiresReboot `
                -MsiUpgradeCode $MsiUpgradeCode

        }

        else {

            $mobileAppBody = GetWin32AppBody -EXE -displayName "$DisplayName" -publisher "$publisher" `
            -description $description -filename $FileName -SetupFileName "$SetupFileName" `
            -installExperience $installExperience -installCommandLine $installCmdLine `
            -uninstallCommandLine $uninstallcmdline

        }

        if($DetectionRules.'@odata.type' -contains "#microsoft.graph.win32LobAppPowerShellScriptDetection" -and @($DetectionRules).'@odata.type'.Count -gt 1){

            Write-Host
            Write-Warning "A Detection Rule can either be 'Manually configure detection rules' or 'Use a custom detection script'"
            Write-Warning "It can't include both..."
            Write-Host
            break

        }

        else {

        $mobileAppBody | Add-Member -MemberType NoteProperty -Name 'detectionRules' -Value $detectionRules

        }

        #ReturnCodes

        if($returnCodes){
        
        $mobileAppBody | Add-Member -MemberType NoteProperty -Name 'returnCodes' -Value @($returnCodes)

        }

        else {

            Write-Host
            Write-Warning "Intunewin file requires ReturnCodes to be specified"
            Write-Warning "If you want to use the default ReturnCode run 'Get-DefaultReturnCodes'"
            Write-Host
            break

        }

        Write-Host
        Write-Host "Creating application in Intune..." -ForegroundColor Yellow
		$mobileApp = MakePostRequest "mobileApps" ($mobileAppBody | ConvertTo-Json);

		# Get the content version for the new app (this will always be 1 until the new app is committed).
        Write-Host
        Write-Host "Creating Content Version in the service for the application..." -ForegroundColor Yellow
		$appId = $mobileApp.id;
		$contentVersionUri = "mobileApps/$appId/$LOBType/contentVersions";
		$contentVersion = MakePostRequest $contentVersionUri "{}";

        # Encrypt file and Get File Information
        Write-Host
        Write-Host "Getting Encryption Information for '$SourceFile'..." -ForegroundColor Yellow

        $encryptionInfo = @{};
        $encryptionInfo.encryptionKey = $DetectionXML.ApplicationInfo.EncryptionInfo.EncryptionKey
        $encryptionInfo.macKey = $DetectionXML.ApplicationInfo.EncryptionInfo.macKey
        $encryptionInfo.initializationVector = $DetectionXML.ApplicationInfo.EncryptionInfo.initializationVector
        $encryptionInfo.mac = $DetectionXML.ApplicationInfo.EncryptionInfo.mac
        $encryptionInfo.profileIdentifier = "ProfileVersion1";
        $encryptionInfo.fileDigest = $DetectionXML.ApplicationInfo.EncryptionInfo.fileDigest
        $encryptionInfo.fileDigestAlgorithm = $DetectionXML.ApplicationInfo.EncryptionInfo.fileDigestAlgorithm

        $fileEncryptionInfo = @{};
        $fileEncryptionInfo.fileEncryptionInfo = $encryptionInfo;

        # Extracting encrypted file
        $IntuneWinFile = Get-IntuneWinFile "$SourceFile" -fileName "$filename"

        [int64]$Size = $DetectionXML.ApplicationInfo.UnencryptedContentSize
        $EncrySize = (Get-Item "$IntuneWinFile").Length

		# Create a new file for the app.
        Write-Host
        Write-Host "Creating a new file entry in Azure for the upload..." -ForegroundColor Yellow
		$contentVersionId = $contentVersion.id;
		$fileBody = GetAppFileBody "$FileName" $Size $EncrySize $null;
		$filesUri = "mobileApps/$appId/$LOBType/contentVersions/$contentVersionId/files";
		$file = MakePostRequest $filesUri ($fileBody | ConvertTo-Json);
	
		# Wait for the service to process the new file request.
        Write-Host
        Write-Host "Waiting for the file entry URI to be created..." -ForegroundColor Yellow
		$fileId = $file.id;
		$fileUri = "mobileApps/$appId/$LOBType/contentVersions/$contentVersionId/files/$fileId";
		$file = WaitForFileProcessing $fileUri "AzureStorageUriRequest";

		# Upload the content to Azure Storage.
        Write-Host
        Write-Host "Uploading file to Azure Storage..." -f Yellow

		$sasUri = $file.azureStorageUri;
		UploadFileToAzureStorage $file.azureStorageUri "$IntuneWinFile" $fileUri;

        # Need to Add removal of IntuneWin file
        $IntuneWinFolder = [System.IO.Path]::GetDirectoryName("$IntuneWinFile")
        Remove-Item "$IntuneWinFile" -Force

		# Commit the file.
        Write-Host
        Write-Host "Committing the file into Azure Storage..." -ForegroundColor Yellow
		$commitFileUri = "mobileApps/$appId/$LOBType/contentVersions/$contentVersionId/files/$fileId/commit";
		MakePostRequest $commitFileUri ($fileEncryptionInfo | ConvertTo-Json);

		# Wait for the service to process the commit file request.
        Write-Host
        Write-Host "Waiting for the service to process the commit file request..." -ForegroundColor Yellow
		$file = WaitForFileProcessing $fileUri "CommitFile";

		# Commit the app.
        Write-Host
        Write-Host "Committing the file into Azure Storage..." -ForegroundColor Yellow
		$commitAppUri = "mobileApps/$appId";
		$commitAppBody = GetAppCommitBody $contentVersionId $LOBType;
		MakePatchRequest $commitAppUri ($commitAppBody | ConvertTo-Json);

        Write-Host "Sleeping for $sleep seconds to allow patch completion..." -f Magenta
        Start-Sleep $sleep
        Write-Host
    
    }
	
    catch {

		Write-Host "";
		Write-Host -ForegroundColor Red "Aborting with exception: $($_.Exception.ToString())";
	
    }
}