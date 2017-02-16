# Simple modification of basic Azure VM creation script, that shows how to create managed disk from snapshot and attach it to the VM.

$location = "westeurope"
$resourceGroupName = "vm-copy-rg1"
$snapshotResourceGroupName = 'snapshots-rg1'
$snapshotName = 'vm1_snapshot1'
$vmName = 'vm-copy1'

# ResourceGroupName parameter has to be specified, without it. Cmdlet returns all snapshots it can find regardless their name.
$snapshot = Get-AzureRmSnapshot -SnapshotName $snapshotName -ResourceGroupName $snapshotResourceGroupName

New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

$vnetName = 'vnet1'
$vnetPrefix = '10.0.0.0/16'
$subnetName = 'lan'
$subnetPrefix = '10.0.0.0/24'
$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName `
    -Location $location -AddressPrefix $vnetPrefix -Subnet $subnet
 
$pipName = "$vmName-pip1"
$pip = New-AzureRmPublicIpAddress -Name $pipName -ResourceGroupName $resourceGroupName `
    -Location $location -AllocationMethod Dynamic

$nicName = "$vmName-nic1"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName `
    -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

$vmSize = 'Standard_A2'
$managedDiskType = 'Premium_LRS'
$managedDiskCreateOption = 'Copy'
$diskName = "$vmName-osdisk"
$diskCreateOption = 'Attach'
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
$diskConfig = New-AzureRmDiskConfig -AccountType $managedDiskType -Location $location -CreateOption $managedDiskCreateOption -SourceResourceId $snapshot.Id
$osDisk = New-AzureRmDisk -DiskName $diskName -Disk $diskConfig -ResourceGroupName $resourceGroupName
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $diskName -ManagedDiskId $osDisk.Id -CreateOption $diskCreateOption -Windows -Caching ReadWrite
New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vm