
Describe "App Service Plan Deployment Tests" -Tag "Acceptance" {

  BeforeAll{
# common variables
$ResourceGroupName = "sb-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\application-insights.json"
  }
  
  Context "When application insights is deployed with just name" {

    BeforeAll{
      $TemplateParameters = @{
        appInsightsName = "sb-foo-bar-ai"
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

  }
}