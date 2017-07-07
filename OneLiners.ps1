# list api versions for specific azure resource type
(Get-AzureRmResourceProvider | %{$_.ResourceTypes | ? {$_.ResourceTypeName -eq 'virtualMachines'}}).ApiVersions