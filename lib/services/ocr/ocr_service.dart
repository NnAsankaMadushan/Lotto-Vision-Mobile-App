import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:lotto_vision/core/errors/exceptions.dart';

class OCRService {
  final TextRecognizer _textRecognizer;

  OCRService() : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        throw const OCRException('No text detected in image');
      }

      return recognizedText.text;
    } catch (e) {
      throw OCRException('Failed to extract text: ${e.toString()}');
    }
  }

  Future<List<TextBlock>> extractTextBlocks(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return recognizedText.blocks;
    } catch (e) {
      throw OCRException('Failed to extract text blocks: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> extractStructuredText(String imagePath) async {
    try {
      final textBlocks = await extractTextBlocks(imagePath);

      final Map<String, dynamic> structuredData = {
        'fullText': '',
        'lines': <String>[],
        'numbers': <String>[],
        'dates': <String>[],
        'barcodes': <String>[],
      };

      for (var block in textBlocks) {
        for (var line in block.lines) {
          final lineText = line.text.trim();
          structuredData['lines'].add(lineText);
          structuredData['fullText'] += '$lineText\n';

          // Extract numbers (potential lottery numbers)
          final numberMatches = RegExp(r'\b\d{1,2}\b').allMatches(lineText);
          for (var match in numberMatches) {
            structuredData['numbers'].add(match.group(0)!);
          }

          // Extract dates
          final dateMatches = RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}').allMatches(lineText);
          for (var match in dateMatches) {
            structuredData['dates'].add(match.group(0)!);
          }

          // Extract draw numbers
          final drawMatches = RegExp(r'(?:Draw|දිනුම්|லாட்டரி)\s*(?:No|අංකය|எண்)?[:\s]*(\d+)', caseSensitive: false).allMatches(lineText);
          for (var match in drawMatches) {
            if (match.group(1) != null) {
              structuredData['drawNumber'] = match.group(1);
            }
          }
        }
      }

      return structuredData;
    } catch (e) {
      throw OCRException('Failed to extract structured text: ${e.toString()}');
    }
  }

  Future<String> preprocessImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw const ImageProcessingException('Failed to decode image');
      }

      // Enhance image for better OCR
      image = img.grayscale(image);
      image = img.adjustColor(image, contrast: 1.2, brightness: 1.1);
      image = img.gaussianBlur(image, radius: 1);

      // Save enhanced image
      final enhancedPath = imagePath.replaceAll('.', '_enhanced.');
      await File(enhancedPath).writeAsBytes(img.encodeJpg(image, quality: 95));

      return enhancedPath;
    } catch (e) {
      throw ImageProcessingException('Failed to preprocess image: ${e.toString()}');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
