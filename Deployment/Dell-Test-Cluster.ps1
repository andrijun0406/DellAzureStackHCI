$ServerList = "HCINPRDHST001", "HCINPRDHST002", "HCINPRDHST003", "HCINPRDHST004"

#Disable USB NIC used by iDRAC to communicate to host just for test-cluster (only applies to physical servers)
$USBNics=get-netadapter -CimSession $ServerList -InterfaceDescription "Remote NDIS Compatible Device" -ErrorAction Ignore
if ($USBNics){
    Disable-NetAdapter -CimSession $ServerList -InterfaceDescription "Remote NDIS Compatible Device" -Confirm:0
}

#Test cluster first
Test-Cluster -Node $ServerList -Include "Storage Spaces Direct","Inventory","Network","System Configuration","Hyper-V Configuration"

#Enable USB NICs again
if ($USBNics){
    Enable-NetAdapter -CimSession $Servers -InterfaceDescription "Remote NDIS Compatible Device" -Confirm:0
}
