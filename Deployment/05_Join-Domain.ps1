# Run the following command from each of the nodes in PowerShell

# Customize your variable here
$credential = Get-Credential
$domainname = "contoso.com"
$oupath = "OU=AZHCI,DC=CONTOSO,DC=COM"
$newname = "AxNode1"
$domainadminuser1 = "john@contoso.com"
$domainadminuser2 = "bob@contoso.com"

Add-Computer -DomainName $domainname -OUPath $oupath -NewName $newname -Credential $credential -Restart
Add-LocalGroupMember -Group "Administrators" -Member $domainadminuser1
Add-LocalGroupMember -Group "Administrators" -Member $domainadminuser2
