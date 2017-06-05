Function Get-DynInformationFromRecordIDs
{
    [cmdletbinding(DefaultParameterSetName='Properties')]
    Param(
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$RecordID,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$FQDN,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$Zone,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$RecordType,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='RecordUrl')]
    [string]$RecordUrl,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='RecordUrl')]
    [Switch]$JsonObject,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='RecordUrl')]
    [string]$Auth_Token
    )
    Begin
    {
        $DYNHeaders = @{}
        $RecordIDResults = @()
        $DYNHeaders.add('Auth-Token',$Auth_Token)
    }
    Process
    {
        $DYNHeaders.'Auth-Token' = $Auth_Token
        if(!$RecordUrl)
        {
            $RecordIDUrl = "https://api.dynect.net/REST/$RecordType/$Zone/$FQDN/$RecordID/"
            Write-Verbose "Constructed uri using properties: $RecordIDUrl"
        }
        else
        {
            $RecordIDUrl = "https://api.dynect.net$RecordUrl"
            Write-Verbose "Constructed uri using properties: $RecordUrl"
        }
        $RecordIDResults += Invoke-WebRequest -Uri $RecordIDUrl -ContentType 'application/json' -Headers $DYNHeaders -Method Get -ErrorAction Stop -UseBasicParsing
    }
    end
    {
        if($JsonObject.IsPresent)
        {
            Write-Verbose "Returning Json Object"
            $RecordIDResults
        }
        else
        {
            Write-Verbose "Returning parsed object with properties."
            $IPResult = @()
            ($RecordIDResults | ConvertFrom-Json | select -ExpandProperty data) | %{
            $IPDAta = New-Object -TypeName psobject -Property @{
                    zone = $_ | select -ExpandProperty zone
                    rdata = $_ | Select -ExpandProperty rdata
                    fqdn = $_ | select -ExpandProperty fqdn
                    ttl = $_ | select -ExpandProperty ttl
                    recordid = $_ | select -ExpandProperty record_id
                    recordtype = $_ | select -ExpandProperty record_type
                }
                $IPResult += $IPDAta
            }
            $IPResult
        }
    }
}