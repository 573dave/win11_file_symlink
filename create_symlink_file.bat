@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges to create symbolic links.
    echo Please run this script as administrator.
    echo.
    echo Right-click on the script and select "Run as administrator"
    pause
    exit /b 1
)

echo ========================================
echo     Windows Symbolic Link Creator
echo ========================================
echo.

:: Get source file path
:getsource
set "source="
set /p "source=Enter the path of the original file: "

:: Remove quotes if present
set "source=!source:"=!"

:: Check if source exists
if not exist "!source!" (
    echo.
    echo ERROR: The file does not exist: !source!
    echo.
    goto getsource
)

:: Check if it's a file (not a directory)
if exist "!source!\" (
    echo.
    echo ERROR: The specified path is a directory. This script is for files only.
    echo.
    goto getsource
)

echo.
echo Source file verified: !source!
echo.

:: Get destination path
:getdest
set "destination="
set /p "destination=Enter the path where you want the symlink created: "

:: Remove quotes if present
set "destination=!destination:"=!"

:: Check if destination already exists
if exist "!destination!" (
    echo.
    echo WARNING: A file already exists at: !destination!
    set /p "overwrite=Do you want to delete it and create the symlink? (Y/N): "
    if /i "!overwrite!"=="Y" (
        del /f "!destination!" 2>nul
        if exist "!destination!" (
            echo ERROR: Could not delete the existing file.
            echo.
            goto getdest
        )
    ) else (
        echo.
        goto getdest
    )
)

:: Extract destination directory
for %%F in ("!destination!") do set "destdir=%%~dpF"

:: Create destination directory if it doesn't exist
if not exist "!destdir!" (
    echo.
    echo Creating directory: !destdir!
    mkdir "!destdir!" 2>nul
    if errorlevel 1 (
        echo ERROR: Could not create the destination directory.
        echo.
        goto getdest
    )
)

echo.
echo ========================================
echo Creating symbolic link...
echo ========================================
echo.
echo Source:      !source!
echo Destination: !destination!
echo.

:: Create the symbolic link
mklink "!destination!" "!source!"

if errorlevel 1 (
    echo.
    echo ERROR: Failed to create symbolic link.
    echo Possible reasons:
    echo - Insufficient privileges (even with admin rights)
    echo - Invalid paths
    echo - File system doesn't support symbolic links
) else (
    echo.
    echo SUCCESS: Symbolic link created successfully!
    echo.
    
    :: Verify the link
    if exist "!destination!" (
        echo Verification: The symbolic link exists at the destination.
    ) else (
        echo WARNING: The symbolic link was created but cannot be verified.
    )
)

echo.
echo ========================================
echo.
set /p "another=Do you want to create another symbolic link? (Y/N): "
if /i "!another!"=="Y" (
    echo.
    goto getsource
)

echo.
echo Press any key to exit...
pause >nul
