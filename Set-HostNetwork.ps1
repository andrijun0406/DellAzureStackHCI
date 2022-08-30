$ErrorActionPreference = 'Stop'

#region Variables for the scenario

## Optional bandwidth shaping parameters. Change the values to suit your environment

$defaultFlowMinimumBandwidthWeight = 50
$backupBandwidthWeight = 40
$managementBandwidthWeight = 10

## Backup Adapter (Optional)
#$backupAdapterName = 'Backup'
#$backupNetAdapterName = @('SLOT 6 PORT 1', 'SLOT 6 PORT 2') # should be disabled if not used
#$backupNetAdapterName = @('Embedded NIC 1', 'Embedded NIC 2') # should be disabled if not used

# VLAN ID for backup traffic; if no VLAN is preferred set this to 0
#$backupVlanId = 100

# Set this to a string 'DHCP' for a dynamic IP address - Input per Host if static
#$backupIPAddress = '172.16.105.51'

# Backup network address prefix (24 translates to subnet mask 255.255.255.0)
#$backupAddressPrefix = 24

## Management Adapter
$ManagementSwitchName = 'Management'
$ManagementNetAdapterName = @('Integrated NIC 1 Port 1-1','Integrated NIC 1 Port 2-1')
$ManagementAdapterName = 'Management'

# VLAN ID for host management traffic; if no VLAN is preferred set this to 0
$ManagementVlanId = 0

# Management Gateway address
$ManagementGateway = '10.189.192.1'

# DNS Server Address
$ManagementDns = '10.189.217.2'

# Set this to a string 'DHCP' for a dynamic IP address - Input IP Address per Host if static
$ManagementIPAddress = '10.189.192.62'
#$ManagementIPAddress = '10.189.192.63'
#$ManagementIPAddress = '10.189.192.64'
#$ManagementIPAddress = '10.189.192.65'

# Management address prefix (24 translates to subnet mask 255.255.255.0)
$ManagementAddressPrefix = 24

## Storage Adapters
### You must specify 2 or 4 network adapter port names
$StorageNetAdapterName = @('SLOT 3 PORT 1', 'SLOT 3 PORT 2')

### You must specify 1 or 2 or 4 VLANIDs
### Specify 0 if you want the network not tagged with any VLAN
$StorageVlanId = @(101, 102)

### You must specify 2 or 4 IP Addresses
### DHCP as a value is accepted if you want dynamically assigned IP addresses - Input IP address per host if static
$StorageIPAddress = @('192.168.101.11', '192.168.102.11')
#$StorageIPAddress = @('192.168.101.12', '192.168.102.12')
#$StorageIPAddress = @('192.168.101.13', '192.168.102.13')
#$StorageIPAddress = @('192.168.101.14', '192.168.102.14')
### You can specify 1 or 2 or 4 prefix length values (24 translates to subnet mask 255.255.255.0)
$StorageAddressPrefix = @(24)

#endregion

## Create a VM switch for management
$null = New-VMSwitch -Name $ManagementSwitchName -AllowManagementOS 0 -NetAdapterName $ManagementNetAdapterName -MinimumBandwidthMode Weight -Verbose

## Add VM Network Adapters and configure VLANs and IP addresses as needed
### Configure Management Adapter
$managementAdapter = Add-VMNetworkAdapter -SwitchName $ManagementSwitchName -ManagementOS -Passthru -Name $ManagementAdapterName -Verbose
if ($ManagementVlanId -and ($ManagementVlanId -ne 0))
{
 # Set VM Network adapter VLAN only if the VLAN ID specified is other than 0
 Set-VMNetworkAdapterVlan -VMNetworkAdapter $managementAdapter -Access -VlanId $ManagementVlanId -Verbose
 Start-Sleep -Seconds 5
}
if ($ManagementIPAddress -ne 'DHCP')
{
 $null = New-NetIPAddress -InterfaceAlias "vEthernet ($ManagementAdapterName)" -IPAddress $ManagementIPAddress -DefaultGateway $ManagementGateway -PrefixLength $ManagementAddressPrefix -Verbose
 Set-DnsClientServerAddress -InterfaceAlias "vEthernet ($ManagementAdapterName)" -ServerAddresses $ManagementDns -Verbose
}

### Configure Backup Adapter (Optional)
#$backupAdapter = Add-VMNetworkAdapter -SwitchName $ManagementSwitchName -ManagementOS -Passthru -Name $backupAdapterName -Verbose
#if ($backupVlanId -and ($backupVlanId -ne 0))
#{
 # Set VM Network adapter VLAN only if the VLAN ID specified is other than 0
# Set-VMNetworkAdapterVlan -VMNetworkAdapter $backupAdapter -Access -VlanId
#$backupVlanId -Verbose
# Start-Sleep -Seconds 5
#}
#if ($backupIPAddress -ne 'DHCP')
#{
# $null = New-NetIPAddress -InterfaceAlias "vEthernet ($backupAdapterName)" -IPAddress
#$backupIPAddress -PrefixLength $backupAddressPrefix -Verbose
#}

### Management and backup adapter optional configuration
#Set-VMNetworkAdapter -ManagementOS -Name $ManagementAdapterName -MinimumBandwidthWeight
#$managementBandwidthWeight
#Set-VMNetworkAdapter -ManagementOS -Name $ManagementAdapterName -MinimumBandwidthWeight
#$backupBandwidthWeight
#Set-VMSwitch -Name $ManagementSwitchName -DefaultFlowMinimumBandwidthWeight
#$defaultFlowMinimumBandwidthWeight

### Configure storage adapters
for ($i = 0; $i -lt $StorageNetAdapterName.Count; $i++)
{
 # if there is a single VLAN for storage use the first and only element
 if ($storageVlanId.Count -eq 1)
 {
 $storageVlan = $storageVlanId[0]
 }
 else
 {
 # else use the right index to get the VLAN ID
 $storageVlan = $storageVlanId[$i]
 }
 # Check if only one prefix is provided
 if ($StorageAddressPrefix.Count -eq 1)
 {
 $StoragePrefix = $StorageAddressPrefix[0]
 }
 else
 {
 # if more than one, use the right index to get the address prefix
 $StoragePrefix = $StorageAddressPrefix[$i]
 }
 if ($storageVlan -and ($storageVlan -ne 0))
 {
 # Set VM Network adapter VLAN only if the VLAN ID specified is other than 0
 Set-NetAdapterAdvancedProperty -Name $StorageNetAdapterName[$i] -DisplayName 'VLAN ID' -DisplayValue $storageVlan -Verbose
 Start-Sleep -Seconds 5
 }
 if ($StorageIPAddress[$i] -ne 'DHCP')
 {
 $null = New-NetIPAddress -InterfaceAlias $StorageNetAdapterName[$i] -IPAddress $StorageIPAddress[$i] -PrefixLength $StoragePrefix -Verbose
 }
}
