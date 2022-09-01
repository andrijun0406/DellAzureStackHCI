#define variables
$ClusterName="HCINPRDCLU001""
$Stornet1="192.168.101."
$Stornet2="192.168.102."

# Rename Cluster Network for easier management

(Get-ClusterNetwork -Cluster $clustername | Where-Object Address -eq $StorNet1"0").Name="SMB01"
(Get-ClusterNetwork -Cluster $clustername | Where-Object Address -eq $StorNet2"0").Name="SMB02"¨
(Get-ClusterNetwork -Cluster $clustername | Where-Object Role -eq "ClusterAndClient").Name="Management"

# Configuring the host management network as a lower-priority network for live migration

Get-ClusterResourceType -Cluster $clustername -Name "Virtual Machine" | Set-ClusterParameter -Name MigrationExcludeNetworks -Value ([String]::Join(";",(Get-ClusterNetwork -Cluster $clustername | Where-Object {$_.Role -ne "Cluster"}).ID))
Set-VMHost -VirtualMachineMigrationPerformanceOption SMB -cimsession $servers

$clusterResourceType = Get-ClusterResourceType -Name 'Virtual Machine'
$hostNetworkID1 = Get-ClusterNetwork | Where-Object { $_.Name -eq "SMB01"} | Select-Object -ExpandProperty ID
$hostNetworkID2 = Get-ClusterNetwork | Where-Object { $_.Name -eq "SMB02" } | Select-Object -ExpandProperty ID

$newMigrationOrder = ([String]::Join(";",$hostNetworkID1,$hostNetworkID2))
Set-ClusterParameter -InputObject $clusterResourceType -Name MigrationNetworkOrder -Value $newMigrationOrder
