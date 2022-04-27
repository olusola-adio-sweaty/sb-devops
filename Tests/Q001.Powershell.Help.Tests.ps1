<#
.SYNOPSIS
Runs the Help Quality tests

.DESCRIPTION
Runs the Help Quality tests

.EXAMPLE
Q001.Powershell.Help.Tests.ps1

#>
# Describe "PowerShell script help quality tests" -Tag "Quality" {

#     BeforeDiscovery {
#         $Scripts = Get-ChildItem -Path $PSScriptRoot\..\*.ps1 -File -Recurse | Where-Object { $_.FullName -notlike "*/tests/*" }
#         Write-Host "File count discovered for Help quality Tests: $($Scripts.Count)"
#     }

#     Context "<_.BaseName>" -Foreach @($Scripts) {

#         BeforeDiscovery {
#             $help = Get-Help $_.FullName
#             $parameters = @()
#             Write-Output $parameters.Count
#             if ($help.parameters.parameter.count -ne 0) {
#                 $parameters = $help.Parameters.Parameter
#             }
#         }

#         It "Should have a Synopsis" -Foreach @{help = $help}{
#             $help.Synopsis | Should -Not -BeNullOrEmpty
#         }
#         It "Should have a Description" -Foreach @{help = $help}{
#             $help.Description | Should -Not -BeNullOrEmpty
#         }
#         It "Should have an Example" -Foreach @{help = $help}{
#             $help.examples | Select-Object -First 1 | Should -HaveCount 1
#         }
#         It "Should have a Parameter description for <_.Name>" -ForEach @($parameters) {
#             $_.Description.Text | Should -Not -BeNullOrEmpty
#         }
#     }
# }

BeforeDiscovery {
    $Scripts = Get-ChildItem -Path $PSScriptRoot\..\*.ps1 -File -Recurse
    Write-Host "File count discovered for Help quality Tests: $($Scripts.Count)"
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