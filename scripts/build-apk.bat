@echo off
echo Building APK for Android...
echo.

cd /d "C:\Users\Hamed\Documents\vice-app"

REM Try to find Java 17 and set JAVA_HOME
if exist "C:\Program Files\Eclipse Adoptium\jdk-17*" (
    for /d %%i in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do (
        set "JAVA_HOME=%%i"
        echo Found Java 17 at: %%i
        goto :found
    )
)
if exist "C:\Program Files\Java\jdk-17*" (
    for /d %%i in ("C:\Program Files\Java\jdk-17*") do (
        set "JAVA_HOME=%%i"
        echo Found Java 17 at: %%i
        goto :found
    )
)

:found
if not defined JAVA_HOME (
    echo.
    echo ⚠️  Java 17 not found automatically.
    echo.
    echo Java 17 is required for Android builds.
    echo See FIX_JAVA.md for installation instructions.
    echo.
    pause
    exit /b 1
)

echo Using JAVA_HOME: %JAVA_HOME%
echo.

"C:\Users\Hamed\Documents\flutter\bin\flutter.bat" build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ APK built successfully!
    echo.
    echo APK Location:
    echo   build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Next steps:
    echo   1. Transfer the APK to your phone (email, USB, cloud storage)
    echo   2. Enable 'Unknown sources' in phone settings
    echo   3. Open the APK file on your phone and install
    echo.
    
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        echo Opening APK folder...
        start explorer.exe "build\app\outputs\flutter-apk"
    )
) else (
    echo.
    echo ❌ Build failed. Check the error messages above.
)

pause

