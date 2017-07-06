<#
.SYNOPSIS
    Deploys ARM template
.EXAMPLE
    PS C:\> vm.deploy.ps1 -ResourceGroupName "vm-test-rg1" -Location "West Europe"
    Deploys vm.json template with parameters from vm.parameters.json file
.NOTES
    Script assumes convention over configuration approach.
    If one will name all files correctly e.g.
    
    vm.json
    vm.parameters.json
    vm.deploy.ps1

    script will disassemble file names and process only the ones with proper name.
#>
[CmdletBinding()]
param (
    $ResourceGroupName,
    $Location
)

begin {
    $templateName = $MyInvocation.MyCommand.Name.Split('.')[0]
    $templateFile = Get-Item -Path "$PSScriptRoot\$templateName.json"
    $templateParameterFile = Get-Item -Path "$PSScriptRoot\$templateName.parameters.json"
}

process {
    $deploymentParameters = @{
        Name                  = ('deployment' + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm'))
        ResourceGroupName     = $resourceGroupName
        TemplateFile          = $templateFile
        TemplateParameterFile = $templateParameterFile
        Force                 = $true
        Verbose               = $true
    }

    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location -Force
    New-AzureRmResourceGroupDeployment @deploymentParameters
}