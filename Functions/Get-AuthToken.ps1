function Get-AuthToken {

param ( 
    [Parameter(Mandatory = $true)]
    [string]$client, 
    [Parameter(Mandatory = $true)]
    [string]$secret, 
    [Parameter(Mandatory = $true)]
    [string]$tenant 
    )

<#
.SYNOPSIS
This function is used to authenticate with the Graph API REST interface
.DESCRIPTION
The function authenticate with the Graph API Interface with the tenant name
.EXAMPLE
Get-AuthToken
Authenticates you with the Graph API interface
.NOTES
NAME: Get-AuthToken
#>

$client_id = $client
$client_secret = $secret
$tenant_id = $tenant

$resource = "https://graph.microsoft.com"
$authority = "https://login.microsoftonline.com/$tenant_id"
$tokenEndpointUri = "$authority/oauth2/token"

$content = "grant_type=client_credentials&client_id=$client_id&client_secret=$client_secret&resource=$resource"


$response = Invoke-RestMethod -Uri $tokenEndpointUri -Body $content -Method Post -UseBasicParsing
        

$authHeader = @{
'Content-Type'='application/json'
'Authorization'="Bearer " + $response.access_token
'ExpiresOn'=$response.expires_on
}
return $authHeader
}