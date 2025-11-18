# Quick Start Guide

Get LottoVision running in 5 minutes!

## Step 1: Install Dependencies (1 min)

```bash
flutter pub get
```

## Step 2: Generate Code (1 min)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- Hive TypeAdapters for local storage
- Riverpod provider code (if any)

## Step 3: Add Permissions (2 min)

### Android: `android/app/src/main/AndroidManifest.xml`

Add inside `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS: `ios/Runner/Info.plist`

Add inside `<dict>` tag:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan lottery tickets</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to select ticket images</string>
```

## Step 4: Run the App (1 min)

```bash
flutter run
```

That's it! The app should now launch on your device/emulator.

---

## What Works Out of the Box

✅ UI screens and navigation
✅ Camera/Gallery image picker
✅ OCR text extraction
✅ Ticket parsing (basic)
✅ Local storage
✅ Theme switching
✅ Multilanguage support

## What Needs Configuration

⚠️ **Lottery Results Fetching**
- The NLB website parser needs to be customized
- File: `lib/services/lottery/lottery_results_service.dart`
- Action: Inspect https://www.nlb.lk and update HTML parsing logic

⚠️ **Firebase (Optional)**
- Create Firebase project
- Download config files
- Place in android/ios folders

## Testing the App

### Test Ticket Scanning

1. Launch app
2. Tap "Scan Ticket"
3. Take a photo of any text with numbers
4. View extracted information

**Note**: For best results, use clear, well-lit photos of actual lottery tickets

### Test OCR Extraction

The app will attempt to extract:
- Lottery type (Mahajana, Govisetha, etc.)
- Draw number
- Draw date
- Number sets
- Serial number

### Mock Results (Development)

The `LotteryResultsService` has a `getMockResult()` method that returns fake results for testing.

## Common Issues

### Issue: "Missing generated files"
**Solution**: Run build_runner again
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Camera permission denied"
**Solution**:
- Check permissions in manifest files
- On Android 6.0+, grant permission when prompted
- Or manually enable in Settings > App > Permissions

### Issue: "OCR not detecting text"
**Solution**:
- Ensure good lighting
- Photo should be clear and focused
- Text should be horizontal (not rotated)
- Try enhancing image quality in phone camera settings

### Issue: "Cannot parse lottery type"
**Solution**:
- The ticket must contain recognizable keywords
- Check `lottery_parser.dart` for supported keywords
- Add more keywords if needed

## File Locations Reference

| What to Edit | File Path |
|-------------|-----------|
| Add new lottery type | `lib/core/constants/lottery_types.dart` |
| Update OCR patterns | `lib/services/ocr/lottery_parser.dart` |
| Fix NLB result parsing | `lib/services/lottery/lottery_results_service.dart` |
| Change theme colors | `lib/core/theme/app_theme.dart` |
| Add translations | `lib/l10n/app_*.arb` |
| Modify UI | `lib/presentation/screens/` |

## Development Workflow

1. **Make Code Changes**
2. **Hot Reload**: Press `r` in terminal (or use IDE button)
3. **Full Restart**: Press `R` in terminal (needed for some changes)

## Building Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Next Steps

1. **Customize for Real Tickets**
   - Test with actual Sri Lankan lottery tickets
   - Fine-tune OCR patterns
   - Update lottery configurations

2. **Implement NLB Results**
   - Study NLB website structure
   - Update web scraping logic
   - Add result caching

3. **Add Features**
   - History screen implementation
   - Results screen with live data
   - Statistics and analytics
   - Push notifications

4. **Polish UI/UX**
   - Add loading animations
   - Improve error messages
   - Add onboarding screens
   - Implement settings

## Getting Help

- Check `README.md` for detailed documentation
- Check `PROJECT_STRUCTURE.md` for architecture overview
- Review inline code comments
- Check Flutter docs: https://flutter.dev

---

Happy coding! 🚀
