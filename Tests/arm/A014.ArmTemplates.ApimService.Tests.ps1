
Describe "Apim Service Deployment Tests" -Tag "Acceptance" {

    BeforeAll {
        # common variables
        $ResourceGroupName = "sb-test-template-rg"
        $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\apim-service.json"
    }
  
    Context "When APIM service is deployed with just name, admin email, environment name and organisation name" {

        BeforeAll {
            $TemplateParameters = @{
                adminEmail       = "foo@bar.com"
                apimServiceName  = "sb-foo-bar-apim"
                environmentName  = "foo"
                organizationName = "Foo Bar"
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