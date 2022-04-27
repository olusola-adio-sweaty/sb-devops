Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Unpublish-AzureRmCdnEndpointContent {}

Describe "Clear-Cdn unit tests" -Tag "Unit" {


    It "Should pass parameters to Unpublish-AzureRmCdnEndpointContent" {

        Mock Unpublish-AzureRmCdnEndpointContent

        .\Clear-Cdn -ResourceGroupName sb-foo-bar-rg -CdnName sb-foo-bar-cdn -EndpointName sb-foo-bar-assets

        Should -Invoke -CommandName Unpublish-AzureRmCdnEndpointContent

    }

}

Push-Location -Path $PSScriptRoot