# Windows Symlink Creator

A simple, interactive tool for creating symbolic links on Windows, now available in both **Batch (.bat)** and **PowerShell (.ps1)** script versions.

## Features

- **Interactive prompts** - No need to remember complex command syntax.
- **GUI file pickers (PowerShell only)** - Select files and link locations using Windows Explorer dialogs.
- **Administrator privilege check** - Automatically verifies required permissions.
- **Path validation** - Ensures source files exist before creating links.
- **Safety checks** - Warns before overwriting existing files.
- **Directory creation** - Automatically creates destination directories if needed.
- **Batch processing** - Create multiple symlinks without restarting.
- **Clear error messages** - Helpful feedback for troubleshooting.
- **Unicode support (PowerShell only)** - Handles files with non-ASCII characters.
- **Logging (PowerShell only)** - Tracks all symlink creation attempts in `symlinks.log`.

## Requirements

- Windows 11, Windows 10, Windows 8.1, or Windows 7
- Administrator privileges (required by Windows for creating symbolic links)
- NTFS file system (for symbolic link support)
- **PowerShell Version**: Requires Windows PowerShell 5.1 or higher

## Installation

1. Download your preferred script:
    - `create_symlink_file.bat` (Batch)
    - `create_symlink_file.ps1` (PowerShell)
2. Save to a convenient location on your computer.
3. No additional installation required - both scripts are standalone.

## Usage

**Batch Version (`create_symlink_file.bat`):**

1. Right-click the batch file and select **"Run as administrator"**.
2. Follow command-line prompts:
   - Type the full path to your original file.
   - Type the full path for the symlink.
3. The script will create the symbolic link and verify success.

**PowerShell Version (`create_symlink_file.ps1`):**

1. Right-click the PowerShell script and select **"Run with PowerShell as administrator"**.
2. Respond to GUI Explorer dialogs:
   - Choose your original file using a file picker.
   - Choose the symlink location using a Save dialog.
3. Review creation results.
4. All attempts and results are logged to `symlinks.log` in the script directory.

### Example (PowerShell)

- Select original file via Explorer dialog
- Select symlink location via Save dialog

## Differences: PowerShell vs Batch Script

| Feature                        | Batch (`.bat`)   | PowerShell (`.ps1`)          |
|------------------------------- |------------------|------------------------------|
| GUI file pickers               | No               | **Yes (Explorer dialogs)**   |
| Unicode path support           | Limited          | **Full support**             |
| Interactive prompts            | Yes              | Yes                          |
| Administrator check            | Yes              | Yes                          |
| Path existence validation      | Yes              | Yes                          |
| Overwrite prompt & safety      | Yes              | Yes                          |
| Auto create destination folder | Yes              | Yes                          |
| Multiple link creation         | Yes              | Yes                          |
| Logging to file                | No               | **Yes (`symlinks.log`)**     |
| Error & troubleshooting info   | Yes (console)    | **Yes (console & log)**      |

## Troubleshooting

**PowerShell Specific Issues**
- If you see security warnings about running scripts, right-click the `.ps1` file, select **Properties**, and unblock the file.
- You may need to set the execution policy: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

See batch section above for general symbolic link requirements and troubleshooting tips.

## Limitations

- Both scripts are designed for **files only**, not directories.
- Requires administrator privileges (Windows security requirement).
- Works only on NTFS file systems.
- Network paths may require additional permissions.

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is released into the public domain under The Unlicense. See the [LICENSE.md](LICENSE.md) file for details.

## Author

Created by Dave

## Acknowledgments

- Uses Windows' native `mklink` command
- Inspired by the need for a user-friendly symbolic link creation tool
