import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';

class LotteryParser {
  static const Map<String, LotteryType> _lotteryKeywords = {
    'mahajana': LotteryType.mahajana,
    'මහජන': LotteryType.mahajana,
    'govisetha': LotteryType.govisetha,
    'ගෝවිසේත': LotteryType.govisetha,
    'dhana': LotteryType.dhanaNidhanaya,
    'ධන': LotteryType.dhanaNidhanaya,
    'jathika': LotteryType.jathika,
    'ජාතික': LotteryType.jathika,
    'mega': LotteryType.megaPower,
    'මෙගා': LotteryType.megaPower,
    'shanida': LotteryType.shanida,
    'ශනිදා': LotteryType.shanida,
    'vasana': LotteryType.vasana,
    'වසන': LotteryType.vasana,
  };

  LotteryType detectLotteryType(String text) {
    final lowerText = text.toLowerCase();

    for (var entry in _lotteryKeywords.entries) {
      if (lowerText.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    throw const LotteryParseException('Could not detect lottery type');
  }

  int? extractDrawNumber(String text) {
    // Pattern: "Draw No: 1234" or "දිනුම් අංකය: 1234"
    final patterns = [
      RegExp(r'draw\s*(?:no|number|#)?[:\s]*(\d+)', caseSensitive: false),
      RegExp(r'දිනුම්\s*අංකය[:\s]*(\d+)'),
      RegExp(r'லாட்டரி\s*எண்[:\s]*(\d+)'),
      RegExp(r'#(\d{4,6})'),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return int.tryParse(match.group(1)!);
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
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final year = int.parse(match.group(3)!);
          return DateTime(year, month, day);
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  List<List<int>> extractNumberSets(String text, LotteryType lotteryType) {
    final config = LotteryConfig.getConfig(lotteryType);
    if (config == null) {
      throw LotteryParseException('No configuration for ${lotteryType.displayName}');
    }

    final List<List<int>> numberSets = [];
    final lines = text.split('\n');

    for (var line in lines) {
      final numbers = extractNumbersFromLine(line, config);
      if (numbers.isNotEmpty && numbers.length == config.numbersCount) {
        // Validate numbers are in range
        if (numbers.every((n) => n >= config.minNumber && n <= config.maxNumber)) {
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

    // Match individual numbers
    final numberMatches = RegExp(r'\b(\d{1,2})\b').allMatches(line);

    for (var match in numberMatches) {
      final num = int.tryParse(match.group(1)!);
      if (num != null && num >= config.minNumber && num <= config.maxNumber) {
        numbers.add(num);
      }
    }

    return numbers;
  }

  String? extractSerialNumber(String text) {
    // Pattern: Serial numbers are usually alphanumeric
    final patterns = [
      RegExp(r'serial[:\s]*([A-Z0-9]{6,15})', caseSensitive: false),
      RegExp(r'ticket[:\s]*([A-Z0-9]{6,15})', caseSensitive: false),
      RegExp(r'\b([A-Z]{2}\d{8,12})\b'),
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
    try {
      final lotteryType = detectLotteryType(text);
      final drawNumber = extractDrawNumber(text);
      final drawDate = extractDrawDate(text);
      final numberSets = extractNumberSets(text, lotteryType);
      final serialNumber = extractSerialNumber(text);

      if (drawNumber == null) {
        throw const LotteryParseException('Could not extract draw number');
      }

      return LotteryTicket(
        id: ticketId,
        lotteryType: lotteryType,
        drawNumber: drawNumber,
        drawDate: drawDate ?? DateTime.now(),
        numberSets: numberSets,
        serialNumber: serialNumber,
        imageUrl: imagePath,
        scannedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is LotteryParseException) rethrow;
      throw LotteryParseException('Failed to parse ticket: ${e.toString()}');
    }
  }
}
