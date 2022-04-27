Describe "CDN Endpoint Deployment Tests" -Tag "Acceptance" {

    
    BeforeAll {
        # common variables
        $ResourceGroupName = "sb-test-template-rg"
        $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\CDN\cdn-endpoint.json"
        $TemplateParametersDefault = @{
            cdnProfileName  = "sb-foo-shared-cdn"
            cdnEndPointName = "sb-foo-bar-assets"
            originHostName  = "https://sbfoobarstr.z6.web.core.windows.net/"
        }
    }

    Context "When CDN Endpoint is deployed with cdnProfileName, cdnEndPointName and originHostName" {

        BeforeAll{
            $TemplateParameters = $TemplateParametersDefault
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

    Context "When CDN Endpoint is deployed with cdnProfileName, cdnEndPointName, originHostName and cacheExpirationOverride" {

        BeforeAll{
            $TemplateParameters = $TemplateParametersDefault
            $TemplateParameters['cacheExpirationOverride'] = "7"
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