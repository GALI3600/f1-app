# Deep Linking Setup Guide

This guide explains how to configure deep linking for F1Sync on Android and iOS platforms.

## Overview

F1Sync supports deep linking with the following URL schemes:
- **Custom scheme:** `f1sync://`
- **Universal Links (iOS) / App Links (Android):** `https://f1sync.app`

## Supported Deep Link Paths

| Path | Description | Example |
|------|-------------|---------|
| `/` | Home screen | `f1sync://` or `https://f1sync.app/` |
| `/meetings` | Meetings history | `f1sync://meetings` |
| `/meetings/:id` | Meeting detail | `f1sync://meetings/1239` |
| `/drivers` | Drivers list | `f1sync://drivers` |
| `/drivers/:number` | Driver detail | `f1sync://drivers/44` |
| `/sessions/:key` | Session detail | `f1sync://sessions/9165` |
| `/sessions/latest` | Latest session | `f1sync://sessions/latest` |

---

## Android Configuration

### 1. Update AndroidManifest.xml

Add the following intent filters to your main activity in `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.f1sync.app">

    <application
        android:label="F1Sync"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Main launcher intent -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Custom URL scheme: f1sync:// -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data android:scheme="f1sync" />
            </intent-filter>

            <!-- App Links: https://f1sync.app -->
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />

                <data android:scheme="https" />
                <data android:host="f1sync.app" />

                <!-- Meetings paths -->
                <data android:pathPrefix="/meetings" />

                <!-- Drivers paths -->
                <data android:pathPrefix="/drivers" />

                <!-- Sessions paths -->
                <data android:pathPrefix="/sessions" />
            </intent-filter>

        </activity>

        <!-- Other configurations -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>

    <!-- Internet permission (if not already present) -->
    <uses-permission android:name="android.internet" />
</manifest>
```

### 2. Android App Links Verification (Optional but Recommended)

For Android App Links to work, you need to host a `assetlinks.json` file on your domain.

**File:** `https://f1sync.app/.well-known/assetlinks.json`

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.f1sync.app",
    "sha256_cert_fingerprints": [
      "YOUR_APP_SHA256_FINGERPRINT_HERE"
    ]
  }
}]
```

**To get your SHA256 fingerprint:**

```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-key-alias
```

---

## iOS Configuration

### 1. Update Info.plist

Add URL scheme and Universal Links configuration to `ios/Runner/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing configuration -->

    <!-- Custom URL Scheme: f1sync:// -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.f1sync.app</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>f1sync</string>
            </array>
        </dict>
    </array>

    <!-- Universal Links: https://f1sync.app -->
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:f1sync.app</string>
    </array>

    <!-- Other existing keys -->
</dict>
</plist>
```

### 2. Enable Associated Domains in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **Associated Domains**
6. Add domain: `applinks:f1sync.app`

### 3. Universal Links Verification (Optional but Recommended)

Host an `apple-app-site-association` file on your domain.

**File:** `https://f1sync.app/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.f1sync.app",
        "paths": [
          "/meetings/*",
          "/drivers/*",
          "/sessions/*"
        ]
      }
    ]
  }
}
```

**Note:** Replace `TEAM_ID` with your Apple Developer Team ID.

---

## Testing Deep Links

### Android

#### Test Custom Scheme (f1sync://)

```bash
# Open meetings
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://meetings"

# Open specific meeting
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://meetings/1239"

# Open specific driver
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://drivers/44"

# Open specific session
adb shell am start -W -a android.intent.action.VIEW -d "f1sync://sessions/9165"
```

#### Test App Links (https://f1sync.app)

```bash
# Open meetings via HTTPS
adb shell am start -W -a android.intent.action.VIEW -d "https://f1sync.app/meetings"

# Open specific driver
adb shell am start -W -a android.intent.action.VIEW -d "https://f1sync.app/drivers/44"
```

### iOS

#### Test Custom Scheme (f1sync://)

```bash
# Open meetings
xcrun simctl openurl booted "f1sync://meetings"

# Open specific meeting
xcrun simctl openurl booted "f1sync://meetings/1239"

# Open specific driver
xcrun simctl openurl booted "f1sync://drivers/44"

# Open specific session
xcrun simctl openurl booted "f1sync://sessions/9165"
```

#### Test Universal Links (https://f1sync.app)

```bash
# Open meetings via HTTPS
xcrun simctl openurl booted "https://f1sync.app/meetings"

# Open specific driver
xcrun simctl openurl booted "https://f1sync.app/drivers/44"
```

### Testing on Real Devices

1. **Create test links** in a Notes app or send via Messages
2. Tap the link
3. App should open to the correct screen

---

## Debugging Deep Links

### Android

Check if App Links are verified:

```bash
adb shell pm get-app-links com.f1sync.app
```

View app link verification status:

```bash
adb shell pm verify-app-links --re-verify com.f1sync.app
```

### iOS

Check Universal Links association:

```bash
# View associated domains
swcutil show-app-assoc-for-app <bundle-id>

# Example
swcutil show-app-assoc-for-app com.f1sync.app
```

---

## Common Issues & Solutions

### Android

**Issue:** App Links not working (opens browser instead)
- **Solution:** Verify `assetlinks.json` is accessible at `https://f1sync.app/.well-known/assetlinks.json`
- Check SHA256 fingerprint matches your app's signature
- Ensure `android:autoVerify="true"` is set in intent filter

**Issue:** Custom scheme not working
- **Solution:** Check `android:scheme` is lowercase
- Ensure activity has `android:exported="true"`

### iOS

**Issue:** Universal Links not working
- **Solution:** Verify `apple-app-site-association` file is accessible
- Check Team ID is correct
- Ensure Associated Domains capability is enabled in Xcode
- Universal Links only work from different apps (not Safari address bar)

**Issue:** Custom scheme not working
- **Solution:** Check URL scheme is properly configured in Info.plist
- Rebuild app after changing Info.plist

---

## Security Considerations

1. **Validate parameters:** Always validate deep link parameters before using them
   - The app already validates parameters with `int.tryParse()` in `app_router.dart`
   - Invalid parameters show an error screen

2. **Handle sensitive data:** Don't pass sensitive data in URLs
   - User tokens, passwords, etc. should not be in deep links

3. **Rate limiting:** Consider rate limiting deep link handling to prevent abuse

4. **SSL/TLS:** Always use HTTPS for App Links/Universal Links
   - Never use HTTP in production

---

## Marketing & Sharing

### QR Codes

Generate QR codes for common deep links:

```
https://f1sync.app/drivers/44       # Lewis Hamilton
https://f1sync.app/drivers/1        # Max Verstappen
https://f1sync.app/meetings/latest  # Latest Grand Prix
```

### Social Media Sharing

Use Open Graph tags on your website for better link previews:

```html
<meta property="og:title" content="F1Sync - Formula 1 Live Data" />
<meta property="og:description" content="Follow your favorite drivers and GPs" />
<meta property="og:image" content="https://f1sync.app/og-image.png" />
<meta property="og:url" content="https://f1sync.app" />
```

---

## Implementation Status

- ✅ GoRouter configured with all routes
- ✅ Custom page transitions (fade and slide)
- ✅ Error handling for invalid routes
- ✅ Route extensions helper (`GoRouterX`)
- ✅ Parameter validation
- 📋 Android deep linking configuration (documented)
- 📋 iOS deep linking configuration (documented)

**Note:** The platform-specific configurations (AndroidManifest.xml, Info.plist) will need to be applied when the android/ios folders are added to the project.

---

## Next Steps

1. Create android/ios platform folders: `flutter create --platforms=android,ios .`
2. Apply the configurations from this guide
3. Test all deep link paths
4. Set up domain verification files if using App Links/Universal Links
5. Test on real devices

---

**Last Updated:** 2025-11-20
**Version:** 1.0
