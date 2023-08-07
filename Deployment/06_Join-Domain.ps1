# Run the following command from each of the nodes in PowerShell
function Join-Domain
{
    param (
        [string]$title = 'Enter Domain Parameter here:'
    )
    Clear-Host
    Write-Host "==================== $title ===================="
    
    $credential = Get-Credential
    $domainname = Read-Host "Domain Name (FQDN, e.g. contoso.com)"
    $oupath = Read-Host "OU Path (e.g. OU=AZHCI,DC=CONTOSO,DC=COM)" 
    $newname = Read-Host "New Host Name (e.g. AxNode1)"

    Add-Computer -DomainName $domainname -OUPath $oupath -NewName $newname -Credential $credential -Restart -Force
}
Join-Domain
