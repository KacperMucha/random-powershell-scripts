# autocompletion for SubscriptionName parameter in Select-AzureRmSubscription or Get-AzureRmSubscription cmdlets
Register-ArgumentCompleter -ParameterName 'SubscriptionName' -ScriptBlock {
    $subscriptions = Get-AzureRmSubscription
    $subscriptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new("`"$($_.Name)`"")
    }
}