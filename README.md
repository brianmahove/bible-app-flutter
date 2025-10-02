# Bible App Flutter 📖

A beautiful and feature-rich Bible application built with Flutter that allows you to read, study, and explore the Bible with ease.

![Bible App](https://img.shields.io/badge/Flutter-3.19.0-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3.0-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## Features ✨

### 📚 Bible Reading
- **Multiple English Translations** - KJV, NKJV, NIV, ESV, NASB, NLT, BSB, and more
- **Complete Books & Chapters** - All 66 books with proper chapter navigation
- **Clean Reading Interface** - Easy-to-read verse formatting with verse numbers

### 🔍 Study Tools
- **Bookmarks** - Save your favorite verses with notes
- **Reading History** - Track your reading progress
- **Search Functionality** - Find verses quickly
- **Commentary Integration** - Access Bible commentaries (when available)

### 📱 Offline Capabilities
- **Download Translations** - Download entire Bible translations for offline use
- **Download Individual Books** - Choose specific books to save storage
- **Offline Mode** - Read without internet connection
- **Storage Management** - View and manage downloaded content

### 🎨 User Experience
- **Dark/Light Mode** - Toggle between themes
- **Smooth Navigation** - Intuitive book and chapter selection
- **Progress Tracking** - Real-time download progress
- **Responsive Design** - Works on phones and tablets

## Screenshots 📸

| Home Screen | Translation Selection | Chapter Reading |
|-------------|----------------------|-----------------|
| ![Home](screenshots/home.png) | ![Translations](screenshots/translations.png) | ![Reading](screenshots/reading.png) |

| Bookmarks | Downloads | Dark Mode |
|-----------|-----------|-----------|
| ![Bookmarks](screenshots/bookmarks.png) | ![Downloads](screenshots/downloads.png) | ![Dark Mode](screenshots/dark_mode.png) |

## Installation 🚀

### Prerequisites
- Flutter SDK (3.19.0 or higher)
- Dart (3.3.0 or higher)
- Android Studio/VSCode with Flutter extension

### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/bible-app-flutter.git
   cd bible-app-flutter
Install dependencies

bash
flutter pub get
Run the app

bash
flutter run
Building for Release
bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
Project Structure 🏗️
text
lib/
├── main.dart                 # App entry point
├── models/
│   └── bible_models.dart     # Data models (Translation, Book, Chapter, etc.)
├── providers/
│   └── bible_provider.dart   # State management using Provider
├── services/
│   ├── bible_api.dart        # API service for Bible data
│   ├── database_service.dart # Local database for bookmarks & history
│   └── download_service.dart # Offline download management
└── screens/
    ├── home_screen.dart      # Main home screen
    ├── translation_screen.dart
    ├── book_screen.dart
    ├── chapter_screen.dart
    ├── search_screen.dart
    ├── bookmarks_screen.dart
    ├── commentary_screen.dart
    ├── history_screen.dart
    ├── download_manager_screen.dart
    └── book_download_screen.dart
API Integration 🌐
This app uses the HelloAO Bible API for:

Available translations

Book lists

Chapter content

Commentary data

The API is free to use and provides reliable Bible data in multiple formats.

Dependencies 📦
Core Dependencies
yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0          # HTTP requests for API calls
  provider: ^6.1.1      # State management
  shared_preferences: ^2.2.2 # Local storage for preferences
  sqflite: ^2.3.0       # Local database
  path: ^1.8.3          # Path utilities
  dio: ^5.3.2           # Advanced HTTP client for downloads
  path_provider: ^2.1.1 # File system access
  permission_handler: ^11.0.1 # Permission management
  flutter_markdown: ^0.6.18 # Markdown rendering for commentaries
Dev Dependencies
yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
Features in Detail 🔧
State Management
Uses Provider for efficient state management

Centralized BibleProvider handles all app state

Reactive updates with ChangeNotifier

Offline Storage
SQLite Database for bookmarks and reading history

File System for downloaded Bible content

Shared Preferences for user settings

Download System
Progressive downloading with progress tracking

Resume capability for interrupted downloads

Storage management with size tracking

Smart caching with offline-first approach

User Interface
Material Design 3 components

Responsive layout for different screen sizes

Accessibility support

Smooth animations and transitions

Contributing 🤝
We welcome contributions! Please feel free to submit issues, feature requests, or pull requests.

Development Setup
Fork the repository

Create a feature branch (git checkout -b feature/amazing-feature)

Commit your changes (git commit -m 'Add some amazing feature')

Push to the branch (git push origin feature/amazing-feature)

Open a Pull Request

Code Style
Follow Dart/Flutter best practices

Use meaningful variable and function names

Add comments for complex logic

Write tests for new features

Roadmap 🗺️
Planned Features
Audio Bible integration

Reading plans and devotionals

Cross-references between verses

Verse sharing to social media

Multiple language support

Advanced search with filters

Parallel Bible reading

User notes and highlights

Bible word studies

Strong's numbers integration

Support 💬
If you need help with:

Setting up the development environment

Understanding the codebase

Reporting bugs

Suggesting features

Please open an issue on GitHub, and we'll be happy to assist you.

License 📄
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments 🙏
HelloAO for providing the free Bible API

Flutter Community for excellent packages and support

Bible translators and organizations for making God's Word accessible

Bible Translations Available 📖
King James Version (KJV)

New King James Version (NKJV)

New International Version (NIV)

English Standard Version (ESV)

New American Standard Bible (NASB)

New Living Translation (NLT)

Berean Study Bible (BSB)

Christian Standard Bible (CSB)

Revised Standard Version (RSV)

World English Bible (WEB)

And many more...

Made with ❤️ and Flutter for Bible study and spiritual growth

*"Your word is a lamp to my feet and a light to my path." - Psalm 119:105*

text

## Additional GitHub Files

### `.gitignore`
Flutter
.flutter/
flutter_*.json
.packages
.pub-cache/
.pub/
/build/

Android
/android//gradle-wrapper.jar
/android/.gradle
/android/captures/
/android/gradlew
/android/gradlew.bat
/android/local.properties
/android//GeneratedPluginRegistrant.java

iOS
/ios//*.mode1v3
/ios//*.mode2v3
/ios/**/*.moved-aside
/ios//*.pbxuser
/ios//*.perspectivev3
/ios/**/*sync/
/ios//.sconsign.dblite
/ios//.tags*
/ios//.vagrant/
/ios//DerivedData/
/ios//Icon?
/ios//Pods/
/ios/**/.symlinks/

IntelliJ
.idea/
*.iws
*.iml
*.ipr

VSCode
.vscode/

OS
.DS_Store
Thumbs.db

Environment
.env
.env.local
.env.production

text

### `LICENSE`
```text
MIT License

Copyright (c) 2024 Bible App Flutter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
Repository Topics
Add these topics to your GitHub repository:

text
flutter, dart, bible, christian, religion, mobile-app, cross-platform, offline, bible-study, spiritual, open-source
