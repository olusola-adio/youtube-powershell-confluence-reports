<#
.SYNOPSIS
Create app authentication

.DESCRIPTION
Create app authentication

.PARAMETER BaseURI
The name of the BaseURI

.PARAMETER confluenceApiUsername
The name of the confluence user

.PARAMETER confluenceApiTokenPass
confluence token

.PARAMETER ConfluenceInventoryPageId
The ID of the Page to publish to

.PARAMETER confluenceTable
The name of the confluence table

.EXAMPLE
PublishConfluenceReport -BaseURI $(BaseURI) -confluenceApiUsername $(ConfluenceApiUsername) -ConfluenceApiTokenPass $(ConfluenceApiTokenPass) -ConfluenceInventoryPageId $(ConfluenceInventoryPageId) ConfluenceTable $(ConfluenceTable)

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
    [String]$ConfluenceInventoryPageId
)

try {

    $resources = Get-AzResource
    foreach ($resource in $resources) {
        Write-Host "Name: $($resource.Name)       ResourceGroupName: $($resource.ResourceGroupName)        Resource Type: $($resource.ResourceType)       Location: $($resource.Location)"
    }

    $ConfluenceTable = $resources |
    select-object ResourceGroupName, Name, ResourceType, Location |
    Sort-Object ResourceGroupName, Name

    & $PSScriptRoot + "\PublishConfluenceReport.ps1" -BaseURI $($BaseURI) -confluenceApiUsername $($ConfluenceApiUsername) -ConfluenceApiTokenPass $($ConfluenceApiTokenPass) -ConfluenceInventoryPageId $($ConfluenceInventoryPageId) -ConfluenceTable $($ConfluenceTable)

}
catch {
    throw $_
}