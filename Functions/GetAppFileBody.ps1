function GetAppFileBody($name, $size, $sizeEncrypted, $manifest){

	$body = @{ "@odata.type" = "#microsoft.graph.mobileAppContentFile" };
	$body.name = $name;
	$body.size = $size;
	$body.sizeEncrypted = $sizeEncrypted;
	$body.manifest = $manifest;
    $body.isDependency = $false;

	$body;
}