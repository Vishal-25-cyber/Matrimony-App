# Google Play Store Data Safety Questionnaire Guide

This document provides exact, code-verified answers for the **Data Safety** form in the Google Play Console for **Pandarathar Matrimony** (`com.pandarathar.matrimony`).

---

## 1. Overview & Data Collection Summary

| Question in Play Console | Answer | Technical Explanation |
| :--- | :--- | :--- |
| **Does your app collect or share any of the required user data types?** | **Yes** | The app collects user account, profile, horoscope, and ₹25 verification payment details. |
| **Is all of the user data collected by your app encrypted in transit?** | **Yes** | All data between the app, backend, and Cloudflare R2 is transmitted using HTTPS / TLS 1.3. Enforced by `network_security_config.xml`. |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | Users can delete their data in-app via **Settings ➔ Delete Account** or externally via the web deletion page. |
| **Do you have a publicly accessible deletion request URL?** | **Yes** | Host `web/delete-account.html` on your domain. |

---

## 2. Detailed Data Categories Breakdown

### A. Personal Info

#### 1. Name
- **Collected?** Yes
- **Shared?** No (Internal app matching only)
- **Purpose:** App functionality, Account management, Matrimonial candidate identification
- **Is collection required or optional?** Required
- **Can user request deletion?** Yes (Deleted permanently when account is deleted)

#### 2. Phone Number
- **Collected?** Yes (10-digit mobile number)
- **Shared?** Shared only with authorized matrimony candidates upon ₹25 contact unlock
- **Purpose:** Account login, candidate matching, and verified alliance communication
- **Is collection required or optional?** Required
- **Can user request deletion?** Yes

#### 3. Email Address
- **Collected?** Yes (Optional during signup)
- **Shared?** No
- **Purpose:** Account management, password recovery
- **Is collection required or optional?** Optional
- **Can user request deletion?** Yes

#### 4. Other Personal Information (Gender, Date of Birth, Caste, Education, Location)
- **Collected?** Yes
- **Shared?** Displayed to other registered members within the app for matchmaking
- **Purpose:** App functionality, Matrimonial search and filtering
- **Is collection required or optional?** Required
- **Can user request deletion?** Yes

---

### B. Photos and Videos

#### 1. Photos
- **Collected?** Yes (User profile picture)
- **Shared?** Displayed to registered members in search results and profile details
- **Purpose:** Candidate identification for matrimonial proposals
- **Storage Location:** Cloudflare R2 private bucket via secure presigned endpoints
- **Is collection required or optional?** Optional
- **Can user request deletion?** Yes (Can replace photo or delete account)

---

### C. Financial Info

#### 1. Purchase History / Payment Info
- **Collected?** Yes (UPI Transaction Reference / UTR number, Amount ₹25, Payer Name)
- **Shared?** No
- **Purpose:** Payment verification and account/contact unlocking
- **Important Note for Play Console:** The app **does NOT** collect credit card numbers, debit card numbers, CVVs, or bank login passwords. All payments are executed peer-to-peer via UPI apps (GPay, PhonePe, Paytm).
- **Is collection required or optional?** Optional (Only required if user chooses to unlock a candidate's contact)
- **Can user request deletion?** Historical financial records may be retained for statutory tax/audit compliance.

---

### D. Astrology & Horoscope Details (Cultural & Demographic Data)
- **Collected?** Yes (Rasi, Nakshatra, Gothram, Chevvai Dosham, Rahu-Ketu Dosham, planetary positions)
- **Shared?** Displayed to prospective alliances within the app
- **Purpose:** Calculating 10 traditional marriage Poruthams (பத்து பொருத்தங்கள்)
- **Is collection required or optional?** Optional / Profile enhancement
- **Can user request deletion?** Yes

---

### E. App Info, Performance & Device Identifiers
- **Diagnostic / Crash logs collected?** No third-party analytics or crash reporting SDKs are bundled.
- **Advertising ID collected?** **No** — The app does not display ads and does not use Google Mobile Ads (AdMob) or other ad network SDKs.
- **Location (GPS)?** **No** — Only self-declared city/district text (e.g. "Chennai", "Coimbatore") is stored. No background or fine GPS location is requested.

---

## 3. Play Console Submission Checklist
- [x] Declare **Personal Info** (Name, Phone number, Email, Demographic details)
- [x] Declare **Photos** (Profile photos)
- [x] Declare **Financial Info** (Payment references / UTR)
- [x] Check **"Data is encrypted in transit"**
- [x] Check **"Users can request deletion"** and provide link to `https://yourdomain.com/delete-account.html`
- [x] Privacy Policy link: `https://yourdomain.com/privacy.html`
