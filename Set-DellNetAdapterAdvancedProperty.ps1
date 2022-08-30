$StorageAdapters = @('SLOT 3 PORT 1', 'SLOT 3 PORT 2')
ForEach ($port in $StorageAdapters)
{
$adapterProperties = Get-NetAdapterAdvancedProperty -Name $port -AllProperties
$driverDesc = $adapterProperties.Where({$_.RegistryKeyword -eq
'DriverDesc'}).RegistryValue
if ($driverDesc -like "*Mellanox*")
{
# For Windows Server 22 and 21H2 installations.
Get-NetAdapter $port | Set-NetAdapterAdvancedProperty -DisplayName
"NetworkDirect Technology" -DisplayValue "RoCEv2"
# Check if the DcbxMode property exists
if ($adapterProperties.Where({$_.DisplayName -eq 'DcbxMode'}))
{
Set-NetAdapterAdvancedProperty -Name $port -DisplayName 'DcbxMode'
-DisplayValue 'Host In Charge'
}
#Set NetworkDirect Technology to RoCEv2
if ((Get-ComputerInfo).OSDisplayVersion -like "*21H2*") {
Get-NetAdapter $port | Set-NetAdapterAdvancedProperty -DisplayName
"NetworkDirect Technology" -DisplayValue "RoCEv2"
}
}
elseif ($driverDesc -like "*Qlogic*")
{
# Check if the NetworkDirect Technology property exists
if ($adapterProperties.Where({$_.DisplayName -eq 'NetworkDirect Technology'}))
{
Set-NetAdapterAdvancedProperty -Name $port -DisplayName 'NetworkDirect
Technology' -DisplayValue 'iWarp'
}
}
}
