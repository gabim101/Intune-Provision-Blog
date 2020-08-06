Function Test-AuthToken(){

    # Checking if authToken exists before running authentication
    if($global:authToken){

        # Setting DateTime to Universal time to work in all timezones
        $DateTime = (Get-Date).ToUniversalTime()

        # If the authToken exists checking when it expires
        $TokenExpires = ($authToken.ExpiresOn.datetime - $DateTime).Minutes

            if($TokenExpires -le 0){

            write-host "Authentication Token expired" $TokenExpires "minutes ago" -ForegroundColor Yellow
            write-host

                # Defining Azure AD tenant name, this is the name of your Azure Active Directory (do not use the verified domain name)

                

            $global:authToken = Get-AuthToken -client $($client_id) -secret $($client_secret) -tenant $($tenantId)

            }
    }

    # Authentication doesn't exist, calling Get-AuthToken function

    else {

        

    # Getting the authorization token
    $global:authToken = Get-AuthToken -client $($client_id) -secret $($client_secret) -tenant $($tenantId)

    }
}