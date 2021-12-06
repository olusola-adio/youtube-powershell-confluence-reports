<#
.SYNOPSIS
PublishConfluenceReport

.DESCRIPTION
PublishConfluenceReport - takes a collection and publishes it to Conflluence

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

.PARAMETER confluenceTable
The name of the confluence table

.EXAMPLE
PublishConfluenceReport -BaseURI $(BaseURI) -confluenceApiUsername $(ConfluenceApiUsername) -ConfluenceApiTokenPass $(ConfluenceApiTokenPass) -ConfluenceInventoryPageId $(ConfluenceInventoryPageId) ReportName $(ReportName) ConfluenceTable $(ConfluenceTable)

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
    [String]$ConfluencePageId,
    [Parameter(Mandatory = $true)]
    [String]$ReportName,
    [parameter(Mandatory = $true)]
    [object[]]$ConfluenceTable
)

try {

    $pass = ConvertTo-SecureString -String $ConfluenceApiTokenPass -AsPlainText -Force
    $confluenceCredential = New-Object System.Management.Automation.PSCredential ($ConfluenceApiUsername, $pass)
    Set-ConfluenceInfo -BaseURI $BaseURI -Credential $confluenceCredential

    $Body = $ConfluenceTable | ConvertTo-ConfluenceTable | Out-String | ConvertTo-ConfluenceStorageFormat

    $subscription = (get-azcontext).Subscription.Name
    $timestamp = (Get-Date).ToString('F')
    New-ConfluencePage -Title "$($ReportName) - $subscription - $timestamp" -Body $Body -ParentID $ConfluencePageId

}
catch {
    throw $_
}