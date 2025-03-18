if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
    Write-Host "need admin permissions !" -ForegroundColor Red
    Exit
}
$CsvPath = Read-Host "enter the absolute path of the CSV file"
if (-Not (Test-Path $CsvPath)) 
{
    Write-Host "Invalid file ! Try again !" -ForegroundColor Red
    Exit
}
$Delimiter = Read-Host "which separator (, ou ;)"
if ($Delimiter -ne "," -and $Delimiter -ne ";") 
{
    Write-Host "Invalid separator ! Choose Only , or ;" -ForegroundColor Red
    Exit
}