Function Publish-DynPendingChangesForAZone
{
    [cmdletbinding(DefaultParameterSetName='Properties')]
    Param(
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$Zone,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [Switch]$JsonObject,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [switch]$Publish,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$Notes,
    [parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='Properties')]
    [string]$Auth_Token
    )
    Begin
    {
        $DYNHeaders = @{}
        $PublishBodyArguments = @{}
        $PublishWebRespose = @()
        $DYNHeaders.add('Auth-Token',$Auth_Token)
        $PublishBodyArguments.add('publish',$false)
        $PublishBodyArguments.add('notes',"Pushed from REST API")
    }
    Process
    {
        $DYNHeaders.'Auth-Token' = $Auth_Token
        $PublishUrl = "https://api.dynect.net/REST/Zone/$Zone/"
        Write-Verbose "Dyn publish uri $PublishUrl"
        if($Publish.IsPresent)
        {
            Write-Verbose "Publish value is : $Publish"
            $PublishBodyArguments.publish = $true 
        }
        if($Notes)
        {
            Write-Verbose "notes value is $Notes"
            $PublishBodyArguments.notes = $Notes
        }
        $PublishWebRespose += Invoke-WebRequest -Uri $PublishUrl -ContentType 'application/json' -Headers $DYNHeaders -Method Put -ErrorAction Stop -Body ($PublishBodyArguments | ConvertTo-Json) -UseBasicParsing
    }
    end
    {
        if($JsonObject.IsPresent)
        {
            Write-Verbose "Returning Json Object"
            $PublishWebRespose
        }
        else
        {
            Write-Verbose "Returning parsed object with properties"
            $PublishResults = @()
            ($PublishWebRespose | ConvertFrom-Json) | %{
            $PublishData = New-Object -TypeName psobject -Property @{
                status = $_.status
                zone_type = $_.data.zone_type
                task_id = $_.data.task_id
                serial_style = $_.data.serial_style
                zone = $_.data.zone
                job_id = $_.job_id
                INFO = $_.msgs.INFO
            }
                $PublishResults += $PublishData
            }
            $PublishResults
        }
    }
}