
Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Import-ApimSwaggerApiDefinition unit tests" -Tag "DontRun" {

    It "Should not create a file"  {

        Mock Invoke-RestMethod
        Mock Set-Content
        Mock Get-AzApiManagementApi { [PsCustomObject]
            @{
                ApiId = "bar"
                Path = "bar"
            }
        }
        Mock Import-AzApiManagementApi

        $CmdletParameters = @{
           ApimResourceGroup = "sb-foo-bar-rg"
           InstanceName = "sb-foo-bar-apim"
           ApiName = "bar"
           SwaggerSpecificationUrl = "https://sb-foo-bar-fa.azurewebsites.net/api/bar/bar-api-definition"
       }

        .\Import-ApimSwaggerApiDefinition @CmdletParameters

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-Content -Exactly 0 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Import-AzApiManagementApi -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot