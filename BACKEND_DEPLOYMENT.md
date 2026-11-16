# Backend Production Deployment Guide

## Overview

The Pandarathar Matrimony application uses a dedicated Dart HTTP backend service located at `bin/db_bridge.dart`. This service acts as the secure intermediary between the client app, **MongoDB Atlas**, and **Cloudflare R2** image storage.

```
┌─────────────────────────────────┐
│  Flutter Client (Android App)   │
└────────────────┬────────────────┘
                 │
                 │ HTTPS (TLS 1.3)
                 ▼
┌─────────────────────────────────┐
│     Cloud Backend Service       │
│     (bin/db_bridge.dart)        │
└────────┬───────────────┬────────┘
         │               │
         │ TLS           │ HTTPS / S3 API
         ▼               ▼
┌────────────────┐ ┌────────────────┐
│ MongoDB Atlas  │ │ Cloudflare R2  │
│ Database       │ │ Object Storage │
└────────────────┘ └────────────────┘
```

---

## 1. Required Server Environment Variables

When deploying `bin/db_bridge.dart` on your cloud server or container platform, supply the following environment variables. **Do not embed these secrets in the Flutter client code.**

| Environment Variable | Description | Example / Recommended Value |
| :--- | :--- | :--- |
| `PORT` | Listening port (assigned automatically by cloud hosts) | `8080` or `8765` |
| `MONGODB_ATLAS_URI` | MongoDB Atlas connection string | `mongodb+srv://<user>:<password>@cluster.mongodb.net/pandarathar_matrimony?appName=portfolio&safeAtlas=true` |
| `CLOUDFLARE_R2_ACCOUNT_ID` | Cloudflare account ID | Your 32-character account ID |
| `CLOUDFLARE_R2_ACCESS_KEY_ID` | Cloudflare R2 API Token Access Key | Your R2 Access Key |
| `CLOUDFLARE_R2_SECRET_ACCESS_KEY` | Cloudflare R2 API Token Secret | Your R2 Secret Key |
| `CLOUDFLARE_R2_BUCKET_NAME` | R2 bucket for profile images | `matrimony-profile-images` |
| `CLOUDFLARE_R2_PREFIX` | Image object key prefix | `profiles/` |
| `CLOUDFLARE_R2_ENDPOINT` | R2 S3 API Endpoint | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` |

---

## 2. Docker Deployment (Render, Railway, Fly.io, Cloud Run)

Create a `Dockerfile` in the project root:

```dockerfile
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/db_bridge.dart -o bin/server

FROM subfuzion/dart:slim
COPY --from=build /app/bin/server /app/bin/server

EXPOSE 8080
ENV PORT=8080

CMD ["/app/bin/server"]
```

### Steps to Deploy on Render / Railway:
1. Connect your repository to [Render](https://render.com) or [Railway](https://railway.app).
2. Create a new **Web Service**.
3. Set the Environment Variables (`MONGODB_ATLAS_URI`, `CLOUDFLARE_R2_*`).
4. Copy your assigned public HTTPS URL (e.g. `https://matrimony-api.onrender.com`).

---

## 3. VPS / Ubuntu Server Deployment (Systemd + Nginx SSL)

### Step 1: Compile the server binary on your Linux VPS
```bash
sudo apt update && sudo apt install -y curl apt-transport-https
sudo sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
sudo apt update && sudo apt install -y dart

cd /var/www/matrimony-backend
dart pub get
dart compile exe bin/db_bridge.dart -o bin/server
```

### Step 2: Create a systemd service (`/etc/systemd/system/matrimony-api.service`)
```ini
[Unit]
Description=Pandarathar Matrimony Backend Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/matrimony-backend
ExecStart=/var/www/matrimony-backend/bin/server
Restart=always
RestartSec=5
Environment=PORT=8765
Environment=MONGODB_ATLAS_URI="mongodb+srv://..."
Environment=CLOUDFLARE_R2_ACCOUNT_ID="..."
Environment=CLOUDFLARE_R2_ACCESS_KEY_ID="..."
Environment=CLOUDFLARE_R2_SECRET_ACCESS_KEY="..."
Environment=CLOUDFLARE_R2_BUCKET_NAME="matrimony-profile-images"

[Install]
WantedBy=multi-user.target
```

### Step 3: Enable and start service
```bash
sudo systemctl daemon-reload
sudo systemctl enable matrimony-api
sudo systemctl start matrimony-api
```

### Step 4: Configure Nginx Reverse Proxy with Let's Encrypt SSL
```nginx
server {
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8765;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo certbot --nginx -d api.yourdomain.com
```

---

## 4. Verification

Once deployed, verify that the health check responds with HTTP 200:
```bash
curl -I https://api.yourdomain.com/api/health
```
Expected response:
```http
HTTP/2 200
content-type: application/json
```

---

## 5. Compiling the Production App

Build the release App Bundle pointing to your live production HTTPS backend:
```bash
flutter build appbundle --release --dart-define=BACKEND_URL=https://api.yourdomain.com
```
