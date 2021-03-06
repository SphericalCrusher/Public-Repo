<#
Script  :  AD-Account-Lockout.ps1
Version :  1.0
Date    :  6/2/2020
Author: Jody Ingram
Pre-reqs: N/A
Notes: This script reports on the last time an AD account is locked out and which device it occured on. Specifically, referencing event IDs that report the lock, not failed authentication attempts.
#>

$ErrorActionPreference = "SilentlyContinue"
Clear-Host
$User = Read-Host -Prompt "Please enter a username"
# Locate the PDC (Primary Domain Controller)
$PDC = (Get-ADDomainController -Discover -Service PrimaryDC).Name
# Locate all Domain Controllers
$DCs = (Get-ADDomainController -Filter *).Name #| Select-Object name
foreach ($DC in $DCs) {
Write-Host -ForegroundColor Green "Checking lockout events on $dc for the User: $user"
    if ($DC -eq $PDC) {
        Write-Host -ForegroundColor Green "$DC is the PDC"
        }
    Get-WinEvent -ComputerName $DC -Logname Security -FilterXPath "*[System[EventID=4740 or EventID=4625 or EventID=4770 or EventID=4771 and TimeCreated[timediff(@SystemTime) <= 3600000]] and EventData[Data[@Name='TargetUserName']='$User']]" | Select-Object TimeCreated,@{Name='User Name';Expression={$_.Properties[0].Value}},@{Name='Source Host';Expression={$_.Properties[1].Value}} -ErrorAction SilentlyContinue
    
    }
