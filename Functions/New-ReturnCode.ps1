function New-ReturnCode(){

param
(
[parameter(Mandatory=$true)]
[int]$returnCode,
[parameter(Mandatory=$true)]
[ValidateSet('success','softReboot','hardReboot','retry')]
$type
)

    @{"returnCode" = $returnCode;"type" = "$type"}

}