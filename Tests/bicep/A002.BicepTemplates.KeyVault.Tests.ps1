# common variables

Describe "Key Vault Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    $ResourceGroupName = "sb-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\BicepModules\keyvault.bicep"

  }

  Context "When KeyVault deployed with just key vault name" {
    BeforeAll {
      $TemplateParameters = @{
        keyVaultName = "sb-foo-bar-kv"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
    }

    It "Should be deployed successfully" {
      $output = Test-AzResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

  }
}