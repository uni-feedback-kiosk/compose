Write-Host "Writing environment variables for kiosk user"
$username = "kiosk"
$sid = (Get-WmiObject win32_useraccount -Filter "name = '$username'").SID
    

foreach ($line in (Get-Content app.env)) {
    $name, $value = $line.split('=')
    if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
        continue
    }
    
    Write-Host "Setting $name"
    Set-ItemProperty "registry::hkey_users\$sid\Environment" -Name $name -Value $value
}

Write-Host "Done"
