# Hardware User Acceptance Test (UAT) PowerShell Scripts Compilation

## System Under Test (SUT)
* CLuster with 4 x Dell AX-750 node with the following specs:
* CPU  : 2 x Intel Xeon Gold 5318Y (2.1Ghz 24C)
* RAM  : 16 x 64GB (1,024 GB)
* Disk : 10 x 3.84TB SSD vSAS MU 3 DWPD
* NIC  : 1 x OCP3 Broadcom Dual Port 10/25GbE, 2 x PCIe Mellanox ConnectX-5 Dual Port 10/25GbE 

## Hardware Performance Test
### Testing Method - run VMFleet
* [VMFleet](https://github.com/microsoft/diskspd/tree/master/Frameworks/VMFleet) is a stress-test tool which are used alot by many Microsoft customers and partners to evaluate performance of their Azure Stack HCI clusters
* VMFleet consists of a set of PowerShell scripts that deploy VMs to a Hyper-V cluster and executes Microsoft's [ **DISKSPD** ](https://docs.microsoft.com/en-us/azure-stack/hci/manage/diskspd-overview) within those VMs to generate I/O.
* DISKSPD is very helpful for creating syntethic workloads to test an application's resource utilization before going into production.
* VMFleet test are run with the following schemes:
  * Healthy cluster running 64 VMs per node for total 256 VMs in a cluster of 4 x AX nodes.
  * Healthy cluster running 32 VMs per node for total 128 VMs in a cluster of 4 x AX nodes.

* The following table presents the range of VMFleet and DISKSPD parameters used:
  
| VMFleet and DISKSPD parameters | Values                                  | 
| ------------------------------ | --------------------------------------- | 
| Number of VMs per Node         | 64                                      | 
| vCPUs per VM                   | 2                                       | 
| Memory per VM                  | 4 GB                                    | 
| VHDX size per VM               | 40 GB                                   | 
| VM Operating System            | Windows Server 2022                     | 
| Data file used in DISKSPD      | 10 GB                                   |
| CSV in-memory Read Cache       | 0                                       | 
| Block Sizes                    | 4 - 512 KB                              | 
| Thread counts                  | 1 - 2                                   |
| Outstanding I/Os               | 2 - 32                                  |   
| Write percentages              | 0 - 100                                 |
| I/O patterns                   | Random, Sequential                      |
   

## Hardware Failure Test (Understanding VMs availability behaviour)
### Testing Method - run one VMs in each node and see it's behaviour. Note that those VMs are using Management Network (the same network as Hosts, and WAC)

| VMs                            | Hosted in               |  Volume reside  | Network    |
| ------------------------------ | ------------------------| --------------- | ---------- | 
| testvm01                       | hcinprdhst001           |  Volume01       | Management |
| testvm02                       | hcinprdhst002           |  Volume01       | Management |
| testvm03                       | hcinprdhst003           |  Volume01       | Management |
| testvm04                       | hcinprdhst004           |  Volume01       | Management |

### Scenario 01 - Shutdown one node in a four node cluster
#### Steps:
  * Ping the target VM from management hosts (e.g. testvm01)
  * Go to iDRAC Web Console and do Power Off System on the host where the target VM resides (e.g. hcinprdhst001)
  * Observe the ping result from management hosts command line
  * Observe target VM movement from Windows Admin Center
  * Check uptime of the VM once it is restarted to other host
  * Check Storage Repair Job
#### Expected Result:
  * Target VM can still be ping'ed (several timeout is expected)
  * Target VM will be restarted to another available hosts
  * Cluster still online, Volume01 will be in repair state
  * Once Volume01 is healthy, Power On again the shutdown'ed host
  * Once the host is up and joined again in the cluster, live migrate back target VM to its previous host

### Scenario 02 - Shutdown two node at once in a four node cluster at once
#### Steps:
  * Ping the target VMs from management hosts (e.g. testvm01 and testvm02)
  * Go to iDRAC Web Console and do Power Off Systems on the hosts where the target VMs reside at once (e.g. hcinprdhst001 and hcinprdhst001)
  * Observe the ping result from management hosts command line
  * Observe target VMs movement from Windows Admin Center
  * Check uptime of the VMs once it is restarted to other remaining hosts
  * Check Storage Repair Job
#### Expected Result:
  * Target VMs can still be ping'ed (several timeout is expected)
  * Target VMs will be restarted to another available hosts
  * Cluster still online, Volume01 will be in repair state
  * Once Volume01 is healthy, Power On again the shutdown'ed hosts
  * Once the two hosts are up and joined again in the cluster, live migrate back target VMs to its previous hosts
  
### Scenario 03 - Shutdown three node in a four node cluster


## Hardware Failure Test - Removing Disk
### Scenario 01 - Remove one disk in one of the cluster node
#### Steps
**Step 1** -  Run PowerShell to fill variables and make sure all management tools are installed
```powershell
# Check if proxy exists
$ClusterName="AzSHCI-Cluster"
$Nodes=(Get-ClusterNode -Cluster $ClusterName).Name
Install-WindowsFeature -Name RSAT-Clustering,RSAT-Clustering-PowerShell
```
**Step 2** Remove the Disk physically. Use Blink Feature in OpenManage to identify which disk to be removed

**Step 3** Explore Cluster Nodes status.
```powershell
Get-ClusterNode -Cluster $ClusterName
 ```
#### Expected Results
#### Result Capture

### Scenario 02 - Remove two disk in two different cluster node
#### Steps
#### Expected Results
#### Result Capture

### Scenario 03 - Remove three disk in two different cluster node
#### Steps
#### Expected Results
#### Result Capture

## Hardware Failure Test with VMFleet (understanding impact to performance)
### Testing Method - run VMFleet
### Scenario 01 - Shutdown one node in a four node cluster
* VMFleet with previous schemes are run with one node failed
### Scenario 02 - Shutdown two node in a four node cluster at once
* VMFleet with previous schemes are run with one node failed
### Scenario 03 - Shutdown two node in a four node cluster with 1 hour interval from 1 node shutdown
### Scenario 04 - Shutdown one drive lost
### Scenario 05 - Shutdown two drives lost in different servers
### Scenario 06 - Shutdown three node in a four node cluster
### Scenario 07 - Shutdown three disk or more in three or more nodes at once


