
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
      $DiagnosticSettingName = "$($prefix)-eh-diag-setting"

      $code = (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/olusola-adio-sweaty/sb-devops/master/ArmTemplates/Datadog/function-code.js")

      $environment = Get-AzEnvironment -Name "AzureCloud"
      $endpointSuffix = $environment.StorageEndpointSuffix

      $TemplateParameters = @{
          ResourceGroupName = $ResourceGroupName
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