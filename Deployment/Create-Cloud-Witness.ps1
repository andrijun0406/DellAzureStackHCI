#customize the following variable to your environment

$ResourceGroupName="AzSHCICloudWitness"
$StorageAccountName="azshcicloudwitness$(Get-Random -Minimum 100000 -Maximum 999999)"

#make sure PowerShell modules are present
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
$ModuleNames="Az.Accounts","Az.Resources","Az.Storage"
foreach ($ModuleName in $ModuleNames){
    Install-Module -Name $ModuleName -Force
}

#login to Azure
if (-not (Get-AzContext)){
    Connect-AzAccount -UseDeviceAuthentication
}
#select context if more available
$context=Get-AzContext -ListAvailable
if (($context).count -gt 1){
    $context | Out-GridView -OutputMode Single | Set-AzContext
}
#Create resource group
$Location=Get-AzLocation | Where-Object Providers -Contains "Microsoft.Storage" | Out-GridView -OutputMode Single
#create resource group first
if (-not(Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Ignore)){
    New-AzResourceGroup -Name $ResourceGroupName -Location $location.Location
}
#create Storage Account
If (-not(Get-AzStorageAccountKey -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore)){
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -SkuName Standard_LRS -Location $location.location -Kind StorageV2 -AccessTier Cool 
}
$StorageAccountAccessKey=(Get-AzStorageAccountKey -Name $StorageAccountName -ResourceGroupName $ResourceGroupName | Select-Object -First 1).Value

#Configure Witness
Set-ClusterQuorum -Cluster $ClusterName -CloudWitness -AccountName $StorageAccountName -AccessKey $StorageAccountAccessKey -Endpoint "core.windows.net"
 
