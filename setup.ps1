$TEMPLATES_FOLDER = "./templates"

$variables = @{
    ASSET_PATH = "C:\Program Files\uni-feedback-kiosk\uni-feedback-kiosk-app.exe"
}

function Get-RandomString {
    param (
        [uint32]$Length
    )

    -join (((48..57) + (97..122)) * 80 | Get-Random -Count $Length | ForEach-Object { [char]$_ }) 
}

function Add-ServerConfig {
    Write-Host "Configure file server"

    $variables["JWT_KEY"] = Get-RandomString -Length 40
  
    $variables["DB_USERNAME"] = "ppfs_db_$(Get-RandomString -Length 8)"
    $variables["DB_PASSWORD"] = Get-RandomString -Length 40
  
    $variables["ADMIN_USERNAME"] = Read-Host "File server admin username"
  
    $variables["ADMIN_PASSWORD"] = Get-RandomString -Length 40
    Write-Host "File server admin password: $($variables["ADMIN_PASSWORD"])"
  
    $variables["USER_USERNAME"] = "ppfs_user_$(Get-RandomString -Length 6)"
    $variables["USER_PASSWORD"] = Get-RandomString -Length 40
  
    $replace_command = ""
    foreach ($pair in $variables.GetEnumerator()) {
        $replace_command += ".Replace(""```$$($pair.Key)"", ""$($pair.Value)"")"
    }
  
    Write-Host "Substituting variables"
    Invoke-Expression "(Get-Content ""${TEMPLATES_FOLDER}/.env"")${replace_command}" | Set-Content -Encoding UTF8 .env
    Invoke-Expression "(Get-Content ""${TEMPLATES_FOLDER}/ppfs.yaml"")${replace_command}" | Set-Content -Encoding UTF8 ppfs.yaml
  
    Write-Host "Done`n"
}

function Add-AppConfig {
    Write-Host "Configure the app"

    $variables["SMTP_HOST"] = Read-Host "SMTP hostname (without port)"
    $variables["SMTP_PORT"] = Read-Host "SMTP port"
    $variables["SMTP_USERNAME"] = Read-Host "SMTP username"
    $variables["SMTP_PASSWORD"] = Read-Host "SMTP password"
    $variables["SMTP_RECIPIENT"] = Read-Host "SMTP recipient"

    if ($asset_path = Read-Host "Application path [$($variables["ASSET_PATH"])]") {
        $variables["ASSET_PATH"] = $asset_path
    }
  
    $replace_command = ""
    foreach ($pair in $variables.GetEnumerator()) {
        $replace_command += ".Replace(""```$$($pair.Key)"", ""$($pair.Value)"")"
    }
  
    Write-Host "Substituting variables"
    Invoke-Expression "(Get-Content ""${TEMPLATES_FOLDER}/app.env"")${replace_command}" | Set-Content -Encoding UTF8 app.env
  
    Write-Host "Done`n"
}

$steps = "Add-ServerConfig", "Add-AppConfig"
for ($i = 0; $i -lt $steps.Count; $i++) {
    Write-Host -NoNewline "[$($i+1)/$($steps.Count)] "
    Invoke-Expression $steps[$i]
}
