// Lottery Parser Service
import 'package:flutter/foundation.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';

class LotteryParser {
  static const Map<String, LotteryType> _lotteryKeywords = {
    'lagna wasana': LotteryType.lagnaWasana,
    'ලග්න වාසනාව': LotteryType.lagnaWasana,
    'වාසනා': LotteryType.lagnaWasana,
    'ලග්න': LotteryType.lagnaWasana,
    'ලග්නවාසනා': LotteryType.lagnaWasana,
    'lagna': LotteryType.lagnaWasana,
    'wasana': LotteryType.lagnaWasana,
    'mahajana': LotteryType.mahajana,
    'මහජන': LotteryType.mahajana,
    'govisetha': LotteryType.govisetha,
    'ගෝවිසේත': LotteryType.govisetha,
    'dhana': LotteryType.dhanaNidhanaya,
    'ධන': LotteryType.dhanaNidhanaya,
    'nidhanaya': LotteryType.dhanaNidhanaya,
    'නිධානය': LotteryType.dhanaNidhanaya,
    'jathika': LotteryType.jathika,
    'ජාතික': LotteryType.jathika,
    'mega': LotteryType.megaPower,
    'මෙගා': LotteryType.megaPower,
    'shanida': LotteryType.shanida,
    'ශනිදා': LotteryType.shanida,
    'vasana': LotteryType.vasana,
    'වසන': LotteryType.vasana,
    'suba dawasak': LotteryType.subaDawasak,
    'සුබ දවසක්': LotteryType.subaDawasak,
    'සූබ': LotteryType.subaDawasak,
    'suba': LotteryType.subaDawasak,
    'super ball': LotteryType.superBall,
    'superball': LotteryType.superBall,
  };

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  LotteryType detectLotteryType(String text) {
    if (kDebugMode) {
      debugPrint('[LotteryParser] --- RAW OCR TEXT START ---');
      debugPrint(text);
      debugPrint('[LotteryParser] --- RAW OCR TEXT END ---');
    }
    final lowerText = text.toLowerCase();
    final normalizedText = _normalize(text);

    for (var entry in _lotteryKeywords.entries) {
      if (lowerText.contains(entry.key.toLowerCase())) {
        if (kDebugMode) {
          debugPrint('[LotteryParser] Detected ${entry.value.name} via keyword: ${entry.key}');
        }
        return entry.value;
      }
    }

    for (final type in LotteryType.values) {
      if (type == LotteryType.unknown) continue;
      final normalizedName = _normalize(type.displayName);
      if (normalizedName.isNotEmpty && normalizedText.contains(normalizedName)) {
        if (kDebugMode) {
          debugPrint('[LotteryParser] Detected ${type.name} via display name');
        }
        return type;
      }
    }

    if (kDebugMode) {
      debugPrint('[LotteryParser] Detection failed. Raw Text: \n$text');
    }
    throw const LotteryParseException('Could not detect lottery type');
  }

  int? extractDrawNumber(String text) {
    final lines = text.split('\n');
    final drawKeywords = ['draw', 'dran', 'dra', 'drew', 'dinum', 'no', 'number', '#', 'na', 'n.', 'ge', 'g.', 'g', 'දිනුම්', 'අංකය'];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      final trimmed = lines[i].trim();

      final numericGroups = RegExp(r'\d+').allMatches(trimmed).length;
      if (numericGroups >= 3) continue;
      if (RegExp(r'^[A-Z]\d+').hasMatch(trimmed)) continue;

      bool isMetadata = false;
      for (var kw in _lotteryKeywords.keys) {
        if (line.contains(kw)) { isMetadata = true; break; }
      }
      if (isMetadata) continue;

      for (var kw in drawKeywords) {
        // Look for keyword and then a number, possibly with a single char prefix (like g2129)
        if (line.contains(kw)) {
          // 1. Look for number on the SAME line
          // Allow single letter prefix like g2129 or n2129
          final matches = RegExp(r'[a-z]?(\d{3,5})\b').allMatches(trimmed.toLowerCase());
          for (var m in matches) {
            final valStr = m.group(1)!;
            if (valStr == '2024' || valStr == '2025' || valStr == '2026') continue;
            final val = int.tryParse(valStr);
            if (val != null) return val;
          }

          // 2. Look for number on PREVIOUS or NEXT line
          for (int dist in [-1, 1]) {
            int targetIdx = i + dist;
            if (targetIdx >= 0 && targetIdx < lines.length) {
              final nextLineText = lines[targetIdx].trim().toLowerCase();
              if (RegExp(r'\d+').allMatches(nextLineText).length > 2) continue; // Skip number sets
              
              final match = RegExp(r'[a-z]?(\d{3,5})\b').firstMatch(nextLineText);
              if (match != null) {
                final valStr = match.group(1)!;
                if (valStr != '2024' && valStr != '2025' && valStr != '2026') {
                  final val = int.tryParse(valStr);
                  if (val != null) return val;
                }
              }
            }
          }
        }
      }
    }

    // Fallback: search for any standalone 4-digit number that isn't a year
    // AND is the ONLY number on its line (likely a draw number)
    final allDigitMatches = RegExp(r'\b(\d{4})\b').allMatches(text);
    for (var m in allDigitMatches) {
      final valStr = m.group(1)!;
      if (valStr == '2024' || valStr == '2025' || valStr == '2026') continue;
      
      int offset = m.start;
      int lineStart = text.lastIndexOf('\n', offset);
      int lineEnd = text.indexOf('\n', offset);
      if (lineEnd == -1) lineEnd = text.length;
      final lineText = text.substring(lineStart == -1 ? 0 : lineStart + 1, lineEnd).toLowerCase();
      
      // If line has multiple numbers, it's probably a number set. skip.
      if (RegExp(r'\d+').allMatches(lineText).length > 1) continue;
      if (RegExp(r'[a-z]\d+').hasMatch(lineText)) continue;

      bool isMetadata = false;
      for (var kw in _lotteryKeywords.keys) { if (lineText.contains(kw)) { isMetadata = true; break; } }
      if (!isMetadata && valStr != '5601') {
        final val = int.tryParse(valStr);
        if (val != null) return val;
      }
    }
    return null;
  }

  DateTime? extractDrawDate(String text) {
    // Pattern: DD/MM/YYYY or DD-MM-YYYY
    final patterns = [
      RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})'),
      RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        try {
          if (pattern == patterns[0]) {
            // DD/MM/YYYY
            final day = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final year = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          } else {
            // YYYY/MM/DD
            final year = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            final day = int.parse(match.group(3)!);
            return DateTime(year, month, day);
          }
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  List<List<int>> extractNumberSets(String text, LotteryType lotteryType) {
    if (kDebugMode) {
      debugPrint('[LotteryParser] Extracting number sets for ${lotteryType.name}');
    }
    final config = LotteryConfig.getConfig(lotteryType);
    if (config == null) {
      throw LotteryParseException('No configuration for ${lotteryType.displayName}');
    }

    final List<List<int>> numberSets = [];
    final lines = text.split('\n');

    for (var line in lines) {
      final lowerLine = line.toLowerCase();

      bool isMetadataLine = false;
      for (var entry in _lotteryKeywords.entries) {
        if (lowerLine.contains(entry.key)) {
          isMetadataLine = true;
          break;
        }
      }

      if (!isMetadataLine) {
        final ignoreKeywords = ['draw', 'dran', 'date', 'serial', 'ticket', 'rs', 'l40'];
        for (var kw in ignoreKeywords) {
          if (lowerLine.contains(kw)) {
            isMetadataLine = true;
            break;
          }
        }
      }

      if (isMetadataLine) continue;

      final numbers = extractNumbersFromLine(line, config);
      if (numbers.isNotEmpty && numbers.length == config.numbersCount) {
        // Validate numbers are in range
        if (numbers.every((n) => n >= config.minNumber && n <= config.maxNumber)) {
          if (kDebugMode) {
            debugPrint('[LotteryParser] Found valid number set: $numbers from line: "$line"');
          }
          numberSets.add(numbers);
        }
      }
    }

    if (numberSets.isEmpty) {
      throw const LotteryParseException('No valid number sets found');
    }

    return numberSets;
  }

  List<int> extractNumbersFromLine(String line, LotteryConfig config) {
    final numbers = <int>[];

    // Clean line: remove non-numeric chars except spaces
    final cleanedLine = line.replaceAll(RegExp(r'[^0-9]'), ' ');
    
    // Split by whitespace
    final parts = cleanedLine.split(RegExp(r'\s+'));

    for (var part in parts) {
      if (part.isEmpty) continue;

      // If part is 1 or 2 digits, it's a direct match
      if (part.length <= 2) {
        final num = int.tryParse(part);
        if (num != null && num >= config.minNumber && num <= config.maxNumber) {
          numbers.add(num);
        }
      } 
      // If part is longer (e.g. "415664"), OCR joined them. Split into pairs.
      else if (part.length % 2 == 0 || part.length > 2) {
        for (int i = 0; i < part.length; i += 2) {
          if (i + 1 < part.length) {
            final pair = part.substring(i, i + 2);
            final num = int.tryParse(pair);
            if (num != null && num >= config.minNumber && num <= config.maxNumber) {
              numbers.add(num);
            }
          } else {
            // Handle trailing single digit if needed
            final single = part.substring(i);
            final num = int.tryParse(single);
            if (num != null && num >= config.minNumber && num <= config.maxNumber) {
              numbers.add(num);
            }
          }
        }
      }
    }

    return numbers;
  }

  String? extractLuckySign(String text) {
    // Zodiac signs in English and Sinhala
    final zodiacSigns = {
      // English: Sinhala
      'aries': 'මේෂ',
      'taurus': 'වෘෂභ',
      'gemini': 'මිතුන',
      'cancer': 'කටක',
      'leo': 'සිංහ',
      'virgo': 'කන්‍යා',
      'libra': 'තුලා',
      'scorpio': 'වෘශ්චික',
      'sagittarius': 'ධනු',
      'capricorn': 'මකර',
      'aquarius': 'කුම්භ',
      'pisces': 'මීන',
    };

    final lines = text.split('\n');
    String? foundLetter;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();

      // 1. Check for single capital letter alone (e.g., "G" or "GGG")
      if (RegExp(r'^[A-Z]$').hasMatch(trimmed)) {
        foundLetter = trimmed;
      } else if (RegExp(r'^([A-Z])\1\1$').hasMatch(trimmed)) {
        foundLetter = trimmed[0];
      }

      // 2. Check for Zodiac signs (English or Sinhala)
      for (var entry in zodiacSigns.entries) {
        if (lower.contains(entry.key) || trimmed.contains(entry.value)) {
          return entry.key.toUpperCase();
        }
      }

      // 3. Check for leading capital letter on a line with numbers (e.g., "Q 39 41 56")
      // This is common in many lottery formats where the letter is part of the number row.
      final leadingLetterMatch = RegExp(r'^([A-Z])[\s\d]').firstMatch(trimmed);
      if (leadingLetterMatch != null) {
        foundLetter = leadingLetterMatch.group(1);
      }
    }
    return foundLetter;
  }

  String? extractSerialNumber(String text) {
    // Pattern: Serial numbers are usually alphanumeric
    final patterns = [
      RegExp(r'serial[:\s]*([A-Z0-9]{6,15})', caseSensitive: false),
      RegExp(r'ticket[:\s]*([A-Z0-9]{6,15})', caseSensitive: false),
      RegExp(r'\b([A-Z]{2}\d{8,12})\b'),
      RegExp(r'\b(\d{10,16})\b'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }

    return null;
  }

  LotteryTicket parseTicket(String text, String ticketId, String? imagePath) {
    if (kDebugMode) {
      debugPrint('[LotteryParser] Starting to parse ticket text');
    }
    try {
      final lotteryType = detectLotteryType(text);
      final drawNumber = extractDrawNumber(text);
      final drawDate = extractDrawDate(text);
      final numberSets = extractNumberSets(text, lotteryType);
      final luckyLetter = extractLuckySign(text);
      final serialNumber = extractSerialNumber(text);

      if (kDebugMode) {
        debugPrint('[LotteryParser] Parse successful: type=${lotteryType.name}, draw=#$drawNumber, date=$drawDate, letter=$luckyLetter, serial=$serialNumber');
      }

      if (drawNumber == null) {
        throw const LotteryParseException('Could not extract draw number');
      }

      return LotteryTicket(
        id: ticketId,
        lotteryType: lotteryType,
        drawNumber: drawNumber,
        drawDate: drawDate ?? DateTime.now(),
        numberSets: numberSets,
        luckyLetter: luckyLetter,
        serialNumber: serialNumber,
        imageUrl: imagePath,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LotteryParser] Parse error: $e');
      }
      if (e is LotteryParseException) rethrow;
      throw LotteryParseException('Failed to parse ticket: ${e.toString()}');
    }
  }
}
