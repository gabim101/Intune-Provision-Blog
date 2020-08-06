function GetAppCommitBody($contentVersionId, $LobType){

	$body = @{ "@odata.type" = "#$LobType" };
	$body.committedContentVersion = $contentVersionId;

	$body;

}
