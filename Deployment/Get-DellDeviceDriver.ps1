# Get list of device driver relevant to Azure Stack HCI OS
Get-PnpDevice | Select-Object Name, @{l='DriverVersion';e={(Get-PnpDeviceProperty -InstanceId $_.InstanceId -KeyName 'DEVPKEY_Device_DriverVersion').Data}} -Unique | Where-Object {($_.Name -like "*HBA*") -or ($_.Name -like "*mellanox*") -or ($_.Name -like "*Qlogic*") -or ($_.Name -like "*X710*") -or ($_.Name -like "*Broadcom*") -or ($_.Name -like "*marvell*") -or ($_.Name -like "*E810*")}
