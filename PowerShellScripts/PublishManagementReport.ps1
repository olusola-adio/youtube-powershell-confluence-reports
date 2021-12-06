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
    Install-Module ConfluencePS -force
    Import-Module ConfluencePS -force


    $subscription = (get-azcontext).Subscription
    $fileContents = Get-Content .\PowerShellScripts\PublishManagementReport.query.json

    $token = (Get-AzAccessToken).Token

    $headers = @{"Authorization" = "Bearer " + $token }

    $Parameters = @{
        Method      = "POST"
        Uri         = "https://management.azure.com/subscriptions/$($subscription.Id)/providers/Microsoft.CostManagement/query?api-version=2021-10-01"
        Body        = $fileContents
        ContentType = "application/json"
        Headers     = $headers
    }
    $results = Invoke-RestMethod @Parameters

    $OutputResults = @()
    foreach ($row in $results.properties.rows) {
        $obj = New-Object -TypeName psobject
        $columnPos = 0
        foreach ($column in $results.properties.columns) {
            $obj | Add-Member -MemberType NoteProperty -Name $column.name  -Value $row[$columnPos]
            $columnPos++
        }
        $OutputResults += $obj
    }

    & $PSScriptRoot/PublishConfluenceReport.ps1 -BaseURI $($BaseURI) -confluenceApiUsername $($ConfluenceApiUsername) -ConfluenceApiTokenPass $($ConfluenceApiTokenPass) -ConfluenceInventoryPageId $($ConfluenceInventoryPageId) -ReportName $($ReportName) -ConfluenceTable $($OutputResults)

}
catch {
    throw $_
}