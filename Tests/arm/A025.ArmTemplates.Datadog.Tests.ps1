
Describe "Datadog Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "sb-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\Datadog\event-hub-log-forwarder.json"
  }

  Context "When an Event Grid Topic is deployed with a name and sku" {

    BeforeAll {

      $DatadogSite = "datadoghq.eu"

      $EventhubNamespace = "$($prefix)-eh-ns"
      $FunctionAppName ="$($prefix)-fa"
      $EventhubName = "$($prefix)-eh"
      $FunctionName = "$($prefix)-fn"
      $functionAppNameInsights = "$($prefix)-ai"

      $code = "code"

      $endpointSuffix = "core.windows.net"

      $TemplateParameters = @{
          functionCode = $code
          apiKey = $ApiKey
          location = $ResourceGroupLocation
          eventHubName = $EventhubName
          functionName = $FunctionName
          datadogSite = $DatadogSite
          endpointSuffix = $endpointSuffix
      }

      # Use values if parameters passed, otherwise we rely on the default value generated by the ARM template
      $TemplateParameters["eventhubNamespace"] = $EventhubNamespace
      $TemplateParameters["functionAppNameInsights"] = $functionAppNameInsights
      $TemplateParameters["functionAppName"] = $FunctionAppName

  
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