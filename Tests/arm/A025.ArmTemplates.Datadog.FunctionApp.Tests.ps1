
Describe "Datadog Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "sb-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\Datadog\function-app.json"
  }

  Context "When an Event Grid Topic is deployed with a name and sku" {

    BeforeAll {

      $prefix = "sb-test-template"
      $DatadogSite = "datadoghq.eu"

      $EventhubNamespace = "$($prefix)-eh-ns"
      $FunctionAppName ="$($prefix)-fa"
      $EventhubName = "$($prefix)-eh"
      $FunctionName = "$($prefix)-fn"
      $functionAppNameInsights = "$($prefix)-ai"
      $ApiKey = "kjhjkhkj"

      $code = (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/olusola-adio-sweaty/sb-devops/master/ArmTemplates/Datadog/function-code.js")


      $endpointSuffix = "core.windows.net"

      $TemplateParameters = @{
          functionCode = $code
          apiKey = $ApiKey
          eventHubName = $EventhubName
          functionName = $FunctionName
          datadogSite = $DatadogSite
          endpointSuffix = $endpointSuffix
          eventhubNamespace = $EventhubNamespace
          functionAppNameInsights = $functionAppNameInsights
          functionAppName = $FunctionAppName
          copies =2
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