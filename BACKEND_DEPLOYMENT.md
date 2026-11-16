# Backend Production Deployment Guide

## Overview

The Pandarathar Matrimony backend service is a standalone Dart HTTP server (`backend/bin/db_bridge.dart`). It acts as the secure intermediary between the mobile application, **MongoDB Atlas**, and **Cloudflare R2** image storage.

```
┌─────────────────────────────────┐
│  Flutter Client (Android App)   │
└────────────────┬────────────────┘
                 │
                 │ HTTPS (TLS 1.3)
                 ▼
┌─────────────────────────────────┐
│     Cloud Backend Service       │
│  (backend/bin/db_bridge.dart)   │
└────────┬───────────────┬────────┘
         │               │
         │ TLS 1.3       │ HTTPS / S3 API
         ▼               ▼
┌────────────────┐ ┌────────────────┐
│ MongoDB Atlas  │ │ Cloudflare R2  │
│ Database       │ │ Object Storage │
└────────────────┘ └────────────────┘
```

---

## 1. Backend Structure (Pure Dart, Zero Flutter SDK Dependencies)

The backend is isolated from the Flutter client to compile independently in standard Docker environments without the Flutter SDK:

```
backend/
├── pubspec.yaml            # Pure Dart dependencies (crypto, http, mongo_dart)
├── Dockerfile              # Docker configuration when Root Directory = backend
└── bin/
    └── db_bridge.dart      # HTTP API server entry point
Dockerfile                  # Root Docker configuration when Root Directory = . (root)
.dockerignore               # Ignores Flutter build artifacts, mobile folders, secrets
```

---

## 2. Server Environment Variables (Render / Cloud Platform)

Supply the following environment variables in your cloud hosting provider dashboard (e.g. Render Dashboard ➔ Environment). **Never commit real credentials to Git.**

| Environment Variable | Required | Description | Example / Recommended Value |
| :--- | :---: | :--- | :--- |
| `PORT` | Yes | Listening port (assigned automatically by cloud hosts) | `8080` (or host assigned) |
| `MONGODB_ATLAS_URI` | Yes | MongoDB Atlas connection string | `mongodb+srv://<user>:<password>@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio&safeAtlas=true` |
| `CLOUDFLARE_R2_ACCOUNT_ID` | Yes | Cloudflare 32-char Account ID | `<YOUR_CLOUDFLARE_ACCOUNT_ID>` |
| `CLOUDFLARE_R2_ACCESS_KEY_ID` | Yes | Cloudflare R2 API Token Access Key | `<YOUR_R2_ACCESS_KEY>` |
| `CLOUDFLARE_R2_SECRET_ACCESS_KEY` | Yes | Cloudflare R2 API Token Secret | `<YOUR_R2_SECRET_KEY>` |
| `CLOUDFLARE_R2_BUCKET_NAME` | Yes | R2 Bucket Name for profile pictures | `matrimony-profile-images` |
| `CLOUDFLARE_R2_PREFIX` | No | Object key prefix | `profiles/` |
| `CLOUDFLARE_R2_ENDPOINT` | No | Custom S3 Endpoint (defaults to Account ID) | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` |

---

## 3. Deploying on Render (Step-by-Step)

1. Sign in to [Render](https://dashboard.render.com).
2. Click **New +** ➔ **Web Service**.
3. Select your GitHub repository: `Vishal-25-cyber/Matrimony-App`.
4. Configure service settings:
   - **Name:** `pandarathar-matrimony-api`
   - **Language / Environment:** `Docker`
   - **Branch:** `main`
   - **Root Directory:** *(leave blank for repository root, or enter `backend`)*
   - **Instance Type:** `Free` (or `Starter`)
5. Under **Environment Variables**, add:
   - `MONGODB_ATLAS_URI`
   - `CLOUDFLARE_R2_ACCOUNT_ID`
   - `CLOUDFLARE_R2_ACCESS_KEY_ID`
   - `CLOUDFLARE_R2_SECRET_ACCESS_KEY`
   - `CLOUDFLARE_R2_BUCKET_NAME`
6. Click **Deploy Web Service**.
7. Render will build the container using `backend/pubspec.yaml` without requiring the Flutter SDK.
8. Once live, Render assigns a public HTTPS URL:
   `https://pandarathar-matrimony-api.onrender.com`

---

## 4. Local Verification & Docker Build Test

### Test Pure Dart Compilation:
```bash
cd backend
dart pub get
dart compile exe bin/db_bridge.dart -o bin/server
```

### Test Docker Build Locally (if Docker is installed):
```bash
docker build -t matrimony-backend .
docker run -p 8080:8080 --env-file .env matrimony-backend
```

---

## 5. Health Check Verification

Once deployed on Render, verify your live public endpoint:
```bash
curl -I https://pandarathar-matrimony-api.onrender.com/api/health
```
Expected response:
```http
HTTP/2 200
content-type: application/json
```

---

## 6. Compiling the Flutter Mobile App with the Live Backend

After your Render service is live, compile the final Android App Bundle for Google Play Store using your real Render domain:
```bash
flutter build appbundle --release --dart-define=BACKEND_URL=https://pandarathar-matrimony-api.onrender.com
```
