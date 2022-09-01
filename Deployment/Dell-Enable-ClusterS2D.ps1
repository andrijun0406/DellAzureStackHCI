 # Enable S2D
 Enable-ClusterS2D -confirm:0 -Verbose

# Verify the storage pools
Get-ClusterS2D
Get-StoragePool
Get-StoragePool | Get-Physical Disk
Get-StorageTier
Get-ClusterPerformanceHistory
