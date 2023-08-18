#Let's remove those damn taskbar pins too (and god knows if this even works in different versions, there's like five different ways to unpin something from taskbar)
$quicklaunch = Join-Path ([environment]::GetFolderPath("ApplicationData")) 'Microsoft\Internet Explorer\Quick Launch'

if (-not $packageScript) {
    Write-Host "Skipping Cleanup of Desktop Shortcuts as there is no install script for this package"
    return
}

if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("DesktopDirectory"))) {
    Write-Warning "User desktop directory cannot be found, is Chocolatey running as SYSTEM?"
    return
}

$global:CleanupDesktopShortcutsHook = @{
    PreShortcuts = @(Get-Childitem -Path $quicklaunch,([environment]::GetFolderPath("DesktopDirectory")) -Filter "*.lnk" -Recurse -Force)
}

if (Test-ProcessAdminRights) {
    if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("CommonDesktopDirectory"))) {
        Write-Warning "System wide desktop directory cannot be found, something went wrong."
        return
    }
    $global:CleanupDesktopShortcutsHook.PreShortcuts += @(Get-Childitem -Path ([environment]::GetFolderPath("CommonDesktopDirectory")) -Filter "*.lnk")
}
