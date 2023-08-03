# Mandatory Features:
# ==================
#1 BitLocker 
#2 Data-Center-Bridging
#3 Failover-Clustering
#4 FS-FileServer
#5 FS-Data-Deduplication
#6 Hyper-V
#7 NetworkATC
#8 NetworkHUD
#9 FS-SMBBW

$features = "BitLocker","Data-Center-Bridging","Failover-Clustering","FS-FileServer","FS-Data-Deduplication","Hyper-V","NetworkATC","NetworkHUD","FS-SMBBW"
Install-WindowsFeature -Name $features
