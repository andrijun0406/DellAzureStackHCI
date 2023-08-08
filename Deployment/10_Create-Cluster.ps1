# Change variables here

$Servers="AX750-N1","AX750-N2","AX750-N3"
$ClusterName="AZSG-HCI-CLS01"
$ClusterIP="172.22.129.20"

# Disable USBNic adapter first
if ((Get-CimInstance -ClassName win32_computersystem -CimSession $Servers[0]).Manufacturer -like "*Dell*"){
    #Disable USB NIC used by iDRAC to communicate to host just for test-cluster
    Disable-NetAdapter -CimSession $Servers -InterfaceDescription "Remote NDIS Compatible Device" -Confirm:0
}

New-Cluster -Name $ClusterName -Node $servers -StaticAddress $ClusterIP

Start-Sleep 5
Clear-DnsClientCache

if ((Get-CimInstance -ClassName win32_computersystem -CimSession $Servers[0]).Manufacturer -like "*Dell*"){
    #Enable USB NIC used by iDRAC
    Enable-NetAdapter -CimSession $Servers -InterfaceDescription "Remote NDIS Compatible Device"
}