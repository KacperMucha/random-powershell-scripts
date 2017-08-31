# autocompletion for SubscriptionName parameter in Select-AzureRmSubscription or Get-AzureRmSubscription cmdlets
Register-ArgumentCompleter -ParameterName 'SubscriptionName' -ScriptBlock {
    $subscriptions = Get-AzureRmSubscription
    $subscriptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new("`"$($_.Name)`"")
    }
}

function Convert-ExchangeSizeToByte {
    <#
    .SYNOPSIS
        Converts string data returned by Exchange cmdlets to bytes
    .EXAMPLE
        PS C:\> "{0:N2}" -f ((Convert-ExchangeSizeToByte -InputObject "10.64 MB (11,158,319 bytes)") / 1MB)
        Converts string in Exchange cmdlet format to MB value with two decimal places
    .INPUTS
        System.String
    .OUTPUTS
        System.Int
    #>
    [CmdletBinding()]
    param (
        $InputObject
    )

    begin {
        $Regex = "\((.+)\)"
    }

    process {
        $Bytes = [Regex]::Match($InputObject, $Regex).Groups[1].Value.Replace(" bytes", "").Replace(",", "")
        [int]$Bytes
    }
}