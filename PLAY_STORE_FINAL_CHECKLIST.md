# Google Play Store Final Release Checklist

This checklist tracks every task required to successfully launch **Pandarathar Matrimony** (`com.pandarathar.matrimony`) on the Google Play Store.

---

## A. Completed Automatically in Codebase

- [COMPLETED] Responsive layouts across mobile (<600px), tablet (600–1024px), and desktop (>1024px)
- [COMPLETED] Artificial 420px fixed desktop container removed from `lib/main.dart`
- [COMPLETED] Orientation support enabled for portrait and landscape
- [COMPLETED] Adaptive `NavigationRail` for tablets/desktops and `BottomNavigationBar` for mobile
- [COMPLETED] Adaptive profile grid (1-col mobile, 2-col tablet, 3-col desktop)
- [COMPLETED] Layout constraints applied to prevent stretching on ultra-wide screens
- [COMPLETED] Form headers, button rows, and dialog overflow errors resolved
- [COMPLETED] In-app permanent Account Deletion implemented in `SettingsScreen` connecting to `MongoDBService.deleteProfile()`
- [COMPLETED] In-app Privacy Policy dialog expanded with all 8 data categories in `SettingsScreen`
- [COMPLETED] Android package ID and namespace set to `com.pandarathar.matrimony`
- [COMPLETED] Target SDK 35 (Android 15), Compile SDK 36, Min SDK 21 configured
- [COMPLETED] App name set to `Pandarathar Matrimony` and Tamil `பண்டாரத்தார் மேட்ரிமோனி`
- [COMPLETED] Android launcher icons generated from `assets/images/app_crest.jpg` across all mipmap densities (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- [COMPLETED] Android 8+ Adaptive icon configured with `#7A132B` background
- [COMPLETED] High-resolution 512x512 icon generated at `assets/images/play_store_512.png` and `web/icons/Icon-512.png`
- [COMPLETED] Android Network Security Config (`network_security_config.xml`) strictly enforcing HTTPS for all public network traffic
- [COMPLETED] Release mode backend discovery strictly isolated: no localhost, 127.0.0.1, or private LAN fallback in production
- [COMPLETED] Server `bin/db_bridge.dart` updated with dynamic cloud `PORT` binding and zero client-side credential exposure
- [COMPLETED] Standalone Dockerfile created for cloud deployment
- [COMPLETED] Public Privacy Policy web page created at `web/privacy.html`
- [COMPLETED] Public Account Deletion request web page created at `web/delete-account.html`
- [COMPLETED] Signing configuration setup in `build.gradle.kts` loading from `android/key.properties`
- [COMPLETED] `android/key.properties`, `*.jks`, and `*.keystore` protected in `.gitignore`
- [COMPLETED] Data Safety documentation created at `PLAY_STORE_DATA_SAFETY.md`
- [COMPLETED] Store listing metadata created at `PLAY_STORE_LISTING.md`
- [COMPLETED] Screenshot capture guide created at `PLAY_STORE_SCREENSHOTS.md`
- [COMPLETED] Static analysis: `flutter analyze lib/` passing with 0 errors and 0 warnings
- [COMPLETED] Unit test suite: 48/48 core tests passing

---

## B. Requires My Credentials (Manual Action)

- [MANUAL] **Generate Production Keystore:** Run the following command from the project root and enter your private password:
  ```powershell
  keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- [MANUAL] **Populate `android/key.properties`:** Enter your real keystore passwords in `android/key.properties`:
  ```properties
  storePassword=YOUR_ACTUAL_STORE_PASSWORD
  keyPassword=YOUR_ACTUAL_KEY_PASSWORD
  keyAlias=upload
  storeFile=upload-keystore.jks
  ```

---

## C. Requires Backend Deployment (External Hosting)

- [BLOCKED] **Deploy `bin/db_bridge.dart` to Cloud:** Deploy the backend server to Render, Railway, AWS, or your VPS.
- [BLOCKED] **Obtain Live HTTPS Domain:** Provide the live HTTPS URL (e.g. `https://api.yourdomain.com`).
- [BLOCKED] **Compile with Live Backend URL:**
  ```powershell
  flutter build appbundle --release --dart-define=BACKEND_URL=https://api.yourdomain.com
  ```

---

## D. Requires Website Hosting (Public URLs)

- [MANUAL] **Host Privacy Policy:** Upload `web/privacy.html` to your live website (e.g. `https://yourdomain.com/privacy.html`).
- [MANUAL] **Host Account Deletion Page:** Upload `web/delete-account.html` to your live website (e.g. `https://yourdomain.com/delete-account.html`).

---

## E. Requires Google Play Console

- [MANUAL] **Create Developer Account:** Register at [play.google.com/console](https://play.google.com/console) ($25 one-time fee).
- [MANUAL] **Create App:** Set Title to `Pandarathar Matrimony`, Default Language to English (United States) or English (India), Category to Social/Lifestyle.
- [MANUAL] **Fill App Content & Data Safety:** Use the answers prepared in `PLAY_STORE_DATA_SAFETY.md`.
- [MANUAL] **Provide Privacy Policy URL:** Paste your live `https://yourdomain.com/privacy.html` link.
- [MANUAL] **Provide Account Deletion URL:** Paste your live `https://yourdomain.com/delete-account.html` link.
- [MANUAL] **Set Store Listing:** Copy and paste the descriptions from `PLAY_STORE_LISTING.md`.

---

## F. Requires Screenshots & Assets

- [COMPLETED] 512x512 App Icon prepared at `assets/images/play_store_512.png`
- [MANUAL] **Feature Graphic (1024 x 500 px):** Create a 1024x500 banner with the Pandarathar crest and wedding couple artwork.
- [MANUAL] **Phone Screenshots:** Capture 6 to 8 phone screenshots using the sequence in `PLAY_STORE_SCREENSHOTS.md`.

---

## G. Final Release Verification

- [BLOCKED] Build signed release bundle with production keystore and live backend URL
- [MANUAL] Upload `app-release.aab` to Play Console **Internal Testing** track first
- [MANUAL] Add test user email addresses and download from Play Store to verify on a physical phone
- [MANUAL] Promote to **Closed Testing** or **Production**
