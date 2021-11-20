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
    [String]$ConfluenceInventoryPageId,
    [parameter(Mandatory = $true)]
    [object[]]$ConfluenceTable = (Get-AzResource |
    select-object ResourceGroupName, Name, ResourceType, Location |
    Sort-Object ResourceGroupName, Name | ConvertTo-ConfluenceTable | Out-String)
)

try {

    $resources = Get-AzResource
    foreach ($resource in $resources) {
        Write-Host "Name: $($resource.Name)       ResourceGroupName: $($resource.ResourceGroupName)        Resource Type: $($resource.ResourceType)       Location: $($resource.Location)"
    }

    $pass = ConvertTo-SecureString -String $ConfluenceApiTokenPass -AsPlainText -Force
    $confluenceCredential = New-Object System.Management.Automation.PSCredential ($ConfluenceApiUsername, $pass)
    Set-ConfluenceInfo -BaseURI $BaseURI -Credential $confluenceCredential

    # $ConfluenceTable = $resources |
    # select-object ResourceGroupName, Name, ResourceType, Location |
    # Sort-Object ResourceGroupName, Name | ConvertTo-ConfluenceTable | Out-String

    $Body = $ConfluenceTable | ConvertTo-ConfluenceStorageFormat

    $subscription = (get-azcontext).Subscription.Name
    $timestamp = (Get-Date).ToString('F')
    New-ConfluencePage -Title "Resource Report - $subscription - $timestamp" -Body $Body -ParentID $confluenceInventoryPageId

}
catch {
    throw $_
}