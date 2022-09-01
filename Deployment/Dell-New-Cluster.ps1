# Command to create the cluster
# at this point make sure the DNS already propagated and all the nodes are reachable using hostname

$ServerList = "HCINPRDHST001", "HCINPRDHST002", "HCINPRDHST003", "HCINPRDHST004"
$ClusterName = "HCINPRDCLU001"
$ClusterIPAddress ="10.189.192.66"
New-Cluster -Name $ClusterName -Node $ServerList -StaticAddress $ClusterIPAddress -NoStorage -Verbose
