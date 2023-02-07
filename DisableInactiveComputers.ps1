
$Logfile = "$env:windir\Temp\Logs\MS365ModuleInstall.log"
Function LogWrite{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
   write-output $logstring
}

function Get-TimeStamp {
    return "[{0:dd/MM/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

if (!(Test-Path "$env:windir\Temp\Logs\"))
{
   mkdir $env:windir\Temp\Logs
   LogWrite "$(Get-TimeStamp): Script has started."
   LogWrite "$(Get-TimeStamp): Log directory created."
}
else
{
    LogWrite "$(Get-TimeStamp): Script has started."
    LogWrite "$(Get-TimeStamp): Log directory exists."
}

LogWrite "$(Get-TimeStamp): Importing the Active Directory module."
Import-Module ActiveDirectory
LogWrite "$(Get-TimeStamp): Set days for inactivity."
$DaysInactive = 31
LogWrite "$(Get-TimeStamp): Seting inactive date." 
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

LogWrite "$(Get-TimeStamp): Collecting the list of inactive computers."
$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

LogWrite "$(Get-TimeStamp): Exporting list of inactive computers."
$Computers | Export-Csv $env:windir\Temp\Logs\InactiveComputers.csv

LogWrite "$(Get-TimeStamp): Disabling inactive computers."
ForEach ($Computer in $Computers){
  $DName = $Computer.DistinguishedName
  Set-ADComputer -Identity $DName -Enabled $false
  Get-ADComputer -Filter { DistinguishedName -eq $DName } | Select-Object Name, Enabled
  LogWrite "$(Get-TimeStamp): Disabled the computer $DName."
}

LogWrite "$(Get-TimeStamp): The script has been executed, now exiting..."
exit