# Deployment and Management PowerShell Scripts Compilation

This script is applicable to:
1. Azure Stack HCI Operating System, version 20H2 and 21H2
2. Dell Integrated System for Azure Stack HCI Hardware delivered from Dell (a.k.a AX nodes)
3. Scalable network options with RDMA capable TOR switches using Dell Switches and Non-Converged Network (separate Storage traffic and VM/Management Traffic)
4. The sequence of the script is following [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/)

## Deployment Prerequisite
1. AX nodes and TOR switches are racked and stacked and powered-on according to the deployment worksheet
2. Active Directory are in-place with users setup as Admin and Local Admin in each of cluster nodes
3. DNS are in-place and FQDN are resolved for related IP address configured

## PreDeployment Configuration

Task 01 - Configuring iDRAC and BIOS
* AX nodes are pre-installed with HCI OS and an optimized BIOS and iDRAC settings, however after racked and stacked and connected to TOR switch and OOB switch, if the OOB network in the environment does not provide DHCP IP addresses for iDRAC, you must manually set a static IPv4 address on each iDRAC network interface. You can access the physical server console to set the addresses by using KVM or other means.
* Perform the following steps to configure iDRAC IPv4 addresses in each hosts:
  1. During the system boot, press F12.
  2. At System Setup Main Menu, select iDRAC Settings.
  3. Under iDRAC Settings, select Network.
  4. Under IPV4 SETTINGS, at Enable IPv4, select Enabled.
  5. Enter the static IPv4 address details.
  6. Click Back, and then click Finish.

* Reference: [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/)

[Task 01 - Configuring Network Switches](SwitchDellRoce.conf)
* Config should be imported per TOR switches (TOR switch A and B)
* Reference: [ Dell Switch ROCE configurations ](https://infohub.delltechnologies.com/t/reference-guide-switch-configurations-roce-only-mellanox-cards/)

[Task 02 - Non-Converged Host Network Configuration](Set-DellHostNetwork.ps1)
* Script should be executed per Host
* Sample of Physical Network Adapter in AX-750 mapping (adjust per customer requirement):

| Name                      | InterfaceDescription                    | ifIndex | Status       | IP Address (sample)  | Vlan (sample) | Purpose                     |
| ------------------------- | --------------------------------------- | ------- | ------------ | -------------------- | ------------- | --------------------------- |
| Slot 3 Port 1             | Mellanox ConnectX-5 adapter #3          | 17      | Up           | 192.168.101.11/24    | 101           | S2D Traffic (RDMA/Jumbo)    | 
| Slot 3 Port 2             | Mellanox ConnectX-5 adapter #4          | 8       | Up           | 192.168.102.11/24    | 102           | S2D Traffic (RDMA/Jumbo)    |
| Integrated NIC 1 Port 1-1 | Broadcom NetXtreme E-Series Advanced    | 11      | Up           | N/A                  | N/A           | Data and Management Traffic |
| Integrated NIC 1 Port 2-1 | Broadcom NetXtreme E-Series Advanced #2 | 10      | Up           | N/A                  | N/A           | Data and Management Traffic |
| vEthernet (Management)    | Hyper-V Virtual Ethernet Adapter        | 14      | Up           | 10.189.192.62/24     | Untagged      | vNIC for Data/Management    |
| Slot 6 Port 1             | Mellanox ConnectX-5 adapter             | 2       | Disconnected | N/A                  | N/A           | Backup Traffic (Not Used)   |
| Slot 6 port 2             | Mellanox ConnectX-5 adapter #2          | 9       | Disconnected | N/A                  | N/A           | Backup Traffic (Not Used)   |
| Embedded NIC 1            | Broadcom NetXtrem Gigabit Ethernet #2   | 7       | Disconnected | N/A                  | N/A           | Backup Traffic (Not Used)   |
| Embedded NIC 2            | Broadcom NetXtrem Gigabit Ethernet      | 3       | Disconnected | N/A                  | N/A           | Backup Traffic (Not Used)   |

* The following Diagram illustrates the Host Network architecture for Scalable Non-Converged design:
![Scalable Non-Converged](scalable-non-converged.png)

* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

[Task 03 - Update Network Adapter Advanced Properties](Set-DellNetAdapterAdvancedProperty.ps1)
* Script should be executed per Host
* Script will configure based on Network Adapter Type (QLogic will use iWARP, Mellanox will use ROCEv2)
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

[Task 04 - Enable RDMA on Storage Adapters](Enable-DellNetAdapterRdma.ps1)
* Script should be executed per Host
* Only Storage Adapters will be RDMA enabled
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

[Task 05 - Configure DCB and QoS on each of the Hosts - for RDMA ROCEv2 only](Set-DellNetQos.ps1)
* Script should be executed per Host
* DCB and QoS must be set on TOR switches and the Hosts as the following tables:

| QoS Priority  | QoS Flow Control | % Bandwidth | Purpose                  |
| ------------- | ---------------- | ----------- | ------------------------ |
| 0-2,4,6,7     | Disabled         | N/A         | 0 - Best effort traffic  |
| 3             | Enabled          | 50          | SMB/RDMA                 |
| 5             | Disabled         | 2           | Cluster Network          |

* Manually disable DCB on the management adapters using the command Disable-NetAdapterQos <nicName>.
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)
  
[Task 06 - Enable Jumbo Frame](Set-JumboFrame.ps1)
* Script should be executed per Host
* Only Storage Adapters will be set with Jumbo Frame
* Reference: [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/)
