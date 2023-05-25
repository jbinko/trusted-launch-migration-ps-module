Import-Module Az.Accounts -ErrorAction SilentlyContinue

$p = Get-ChildItem -Path "$PSScriptRoot\Set-TrustedLaunch.ps1"
. $p.Fullname
Export-ModuleMember -Function $p.Basename
