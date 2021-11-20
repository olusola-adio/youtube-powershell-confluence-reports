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

.PARAMETER ReportTitle
The name of the ReportTitle

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
    [object[]]$ConfluenceTable,
    [Parameter(Mandatory = $true)]
    [String]$ReportTitle
)

try {

    $pass = ConvertTo-SecureString -String $ConfluenceApiTokenPass -AsPlainText -Force
    $confluenceCredential = New-Object System.Management.Automation.PSCredential ($ConfluenceApiUsername, $pass)
    Set-ConfluenceInfo -BaseURI $BaseURI -Credential $confluenceCredential

    $Body = $ConfluenceTable | ConvertTo-ConfluenceTable | Out-String | ConvertTo-ConfluenceStorageFormat

    $subscription = (get-azcontext).Subscription.Name
    $timestamp = (Get-Date).ToString('F')
    New-ConfluencePage -Title "$ReportTitle - $subscription - $timestamp" -Body $Body -ParentID $confluenceInventoryPageId

}
catch {
    throw $_
}