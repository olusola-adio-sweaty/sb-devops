Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Set-SbResourceGroupTags unit tests" -Tag "Unit" {

    BeforeAll {
        Mock Get-AzureRmResourceGroup { [PsCustomObject]
            @{
                ResourceGroupName = "sb-foobar-rg"
                Location          = "westeurope"
                Tags              = @{  "env" = "test"; 
                                        "org" = "sb"; 
                                        "team" = "app"; 
                                        "CostCenter" = "10001"; 
                                        "instance" = "dpp" 
                                    } 
            }
        }
        Mock New-AzureRmResourceGroup
        Mock Set-AzureRmResourceGroup
    
    }
    It "Should do nothing if a resource group exists with matching tags" {

        .\Set-SbResourceGroupTags -ResourceGroupName "sb-foobar-rg" -env "test" -org "sb" -team "app" -CostCenter "10001" -instance "dpp"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 0 -Scope It

    }

    It "Should update existing resource group if group exists with different tags" {

        .\Set-SbResourceGroupTags -ResourceGroupName "sb-foobar-rg" -env "prod" -org "sb" -team "app" -CostCenter "10001" -instance "dpp"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 1 -Scope It

    }

    It "Should create new resource group if group doesn't exists" {

        Mock Get-AzureRmResourceGroup

        .\Set-SbResourceGroupTags -ResourceGroupName "sb-barfoo-rg" -env "prod" -org "sb" -team "app" -CostCenter "10001" -instance "dpp"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 0 -Scope It

    }

    It "Should add tags to the group it not tags exist" {

        Mock Get-AzureRmResourceGroup { [PsCustomObject]
            @{
                ResourceGroupName = "sb-foobar-rg"
                Location          = "westeurope"
            }
        }
    
        .\Set-SbResourceGroupTags -ResourceGroupName "sb-barfoo-rg" -env "test" -org "sb" -team "app" -CostCenter "10001" -instance "dpp"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot