<#
.SYNOPSIS
    Gets list of all possible Azure VM image Publishers, Offers and Skus
.EXAMPLE
    PS C:\> Get-AzureRmVmImageSetting.ps1 -Location "West Europe"
    Gets Azure VM image settings for location West Europe
.NOTES
    Small helper script that assumes that you are already logged in using Login-AzureRmAccount.
    Omitted error handling on purpose.
#>
function Get-AzureRmVmImageSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $Location
    )

    process {
        $publishers = (Get-AzureRmVMImagePublisher -Location $location).PublisherName
        
        $offers = $publishers | ForEach-Object {
            $publisher = $_
            Write-Verbose -Message "Processing publisher: $publisher"
            Get-AzureRmVMImageOffer -PublisherName $publisher -Location $location
        }    
        
        $skus = $offers | ForEach-Object {
            $offer = $_
            Write-Verbose -Message "Processing offer: $($offer.Offer)"
            Get-AzureRmVMImageSku -PublisherName $offer.PublisherName -Offer $offer.Offer -Location $location
        }

        $outputProperties = @{
            Publishers = $publishers
            Offers = $offers.Offer
            Skus = $skus.Skus
        }
        $output = New-Object -TypeName psobject -Property $outputProperties
        
        $output        
    }
}