cls
$wwwrootfolder = "C:\inetpub\wwwroot\"
 
Write-Host "===== Check $wwwrootfolder =====" -ForegroundColor Black -BackgroundColor Yellow
$files = Get-ChildItem $wwwrootfolder -Recurse
foreach ($file in $files){
if ($file.LastWriteTime -gt (date(08.2021))){
Write-Host $file.Mode $file.LastWriteTime $file.Length $file.Name -ForegroundColor White -BackgroundColor Red
}
else {
Write-Host $file.Mode $file.LastWriteTime $file.Length $file.Name}
}


Write-Host "===== Check $env:ExchangeInstallPath\FrontEnd\HttpProxy\owa =====" -ForegroundColor Black -BackgroundColor Yellow
$files = Get-ChildItem $env:ExchangeInstallPath\FrontEnd\HttpProxy\owa -Recurse
foreach ($file in $files){
if ($file.LastWriteTime -gt (date(08.2021))){
Write-Host $file.Mode $file.LastWriteTime $file.Length $file.Name -ForegroundColor White -BackgroundColor Red
}
else{
Write-Host $file.Mode $file.LastWriteTime $file.Length $file.Name}
}

Write-Host "===== Check Virtual Directory in Config Files  =====" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "File: C:\Windows\System32\inetsrv\Config\applicationHost.config" -ForegroundColor Black -BackgroundColor White
((Select-String -Path "C:\Windows\System32\inetsrv\Config\applicationHost.config" -Pattern "VirtualDirectory").Line).Trim()
Write-Host "File: C:\inetpub\temp\apppools\MSExchangeECPAppPool\MSExchangeECPAppPool.config" -ForegroundColor Black -BackgroundColor White
((Select-String -Path "C:\Windows\System32\inetsrv\Config\applicationHost.config" -Pattern "VirtualDirectory").Line).Trim()

Write-Host "==== Check All Users =====" -ForegroundColor Black -BackgroundColor Yellow
Get-ChildItem "C:\Users\All Users"

Write-Host "===== Check Exchange PST Export =====" -ForegroundColor Black -BackgroundColor Yellow
$UserCredential = Get-Credential
$exchange = [System.Net.DNS]::GetHostByName(($env:COMPUTERNAME)).HOstname
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exchange/powershell -Authentication Kerberos -Credential $UserCredential
Import-PSSession $session -DisableNameChecking -AllowClobber
$MER = Get-MailboxExportRequest
if ($MER -eq $null){Write-Host No PSTs Exported}
Write-Host $MER -BackgroundColor Red -ForegroundColor White


Write-Host "===== Check new AD Users last 30 days =====" -ForegroundColor Black -BackgroundColor Yellow
$DateCutOff=(Get-Date).AddDays(-30)
Get-ADUser -Filter * -Property whenCreated | Where {$_.whenCreated -gt $datecutoff} | FT Name, whenCreated



Write-Host "===== Check Password Last set of Administrator =====" -ForegroundColor Black -BackgroundColor Yellow
Get-ADUser -Identity administrator -Properties passwordlastset | Select-Object DistinguishedName, PasswordLastSet
Start-Sleep -Seconds 8

Write-Host "===== Check Scanmail Services =====" -ForegroundColor Black -BackgroundColor Yellow
Get-Service -Name ScanMail_Master | Select-Object Name, Status, StartType 

Write-Host "===== Check Exchage Version =====" -ForegroundColor Black -BackgroundColor Yellow
$version = Get-Command Exsetup.exe | ForEach {$_.FileVersionInfo}
if (($version.ProductVersion -ne "15.01.2308.014") -or ($version.FileVersion -ne "15.01.2308.014")){
Write-Host $version.ProductVersion -BackgroundColor Red -ForegroundColor Yellow
}
Write-Host $version.ProductVersion

Write-Host "===== Check Scheduled Task =====" -ForegroundColor Black -BackgroundColor Yellow
Get-ScheduledTask | Where-Object {$_.Date -like "*2021*"} | fl Taskname,date, TaskPath

Write-Host "===== Check Autostart Folder =====" -ForegroundColor Black -BackgroundColor Yellow
Get-ChildItem "$ENV:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
Get-ChildItem  "$ENV:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"

Write-Host "===== Check Drafts Folder of your Administrator User =====" -ForegroundColor Black -BackgroundColor Yellow
Write-Host "Check in Browser"
Start-Process "https://localhost/owa"

Remove-PSSession $session
