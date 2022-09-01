$Servers = "HCINPRDHST001", "HCINPRDHST002", "HCINPRDHST003", "HCINPRDHST004"
$ClusterName = "HCINPRDCLU001"

#Rename and Configure USB NICs
$USBNics=get-netadapter -CimSession $Servers -InterfaceDescription "Remote NDIS Compatible Device" -ErrorAction Ignore
if ($USBNics){
    $Network=(Get-ClusterNetworkInterface -Cluster $ClusterName | Where-Object Adapter -eq "Remote NDIS Compatible Device").Network | Select-Object -Unique
    $Network.Name="iDRAC"
    $Network.Role="none"
}
