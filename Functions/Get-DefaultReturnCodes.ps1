function Get-DefaultReturnCodes(){

@{"returnCode" = 0;"type" = "success"}, `
@{"returnCode" = 1707;"type" = "success"}, `
@{"returnCode" = 3010;"type" = "softReboot"}, `
@{"returnCode" = 1641;"type" = "hardReboot"}, `
@{"returnCode" = 1618;"type" = "retry"}

}