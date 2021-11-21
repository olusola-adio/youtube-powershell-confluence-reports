<#
.SYNOPSIS
PublishResourceReport

.DESCRIPTION
PublishResourceReport - grabs a list of resources and sends the collection to the PublishConfluenceReport script

.PARAMETER BaseURI
The name of the BaseURI

.PARAMETER confluenceApiUsername
The name of the confluence user

.PARAMETER confluenceApiTokenPass
confluence token

.PARAMETER ConfluenceInventoryPageId
The ID of the Page to publish to

.PARAMETER ReportName
The name of the ReportTitle

.EXAMPLE
PublishResourceReport -BaseURI $(BaseURI) -confluenceApiUsername $(ConfluenceApiUsername) -ConfluenceApiTokenPass $(ConfluenceApiTokenPass) -ConfluenceInventoryPageId $(ConfluenceInventoryPageId) ReportName $(ReportName)

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [String]$BaseURI,
    [Parameter(Mandatory = $true)]
    [String]$ConfluenceApiUsername,
    [Parameter(Mandatory = $true)]
    [String]$ConfluenceApiTokenPass,
    [Parameter(Mandatory = $true)]
    [String]$ConfluenceInventoryPageId,
    [Parameter(Mandatory = $true)]
    [String]$ReportName
)

try {

    $resources = Get-AzResource
    foreach ($resource in $resources) {
        Write-Host "Name: $($resource.Name)       ResourceGroupName: $($resource.ResourceGroupName)        Resource Type: $($resource.ResourceType)       Location: $($resource.Location)"
    }

    $ConfluenceTable = $resources |
    select-object ResourceGroupName, Name, ResourceType, Location |
    Sort-Object ResourceGroupName, Name

    & $PSScriptRoot/PublishConfluenceReport.ps1 -BaseURI $($BaseURI) -confluenceApiUsername $($ConfluenceApiUsername) -ConfluenceApiTokenPass $($ConfluenceApiTokenPass) -ConfluenceInventoryPageId $($ConfluenceInventoryPageId) -ReportName $($ReportName) -ConfluenceTable $($ConfluenceTable)
}
catch {
    throw $_
}