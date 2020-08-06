function Import_DeviceCompliancePolicy {
param (
	[Parameter(Mandatory = $true)]
	[string]$ImportPath 
)
$JSON_Data = gc "$ImportPath"

# Excluding entries that are not required - id,createdDateTime,lastModifiedDateTime,version
$JSON_Convert = $JSON_Data | ConvertFrom-Json | Select-Object -Property * -ExcludeProperty id,createdDateTime,lastModifiedDateTime,version

$DisplayName = $JSON_Convert.displayName

$JSON_Output = $JSON_Convert | ConvertTo-Json -Depth 5

# Adding Scheduled Actions Rule to JSON
$scheduledActionsForRule = '"scheduledActionsForRule":[{"ruleName":"PasswordRequired","scheduledActionConfigurations":[{"actionType":"block","gracePeriodHours":0,"notificationTemplateId":"","notificationMessageCCList":[]}]}]'        

$JSON_Output = $JSON_Output.trimend("}")

$JSON_Output = $JSON_Output.TrimEnd() + "," + "`r`n"

# Joining the JSON together
$JSON_Output = $JSON_Output + $scheduledActionsForRule + "`r`n" + "}"
            
write-host
write-host "Compliance Policy '$DisplayName' Found..." -ForegroundColor Yellow
write-host
$JSON_Output
write-host
Write-Host "Adding Compliance Policy '$DisplayName'" -ForegroundColor Yellow
Add-DeviceCompliancePolicy -JSON $JSON_Output
}
