# Flutter Wallpaper App

A production-ready Flutter wallpaper application for Android that does NOT rely on any third-party wallpaper APIs.

## Features
- **Offline-First**: Caches wallpapers and data locally.
- **Material 3 Design**: Modern UI with Dark/Light mode support.
- **Local & Remote**: Load wallpapers from a remote JSON or fallback to local assets.
- **Favorites**: Save your favorite wallpapers.
- **Set Wallpaper**: Home Screen, Lock Screen, or Both.
- **Download & Share**: Save to device or share with friends.

## Setup & Installation

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

## Configuration

### Adding New Wallpapers
The app uses a JSON structure to manage wallpapers. You can host this JSON file on GitHub Pages, Firebase, or use a local file.

**JSON Structure:**
```json
{
  "categories": [
    {
      "name": "Nature",
      "wallpapers": [
        {
          "id": "1",
          "type": "static",
          "url": "https://example.com/nature1.jpg"
        }
      ]
    }
  ]
}
```

To update the source URL, edit `lib/core/constants/app_constants.dart`:
```dart
static const String remoteWallpaperJsonUrl = 'YOUR_JSON_URL_HERE';
```

### Adding Categories
Simply add a new object to the `categories` array in your JSON file. The app handles categories dynamically.

## Build for Release (Android)

1. Update version in `pubspec.yaml`.
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
- `lib/core`: Constants and Utilities

## License
MIT
