function CloneObject($object){

	$stream = New-Object IO.MemoryStream;
	$formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter;
	$formatter.Serialize($stream, $object);
	$stream.Position = 0;
	$formatter.Deserialize($stream);
}