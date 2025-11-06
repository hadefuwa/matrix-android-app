# How to Get the App on Your Phone

There are several ways to install the app on your Android phone. Here are the easiest methods:

## Method 1: Build APK and Install (Easiest - No USB Required)

This method creates an APK file you can install directly on your phone.

### Step 1: Build the APK

**Option A: Using Flutter (if in PATH)**
```powershell
# Build release APK
flutter build apk --release

# The APK will be created at:
# build/app/outputs/flutter-apk/app-release.apk
```

**Option B: Using Flutter with full path**
```powershell
# Navigate to project directory
cd "C:\Users\Hamed\Documents\vice-app"

# Build APK using full path
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" build apk --release
```

### Step 2: Transfer APK to Your Phone

1. **Find the APK file:**
   - Location: `C:\Users\Hamed\Documents\vice-app\build\app\outputs\flutter-apk\app-release.apk`

2. **Transfer to phone:**
   - **Option A:** Email it to yourself
   - **Option B:** Use Google Drive / Dropbox
   - **Option C:** Transfer via USB (copy to phone storage)
   - **Option D:** Use Bluetooth
   - **Option E:** Use a file-sharing app

### Step 3: Install on Your Phone

1. **Enable Unknown Sources:**
   - Go to **Settings** → **Security** (or **Apps** → **Special access**)
   - Enable **"Install unknown apps"** or **"Unknown sources"**
   - Or enable it for the specific app you'll use to install (e.g., File Manager, Email)

2. **Open the APK file:**
   - Open the file manager or email app on your phone
   - Find the `app-release.apk` file
   - Tap on it

3. **Install:**
   - Tap **"Install"**
   - Wait for installation to complete
   - Tap **"Open"** to launch the app

---

## Method 2: Install Directly via USB (USB Debugging)

This method installs the app directly from your computer while your phone is connected.

### Step 1: Enable USB Debugging on Your Phone

1. **Enable Developer Options:**
   - Go to **Settings** → **About phone**
   - Tap **"Build number"** 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging:**
   - Go to **Settings** → **Developer options**
   - Enable **"USB debugging"**
   - Enable **"Install via USB"** (if available)

3. **Connect Phone:**
   - Connect your phone to your computer via USB
   - On your phone, when prompted, tap **"Allow USB debugging"**
   - Check **"Always allow from this computer"** (optional)

### Step 2: Verify Connection

**Option A: Using Flutter (if in PATH)**
```powershell
flutter devices
```

**Option B: Using Flutter with full path**
```powershell
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" devices
```

You should see your phone listed, e.g.:
```
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 13 (API 33)
```

**Option C: Using ADB**
```powershell
adb devices
```

### Step 3: Install and Run

**Option A: Using Flutter (if in PATH)**
```powershell
# Install and run directly
flutter run

# Or build and install only
flutter install
```

**Option B: Using Flutter with full path**
```powershell
cd "C:\Users\Hamed\Documents\vice-app"
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" run
```

The app will install and launch on your phone automatically!

---

## Method 3: Using Android Studio (Easiest GUI Method)

If you have Android Studio installed:

1. **Open Project:**
   - Open Android Studio
   - File → Open → Select `C:\Users\Hamed\Documents\vice-app`

2. **Connect Phone:**
   - Connect your phone via USB
   - Enable USB debugging (see Method 2, Step 1)

3. **Run:**
   - Click the green **"Run"** button (▶️)
   - Select your phone from the device list
   - The app will build, install, and launch automatically!

---

## Troubleshooting

### "USB debugging not working"

1. **Check USB cable:** Use a data cable (not just charging)
2. **Try different USB port:** Some USB ports may not support data transfer
3. **Install USB drivers:** Download and install your phone's USB drivers from manufacturer website
4. **Restart ADB:**
   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

### "Device not showing up"

1. **Check USB debugging is enabled** (see Method 2)
2. **Try different USB mode:** Set phone to "File Transfer" or "MTP" mode
3. **Check if phone is authorized:** Look for popup on phone asking to allow USB debugging
4. **Restart both computer and phone**

### "Flutter command not found"

Use the full path method:
```powershell
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" build apk --release
```

### "Install blocked"

On your phone:
- Go to **Settings** → **Security** → **Unknown sources**
- Enable installation from unknown sources
- Or enable it for the specific app (File Manager, Email, etc.)

---

## Quick Reference

### Build APK (for manual install):
```powershell
cd "C:\Users\Hamed\Documents\vice-app"
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" build apk --release
```
**APK Location:** `build\app\outputs\flutter-apk\app-release.apk`

### Install via USB:
```powershell
cd "C:\Users\Hamed\Documents\vice-app"
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" run
```

### Check connected devices:
```powershell
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" devices
```

---

## Recommended Method

**For first-time installation:** Use **Method 1 (Build APK)** - it's the simplest and doesn't require USB debugging setup.

**For development/testing:** Use **Method 2 (USB Debugging)** - allows you to quickly test changes by running `flutter run`.

---

**Need help?** Make sure your phone is:
- ✅ Android 5.0 (API 21) or higher
- ✅ Has enough storage space
- ✅ USB debugging enabled (for Method 2)
- ✅ Unknown sources enabled (for Method 1)





