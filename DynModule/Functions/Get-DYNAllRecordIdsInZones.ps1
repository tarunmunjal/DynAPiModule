Function Get-DYNAllRecordIdsInZones
{
    [cmdletbinding(DefaultParameterSetName='Properties')]
    Param(
    [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [string]$Zone,
    [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
    [string]$Auth_Token,
    [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ParameterSetName='JsonObject')]
    [Switch]$JsonObject,
    [parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,ParameterSetName='RecordUrl')]
    [Switch]$RecordUrl
    )
    Begin
    {
        $DYNHeaders = @{}
        $DYNHeaders.add('Auth-Token',$Auth_Token)
        $ZoneResults = @()
    }
    Process
    {
        $DYNHeaders.'Auth-Token' = $Auth_Token
        $DynZoneUri = "https://api.dynect.net/REST/AllRecord/$Zone/"
        Write-Verbose "$DynZoneUri"
        $ZoneResults += Invoke-WebRequest -Uri $DynZoneUri -ContentType 'application/json' -Headers $DYNHeaders -Method Get -ErrorAction Stop -UseBasicParsing
    }
    end
    {
        $Results = @()
        If($JsonObject.IsPresent)
        {
            Write-Verbose "Returning Json Object"
            $ZoneResults
        }
        elseif($RecordUrl.IsPresent)
        {
            Write-Verbose "Returning RecordUrl"
            $Results = ($ZoneResults | ConvertFrom-Json | select -ExpandProperty data) | Select @{N='RecordUrl';e={$_}}
            $Results
        }
        else
        {
            Write-Verbose "Returning returning parsed object"
            ($ZoneResults | ConvertFrom-Json | select -ExpandProperty data) | %{
                $splitobject = New-Object -TypeName psobject -property @{
                    RecordID = $_ -split '/' | select -Last 1
                    FQDN = ($_ -split '/'  )[4]
                    Zone = ($_ -split '/'  )[3]
                    RecordType = ($_ -split '/'  )[2]
                }
                $Results += $splitobject
            }
            $Results
        }
    }
}
