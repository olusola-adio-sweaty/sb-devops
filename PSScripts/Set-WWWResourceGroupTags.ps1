<#
.SYNOPSIS
Sets standard tags on a resource group required by the ESFA.

.DESCRIPTION
Checks if a resource group exists, if it doesn't creates with specified tags.  If it does validates that the tags are match those specified in the parameters and updates them if necessary.

.PARAMETER ResourceGroupName
Name of the resource group to be created and \ or have tags applied

.PARAMETER Location
[Optional]Location of the resource group, defaults to West Europe

.PARAMETER Environment
Name of the environment, select from a valid ESFA environment name tag: Production, PreProduction or Dev/Test

.PARAMETER env
Name of the environment

.PARAMETER org
Name of the org

.PARAMETER team
Name of the team

.PARAMETER CostCenter
Name of the CostCenter

.PARAMETER instance
Name of the instance


.EXAMPLE
Set-SbResourceGroupTags -ResourceGroupName "sb-dev-foobar-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Course Directory"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$false)]
    [string]$Location = "West Europe",
    [Parameter(Mandatory=$true)]
    [ValidateSet("prod", "test", "dev")]
    [string]$env,
    [Parameter(Mandatory=$true)]
    [ValidateSet("sb","www")]
    [string]$org,
    [Parameter(Mandatory=$true)]
    [ValidateSet("app", "network", "system", "security")]
    [string]$team,
    [Parameter(Mandatory=$true)]
    [string]$CostCenter,
    [Parameter(Mandatory=$true)]
    [string]$instance
)

$Tags = @{
    'env' = $env
    'org' = $org
    'team' = $team
    'ResourceType' = "rg"
    'CostCenter' = $CostCenter
    'instance' = $instance
}

Write-Verbose -Message "Attempting to retrieve existing resource group $ResourceGroupName"
$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue

if(!$ResourceGroup) {

    Write-Verbose -Message "Resource group $ResourceGroupName doesn't exist, creating resource group"
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tags

}
else {

    Write-Verbose -Message "Resource group $ResourceGroupName exists, validating tags"
    $UpdateTags = $false

    if ($ResourceGroup.Tags) {

        # Check existing tags and update if necessary
        $UpdatedTags = $ResourceGroup.Tags
        foreach ($Key in $Tags.Keys) {

            Write-Verbose "Current value of Resource Group Tag $Key is $($ResourceGroup.Tags[$Key])"
            if ($($ResourceGroup.Tags[$Key]) -eq $($Tags[$Key])) {

                Write-Verbose -Message "Current value of tag ($($ResourceGroup.Tags[$Key])) matches parameter ($($Tags[$Key]))"

            }
            elseif ($null -eq $($ResourceGroup.Tags[$Key])) {

                Write-Verbose -Message ("Tag value is not set, adding tag {0} with value {1}" -f $Key, $Tags[$Key])
                $UpdatedTags[$Key] = $Tags[$Key]
                $UpdateTags = $true

            }
            else {

                Write-Verbose -Message ("Tag value is incorrect, setting tag {0} with value {1}" -f $Key, $Tags[$Key])
                $UpdatedTags[$Key] = $Tags[$Key]
                $UpdateTags = $true

            }
        }

    }
    else {

        # No tags to check, just update with the passed in tags
        $UpdatedTags = $Tags
        $UpdateTags = $true

    }

    if ($UpdateTags) {

        Write-Host "Replacing existing tags:"
        $UpdatedTags
        Set-AzureRmResourceGroup -Name $ResourceGroup.ResourceGroupName -Tag $UpdatedTags

    }

}
