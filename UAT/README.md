# Hardware User Acceptance Test (UAT) PowerShell Scripts Compilation

## Hardware Performance Test
### Testing Method - run VMFleet
* VMFleet is a stress-test tool which are used alot by many Microsoft customers and partners to evaluate performance of their Azure Stack HCI clusters
* VMFleet consists of a set of PowerShell scripts that deploy VMs to a Hyper-V cluster and executes Microsoft's **DISKSPD** within those VMs to generate I/O.
* DISKSPD is very helpful for creating syntethic workloads to test an application's resource utilization before going into production.
* VMFleet test are run with the following schemes:
  * Healthy cluster running 64 VMs per node for total 256 VMs in a cluster of 4 x AX nodes
  * Healthy cluster running 32 VMs per node for total 128 VMs in a cluster of 4 x AX nodes
  The following table presents the range of VMFleet and DISKSPD parameters used:
  
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
   
## Hardware Failure Test
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

