<#
.SYNOPSIS
Runs the Help Quality tests

.DESCRIPTION
Runs the Help Quality tests

.EXAMPLE
Pester01.Help.Quality.Tests.ps1

#>

BeforeDiscovery {
    $Scripts = Get-ChildItem -Path $PSScriptRoot\..\*.ps1 -File -Recurse
    Write-Host "Number of files discovered for Help quality Tests: $($Scripts.Count)"
}
Describe "Help quality tests for '<_>'" -ForEach @($Scripts) -Tag "Quality" {

    BeforeDiscovery {
        $scriptName = $_.FullName
        Write-Output "Script name: $($scriptName)"
        $help = Get-Help $_.FullName
        $parameters = @()
        if ($help.parameters.parameter.count -ne 0) {
            $parameters = $help.Parameters.Parameter
        }
        Write-Output "parameter count: $($parameters.Count)"
    }

    Context "Test $scriptName for basic help" -Foreach @{help = $help } {

        It "Should have a Synopsis" {
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }
        It "Should have a Description" {
            $help.Description | Should -Not -BeNullOrEmpty
        }
        It "Should have an Example" {
            $help.examples | Select-Object -First 1 | Should -HaveCount 1
        }
    }

    Context "Parameter Definition for $scriptName" -Foreach @{parameters = $parameters } {
        It "Should have a Parameter description for <_.Name>" -ForEach @($parameters) {
            $_.Description.Text | Should -Not -BeNullOrEmpty
        }
    }
}