# add your admin user here
function Add-LocalAdmins
{
    param (
        [string]$title = 'Add your Domain Users to Local Administrators Group:'
    )
    Clear-Host
    Write-Host "==================== $title ===================="
    $addmore='y'
    $i=1
    do {

        $domainadminuser = Read-Host "Domain User $i Name (e.g. john@contoso.com)"
        Add-LocalGroupMember -Group "Administrators" -Member $domainadminuser
        $i++
        $addmore = Read-Host "Do you want to add more user (Y/N)?"
    } until (
        $addmore -eq 'n'
    )
}
Add-LocalAdmins

