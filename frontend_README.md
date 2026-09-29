# OsonIjara — Flutter App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/status-portfolio%20project-lightgrey)

**OsonIjara** ("Easy Rental") is a full-stack rental-listing app — think a
focused, regional take on Airbnb/property-rental apps — built with Flutter
and a FastAPI backend, with real-time chat between renters and owners.

### 🔗 [**Live demo → osonuyjoy.netlify.app**](https://osonuyjoy.netlify.app)
### 🔗 [Backend API + docs](https://oson-ijara-backend.onrender.com/docs) · [Backend repo](https://github.com/javohir-io/oson_ijara_backend)

> The backend sleeps after 15 minutes idle on its free hosting tier — give
> the first request 10–50s to wake it up.

---

## Features

- 🔐 Register/login with JWT auth
- 🏠 Browse, search, and filter property listings (price range, bedrooms,
  bathrooms, amenities, renovation, student-friendly)
- ➕ Post, edit, and delete your own listings, with photo uploads
- 🔖 Bookmark listings for later
- 💬 **Real-time chat** with a listing's owner over WebSockets
- 👤 Editable profile with avatar upload
- 🎨 Custom navy/ocean-blue/gold design system built from a Figma spec

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart), Material 3 |
| State management | `ChangeNotifier` + `ListenableBuilder` (no external package) |
| Networking | `http` (REST) + `web_socket_channel` (real-time chat) |
| Fonts | `google_fonts` |
| File picking | `file_picker` (cross-platform: web, mobile, desktop) |
| Backend | [FastAPI + PostgreSQL](https://github.com/javohir-io/oson_ijara_backend) |
| Hosting | [Netlify](https://netlify.com) (web build) |

## Screens

Login & Register · Home (search + filters) · Property Detail (photo
carousel, owner contact, chat) · Add/Edit Listing · Saved · Profile & Edit
Profile · Real-time Chat & Conversations

## Getting started locally

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install).

```bash
git clone https://github.com/javohir-io/oson-ijara-app.git
cd oson-ijara-app
flutter pub get
```

This app needs the [backend](https://github.com/javohir-io/oson_ijara_backend)
running somewhere it can reach. Either:

**Point it at the live backend (quickest):**
```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://oson-ijara-backend.onrender.com
```

**Or run the backend locally** (see its README), then:
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

`API_BASE_URL` defaults to `http://10.0.2.2:8000` (Android emulator) if
omitted — see `lib/config/api_config.dart`.

## Building for production

```bash
flutter build web --release --dart-define=API_BASE_URL=https://oson-ijara-backend.onrender.com
```

Deploy the resulting `build/web` folder to any static host (this project
uses Netlify).

## Project structure

```
lib/
├── config/          # API base URL config
├── data/            # PropertyStore (fetches/caches listings)
├── models/          # Property, User, ChatMessage, FilterCriteria...
├── screens/         # One file per screen
├── services/        # ApiClient, AuthStore, ChatStore
├── theme/           # Colors, typography
├── utils/           # Formatters
└── widgets/         # Reusable UI components
```

## Related repo

Backend source, API docs, and architecture notes:
👉 **[github.com/javohir-io/oson_ijara_backend](https://github.com/javohir-io/oson_ijara_backend)**
