<#
.SYNOPSIS
Tests an ARM template file

.DESCRIPTION
Tests a ARM template file to make sure it should deploy.

.PARAMETER ParameterFile
Parameter file with manditory and optional parameters to test with.
Normally contains dummy values unless it is a dependancy in which case a valid value is needed.

.PARAMETER TemplateFile
The template file to test

.PARAMETER ResourceGroupName
The name of the resource group to test the ARM template against.  Defaults to sb-test-template-rg

.EXAMPLE
Test-ArmTemplate.ps1 -ParameterFile paramaters.json -TemplateFile template.json

#>
[CmdletBinding()]
Param(
    [string] $ParameterFile,
    [string] $TemplateFile,
    [string] $ResourceGroupName = "sb-test-template-rg"
)

$DeploymentParameters = @{
    ResourceGroupName     = $ResourceGroupName
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $ParameterFile
    Verbose               = $true
}

Write-Host "- Validating template"
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {

    Write-Verbose -Message "Deployment Parameters:"
    $DeploymentParameters

}
az deployment group validate --resource-group $ResourceGroupName --template-file $TemplateFile --parameters @($ParameterFile)