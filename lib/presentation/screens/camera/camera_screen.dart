import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotto_vision/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lotto_vision/presentation/screens/scanner/scanner_screen.dart';
import 'package:lotto_vision/presentation/widgets/screen_theme.dart';
import 'dart:io' show Platform;

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: buildLottoBackButton(context),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: buildLottoAppBarGradient(context),
        title: LottoBrandedAppBarTitle(
          section: l10n.scanTicket,
        ),
      ),
      body: LottoGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 32),
                Text(
                  'Choose an option',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed:
                      _isProcessing ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Take Photo'),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed:
                      _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Choose from Gallery'),
                  ),
                ),
                if (_isProcessing) ...[
                  const SizedBox(height: 32),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Processing image...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request permission (Android: handle API 33+ vs older devices)
    final Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      permission = Platform.isAndroid ? Permission.photos : Permission.photos;
    }

    var status = await permission.request();

    // On Android 12 and below, gallery access is guarded by READ_EXTERNAL_STORAGE.
    if (source == ImageSource.gallery &&
        Platform.isAndroid &&
        !status.isGranted &&
        !status.isPermanentlyDenied) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission is required'
                  : 'Gallery permission is required',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ScannerScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
