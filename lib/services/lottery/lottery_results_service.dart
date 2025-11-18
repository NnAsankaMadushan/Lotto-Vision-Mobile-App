import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';

class LotteryResultsService {
  final Dio _dio;

  LotteryResultsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.nlbBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  /// Fetch the latest lottery result from NLB website
  Future<LotteryResult> fetchLatestResult(LotteryType lotteryType) async {
    try {
      final response = await _dio.get(AppConstants.resultsEndpoint);

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch results: ${response.statusCode}');
      }

      final document = html_parser.parse(response.data);
      return _parseResultFromHtml(document.outerHtml, lotteryType);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      throw ServerException('Failed to fetch results: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch results: ${e.toString()}');
    }
  }

  /// Fetch lottery result by draw number
  Future<LotteryResult> fetchResultByDraw(
    LotteryType lotteryType,
    int drawNumber,
  ) async {
    try {
      // This is a placeholder - actual implementation depends on NLB API/website structure
      final response = await _dio.get(
        '${AppConstants.resultsEndpoint}?draw=$drawNumber',
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch result for draw $drawNumber');
      }

      final document = html_parser.parse(response.data);
      return _parseResultFromHtml(document.outerHtml, lotteryType, drawNumber);
    } catch (e) {
      throw ServerException('Failed to fetch result: ${e.toString()}');
    }
  }

  /// Parse lottery result from HTML
  LotteryResult _parseResultFromHtml(
    String html,
    LotteryType lotteryType, [
    int? drawNumber,
  ]) {
    try {
      final document = html_parser.parse(html);

      // Extract lottery data based on type
      // This is a simplified example - actual parsing depends on website structure
      final winningNumbers = _extractWinningNumbers(document.outerHtml);
      final extractedDrawNumber = drawNumber ?? _extractDrawNumber(document.outerHtml);
      final drawDate = _extractDrawDate(document.outerHtml);
      final prizes = _extractPrizes(document.outerHtml);

      return LotteryResult(
        id: '${lotteryType.name}_$extractedDrawNumber',
        lotteryType: lotteryType,
        drawNumber: extractedDrawNumber,
        drawDate: drawDate,
        winningNumbers: winningNumbers,
        prizes: prizes,
        fetchedAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException('Failed to parse result: ${e.toString()}');
    }
  }

  List<int> _extractWinningNumbers(String html) {
    // Extract winning numbers using regex patterns
    // Pattern example: class="winning-number">12</span>
    final pattern = RegExp(r'winning-number["\']?>(\d{1,2})<');
    final matches = pattern.allMatches(html);

    final numbers = matches
        .map((m) => int.tryParse(m.group(1) ?? ''))
        .where((n) => n != null)
        .cast<int>()
        .toList();

    if (numbers.isEmpty) {
      // Fallback: try to extract from table cells
      final tablePattern = RegExp(r'<td[^>]*>(\d{1,2})</td>');
      final tableMatches = tablePattern.allMatches(html);
      return tableMatches
          .map((m) => int.tryParse(m.group(1) ?? ''))
          .where((n) => n != null)
          .cast<int>()
          .take(6)
          .toList();
    }

    return numbers;
  }

  int _extractDrawNumber(String html) {
    final pattern = RegExp(r'draw[:\s#]*(\d+)', caseSensitive: false);
    final match = pattern.firstMatch(html);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  DateTime _extractDrawDate(String html) {
    final pattern = RegExp(r'(\d{1,2})[-/](\d{1,2})[-/](\d{4})');
    final match = pattern.firstMatch(html);

    if (match != null) {
      try {
        return DateTime(
          int.parse(match.group(3)!),
          int.parse(match.group(2)!),
          int.parse(match.group(1)!),
        );
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  Map<String, double> _extractPrizes(String html) {
    // Extract prize information from HTML
    // This is a placeholder - actual implementation depends on website structure
    return {
      '1st Prize': 50000000.0,
      '2nd Prize': 500000.0,
      '3rd Prize': 10000.0,
      '4th Prize': 1000.0,
    };
  }

  /// Mock data for development/testing
  Future<LotteryResult> getMockResult(LotteryType lotteryType) async {
    await Future.delayed(const Duration(seconds: 1));

    return LotteryResult(
      id: '${lotteryType.name}_1234',
      lotteryType: lotteryType,
      drawNumber: 1234,
      drawDate: DateTime.now().subtract(const Duration(days: 1)),
      winningNumbers: [5, 12, 23, 34, 38, 42],
      bonusNumber: 15,
      prizes: {
        '6 Numbers': 50000000.0,
        '5 Numbers + Bonus': 5000000.0,
        '5 Numbers': 500000.0,
        '4 Numbers': 10000.0,
        '3 Numbers': 1000.0,
      },
      fetchedAt: DateTime.now(),
    );
  }
}
