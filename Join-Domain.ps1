#at this stage, servers can not resolved to DNS yet so use IP address as Computer Name
#also use local administrator to connect.
#adjust the following parameter accordingly and run below command per remote powershell cli windows

$server1 = "10.189.192.62"
$server2 = "10.189.192.63"
$server3 = "10.189.192.64"
$server4 = "10.189.192.65"


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

#Add-Computer -NewName "hcinprdhst001" -DomainName "contoso.com" -Credential "Contoso\ADAdmin" -Restart -Force
#Add-LocalGroupMember -Group "Administrators" -Member "king@contoso.local"
