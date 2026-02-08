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
          final drawMatches = RegExp(r'(?:Draw|දිනුම්|ලාட்டරි)\s*(?:No|අංකය|எண்)?[:\s]*(\d+)', caseSensitive: false).allMatches(lineText);
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
    // Return original path to avoid memory-intensive processing in Dart.
    // ML Kit's native implementation is much more memory-efficient and 
    // handles varying image qualities well without needing manual contrast adjustments.
    return imagePath;
  }

  String _withEnhancedSuffix(String imagePath) {
    final lastSlash = imagePath.lastIndexOf('/');
    final lastBackslash = imagePath.lastIndexOf('\\');
    final lastSeparator = lastSlash > lastBackslash ? lastSlash : lastBackslash;

    final dir = lastSeparator >= 0 ? imagePath.substring(0, lastSeparator + 1) : '';
    final fileName = lastSeparator >= 0 ? imagePath.substring(lastSeparator + 1) : imagePath;

    final lastDot = fileName.lastIndexOf('.');
    if (lastDot <= 0) {
      return '$dir${fileName}_enhanced';
    }

    final base = fileName.substring(0, lastDot);
    final ext = fileName.substring(lastDot); // includes "."
    return '$dir${base}_enhanced$ext';
  }

  void dispose() {
    _textRecognizer.close();
  }
}
