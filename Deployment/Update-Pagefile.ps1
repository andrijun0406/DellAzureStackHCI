# Updating Page File Settings per node

$blockCacheMB = (Get-Cluster).BlockCacheSize

$pageFilePath = "C:\pagefile.sys"

$initialSize = [Math]::Round(51200 + $blockCacheMB)
$maximumSize = [Math]::Round(51200 + $blockCacheMB)
$system = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
if ($system.AutomaticManagedPagefile) {
$system.AutomaticManagedPagefile = $false
$system.Put()
}

$currentPageFile = Get-WmiObject -Class Win32_PageFileSetting
if ($currentPageFile.Name -eq $pageFilePath)
{
$currentPageFile.InitialSize = $InitialSize
$currentPageFile.MaximumSize = $MaximumSize
$currentPageFile.Put()
}else
{
$currentPageFile.Delete()
Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{Name=$pageFilePath;
InitialSize = $initialSize; MaximumSize = $maximumSize}
}
