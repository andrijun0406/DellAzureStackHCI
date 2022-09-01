$StorageAdapters = @('SLOT 3 PORT 1', 'SLOT 3 PORT 2')
foreach ($port in $StorageAdapters)
{
  Set-NetAdapterAdvancedProperty -Name $port -RegistryKeyword “*JumboPacket” -Registryvalue 9014
}
