Function Update-DynInformationFromRecordIDs
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
    $rdataArguments = @(),
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='RecordUrl')]
    [string]$Auth_Token
    )
    Begin
    {
        $DYNHeaders = @{}
        $BodyArguments = @{}
        $UpdateRequestResults = @()
        $DYNHeaders.add('Auth-Token',$Auth_Token)
        $BodyArguments.add('rdata',$rdataArguments)
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
            $RecordIDUrl = "https://api.dynect.net$RecordUrl/"
            Write-Verbose "Constructed uri using properties: $RecordUrl"
        }
        $rdataNoteProperty = $rdataArguments | gm | ?{$_.membertype -eq 'NoteProperty'} | select -ExpandProperty name
        if($rdataNoteProperty -eq 'address' -and $rdataNoteProperty.count -eq 1)
        {
            $BodyArguments.rdata = $rdataArguments | select address -ErrorAction Stop
        }
        else
        {
            $rdataexample = New-Object -TypeName psobject -property @{
                    address = '123.123.123.123'
                }
            Throw "rdataArguments doesn't contain property 'address' `n Example : $($rdataexample)"
        }
        $jsonbody = $BodyArguments | ConvertTo-Json
        $jsonbody | Out-Host
        $DYNHeaders | Out-Host
        $RecordIDUrl | Out-Host
        $UpdateRequestResults += Invoke-WebRequest -Uri $RecordIDUrl -ContentType 'application/json' -Headers $DYNHeaders -Method Put -ErrorAction Stop -Body $jsonbody -UseBasicParsing
    }
    end
    {
        if($JsonObject.IsPresent)
        {
            Write-Verbose "Returning Json Object"
            $UpdateRequestResults
        }
        else
        {
            Write-Verbose "Returning parsed object with properties."
            $UpdateRequestResultsProperties = @()
            ($UpdateRequestResults | ConvertFrom-Json | select -ExpandProperty data) | %{
            $UpdateRequestData = New-Object -TypeName psobject -Property @{
                status = $_.status
                ttl = $_.data.ttl
                zone = $_.data.zone
                fqdn = $_.data.fqdn
                recordtype = $_.data.record_type
                recordid = $_.data.record_id
                job_id = $_.job_id
                INFO = $_.msgs.INFO
            }
                $UpdateRequestResultsProperties += $UpdateRequestData
            }
            Write-Host "Please note that records are not yet published. Use Publish-DynPendingChangesForAZone function to update the records in DYN."
            $UpdateRequestResultsProperties
        }
    }
}