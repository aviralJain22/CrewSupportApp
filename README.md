# Crew Support

A Flutter mobile application for connecting private aviation professionals — owner/operators, pilots, second-in-command crew, flight attendants, and flight instructors.

## Features

- **Multi-role authentication** — register and switch between Owner/Operator, Pilot, Flight Attendant, and Instructor profiles
- **Trip management** — create, view, and manage trips across Current, Future, History, Pending, and Draft states
- **Crew booking** — search and filter pilots, SIC, flight attendants, and flight instructors by experience and day rate
- **Real-time messaging** — in-app chat between profiles via Firebase
- **Push notifications** — Firebase Cloud Messaging for trip and crew updates
- **Availability management** — crew members can set and update their availability windows
- **Connections** — follow and connect with other aviation professionals
- **Favorites** — bookmark profiles for quick access
- **Profile pages** — rich profiles with ratings, certifications, type ratings, and social links
- **Local airport database** — offline IATA/ICAO code lookup via Isar

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart 3.x) |
| State management | GetX |
| Backend | Back4App (Parse Server) |
| Real-time / push | Firebase (Messaging, Analytics, Crashlytics) |
| Local database | Isar 3 |
| Fonts | Google Fonts (Raleway, Nunito) |
| Navigation | GetX named routes |

## Project Structure

```
lib/
├── app/          # App entry, theme, routes
├── core/         # Environment config
├── database/     # Isar local DB (airport codes)
├── features/     # All screens and controllers
│   ├── auth/         # Login, register, OTP, forgot password
│   ├── home/         # Dashboard home + sub-screens (Current, Future, History…)
│   ├── trip/         # Create trip flow, captain/SIC/FA/FI search & results
│   ├── profile/      # Owner, pilot, FA profile screens + view profiles
│   ├── connection/   # Connections tab
│   ├── message/      # Chat list + chat screen
│   ├── notification/ # Notifications tab
│   ├── availability/ # Manage availability
│   ├── favorite/     # Favourited profiles
│   └── docs/         # Help centre, FAQ
├── mock/         # Mock data for development
├── model/        # API response models
└── utils/        # Colors, constants, helpers
```

## Getting Started

### Prerequisites

- Flutter SDK `>=3.38.4`
- Dart `>=3.11.0`
- A Back4App application (Parse Server)
- A Firebase project with Messaging, Analytics, and Crashlytics enabled

### Setup

1. Clone the repo and install dependencies:
   ```bash
   flutter pub get
   ```

2. Copy the environment template and fill in your keys:
   ```bash
   cp .env.dev.example .env.dev
   ```

3. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective platform folders.

4. Run the app:
   ```bash
   flutter run
   ```

### Code generation (Isar)

After modifying any Isar model (`@Collection` annotated class), regenerate the adapters:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Dependency Notes

Several packages are currently pinned to older major versions due to transitive `win32` conflicts between `file_picker ^11.x` and `chewie`/`share_plus` latest releases. Upgrade path:

- `chewie` and `share_plus` can be bumped once `file_picker ^12.x` stable ships.
- `build_runner` and `isar_generator` are coupled — upgrade only together when Isar publishes a version compatible with `build ^4.x`.
