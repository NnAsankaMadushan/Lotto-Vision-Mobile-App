# LottoVision - Sri Lankan Lottery Ticket Scanner & Result Checker

A comprehensive Flutter mobile application that allows Sri Lankan users to scan lottery tickets using OCR technology and automatically check winning results.

## Features

- 📸 **Ticket Scanning**: Take photos or select from gallery to scan lottery tickets
- 🔍 **OCR Technology**: Extract ticket information using Google ML Kit
- 🎯 **Multiple Lottery Support**:
  - Mahajana Sampatha
  - Govisetha
  - Dhana Nidhanaya
  - Jathika Sampatha
  - Mega Power
  - And more...
- ✅ **Automatic Result Checking**: Compare ticket numbers with official lottery results
- 💰 **Win Detection**: Instant notification of winning status and prize amounts
- 📊 **History Tracking**: Store and manage scanned tickets
- 🌍 **Multilingual**: Support for English, Sinhala, and Tamil
- 🌓 **Theme Support**: Light and Dark mode
- 💾 **Offline Storage**: Local caching using Hive

## Architecture

This project follows **Clean Architecture** principles with **MVVM** pattern:

```
lib/
├── core/                   # Core utilities, constants, and theme
│   ├── constants/         # App constants and lottery configurations
│   ├── errors/            # Error handling (failures & exceptions)
│   ├── theme/             # App theme configuration
│   ├── utils/             # Utility functions and typedefs
│   └── di/                # Dependency injection setup
├── data/                  # Data layer
│   ├── datasources/       # Local and remote data sources
│   ├── models/            # Data models with Hive adapters
│   └── repositories/      # Repository implementations
├── domain/                # Business logic layer
│   ├── entities/          # Core business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business use cases
├── presentation/          # Presentation layer
│   ├── providers/         # Riverpod state management
│   ├── screens/           # UI screens
│   └── widgets/           # Reusable widgets
├── services/              # External services
│   ├── ocr/               # OCR and ticket parsing
│   ├── lottery/           # Lottery results fetching
│   └── firebase/          # Firebase services
└── l10n/                  # Localization files
```

## Tech Stack

- **Flutter & Dart** (Latest stable)
- **State Management**: Riverpod
- **Local Database**: Hive
- **OCR**: Google ML Kit
- **Backend**: Firebase (Auth, Firestore, Storage)
- **HTTP Client**: Dio
- **Web Scraping**: HTML parser
- **Image Processing**: Image package
- **Permissions**: Permission Handler
- **Barcode Scanning**: Mobile Scanner

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter SDK (3.9.2 or higher)
   ```bash
   flutter --version
   ```

2. **Android Studio / VS Code**: With Flutter and Dart plugins

3. **Firebase Project**: Create a Firebase project for the app

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lotto_vision
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for Hive adapters and Riverpod)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase Configuration**

   a. Download `google-services.json` (Android) and place it in:
   ```
   android/app/google-services.json
   ```

   b. Download `GoogleService-Info.plist` (iOS) and place it in:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

5. **Android Permissions** - Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   ```

6. **iOS Permissions** - Add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Camera access is required to scan lottery tickets</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>Photo library access is required to select ticket images</string>
   ```

7. **Run the app**
   ```bash
   flutter run
   ```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## How It Works

### 1. Ticket Scanning Process

1. User takes a photo or selects from gallery
2. Image is preprocessed for better OCR accuracy
3. Google ML Kit extracts text from the image
4. Custom parser identifies:
   - Lottery type
   - Draw number and date
   - Selected number sets
   - Serial number (if available)
   - Barcode/QR code (if available)

### 2. Lottery Result Parsing

The app fetches official Sri Lankan lottery results from:
- National Lotteries Board (NLB) website
- Web scraping using HTML parser
- Structured data extraction

**Note**: You may need to implement the specific parsing logic based on the current NLB website structure.

### 3. Winning Detection

1. Fetch results for the specific draw
2. Compare user's numbers with winning numbers
3. Calculate matches for each number set
4. Determine prize tier based on match count
5. Display winning status and prize amount

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Implementation Notes

### Sri Lankan Lottery Result Parser

The `LotteryResultsService` in `lib/services/lottery/lottery_results_service.dart` contains placeholders for parsing the NLB website. You'll need to:

1. **Inspect the NLB website structure**
   ```dart
   // Visit https://www.nlb.lk/english/results/
   // Inspect HTML structure for result data
   ```

2. **Update parsing patterns** in `_extractWinningNumbers()` and related methods to match actual HTML structure

3. **Consider using an API** if available, or implement caching to reduce scraping frequency

### OCR Pattern Matching

The `LotteryParser` in `lib/services/ocr/lottery_parser.dart` uses regex patterns to detect:
- Lottery types (including Sinhala and Tamil names)
- Draw numbers
- Dates
- Number sets

You may need to fine-tune these patterns based on actual ticket formats.

### Adding New Lottery Types

1. Update `LotteryType` enum in `lib/core/constants/lottery_types.dart`
2. Add configuration in `LotteryConfig.configs`
3. Update parser keywords in `LotteryParser._lotteryKeywords`

## Known Limitations

1. **OCR Accuracy**: Depends on image quality and lighting conditions
2. **Result Availability**: Requires internet connection to fetch latest results
3. **Website Changes**: NLB website structure changes may break result parsing
4. **Barcode Scanning**: Not fully implemented (requires specific barcode format knowledge)

## Future Enhancements

- [ ] Firebase Authentication integration
- [ ] Cloud backup of scanned tickets
- [ ] Push notifications for draw results
- [ ] Statistics and analytics
- [ ] Number frequency analysis
- [ ] Quick pick number generator
- [ ] Share winning tickets
- [ ] Multiple user accounts

## Troubleshooting

### Build Errors

1. **Missing generated files**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Hive type adapter errors**:
   - Ensure all `@HiveType` annotations have unique `typeId`
   - Run build_runner again

3. **Permission errors on Android**:
   - Check AndroidManifest.xml has all required permissions
   - Request runtime permissions for Android 6.0+

### Runtime Errors

1. **OCR not working**:
   - Ensure Google ML Kit dependencies are properly installed
   - Check camera permissions are granted

2. **Results not fetching**:
   - Verify internet connection
   - Check NLB website is accessible
   - Update parsing logic if website structure changed

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Disclaimer

This app is for educational and convenience purposes only. Always verify winning tickets with official lottery sources. The developers are not responsible for any errors in result checking.

## Support

For issues and questions:
- Create an issue in the repository
- Contact: [your-email@example.com]

## Acknowledgments

- National Lotteries Board of Sri Lanka for lottery data
- Google ML Kit for OCR capabilities
- Flutter community for excellent packages

---

**Made with ❤️ for Sri Lankan lottery players**
