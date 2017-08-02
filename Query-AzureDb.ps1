Function Query-AzureDb {
    param(
        [Parameter(Mandatory=$true)]
        $Url,
        [Parameter(Mandatory=$true)]
        $Name,
        [Parameter(Mandatory=$true)]
        $Credential,
        [Parameter(Mandatory=$true)]
        $Query
    )

    $ErrorActionPreference = 'Stop'

    $UserId = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().Password

    $DatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
    $DatabaseConnection.ConnectionString = "Server = $Url; Database = $Name; User ID = $UserId; Password = $Password;"
    try{
        $DatabaseConnection.Open();
    } catch [System.Management.Automation.MethodInvocationException] {
        Write-Error -Message $($_.Exception.Message)
    }
    $DatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
    $DatabaseCommand.Connection = $DatabaseConnection
    $DatabaseCommand.CommandText = $Query

    try {
        $DbResult = $DatabaseCommand.ExecuteReader()
    } catch [System.Management.Automation.MethodInvocationException] {
        Write-Error -Message $($_.Exception.Message)
    }
    $Table = New-Object -TypeName System.Data.DataTable
    $Table.Load($DbResult)
    $Table

    $DatabaseConnection.Close()
}