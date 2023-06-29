$TEMPLATES_FOLDER = "./templates"
$PROVISIONING_FOLDER = "./windows-provision"

$variables = @{
    ASSET_PATH = "C:\Program Files\uni-feedback-kiosk\uni-feedback-kiosk-app.exe"
}

function Get-RandomString {
    param (
        [uint32]$Length
    )

    -join (((48..57) + (97..122)) * 80 | Get-Random -Count $Length | ForEach-Object { [char]$_ }) 
}

function Get-VariableSubstitution {
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline)]$Content,
        [parameter(Mandatory, Position = 0)][hashtable]$Mapping
    )

    process {
        $Result = $Content
        foreach ($pair in $Mapping.GetEnumerator()) {
            $Result = $Result.Replace("`$$($pair.Key)", "$($pair.Value)")
        }

        $Result
    }
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
  
    Write-Host "Substituting variables"
    Get-Content "${TEMPLATES_FOLDER}/.env" | Get-VariableSubstitution $variables | Set-Content -Encoding UTF8 .env
    Get-Content "${TEMPLATES_FOLDER}/ppfs.yaml" | Get-VariableSubstitution $variables | Set-Content -Encoding UTF8 ppfs.yaml
  
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
  
    Write-Host "Substituting variables"
    Get-Content "${TEMPLATES_FOLDER}/app.env" | Get-VariableSubstitution $variables | Set-Content -Encoding UTF8 app.env
  
    Write-Host "Done`n"
}

function Add-KioskUser {
    Write-Host "Creating the kiosk user"

    Write-Host "Substituting variables"
    Get-Content "${TEMPLATES_FOLDER}/access.xml" | Get-VariableSubstitution $variables | Set-Content -Encoding UTF8 "${PROVISIONING_FOLDER}/access.xml"
  
    Write-Host "Building provisioning package"
    & "${PROVISIONING_FOLDER}/build.ps1"

    Write-Host "Installing the package"
    Install-ProvisioningPackage -Force -Quiet "${PROVISIONING_FOLDER}/kiosk.ppkg" | Out-Null

    Write-Host "Done`n"

    Write-Host "You will need to log into the newly created user, return with Ctrl+Alt+Delete and run ./setenv.ps1 as admin."
}

$steps = "Add-ServerConfig", "Add-AppConfig", "Add-KioskUser"
for ($i = 0; $i -lt $steps.Count; $i++) {
    Write-Host -NoNewline "[$($i+1)/$($steps.Count)] "
    Invoke-Expression $steps[$i]
}

Write-Host "You will need to run ""docker-compose up -d"" to start the file server."
