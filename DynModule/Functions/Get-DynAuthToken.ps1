Function Get-DynAuthToken
{
    [cmdletbinding()]
    Param(
    [parameter(ValueFromPipelineByPropertyName=$true)]
    [string]$customer_name,
    [parameter(ValueFromPipelineByPropertyName=$true)]
    [Switch]$JsonObject,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='unsecure')]
    [string]$user_name,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='unsecure')]
    [string]$password,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='secure')]
    [System.Management.Automation.CredentialAttribute()]$Credentials
    )
    Begin{
        $Body = @{}
        $Body.add('customer_name',$customer_name)
        $Body.add('user_name',$user_name)
        $Body.add('password',$password)
    }
    Process
    {
        if($Credentials)
        {
            Write-Verbose "Credential object option used."
            $user_name = $Credentials.UserName
            $password = $Credentials.getnetworkcredential().Password
        }
        $Body.customer_name = $customer_name
        $Body.user_name = $user_name
        $Body.password = $password
        $DYNAuthTokenUri = "https://api.dynect.net/REST/Session/" 
        Write-Verbose "Dyn AuthToken Uri : $DYNAuthTokenUri"
        $Token = Invoke-WebRequest -Uri $DYNAuthTokenUri -ContentType 'application/json' -Body ($Body | ConvertTo-Json) -Method Post -ErrorAction Stop -UseBasicParsing
    }
    End
    {
        if($JsonObject.IsPresent)
        {
            Write-Verbose "Returning JSON object"
            $Token
        }
        else
        {
            Write-Verbose "Returning parsed object with properties."
            $Token | ConvertFrom-Json | select -ExpandProperty data | select @{n='Auth_token';e={$_ | select -ExpandProperty token}}
        }
    }
}