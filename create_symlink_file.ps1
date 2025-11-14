# -----------------------------------------
# Windows Symbolic Link Creator (PowerShell)
# Enhanced with GUI dialogs, error handling, logging, and Unicode support
# -----------------------------------------

# Function: Log messages to symlinks.log in the script directory
function Write-Log {
    param([string]$Message)
    $logPath = Join-Path -Path $PSScriptRoot -ChildPath "symlinks.log"
    Add-Content -Path $logPath -Value ("[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message)
}

# Function: Show OpenFileDialog for source file
function Get-SourceFile {
    Add-Type -AssemblyName System.Windows.Forms
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Title = 'Select the ORIGINAL file'
    $ofd.Filter = 'All Files (*.*)|*.*'
    $ofd.Multiselect = $false
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $ofd.FileName
    } else {
        return $null
    }
}

# Function: Show SaveFileDialog for destination symlink
function Get-DestinationFile {
    Add-Type -AssemblyName System.Windows.Forms
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Title = 'Select or create the SYMLINK file'
    $sfd.OverwritePrompt = $false
    $sfd.Filter = 'All Files (*.*)|*.*'
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $sfd.FileName
    } else {
        return $null
    }
}

# Check for admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "Script requires administrator privileges. Please run as administrator."
    Write-Host "ERROR: This script requires administrator privileges to create symbolic links."
    Write-Host "Right-click the script and select 'Run with PowerShell as administrator'."
    Pause
    exit 1
}

do {
    Write-Host "========================================"
    Write-Host "    Windows Symbolic Link Creator"
    Write-Host "========================================"
    Write-Host ""

    # ---- Get Source File ----
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

    # ---- Get Destination Symlink Location ----
    $destination = $null
    while ($null -eq $destination) {
        $destination = Get-DestinationFile
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
        # If file exists at destination, confirm overwrite
        if (Test-Path $destination -PathType Leaf) {
            Write-Host "WARNING: File already exists at destination: $destination"
            $overwrite = Read-Host "Do you want to delete it and create the symlink? (Y/N)"
            if ($overwrite -match "^[Yy]") {
                try {
                    Remove-Item $destination -Force
                    Write-Log "Deleted existing file at destination: $destination"
                } catch {
                    Write-Host "ERROR: Could not delete the existing file."
                    Write-Log "Failed to delete existing file at $destination. $_"
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

    # ---- Create the symbolic link ----
    try {
        $mklinkCmd = "cmd /c mklink `"$destination`" `"$source`""
        $result = Invoke-Expression $mklinkCmd
        # Check if link now exists
        if (Test-Path $destination -PathType Leaf) {
            Write-Host "SUCCESS: Symbolic link created successfully!"
            Write-Log "SUCCESS: Linked '$destination' => '$source'"
        } else {
            Write-Host "WARNING: Symbolic link creation command executed but link does not exist."
            Write-Log "WARNING: Symlink command executed but link not present: $destination"
        }
    } catch {
        Write-Host "ERROR: Failed to create symbolic link."
        Write-Host "($_)"
        Write-Log "ERROR: Failed to create symlink from $destination to $source : $_"
    }
    Write-Host ""
    Write-Log "---------------------"
    $again = Read-Host "Do you want to create another symbolic link? (Y/N)"
} while ($again -match "^[Yy]")

Write-Host "Press Enter to exit..."
Pause
