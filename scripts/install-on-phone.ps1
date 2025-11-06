# Install app directly on connected phone via USB
Write-Host "Installing app on connected phone..." -ForegroundColor Green
Write-Host ""

# Navigate to project directory
Set-Location "C:\Users\Hamed\Documents\vice-app"

# Check for connected devices
Write-Host "Checking for connected devices..." -ForegroundColor Cyan
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" devices

Write-Host ""
Write-Host "Installing and running app..." -ForegroundColor Cyan
Write-Host ""

# Install and run
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" run

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ App installed and launched on your phone!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Installation failed." -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. Your phone is connected via USB" -ForegroundColor White
    Write-Host "  2. USB debugging is enabled on your phone" -ForegroundColor White
    Write-Host "  3. You've authorized the computer on your phone" -ForegroundColor White
    Write-Host ""
    Write-Host "See INSTALL_ON_PHONE.md for detailed instructions." -ForegroundColor Cyan
}





