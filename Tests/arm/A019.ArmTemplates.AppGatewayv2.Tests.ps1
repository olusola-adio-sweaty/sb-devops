
Describe "App Gateway Deployment Tests" -Tag "Acceptance" {

  BeforeAll{
# common variables
$ResourceGroupName = "sb-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\app-gateway-v2.json"
  }
  
  Context "When an app gateway is deployed with just a single pool" {
    BeforeAll{
      $TemplateParameters = @{
        appGatewayName      = "sb-foo-bar-ag"
        subnetRef           = "/subscriptions/f3b14109-a3de-4f54-9f58-46d891380a7e/resourceGroups/sb-foo-bar-rg/providers/Microsoft.Network/virtualNetworks/sb-foo-bar-vnet/subnets/appgateway"
        backendPools        = @( @{
                                    name = "mypool"
                                    fqdn = "foo.example.net"
                              } )
        backendHttpSettings = @( @{
                                    name                       = "myHttpSettings"
                                    port                       = 80
                                    protocol                   = "Http"
                                    hostnameFromBackendAddress = $true
                              } )
        routingRules        = @( @{ #routing rules dont make sense with only one backend but the template does not allow an empty routingrules array due to ARM template limitations
                                    name        = "myroutingrule"
                                    backendPool = "mypool"
                                    backendHttp = "myHttpSettings"
                                    paths       = @( "/dummy/*" )
                              } )
        publicIpAddressId   = "1.2.3.4"
        userAssignedIdentityName = "sb-test-template-uim"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
  
  
    }
  
    It "Should be deployed successfully" {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

    if ($output) {
      Write-Error $output.Message
    }

  }
}