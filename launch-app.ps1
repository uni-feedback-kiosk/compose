foreach ($line in (Get-Content app.env)) {
    $name, $value = $line.split('=')
    if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) {
        continue
    }
    Set-Content env:\$name $value
}

Start-Process -Wait $env:APP_PATH
