if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "need admin permissions !" -ForegroundColor Red
    Exit
}
Add-Type -AssemblyName Microsoft.VisualBasic

Write-Host "checking AD installation" -ForegroundColor Cyan
$adFeature = Get-WindowsFeature -Name AD-Domain-Services
if (-Not $adFeature.Installed) {
    Write-Host "AD not installed ! Start ADPackageInstallor.ps1 before." -ForegroundColor Red
    Exit
}
$DomainName = [Microsoft.VisualBasic.Interaction]::InputBox("Choose Domain name (ex: Domolia.local):", "Domain Configuration", "Domolia.local")
if ([string]::IsNullOrWhiteSpace($DomainName)) {
    Write-Host "Domain name is required!" -ForegroundColor Red
    Exit
}
$NetBIOSName = [Microsoft.VisualBasic.Interaction]::InputBox("Choose Netbios Name (ex: DOMOLIA):", "Domain Configuration", "DOMOLIA")
if ([string]::IsNullOrWhiteSpace($NetBIOSName)) {
    Write-Host "NetBIOS name is required!" -ForegroundColor Red
    Exit
}
$SafeModePwd = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your password for DSRM (Directory Services Restore Mode):", "Domain Configuration", "")
if ([string]::IsNullOrWhiteSpace($SafeModePwd)) {
    Write-Host "Password is required!" -ForegroundColor Red
    Exit
}
$SecurePwd = ConvertTo-SecureString $SafeModePwd -AsPlainText -Force

Write-Host "starting server promotion" -ForegroundColor Cyan
Try {
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBIOSName `
        -SafeModeAdministratorPassword $SecurePwd `
        -InstallDNS `
        -Force

    Write-Host "Install finish ! Your computer will restart in 10 sec" -ForegroundColor Green
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} Catch {
    Write-Host "An error occurred during the promotion process: $_" -ForegroundColor Red
}