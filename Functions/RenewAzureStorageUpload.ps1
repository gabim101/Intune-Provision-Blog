function RenewAzureStorageUpload($fileUri){

	$renewalUri = "$fileUri/renewUpload";
	$actionBody = "";
	$rewnewUriResult = MakePostRequest $renewalUri $actionBody;
	
	$file = WaitForFileProcessing $fileUri "AzureStorageUriRenewal" $azureStorageRenewSasUriBackOffTimeInSeconds;

}