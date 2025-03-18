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
$Delimiter = Read-Host "which separator (, or ;)"
if ($Delimiter -ne "," -and $Delimiter -ne ";") 
{
    Write-Host "Invalid separator ! Choose Only , or ;" -ForegroundColor Red
    Exit
}
$UserData = Import-Csv -Path $CsvPath -Delimiter $Delimiter

foreach ($User in $UserData) 
{
    $UserExists = Get-ADUser -Filter {SamAccountName -eq $User.SamAccountName} -ErrorAction SilentlyContinue
    if (-Not $UserExists) 
    {
        New-ADUser -Name $User.Name `
                   -SamAccountName $User.SamAccountName `
                   -UserPrincipalName $User.UserPrincipalName `
                   -GivenName $User.GivenName `
                   -Surname $User.Surname `
                   -Enabled $true `
                   -PasswordNeverExpires $true `
                   -AccountPassword (ConvertTo-SecureString "TotalyN0tSecure" -AsPlainText -Force) `
                   -ChangePasswordAtLogon $true
    }
}
write-host "Finish for users !" -ForegroundColor Green
$GroupCsvPath = $CsvPath -replace '\.csv$', '_groups.csv'
if (Test-Path $GroupCsvPath) 
{
    $GroupData = Import-Csv -Path $GroupCsvPath -Delimiter $Delimiter
    foreach ($Group in $GroupData) 
    {
        $GroupExists = Get-ADGroup -Filter {Name -eq $Group.Name} -ErrorAction SilentlyContinue
        if (-Not $GroupExists) 
        {
            New-ADGroup -Name $Group.Name `
                        -GroupScope Global `
                        -Description $Group.Description `
                        -Path "OU=Groups,DC=mondomaine,DC=local"
        }
    }
}
Write-Host "DataBase loaded succesfully !" -ForegroundColor Cyan
