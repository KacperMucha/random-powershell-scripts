function Find-AzureRmApplicableNsgRule {
    [CmdletBinding()]
    param (
        [string]
        $IpAddress
    )

    begin {
        $nicNetworkSecurityGroupRulesArray = @()
        $networkInterfaces = Get-AzureRmNetworkInterface
    }

    process {
        foreach ($nic in $networkInterfaces) {
            $nicIpAddress = $nic.IpConfigurations.PrivateIpAddress

            if ($nicIpAddress -eq $ipAddress) {
                $nicNetworkSecurityGroupRules = $null
                $nicNetworkSecurityGroupRules = New-Object -TypeName PSCustomObject -Property @{
                    NicName       = $nic.Name
                    IpAddress     = $ipAddress
                    SecurityRules = @()
                }

                $nicDirectNetworkSecurityGroupName = ($nic.NetworkSecurityGroup.Id -split '/')[-1]
                $nicSubnetName = ($nic.IpConfigurations.Subnet.Id -split '/')[-1]

                if ($nicDirectNetworkSecurityGroupName) {
                    $nicDirectNetworkSecurityGroupResourceGroupName = ($nic.NetworkSecurityGroup.Id -split '/')[4]
                    $nicDirectNetworkSecurityGroupProperties = @{
                        Name              = $nicDirectNetworkSecurityGroupName
                        ResourceGroupName = $nicDirectNetworkSecurityGroupResourceGroupName
                    }
                    $networkSecurityGroup = $null
                    $networkSecurityGroup = Get-AzureRmNetworkSecurityGroup @nicDirectNetworkSecurityGroupProperties

                    $networkSecurityGroup.SecurityRules | ForEach-Object {
                        $securityRule = $_
                        $nicNetworkSecurityGroupRules.SecurityRules += $securityRule
                    }

                    $networkSecurityGroup.DefaultSecurityRules | ForEach-Object {
                        $securityRule = $_
                        $nicNetworkSecurityGroupRules.SecurityRules += $securityRule
                    }
                }

                if ($nicSubnetName) {
                    $nicVirtualNetworkName = ($nic.IpConfigurations.Subnet.Id -split '/')[-3]
                    $nicVirtualNetworkResourceGroupName = ($nic.IpConfigurations.Subnet.Id -split '/')[4]
                    $nicVirtualNetworkProperties = @{
                        Name              = $nicVirtualNetworkName
                        ResourceGroupName = $nicVirtualNetworkResourceGroupName
                    }
                    $virtualNetwork = Get-AzureRmVirtualNetwork @nicVirtualNetworkProperties

                    $subnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -Name $nicSubnetName -VirtualNetwork $virtualNetwork
                    $subnetNetworkSecurityGroupName = ($subnetConfig.NetworkSecurityGroup.Id -split '/')[-1]
                    $subnetNetworkSecurityGroupResourceGroupName = ($subnetConfig.NetworkSecurityGroup.Id -split '/')[4]

                    if ($subnetNetworkSecurityGroupResourceGroupName) {
                        $subnetNetworkSecurityGroupProperties = @{
                            Name              = $subnetNetworkSecurityGroupName
                            ResourceGroupName = $subnetNetworkSecurityGroupResourceGroupName
                        }
                        $networkSecurityGroup = $null
                        $networkSecurityGroup = Get-AzureRmNetworkSecurityGroup @subnetNetworkSecurityGroupProperties

                        $networkSecurityGroup.SecurityRules | ForEach-Object {
                            $securityRule = $_
                            $nicNetworkSecurityGroupRules.SecurityRules += $securityRule
                        }

                        $networkSecurityGroup.DefaultSecurityRules | ForEach-Object {
                            $securityRule = $_
                            $nicNetworkSecurityGroupRules.SecurityRules += $securityRule
                        }    
                    }
                }

                $nicNetworkSecurityGroupRulesArray += $nicNetworkSecurityGroupRules
            }
        }
    }

    end {
        $nicNetworkSecurityGroupRulesArray
    }
}