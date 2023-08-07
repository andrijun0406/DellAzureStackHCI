# Run from Management Host
# Update the Hostnames accordingly

$Servers="AX750-N1","AX750-N2","AX750-N3"

Install-PackageProvider -Name NuGet -Force
Install-Module -Name AzStackHci.EnvironmentChecker -Force -AllowClobber

$PSSessions=New-PSSession -ComputerName $Servers -Credential (Get-Credential)
Invoke-AzStackHciConnectivityValidation -PsSession $PSSessions
