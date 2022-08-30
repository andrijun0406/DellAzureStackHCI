# Variables for the scenario
$StorageAdapters = @('SLOT 3 PORT 1', 'SLOT 3 PORT 2')

#New QoS policy with a match condition set to 445 (TCP Port 445 is dedicated for SMB)
#Arguments 3 and 5 to the PriorityValue8021Action parameter indicate the IEEE 802.1p
#values for SMB and cluster traffic.
New-NetQosPolicy -Name 'SMB' –NetDirectPortMatchCondition 445 –PriorityValue8021Action 3
New-NetQosPolicy 'Cluster' -Cluster -PriorityValue8021Action 5

#Map the IEEE 802.1p priority enabled in the system to a traffic class
#Customer may change the bandwidth for the below traffic class based on their environments
New-NetQosTrafficClass -Name 'SMB' –Priority 3 –BandwidthPercentage 50 –Algorithm ETS
New-NetQosTrafficClass -Name 'Cluster' –Priority 5 –BandwidthPercentage 2 –Algorithm ETS

#Configure flow control for the priorities shown in the above table
Enable-NetQosFlowControl –Priority 3
Disable-NetQosFlowControl –Priority 0-2,4-7

#Enable QoS for the Mellanox network adapter ports.
foreach ($port in $StorageAdapters) {
  Enable-NetAdapterQos –InterfaceAlias $port
}

#Disable DCBX Willing mode
Set-NetQosDcbxSetting -Willing $false

#Enable IEEE Priority Tag on all network interfaces to ensure the vSwitch does not drop
the VLAN tag information.
$nics = Get-VMNetworkAdapter -ManagementOS
foreach ($nic in $nics) {
  Set-VMNetworkAdapter -VMNetworkAdapter $nic -IeeePriorityTag ON
}
