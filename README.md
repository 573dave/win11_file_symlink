# Windows Symlink Creator

A simple, interactive Windows batch script that creates symbolic links for files with a user-friendly interface.

## Features

- **Interactive prompts** - No need to remember complex command syntax
- **Administrator privilege check** - Automatically verifies required permissions
- **Path validation** - Ensures source files exist before creating links
- **Safety checks** - Warns before overwriting existing files
- **Directory creation** - Automatically creates destination directories if needed
- **Batch processing** - Create multiple symlinks without restarting
- **Clear error messages** - Helpful feedback for troubleshooting

## Requirements

- Windows 11, Windows 10, Windows 8.1, or Windows 7
- Administrator privileges (required by Windows for creating symbolic links)
- NTFS file system (for symbolic link support)

## Installation

1. Download `create_symlink.bat`
2. Save it to a convenient location on your computer
3. No additional installation required - it's a standalone script

## Usage

1. **Right-click** on `create_symlink.bat`
2. Select **"Run as administrator"**
3. Follow the on-screen prompts:
   - Enter the full path to your original file
   - Enter the full path where you want the symlink created
4. The script will create the symbolic link and verify success

### Example

```
Enter the path of the original file: C:\Users\Documents\important.docx
Enter the path where you want the symlink created: D:\Backup\important.docx
```

## How It Works

The script uses Windows' built-in `mklink` command to create symbolic links. A symbolic link is a special type of file that points to another file or directory. Changes made to either the original file or the symlink affect both, as they reference the same data.

### Benefits of Symbolic Links

- **Space saving** - No duplicate files taking up storage
- **Synchronization** - Changes to one location automatically reflect in all linked locations
- **Organization** - Keep files accessible from multiple logical locations
- **Compatibility** - Works transparently with most applications

## Troubleshooting

### "This script requires administrator privileges"
- You must run the script as administrator. Right-click and select "Run as administrator"

### "Failed to create symbolic link"
Possible causes:
- Insufficient privileges (even with admin rights, some group policies may restrict this)
- Source or destination path is invalid
- File system doesn't support symbolic links (requires NTFS)
- Antivirus software blocking the operation

### "The file does not exist"
- Verify the source file path is correct
- Check for typos in the path
- Ensure you're including the full path with drive letter

## Limitations

- This script is designed for **files only**, not directories
- Requires administrator privileges (Windows security requirement)
- Works only on NTFS file systems
- Network paths may require additional permissions

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is released into the public domain under The Unlicense. See the [LICENSE.md](LICENSE.md) file for details.

## Author

Created by Dave

## Acknowledgments

- Uses Windows' native `mklink` command
- Inspired by the need for a user-friendly symbolic link creation tool
