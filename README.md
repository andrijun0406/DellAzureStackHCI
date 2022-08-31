# Deployment and Management PowerShell Scripts Compilation

This script is applicable to:
1. Azure Stack HCI Operating System, version 20H2 and 21H2
2. Dell Integrated System for Azure Stack HCI Hardware delivered from Dell (a.k.a AX nodes)
3. Scalable network options with RDMA capable TOR switches using Dell Switches and Non-Converged Network (separate Storage traffic and VM/Management Traffic)
4. The sequence of the script is following [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/), but adjusted to the following condition which may occur in customer environment:
    * Uplink to internet and management network are not up yet or will only be up after all the deployment prerequisite are done
    * Proxy and Firewall policy are in place in customer environment

## Deployment Prerequisite
1. AX nodes and TOR switches are racked and stacked and powered-on according to the deployment worksheet
2. Active Directory are in-place with users setup as Admin and **Local Administrator Group** in each of cluster nodes
3. Best practice is to create a new OU and setup rights to create new objects inside the OU.
3. DNS are in-place and FQDN are resolved for related IP address configured
4. Download [ISO image](Deployment-Script-.iso) which consists all the scripts provided in this repo and mount as virtual media, copy the script into C:\Script and run all the script one by one following the task below.

## PreDeployment Configuration

### Task 01 - Configuring iDRAC and BIOS
* AX nodes are pre-installed with HCI OS and an optimized BIOS and iDRAC settings, however after racked and stacked and connected to TOR switch and OOB switch, if the OOB network in the environment does not provide DHCP IP addresses for iDRAC, you must manually set a static IPv4 address on each iDRAC network interface. You can access the physical server console to set the addresses by using KVM or other means.
* Perform the following steps to configure iDRAC IPv4 addresses in each hosts:
1. During the system boot, press F12.
2. At **System Setup Main Menu**, select **iDRAC Settings**.
3. Under **iDRAC Settings**, select **Network**.
4. Under **IPV4 SETTINGS**, at **Enable IPv4**, select **Enabled**.
5. Enter the static IPv4 address details.
6. Click **Back**, and then click **Finish**.

* Reference: [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/)

### Task 02 - Verifying Pre-installed OS and firmware/bios/driver compliance against Support Matrix
* Most of the time the pre-installed OS and firmware/bios/driver has been installed with up to date release, but to make sure please check again here before we connect to uplink network.
* Run the [Get-DellComputerInfo](Get-DellComputerInfo.ps1) script to check installed OS and it's version.
* The result of the script will look like this:
![Check OS version](Check-OSversion.png)
* Run the [Get-DellDeviceDriver](Get-DellDeviceDriver.ps1) script to check installed drivers and firmware and check with latest [Support Matrix](https://www.dell.com/support/kbdoc/en-us/000126014/support-matrix-for-dell-emc-solutions-for-microsoft-azure-stack-hci)
* The result of the script will look like this:
![Check Driver Result](Check-Driver.png)
* Download firmware and BIOS from ... and update using iDRAC with the following guide: [ How to Update Firmware using iDRAC](https://www.dell.com/support/kbdoc/en-us/000134013/dell-poweredge-update-the-firmware-of-single-system-components-remotely-using-the-idrac#:~:text=Update%20Firmware%20Using%20iDRAC9&text=Go%20to%20Maintenance%20%3E%20System%20Update,Local%20as%20the%20Location%20Type.&text=Click%20Browse%2C%20select%20the%20firmware,component%2C%20and%20then%20click%20Upload.).
* Download the driver from .. and update them.
* Reference: [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/)

### [Task 03 - Configuring Network Switches](SwitchDellRoce.conf)
* Config should be imported per TOR switches (TOR switch A and B)
* Reference: [ Dell Switch ROCE configurations ](https://infohub.delltechnologies.com/t/reference-guide-switch-configurations-roce-only-mellanox-cards/)

### Task 04 - Changing Hostname

### [Task 05 - Non-Converged Host Network Configuration](Set-DellHostNetwork.ps1)
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

### [Task 06 - Update Network Adapter Advanced Properties](Set-DellNetAdapterAdvancedProperty.ps1)
* Script should be executed per Host
* Script will configure based on Network Adapter Type (QLogic will use iWARP, Mellanox will use ROCEv2)
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

### [Task 07 - Enable RDMA on Storage Adapters](Enable-DellNetAdapterRdma.ps1)
* Script should be executed per Host
* Only Storage Adapters will be RDMA enabled
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

### [Task 08 - Configure DCB and QoS on each of the Hosts - for RDMA ROCEv2 only](Set-DellNetQos.ps1)
* Script should be executed per Host
* DCB and QoS must be set on TOR switches and the Hosts as the following tables:

| QoS Priority  | QoS Flow Control | % Bandwidth | Purpose                  |
| ------------- | ---------------- | ----------- | ------------------------ |
| 0-2,4,6,7     | Disabled         | N/A         | 0 - Best effort traffic  |
| 3             | Enabled          | 50          | SMB/RDMA                 |
| 5             | Disabled         | 2           | Cluster Network          |

* Manually disable DCB on the management adapters using the command Disable-NetAdapterQos <nicName>.
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)
  
### [Task 09 - Enable Jumbo Frame](Set-JumboFrame.ps1)
* Script should be executed per Host
* Only Storage Adapters will be set with Jumbo Frame
* Reference: [ HCI Deployment Guide ](https://infohub.delltechnologies.com/t/hci-deployment-guide-microsoft-hci-solutions-from-dell-technologies-1/)
   
### Task 10 - Validate RDMA
* Run the [Test RDMA Script](Test-Rdma.ps1) with the following examples:
```powershell
# Get Interface Index for Storage Adapter
Get-NetAdapter -Name 'Slot 3 Port*'
C:\Script\Test-Rdma.ps1 -ifIndex 17 -IsRoCE $true -RemoteIpAddress 192.168.101.12 -PathToDiskspd C:\Script\
```
The result will look like the following:
![Test-RDMA-Result](Test-RDMA-Result.png)
* Reference: [How to Configure Guest RDMA on Windows Server 2019](https://www.dell.com/support/kbdoc/en-ie/000113009/how-to-configure-guest-rdma-on-windows-server-2019#:~:text=Test%20RDMA%20communication%20between%20the,DCB%20settings%20on%20the%20host.)

### Task 11 - Setup Proxy on Cluster Nodes to connect to internet (optional depending on your environment)
   
## Deploy Azure Stack HCI Cluster with PowerShell
   At this stage your network is already configured and firmware/driver/BIOS already at the latest, you are ready now to open your uplink network and connect your cluster nodes to WAC hosts and AD/DNS
### Task 01 - Installing Roles and Features
### Task 02 - Joining Cluster Nodes to an Active Directory Domain
### Task 03 - Deploying and Configuring Cluster
### Task 04 - Enabling Storage Spaces Direct
### Task 05 - Optimization Tasks
### Task 06 - Configuring Cluster Witness
### Task 07 - Register the Cluster and onboarding Arc
