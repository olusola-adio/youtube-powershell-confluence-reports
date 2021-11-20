<#
.SYNOPSIS
Create app authentication

.DESCRIPTION
Create app authentication

.PARAMETER BaseURI
The name of the resource group that contains the APIM instnace

.PARAMETER confluenceApiUsername
The name of the resource group that contains the APIM instnace

.PARAMETER confluenceApiTokenPass
The name of the function app

.PARAMETER ConfluenceInventoryPageId
The name of the resource group that contains the APIM instnace

.PARAMETER confluenceTable
The name of the function app

.EXAMPLE
Create-AppAuthentication -ResourceGroup dfc-foo-bar-rg -FunctionAppName

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)]
    [String]$BaseURI = 'https://logion-ltd.atlassian.net/wiki',
    [Parameter(Mandatory = $false)]
    [String]$ConfluenceApiUsername = 'olusola.adio@logion.co.uk',
    [Parameter(Mandatory = $false)]
    [String]$ConfluenceApiTokenPass = "ogIfPdW1exBfFukY4enl6191",
    [Parameter(Mandatory = $false)]
    [String]$ConfluenceInventoryPageId = '98422',
    [parameter(Mandatory = $false)]
    [object[]]$confluenceTable = (Get-AzResource |
    select-object ResourceGroupName, Name, ResourceType, Location |
    Sort-Object ResourceGroupName, Name | ConvertTo-ConfluenceTable | Out-String)
)

try {

    Install-Module ConfluencePS -force
    Import-Module ConfluencePS -force

    $resources = Get-AzResource
    foreach ($resource in $resources) {
        Write-Host "Name: $($resource.Name)       ResourceGroupName: $($resource.ResourceGroupName)        Resource Type: $($resource.ResourceType)       Location: $($resource.Location)"
    }

    $pass = ConvertTo-SecureString -String $ConfluenceApiTokenPass -AsPlainText -Force
    $confluenceCredential = New-Object System.Management.Automation.PSCredential ($ConfluenceApiUsername, $pass)
    Set-ConfluenceInfo -BaseURI $BaseURI -Credential $confluenceCredential

    # $confluenceTable = $resources |
    # select-object ResourceGroupName, Name, ResourceType, Location |
    # Sort-Object ResourceGroupName, Name | ConvertTo-ConfluenceTable | Out-String

    $Body = $confluenceTable | ConvertTo-ConfluenceStorageFormat

    $subscription = (get-azcontext).Subscription.Name
    $timestamp = (Get-Date).ToString('F')
    New-ConfluencePage -Title "Resource Report - $subscription - $timestamp" -Body $Body -ParentID $confluenceInventoryPageId

}
catch {
    throw $_
}