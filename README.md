# Deployment and Management PowerShell Scripts Compilation

This script is applicable to:
1. Azure Stack HCI Operating System, version 20H2 and 21H2
2. Dell Integrated System for Azure Stack HCI Hardware delivered from Dell (a.k.a AX nodes)
3. Scalable network options with RDMA capable TOR switches using Dell Switches and Non-Converged Network (separate Storage traffic and VM/Management Traffic)

# Deployment Prerequisite
1. Active Directory are in-place with users setup as Admin and Local Admin in each of cluster nodes
2. DNS are in-place and FQDN are resolved for related IP address configured

[Task 01 - Configuring Network Switches](SwitchDellRoce.conf)
* Config should be imported per TOR switches (TOR switch A and B)
* Reference: [ Dell Switch ROCE configurations ](https://infohub.delltechnologies.com/t/reference-guide-switch-configurations-roce-only-mellanox-cards/)

[Task 02 - Non-Converged Host Network Configuration](Set-DellHostNetwork.ps1)
* Script should be executed per Host
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

[Task 03 - Update Network Adapter Advanced Properties](Set-DellNetAdapterAdvancedProperty.ps1)
* Script should be executed per Host
* Script will configure based on Network Adapter Type (QLogic will use iWARP, Mellanox will use ROCEv2)
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

[Task 04 - Enable RDMA on Storage Adapters](Enable-DellNetAdapterRdma.ps1)
* Script should be executed per Host
* Only Storage Adapters will be RDMA enabled
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)

[Task 05 - Configure DCB and QoS on each of the Hosts - for RDMA ROCEv2 only](Enable-DellNetAdapterRdma.ps1)
* Script should be executed per Host
* DCB and QoS must be set on TOR switches and the Hosts as the following tables

| QoS Priority  | QoS Flow Control | Purpose                  |
| ------------- | ---------------- | ------------------------ |
| 0-2,4,6,7     | Disabled         | 0 - Best effort traffic  |
| 3             | Enabled          | RDMA                     |
| 5             | Disabled         | Cluster Network          |

* Manually disable DCB on the management adapters using the command Disable-NetAdapterQos <nicName>.
* Reference: [ Host Network Configuration ](https://infohub.delltechnologies.com/t/reference-guide-network-integration-and-host-network-configuration-options-1/)
