#at this stage, servers can not resolved to DNS yet so use IP address as Computer Name
#also use local administrator to connect.
#adjust the following parameter accordingly and run below command per remote powershell cli windows
#if you running this from management or Windows Admin Centre (WAC) hosts then you need to setup WinRM TrustedHost manually first as the following

$server1 = "10.189.192.62"
$server2 = "10.189.192.63"
$server3 = "10.189.192.64"
$server4 = "10.189.192.65"

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $server1 -Force
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $server2 -Force
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $server3 -Force
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $server4 -Force

#view TrustedHost List:
Get-Item WSMAN:\Localhost\Client\TrustedHosts

#after joined domain clear the list and use kerberos or Group Policy CredSSP
#Clear-Item WSMAN:\Localhost\Client\TrustedHost

# enter remote powershell command in each Powershell cli windows
$user="$server1\Administrator"
Enter-PSSession -ComputerName $server1 -Credential $user

# enter remote powershell command in each Powershell cli windows
#$user="$server2\Administrator"
#Enter-PSSession -ComputerName $server2 -Credential $user

# enter remote powershell command in each Powershell cli windows
#$user="$server3\Administrator"
#Enter-PSSession -ComputerName $server3 -Credential $user

# enter remote powershell command in each Powershell cli windows
#$user="$server4\Administrator"
#Enter-PSSession -ComputerName $server4 -Credential $user

#Run the following command after successfully enter a remote powershell session
Add-Computer -DomainName "contoso.com" -Credential "Contoso\ADAdmin" -OUPath "<DN>" -Restart -Force
Add-LocalGroupMember -Group "Administrators" -Member "king@contoso.local"
