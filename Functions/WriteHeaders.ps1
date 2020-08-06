function WriteHeaders($authToken){

	foreach ($header in $authToken.GetEnumerator())
	{
		if ($header.Name.ToLower() -eq "authorization")
		{
			continue;
		}

		Write-Host -ForegroundColor Gray "$($header.Name): $($header.Value)";
	}
}