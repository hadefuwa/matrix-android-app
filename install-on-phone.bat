@echo off
echo Installing app on connected phone...
echo.

cd /d "C:\Users\Hamed\Documents\vice-app"

echo Checking for connected devices...
"C:\Users\Hamed\Documents\flutter\bin\flutter.bat" devices

echo.
echo Installing and running app...
echo.

"C:\Users\Hamed\Documents\flutter\bin\flutter.bat" run

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ App installed and launched on your phone!
) else (
    echo.
    echo ❌ Installation failed.
    echo.
    echo Make sure:
    echo   1. Your phone is connected via USB
    echo   2. USB debugging is enabled on your phone
    echo   3. You've authorized the computer on your phone
    echo.
    echo See INSTALL_ON_PHONE.md for detailed instructions.
)

pause





