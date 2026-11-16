# Play Store Screenshots Capture Guide

Google Play requires at least **2 phone screenshots** (recommended 6 to 8) and optional 7-inch & 10-inch tablet screenshots.

All screenshots should be high quality, showing actual app features without status bar clutter.

---

## Recommended Screenshot Sequence

| # | Screen / Feature | Route / Navigation Path | Purpose & Captions |
| :-: | :--- | :--- | :--- |
| **1** | **Home Screen (முகப்பு)** | Open app ➔ Bottom Nav: `முகப்பு` | **Caption:** *Trusted Community Matrimony for 15+ Years*<br>Shows the welcoming maroon hero banner, Chennimalai Arumugam founder crest, quick action buttons, and latest candidate cards. |
| **2** | **Search & Filters (வரன் தேடல்)** | Bottom Nav: `தேடல்` | **Caption:** *Precise Filters: Caste, Rasi, Star & Education*<br>Shows the multi-select dropdowns for 12 Rasis, 27 Nakshatras, Education, and Age stepper. |
| **3** | **Search Results (வரன்கள் பட்டியல்)** | Search tab ➔ Click *வரன்களைக் காண்க* | **Caption:** *Explore Compatible Brides & Grooms*<br>Shows the responsive profile cards with candidate photos, age, education, star, and like buttons. |
| **4** | **Profile Details (முழு விவரம்)** | Tap on any profile card (e.g. Soundarya R.) | **Caption:** *Detailed Family Background & Candidate Details*<br>Shows candidate profile, work details, district, and astrological attributes. |
| **5** | **10 Porutham & Horoscope (ஜாதக பொருத்தம்)** | Bottom Nav: `பொருத்தம்` | **Caption:** *Authentic 10 Porutham Vedic Horoscope Matching*<br>Shows the Porutham evaluation table, Rajju status, Dosham analysis, and planetary chart layout. |
| **6** | **Protected Contact Unlock (தொடர்பு பெறுதல்)** | Tap *Unlock Contact / ₹25* | **Caption:** *100% Private Phone Numbers & Verified UPI Unlock*<br>Shows the ₹25 QR scan card, UPI ID copy button, and direct phone/WhatsApp calling action. |
| **7** | **Shortlists & Favorites (விருப்பப் பட்டியல்)** | Bottom Nav: `விருப்பம்` | **Caption:** *Manage Your Shortlist & Track Unlocked Contacts*<br>Shows saved candidate profiles and instant access to unlocked contact records. |
| **8** | **Settings & Privacy (கணக்கு அமைப்புகள்)** | Bottom Nav: `கணக்கு` ➔ `அமைப்புகள்` | **Caption:** *Complete Data Control & Security*<br>Shows privacy settings, terms, 256-bit storage badge, and permanent account deletion button. |

---

## Technical Image Specifications for Play Console

- **Format:** JPEG or 24-bit PNG (no alpha)
- **Minimum dimension:** 320px
- **Maximum dimension:** 3840px
- **Recommended Phone Resolution:** `1080 x 2400` px or `1080 x 1920` px (Aspect ratio 16:9 or 20:9)
- **Recommended Tablet Resolution (Optional):** `1600 x 2560` px (7-inch / 10-inch)

---

## How to Capture Clean Screenshots
You can take screenshots directly from an Android device or emulator using:
```bash
adb exec-out screencap -p > screenshot_1_home.png
adb exec-out screencap -p > screenshot_2_search.png
adb exec-out screencap -p > screenshot_3_results.png
adb exec-out screencap -p > screenshot_4_profile.png
adb exec-out screencap -p > screenshot_5_porutham.png
adb exec-out screencap -p > screenshot_6_unlock.png
```
