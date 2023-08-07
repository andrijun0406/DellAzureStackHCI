# Run this script from management host
# Change servers parameters here
$servers="AX750-N1","AX750-N2","AX750-N3"

if ((Get-CimInstance -ClassName win32_computersystem -CimSession $Servers[0]).Manufacturer -like "*Dell*"){
    #Disable USB NIC used by iDRAC to communicate to host just for test-cluster
    Disable-NetAdapter -CimSession $Servers -InterfaceDescription "Remote NDIS Compatible Device" -Confirm:0
}

Test-Cluster -Node $servers -Include "Storage Spaces Direct","Inventory","Network","System Configuration","Hyper-V Configuration"

if ((Get-CimInstance -ClassName win32_computersystem -CimSession $Servers[0]).Manufacturer -like "*Dell*"){
    #Enable USB NIC used by iDRAC
    Enable-NetAdapter -CimSession $Servers -InterfaceDescription "Remote NDIS Compatible Device"
}