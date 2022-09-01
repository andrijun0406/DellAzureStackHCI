# Update the hardware timeout for the Spaces port in each of nodes (one by one, after restarts wait for it to join first)
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\spaceport\Parameters -Name HwTimeout -Value 0x00002710 -Verbose
Restart-Computer -Force
