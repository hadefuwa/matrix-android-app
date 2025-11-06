# Fix Java 17 Issue for Building APK

The Android build requires **Java 17**, but your system only has Java 11. Here's how to fix it:

## Option 1: Install Java 17 (Recommended)

### Quick Install (Easiest)

1. **Download Java 17:**
   - Go to: https://adoptium.net/temurin/releases/?version=17
   - Download **Windows x64** installer (.msi)
   - Choose **JDK 17** (latest LTS version)

2. **Install:**
   - Run the installer
   - Install to default location: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`
   - ✅ Check "Add to PATH" during installation

3. **Verify Installation:**
   ```powershell
   java -version
   ```
   Should show: `openjdk version "17.x.x"`

4. **Set JAVA_HOME:**
   - Press `Win + X` → "System"
   - "Advanced system settings" → "Environment Variables"
   - Under "User variables", click "New":
     - Variable name: `JAVA_HOME`
     - Variable value: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot`
   - Click OK on all dialogs
   - **Close and reopen PowerShell/terminal**

5. **Build APK:**
   ```powershell
   .\build-apk.bat
   ```

### Alternative: Use Flutter's Java (If Available)

Some Flutter installations come with Java. Try:

```powershell
# Check if Flutter has Java bundled
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" doctor --verbose
```

If it shows a Java path, you can configure Flutter to use it:

```powershell
& "C:\Users\Hamed\Documents\flutter\bin\flutter.bat" config --jdk-dir="<path-to-java-17>"
```

## Option 2: Use Android Studio (Easiest for Non-Technical Users)

If you have Android Studio installed, it comes with Java 17:

1. **Open Android Studio**
2. **Open the project:**
   - File → Open → Select `C:\Users\Hamed\Documents\vice-app`
3. **Build APK:**
   - Build → Build Bundle(s) / APK(s) → Build APK(s)
   - Wait for build to complete
   - APK will be in: `app\build\outputs\apk\release\app-release.apk`

## Option 3: Use Online Build Service (No Installation Needed)

You can use GitHub Actions or other CI/CD services to build the APK automatically, but this requires GitHub setup.

## Quick Fix Script

After installing Java 17, run:

```powershell
.\build-apk.ps1
```

Or the automated script will detect and use Java 17 automatically.

---

## Verification

After installing Java 17, verify:

```powershell
# Check Java version
java -version

# Should show: openjdk version "17.x.x"

# Check JAVA_HOME
echo $env:JAVA_HOME

# Should show: C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot
```

## Troubleshooting

### "Java 17 not found after installation"

1. **Restart terminal/PowerShell** (required for PATH changes)
2. **Verify JAVA_HOME:**
   ```powershell
   echo $env:JAVA_HOME
   ```
3. **Set JAVA_HOME manually:**
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot"
   ```

### "Still using Java 11"

1. **Check PATH order:**
   - Java 17 should come before Java 11 in PATH
   - Or remove Java 11 from PATH temporarily

2. **Use full path:**
   ```powershell
   & "C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot\bin\java.exe" -version
   ```

---

**After installing Java 17, you can build the APK using `.\build-apk.bat`!**





