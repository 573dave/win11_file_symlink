# -----------------------------------------
# Windows Symbolic Link Creator (PowerShell)
# Enhanced with GUI dialogs, error handling, logging, and Unicode support
# -----------------------------------------

function Write-Log {
    param([string]$Message)
    $logPath = Join-Path -Path $PSScriptRoot -ChildPath "symlinks.log"
    Add-Content -Path $logPath -Value ("[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message)
}

function Get-SourceFile {
    Add-Type -AssemblyName System.Windows.Forms
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Title = 'Select the ORIGINAL file'
    $ofd.Filter = 'All Files (*.*)|*.*'
    $ofd.Multiselect = $false
    $ofd.InitialDirectory = $HOME
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ofd.FileName
    } else {
        return $null
    }
}

function Get-DestinationFile {
    param ([string]$SuggestedFileName)
    Add-Type -AssemblyName System.Windows.Forms
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Title = 'Select or create the SYMLINK file'
    $sfd.OverwritePrompt = $false
    $sfd.Filter = 'All Files (*.*)|*.*'
    $sfd.InitialDirectory = $HOME
    $sfd.FileName = $SuggestedFileName
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $sfd.FileName
    } else {
        return $null
    }
}

# --------- ADMINISTRATION/ELEVATION SECTION ----------

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Clear-Host
    Write-Host "========================================"
    Write-Host "      Windows Symbolic Link Creator"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "This script requires administrator privileges to create symbolic links."
    Write-Host ""
    Write-Host "It will re-launch itself with elevated rights."
    Write-Host ""
    $choice = Read-Host "Continue and relaunch as administrator? (Y/N) [Default: Y]"
    if ($choice -notmatch "^[Nn]" ) {
        $script = $MyInvocation.MyCommand.Definition
        Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    }
    exit
}

Clear-Host
Write-Host "========================================"
Write-Host "      Windows Symbolic Link Creator"
Write-Host "========================================"
Write-Host ""
Write-Host "Welcome!"
Write-Host ""
Write-Host "This tool helps you create a symbolic link to a file."
Write-Host ""
Write-Host "You will:"
Write-Host " 1. Select the original source file."
Write-Host " 2. Select or enter the destination symlink file path."
Write-Host " 3. Confirm actions when needed."
Write-Host ""
Write-Host "NOTE:"
Write-Host " - Creating symbolic links requires administrator privileges."
Write-Host " - Default folder for file dialogs: your home directory."
Write-Host ""
Write-Host "Press Enter to start the symlink creation process..."
Read-Host | Out-Null

$source = $null
while ($null -eq $source) {
    $source = Get-SourceFile
    if ($null -eq $source -or -not (Test-Path $source -PathType Leaf)) {
        Write-Host "ERROR: Please select a valid file."
        $source = $null
    }
}
Write-Host ("Source file selected: {0}" -f $source)
Write-Log "Source file selected: $source"

$suggestedFileName = [System.IO.Path]::GetFileName($source)

$destination = $null
while ($null -eq $destination) {
    $destination = Get-DestinationFile $suggestedFileName
    if ([string]::IsNullOrWhiteSpace($destination)) {
        Write-Host "ERROR: Please select a valid destination."
        $destination = $null
        continue
    }
    # Check if destination is a directory
    if (Test-Path $destination -PathType Container) {
        Write-Host "ERROR: You selected a directory. Please select a file path."
        $destination = $null
        continue
    }
    # If file or symlink exists at destination, confirm overwrite
    if (Test-Path $destination) {
        $item = Get-Item $destination -ErrorAction SilentlyContinue
        $existingType = $null
        if ($item) {
            # Determine if destination is a file symlink, directory symlink, regular file or directory
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                if ($item.LinkType -eq "SymbolicLink") {
                    if ($item.PSIsContainer) {
                        $existingType = "directory symlink"
                    } else {
                        $existingType = "file symlink"
                    }
                }
            } elseif ($item.PSIsContainer) {
                $existingType = "directory"
            } else {
                $existingType = "file"
            }
        }
        Write-Host "WARNING: $existingType already exists at destination: $destination"
        $overwrite = Read-Host "Do you want to delete it and create the symlink? (Y/N)"
        if ($overwrite -match "^[Yy]") {
            try {
                Remove-Item $destination -Force
                Write-Log "Deleted existing $existingType at destination: $destination"
                Start-Sleep -Milliseconds 200
                if (Test-Path $destination) {
                    Write-Host "ERROR: Destination could not be deleted, still exists."
                    $destination = $null
                    continue
                }
            } catch {
                Write-Host "ERROR: Could not delete the existing item."
                Write-Log "Failed to delete existing item at $destination. $_"
                $destination = $null
                continue
            }
        } else {
            $destination = $null
            continue
        }
    }
    # Ensure destination directory exists
    $destDir = Split-Path $destination
    if (-not (Test-Path $destDir)) {
        Write-Host "Creating destination directory: $destDir"
        try {
            New-Item -Path $destDir -ItemType Directory | Out-Null
            Write-Log "Created destination directory: $destDir"
        } catch {
            Write-Host "ERROR: Could not create destination directory."
            Write-Log "Failed to create destination directory: $destDir $_"
            $destination = $null
            continue
        }
    }
}

Write-Host ""
Write-Host "========================================"
Write-Host "Creating symbolic link..."
Write-Host "========================================"
Write-Host ""
Write-Host ("Source:      {0}" -f $source)
Write-Host ("Destination: {0}" -f $destination)
Write-Log "Attempting symlink: Source: $source / Destination: $destination"

try {
    # Extra safety: verify destination does not exist as directory for mklink
    if (Test-Path $destination) {
        Remove-Item $destination -Force
        Start-Sleep -Milliseconds 200
    }
    # Creating file symlink
    $mklinkCmd = "cmd /c mklink `"$destination`" `"$source`""
    $result = Invoke-Expression $mklinkCmd
    # Validate the resulting destination is a file symlink (not directory)
    $item = $null
    if (Test-Path $destination) {
        $item = Get-Item $destination -ErrorAction SilentlyContinue
        if ($item -and $item.Attributes -band [System.IO.FileAttributes]::ReparsePoint -and $item.LinkType -eq "SymbolicLink" -and -not $item.PSIsContainer) {
            Write-Host "SUCCESS: Symbolic file link created successfully!"
            Write-Log "SUCCESS: Linked '$destination' => '$source'"
        } else {
            Write-Host "WARNING: Symbolic link was created but is not a file symlink. Please verify."
            Write-Log "WARNING: Link at $destination is not recognized as a file symlink."
        }
    } else {
        Write-Host "WARNING: Symbolic link command executed but link does not exist."
        Write-Log "WARNING: Symlink command executed but link not present: $destination"
    }
} catch {
    Write-Host "ERROR: Failed to create symbolic link."
    Write-Host $_
    Write-Log "ERROR: Failed to create symlink from $destination to $source : $_"
}
Write-Host ""
Write-Log "---------------------"

Write-Host "Press Enter to exit..."
Pause
