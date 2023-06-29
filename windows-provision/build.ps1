$MyInvocation.MyCommand.Path | Split-Path | Push-Location

$icd_folder = "$((Get-AppxPackage Microsoft.WindowsConfigurationDesigner).InstallLocation)\icd"

Write-Host "Resolved ICD path: ${icd_folder}"

icd /Build-ProvisioningPackage +Overwrite `
    /CustomizationXML:customizations.xml `
    /PackagePath:kiosk.ppkg `
    /StoreFile:"""${icd_folder}\Microsoft-Desktop-Provisioning.dat"""

Pop-Location
