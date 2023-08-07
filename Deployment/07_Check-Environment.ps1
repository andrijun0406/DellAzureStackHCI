$Servers="AX750-N1","AX750-N2","AX750-N3"

#region validate servers connectivity with Azure Stack HCI Environment Checker https://www.powershellgallery.com/packages/AzStackHci.EnvironmentChecker
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name AzStackHci.EnvironmentChecker -Force -AllowClobber

    $PSSessions=New-PSSession -ComputerName $Servers -Credential (Get-Credential)
    Invoke-AzStackHciConnectivityValidation -PsSession $PSSessions