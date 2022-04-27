
Describe "Redis Cache Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "sb-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\redis.json"
  }
  
  Context "When a Redis Cache is deployed with just a name" {

    BeforeAll {
      $TemplateParameters = @{
        redisName = "sb-foo-bar-rds"
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