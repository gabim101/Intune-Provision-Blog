function UploadFileToAzureStorage($sasUri, $filepath, $fileUri){

	try {

        $chunkSizeInBytes = 1024l * 1024l * $azureStorageUploadChunkSizeInMb;
		
		# Start the timer for SAS URI renewal.
		$sasRenewalTimer = [System.Diagnostics.Stopwatch]::StartNew()
		
		# Find the file size and open the file.
		$fileSize = (Get-Item $filepath).length;
		$chunks = [Math]::Ceiling($fileSize / $chunkSizeInBytes);
		$reader = New-Object System.IO.BinaryReader([System.IO.File]::Open($filepath, [System.IO.FileMode]::Open));
		$position = $reader.BaseStream.Seek(0, [System.IO.SeekOrigin]::Begin);
		
		# Upload each chunk. Check whether a SAS URI renewal is required after each chunk is uploaded and renew if needed.
		$ids = @();

		for ($chunk = 0; $chunk -lt $chunks; $chunk++){

			$id = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($chunk.ToString("0000")));
			$ids += $id;

			$start = $chunk * $chunkSizeInBytes;
			$length = [Math]::Min($chunkSizeInBytes, $fileSize - $start);
			$bytes = $reader.ReadBytes($length);
			
			$currentChunk = $chunk + 1;			

            Write-Progress -Activity "Uploading File to Azure Storage" -status "Uploading chunk $currentChunk of $chunks" `
            -percentComplete ($currentChunk / $chunks*100)

            $uploadResponse = UploadAzureStorageChunk $sasUri $id $bytes;
			
			# Renew the SAS URI if 7 minutes have elapsed since the upload started or was renewed last.
			if ($currentChunk -lt $chunks -and $sasRenewalTimer.ElapsedMilliseconds -ge 450000){

				$renewalResponse = RenewAzureStorageUpload $fileUri;
				$sasRenewalTimer.Restart();
			
            }

		}

        Write-Progress -Completed -Activity "Uploading File to Azure Storage"

		$reader.Close();

	}

	finally {

		if ($reader -ne $null) { $reader.Dispose(); }
	
    }
	
	# Finalize the upload.
	$uploadResponse = FinalizeAzureStorageUpload $sasUri $ids;

}