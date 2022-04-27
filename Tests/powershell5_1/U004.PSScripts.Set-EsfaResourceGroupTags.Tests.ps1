Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Set-EsfaResourceGroupTags unit tests" -Tag "Unit" {

    BeforeAll {
        Mock Get-AzureRmResourceGroup { [PsCustomObject]
            @{
                ResourceGroupName = "sb-foobar-rg"
                Location          = "westeurope"
                Tags              = @{"Parent Business" = "Karis Ministries"; "Service Offering" = "Karis Ministries Services"; "Environment" = "Dev/Test"; "Portfolio" = "Education and Skills Funding Agency"; "Service Line" = "National Careers Service (CEDD)"; "Service" = "National Careers Service"; "Product" = "Karis Ministries Services"; "Feature" = "Karis Ministries Services" } 
            }
        }
        Mock New-AzureRmResourceGroup
        Mock Set-AzureRmResourceGroup
    
    }
    It "Should do nothing if a resource group exists with matching tags" {

        .\Set-EsfaResourceGroupTags -ResourceGroupName "sb-foobar-rg" -Environment "Dev/Test" -ParentBusiness "Karis Ministries" -ServiceOffering "Karis Ministries Services"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 0 -Scope It

    }

    It "Should update existing resource group if group exists with different tags" {

        .\Set-EsfaResourceGroupTags -ResourceGroupName "sb-foobar-rg" -Environment "Dev/Test" -ParentBusiness "Karis Ministries" -ServiceOffering "Karis Ministries Services (PP)"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 1 -Scope It

    }

    It "Should create new resource group if group doesn't exists" {

        Mock Get-AzureRmResourceGroup

        .\Set-EsfaResourceGroupTags -ResourceGroupName "sb-barfoo-rg" -Environment "Dev/Test" -ParentBusiness "Karis Ministries" -ServiceOffering "Karis Ministries Services"

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
    
        .\Set-EsfaResourceGroupTags -ResourceGroupName "sb-barfoo-rg" -Environment "Dev/Test" -ParentBusiness "Karis Ministries" -ServiceOffering "Karis Ministries Services"

        Should -Invoke -CommandName Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzureRmResourceGroup -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot