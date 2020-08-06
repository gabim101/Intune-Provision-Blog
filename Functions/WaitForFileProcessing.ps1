function WaitForFileProcessing($fileUri, $stage){

	$attempts= 600;
	$waitTimeInSeconds = 10;

	$successState = "$($stage)Success";
	$pendingState = "$($stage)Pending";
	$failedState = "$($stage)Failed";
	$timedOutState = "$($stage)TimedOut";

	$file = $null;
	while ($attempts -gt 0)
	{
		$file = MakeGetRequest $fileUri;

		if ($file.uploadState -eq $successState)
		{
			break;
		}
		elseif ($file.uploadState -ne $pendingState)
		{
			Write-Host -ForegroundColor Red $_.Exception.Message;
            throw "File upload state is not success: $($file.uploadState)";
		}

		Start-Sleep $waitTimeInSeconds;
		$attempts--;
	}

	if ($file -eq $null -or $file.uploadState -ne $successState)
	{
		throw "File request did not complete in the allotted time.";
	}

	$file;
}