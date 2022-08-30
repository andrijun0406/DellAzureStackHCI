# Variables for the scenario
$StorageAdaptersAll = @('SLOT 3 PORT 1', 'SLOT 3 PORT 2')
Enable-NetAdapterRdma -Name $StorageAdaptersAll
