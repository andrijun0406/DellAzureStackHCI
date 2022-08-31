#define and install features

# Fill in these variables with your values
# ensures that your cluster nodes have been joined domain and has an FQDN already registered in DNS. For large organization it could take a while for the record to be propagated
# use IP address instead of hostname.
#$ServerList = "hcinprdhst001", "hcinprdhst002", "hcinprdhst003", "hcinprdhst004"
$ServerList = "10.189.192.62", "10.189.192.63", "10.189.192.64", "10.189.192.65"
$FeatureList = "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica"

# This part runs the Install-WindowsFeature cmdlet on all servers in $ServerList, passing the list of features in $FeatureList.
Invoke-Command ($ServerList) {
    Install-WindowsFeature -Name $Using:Featurelist -IncludeAllSubFeature -IncludeManagementTools
}

#restart and wait for computers
Restart-Computer $ServerList -Protocol WSMan -Wait -For PowerShell -Force
Start-Sleep 20 #Failsafe as Hyper-V needs 2 reboots and sometimes it happens, that during the first reboot the restart-computer evaluates the machine is up

#make sure computers are restarted
Foreach ($Server in $ServerList){
    do{$Test= Test-NetConnection -ComputerName $Server -CommonTCPPort WINRM}while ($test.TcpTestSucceeded -eq $False)
}

