# Amozea - AMOLED Wallpaper App

A production-ready Flutter wallpaper application with backend API integration and multi-language support.

## Features
- **Backend API Integration**: Fetches wallpapers from a Node.js/Express backend
- **Multi-Language Support**: English, Spanish, French, Hindi, and Japanese
- **Offline-First**: Caches wallpapers and data locally
- **Material 3 Design**: Modern UI with Dark/Light mode support
- **Favorites**: Save your favorite wallpapers
- **Auto Wallpaper Changer**: Automatically cycle through favorites
- **Set Wallpaper**: Home Screen, Lock Screen, or Both
- **Download & Share**: Save to device or share with friends
- **Personal Photos**: Add your own photos to the rotation

## Setup & Installation

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate localization files**:
   ```bash
   flutter gen-l10n
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

## Configuration

### Backend API
The app connects to a backend API for wallpapers. Update the URL in `lib/core/constants/app_constants.dart`:
```dart
static const String remoteWallpaperJsonUrl = 'YOUR_API_URL_HERE';
```

### Adding Translations
Translation files are located in `lib/l10n/`. To add a new language:
1. Create a new `.arb` file (e.g., `app_de.arb` for German)
2. Copy the structure from `app_en.arb`
3. Translate all values
4. Run `flutter gen-l10n`

## Build for Release (Android)

1. Update version in `pubspec.yaml`
2. Run build command:
   ```bash
   flutter build apk --release
   # OR
   flutter build appbundle --release
   ```

## Project Structure
- `lib/data`: Data layer (API, Local Storage, Models)
- `lib/domain`: Domain layer (Repositories, Interfaces)
- `lib/presentation`: UI layer (Screens, Widgets, Providers)
- `lib/core`: Constants, Extensions, and Utilities
- `lib/l10n`: Localization files
- `backend`: Node.js/Express backend API

## Backend Setup
See `backend/README.md` for backend setup instructions.

## License
MIT
