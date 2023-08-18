#I don't even know if I need to specify it again
$quicklaunch = Join-Path ([environment]::GetFolderPath("ApplicationData")) 'Microsoft\Internet Explorer\Quick Launch'

if (-not $packageScript) {
    #Warning was provided in pre-install script
    return
}

if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("DesktopDirectory"))) {
    Write-Warning "Skipping cleanup because user desktop directory cannot be found"
    return
}

$global:CleanupDesktopShortcutsHook.PostShortcuts = @(Get-Childitem -Path $quicklaunch,([environment]::GetFolderPath("DesktopDirectory")) -Filter "*.lnk" -Recurse -Force)

if (Test-ProcessAdminRights) {
    if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("CommonDesktopDirectory"))) {
        Write-Warning "System wide desktop directory cannot be found, something went wrong."
        Write-Warning "Skipping cleanup of desktop shortcuts"
        return
    }
    $global:CleanupDesktopShortcutsHook.PostShortcuts += @(Get-Childitem -Path ([environment]::GetFolderPath("CommonDesktopDirectory")) -Filter "*.lnk")
} else {
    Write-Host "Not cleaning desktop shortcuts from the system wide desktop directory as script is not running with Admin rights."
}

foreach ($postshortcut in $CleanupDesktopShortcutsHook.PostShortcuts) {
    if ($CleanupDesktopShortcutsHook.PreShortcuts) {
        if ($CleanupDesktopShortcutsHook.PreShortcuts.fullname.Contains($postshortcut.fullname)) {
            Write-Debug "'$($postshortcut.fullname)' existed before install script run, ignoring"
            continue;
        }
    }
    Write-Host "Removing '$($postshortcut.fullname)'"
    Remove-Item -Path $postshortcut.fullname
    #I mean I could find out how to do this after every package is finished however I'm incredibly lazy
    Write-Host "Restarting taskbar"
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\" -Name "FavoritesRemovedChanges"
    taskkill /f /im explorer.exe
    start explorer.exe
}
