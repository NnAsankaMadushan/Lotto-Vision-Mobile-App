import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/constants/app_constants.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';

class LotteryResultsService {
  final Dio _dio;
  final Map<String, String> _cookies = {};

  LotteryResultsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.nlbBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {
                  'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
              ),
            );

  /// Fetch the latest lottery result from NLB website
  Future<LotteryResult> fetchLatestResult(LotteryType lotteryType) async {
    try {
      final html = await _getNlbHtml(
        AppConstants.resultsEndpoint,
        queryParameters: {'LT': _nlbLotterySlug(lotteryType)},
      );

      final document = html_parser.parse(html);
      return _parseLatestResultFromResultsPage(document, lotteryType);
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
    // Legacy endpoint fallback: historically RN worked, but it may now ignore RN
    // and always return the latest draw for some lottery pages.
    try {
      final html = await _getNlbHtml(
        AppConstants.resultsEndpoint,
        queryParameters: {
          'LT': _nlbLotterySlug(lotteryType),
          'RN': drawNumber,
        },
      );

      final document = html_parser.parse(html);
      final result = _parseLatestResultFromResultsPage(document, lotteryType);
      if (result.drawNumber == drawNumber) {
        return result;
      }

      if (kDebugMode) {
        debugPrint(
          '[NLB] fetchByDraw RN ignored for ${lotteryType.name}: requested=$drawNumber got=${result.drawNumber}; falling back to history page',
        );
      }
    } catch (_) {
      // Fall through to history-page parser.
    }

    try {
      final history = await fetchHistoryResults(lotteryType, limit: 250);
      LotteryResult? match;
      for (final item in history) {
        if (item.drawNumber == drawNumber) {
          match = item;
          break;
        }
      }
      if (match != null) {
        return match;
      }
      throw const ResultsNotFoundException('Result not found for this draw');
    } catch (e) {
      throw ServerException('Failed to fetch result: ${e.toString()}');
    }
  }

  /// Fetch a batch of recent draws from NLB history page for a specific lottery.
  Future<List<LotteryResult>> fetchHistoryResults(
    LotteryType lotteryType, {
    int limit = 100,
  }) async {
    final slug = _nlbLotterySlug(lotteryType);
    if (slug.isEmpty) {
      throw const ResultsNotFoundException('Lottery is not available on NLB');
    }

    try {
      final html = await _getNlbHtml('/results/$slug');
      final document = html_parser.parse(html);
      final history = _parseHistoryResultsFromModernPage(
        document,
        lotteryType,
      );

      if (history.isNotEmpty) {
        if (limit <= 0 || history.length <= limit) {
          return history;
        }
        return history.take(limit).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NLB] history page parse failed type=${lotteryType.name} err=$e');
      }
    }

    // Fallback to latest-only endpoint.
    final latest = await fetchLatestResult(lotteryType);
    return [latest];
  }

  /// Fetch the latest results list shown on NLB results page (all lotteries on that page).
  Future<List<LotteryResult>> fetchAllLatestResults() async {
    try {
      final html = await _getNlbHtml(AppConstants.resultsEndpoint);
      final document = html_parser.parse(html);
      return _parseAllLatestResultsFromResultsPage(document);
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

  /// Fetch the latest results shown on NLB results page with UI metadata (icon + sign).
  Future<List<LotteryResultWithMeta>> fetchAllLatestResultsWithMeta() async {
    try {
      final html = await _getNlbHtml(AppConstants.resultsEndpoint);
      final document = html_parser.parse(html);
      return _parseAllLatestResultsWithMetaFromResultsPage(document);
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

  Future<String> _getNlbHtml(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // NLB uses a simple JS challenge that sets a `human` cookie and reloads.
    // We emulate that flow by extracting the token, storing cookies, and retrying.
    for (var attempt = 0; attempt < 3; attempt++) {
      if (kDebugMode) {
        debugPrint(
          '[NLB] GET $path attempt=${attempt + 1} qs=${queryParameters ?? const {}} cookies=${_cookies.keys.toList()}',
        );
      }
      final response = await _dio.get<String>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.plain,
          headers: _cookies.isEmpty ? null : {'Cookie': _cookieHeaderValue()},
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch results: ${response.statusCode}');
      }

      _mergeSetCookieHeaders(response.headers.map['set-cookie']);
      final body = response.data ?? '';
      if (kDebugMode) {
        debugPrint('[NLB] status=${response.statusCode} len=${body.length}');
      }

      final token = _extractHumanToken(body);
      if (token != null) {
        if (kDebugMode) {
          debugPrint('[NLB] found human token, retrying with cookie');
        }
        _cookies['human'] = token;
        continue;
      }

      return body;
    }

    throw const NetworkException('Failed to bypass NLB protection');
  }

  String _cookieHeaderValue() =>
      _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  void _mergeSetCookieHeaders(List<String>? setCookieHeaders) {
    if (setCookieHeaders == null) return;
    for (final header in setCookieHeaders) {
      final cookiePair = header.split(';').first.trim();
      final eqIndex = cookiePair.indexOf('=');
      if (eqIndex <= 0) continue;
      final name = cookiePair.substring(0, eqIndex).trim();
      final value = cookiePair.substring(eqIndex + 1).trim();
      if (name.isNotEmpty) {
        _cookies[name] = value;
      }
    }
  }

  String? _extractHumanToken(String html) {
    final match = RegExp(r"setCookie\('human','([^']+)'", caseSensitive: false)
        .firstMatch(html);
    return match?.group(1);
  }

  String _nlbLotterySlug(LotteryType type) {
    switch (type) {
      case LotteryType.adaKotipathi:
        // DLB-only lottery.
        return '';
      case LotteryType.adaSampatha:
        return 'ada-sampatha';
      case LotteryType.daruDiriSampatha:
        return 'daru-diri-sampatha';
      case LotteryType.delakshapathi:
        return 'delakshapathi';
      case LotteryType.mahajana:
        return 'mahajana-sampatha';
      case LotteryType.govisetha:
        return 'govisetha';
      case LotteryType.dhanaNidhanaya:
        return 'dhana-nidhanaya';
      case LotteryType.dollarFortune:
        return 'dollar-fortune';
      case LotteryType.handahana:
        return 'handahana';
      case LotteryType.jathika:
        return 'jathika-sampatha';
      case LotteryType.mega60:
        return 'mega-60';
      case LotteryType.megaMillions:
        return 'mega-millions';
      case LotteryType.megaPower:
        return 'mega-power';
      case LotteryType.neeroga:
        return 'neeroga';
      case LotteryType.nlbJaya:
        return 'nlb-jaya';
      case LotteryType.sampathRekha:
        return 'sampath-rekha';
      case LotteryType.sampathaLagnaVarama:
        return 'sampatha-lagna-varama';
      case LotteryType.sevana:
        return 'sevana';
      case LotteryType.shanida:
        return 'shanida';
      case LotteryType.subaDawasak:
        return 'suba-dawasak';
      case LotteryType.superBall:
        // DLB-only lottery; not available on NLB results page.
        return '';
      case LotteryType.superFifty:
        return 'super-fifty';
      case LotteryType.supiriVasana:
        return 'supiri-vasana';
      case LotteryType.vasana:
        return 'vasana-sampatha';
      case LotteryType.lagnaWasana:
        return 'lagna-wasana';
      case LotteryType.unknown:
        return '';
    }
  }

  LotteryResult _parseLatestResultFromResultsPage(
    dom.Document document,
    LotteryType requestedType,
  ) {
    final resultBoxes = document.querySelectorAll('li.lbox');
    final seenNames = <String>[];
    if (kDebugMode) {
      debugPrint('[NLB] parse: lbox count=${resultBoxes.length} type=${requestedType.name}');
    }

    for (final box in resultBoxes) {
      final titleSpans = box.querySelectorAll('h4 > span');
      if (titleSpans.length < 3) continue;

      final lotteryName = titleSpans[0].text.trim();
      seenNames.add(lotteryName);
      final type = LotteryType.fromString(lotteryName);
      if (type != requestedType) continue;

      final drawNumber = int.tryParse(titleSpans[1].text.trim()) ?? 0;
      final drawDateText = titleSpans[2].text.trim();
      final drawDate = _parseNlbDate(drawDateText);

      final parsedValues = _extractNlbNumbersAndSign(box);
      final numbers = parsedValues.numbers;
      final luckyLetter = parsedValues.sign;

      final config = LotteryConfig.getConfig(requestedType);
      final winningNumbers =
          config == null ? numbers : numbers.take(config.numbersCount).toList();

      if (winningNumbers.isEmpty) {
        if (kDebugMode) {
          debugPrint('[NLB] parse failed: empty numbers for ${requestedType.name} draw=$drawNumber');
        }
        throw const ServerException('Failed to parse winning numbers');
      }

      if (kDebugMode) {
        debugPrint(
          '[NLB] parsed ${requestedType.name} draw=$drawNumber date="$drawDateText" numbers=$winningNumbers letter=$luckyLetter',
        );
      }
      return LotteryResult(
        id: '${requestedType.name}_$drawNumber',
        lotteryType: requestedType,
        drawNumber: drawNumber,
        drawDate: drawDate,
        winningNumbers: winningNumbers,
        luckyLetter: luckyLetter,
        prizes: {
          for (final p in (config?.prizes ?? const <Prize>[]))
            p.name: p.estimatedAmount,
        },
        fetchedAt: DateTime.now(),
      );
    }

    if (kDebugMode) {
      debugPrint('[NLB] parse: no matching lbox found for type=${requestedType.name}');
      if (seenNames.isNotEmpty) {
        debugPrint('[NLB] parse: available names=${seenNames.join(' | ')}');
      }
    }
    throw const ResultsNotFoundException('Results not found for this lottery type');
  }

  List<LotteryResult> _parseAllLatestResultsFromResultsPage(dom.Document document) {
    final resultBoxes = document.querySelectorAll('li.lbox');
    if (kDebugMode) {
      debugPrint('[NLB] parseAll: lbox count=${resultBoxes.length}');
    }

    final results = <LotteryResult>[];
    for (final box in resultBoxes) {
      final titleSpans = box.querySelectorAll('h4 > span');
      if (titleSpans.length < 3) continue;

      final lotteryName = titleSpans[0].text.trim();
      final type = LotteryType.fromString(lotteryName);
      if (type == LotteryType.unknown) continue;

      final drawNumber = int.tryParse(titleSpans[1].text.trim()) ?? 0;
      final drawDateText = titleSpans[2].text.trim();
      final drawDate = _parseNlbDate(drawDateText);

      final parsedValues = _extractNlbNumbersAndSign(box);
      final numbers = parsedValues.numbers;

      final config = LotteryConfig.getConfig(type);
      final winningNumbers =
          config == null ? numbers : numbers.take(config.numbersCount).toList();

      if (winningNumbers.isEmpty) continue;

      results.add(
        LotteryResult(
          id: '${type.name}_$drawNumber',
          lotteryType: type,
          drawNumber: drawNumber,
          drawDate: drawDate,
          winningNumbers: winningNumbers,
          prizes: {
            for (final p in (config?.prizes ?? const <Prize>[]))
              p.name: p.estimatedAmount,
          },
          fetchedAt: DateTime.now(),
        ),
      );
    }

    results.sort((a, b) => b.drawDate.compareTo(a.drawDate));
    if (kDebugMode) {
      debugPrint('[NLB] parseAll: results count=${results.length}');
    }
    return results;
  }

  List<LotteryResult> _parseHistoryResultsFromModernPage(
    dom.Document document,
    LotteryType requestedType,
  ) {
    final parsedFromTable = _parseHistoryRowsFromTable(document, requestedType);
    if (parsedFromTable.isNotEmpty) {
      return parsedFromTable;
    }

    final lines = (document.body?.text ?? '')
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (kDebugMode) {
      debugPrint('[NLB] parseHistory: lines=${lines.length} type=${requestedType.name}');
    }

    final config = LotteryConfig.getConfig(requestedType);
    final seenDraws = <int>{};
    final parsed = <LotteryResult>[];
    var i = 0;

    while (i < lines.length) {
      final headerLine = lines[i];
      final drawNumber = _extractNlbHistoryDrawNumber(headerLine);
      if (drawNumber == null || drawNumber <= 0) {
        i++;
        continue;
      }

      var drawDate = _tryParseNlbHistoryDate(headerLine);
      var consumedHeaderLines = 1;
      if (drawDate == null && i + 1 < lines.length) {
        drawDate = _tryParseNlbHistoryDate(lines[i + 1]);
        if (drawDate != null) {
          consumedHeaderLines = 2;
        }
      }

      if (drawDate == null) {
        i++;
        continue;
      }

      final valueTokens = <String>[];
      valueTokens.addAll(
        _extractInlineNlbHistoryTokens(headerLine, drawNumber),
      );
      if (consumedHeaderLines == 2 && i + 1 < lines.length) {
        valueTokens.addAll(
          _extractInlineNlbHistoryTokens(lines[i + 1], drawNumber),
        );
      }

      i += consumedHeaderLines;
      while (i < lines.length) {
        final line = lines[i];
        if (_extractNlbHistoryDrawNumber(line) != null &&
            _tryParseNlbHistoryDate(line) != null) {
          break;
        }
        if (_extractNlbHistoryDrawNumber(line) != null &&
            i + 1 < lines.length &&
            _tryParseNlbHistoryDate(lines[i + 1]) != null) {
          break;
        }
        if (line.toUpperCase() == 'MORE') {
          i++;
          break;
        }
        valueTokens.addAll(_tokenizeNlbHistoryValueLine(line));
        i++;
      }

      if (!seenDraws.add(drawNumber)) continue;
      final values = _parseNlbHistoryTokens(
        valueTokens,
        lotteryType: requestedType,
      );
      final winningNumbers = config == null
          ? values.numbers
          : values.numbers.take(config.numbersCount).toList();
      if (winningNumbers.isEmpty) continue;

      parsed.add(
        LotteryResult(
          id: '${requestedType.name}_$drawNumber',
          lotteryType: requestedType,
          drawNumber: drawNumber,
          drawDate: drawDate,
          winningNumbers: winningNumbers,
          luckyLetter: values.sign,
          prizes: {
            for (final p in (config?.prizes ?? const <Prize>[]))
              p.name: p.estimatedAmount,
          },
          fetchedAt: DateTime.now(),
        ),
      );
    }

    parsed.sort((a, b) {
      final byDate = b.drawDate.compareTo(a.drawDate);
      if (byDate != 0) return byDate;
      return b.drawNumber.compareTo(a.drawNumber);
    });
    if (kDebugMode) {
      debugPrint('[NLB] parseHistory: parsed=${parsed.length} type=${requestedType.name}');
    }
    return parsed;
  }

  List<String> _extractInlineNlbHistoryTokens(String line, int drawNumber) {
    var cleaned = line;
    cleaned = cleaned.replaceAll(
      RegExp(r'Draw\s*Number\s*-?', caseSensitive: false),
      ' ',
    );
    cleaned = cleaned.replaceFirst(RegExp(r'^\s*\d{3,6}'), ' ');
    cleaned = cleaned.replaceAll(
      RegExp('$drawNumber'),
      ' ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)\s+[A-Za-z]+\s+\d{1,2},\s+\d{4}',
        caseSensitive: false,
      ),
      ' ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'[A-Za-z]+\s+\d{1,2},\s+\d{4}',
        caseSensitive: false,
      ),
      ' ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\d{4}-[A-Za-z]{3}-\d{1,2}\s+(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)',
        caseSensitive: false,
      ),
      ' ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(More|Results|DrawDate|Promotional|Draw)\b', caseSensitive: false),
      ' ',
    );

    return _tokenizeNlbHistoryValueLine(cleaned);
  }

  List<LotteryResult> _parseHistoryRowsFromTable(
    dom.Document document,
    LotteryType requestedType,
  ) {
    final rows = document.querySelectorAll('tr');
    if (rows.isEmpty) return const [];

    final config = LotteryConfig.getConfig(requestedType);
    final seenDraws = <int>{};
    final parsed = <LotteryResult>[];

    for (final row in rows) {
      final cells = row.querySelectorAll('td');
      final rowText = row.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (rowText.isEmpty) continue;

      final drawCellText = cells.isNotEmpty
          ? cells[0].text.replaceAll(RegExp(r'\s+'), ' ').trim()
          : rowText;
      final drawNumber = _extractNlbHistoryDrawNumber(drawCellText.isEmpty ? rowText : drawCellText);
      if (drawNumber == null || drawNumber <= 0) continue;

      final drawDate = _tryParseNlbHistoryDate(drawCellText.isEmpty ? rowText : drawCellText) ??
          _tryParseNlbHistoryDate(rowText);
      if (drawDate == null) continue;
      if (!seenDraws.add(drawNumber)) continue;

      final tokens = <String>[];
      if (cells.length >= 2) {
        final valueCell = cells[1];
        final taggedNodes = valueCell.querySelectorAll('li, span, div, p, b, strong');
        if (taggedNodes.isNotEmpty) {
          for (final node in taggedNodes) {
            tokens.addAll(_tokenizeNlbHistoryValueLine(node.text));
          }
        } else {
          tokens.addAll(_tokenizeNlbHistoryValueLine(valueCell.text));
        }
      } else {
        tokens.addAll(_extractInlineNlbHistoryTokens(rowText, drawNumber));
      }

      final values = _parseNlbHistoryTokens(
        tokens,
        lotteryType: requestedType,
      );
      final winningNumbers = config == null
          ? values.numbers
          : values.numbers.take(config.numbersCount).toList();
      if (winningNumbers.isEmpty) continue;

      parsed.add(
        LotteryResult(
          id: '${requestedType.name}_$drawNumber',
          lotteryType: requestedType,
          drawNumber: drawNumber,
          drawDate: drawDate,
          winningNumbers: winningNumbers,
          luckyLetter: values.sign,
          prizes: {
            for (final p in (config?.prizes ?? const <Prize>[]))
              p.name: p.estimatedAmount,
          },
          fetchedAt: DateTime.now(),
        ),
      );
    }

    parsed.sort((a, b) {
      final byDate = b.drawDate.compareTo(a.drawDate);
      if (byDate != 0) return byDate;
      return b.drawNumber.compareTo(a.drawNumber);
    });
    if (kDebugMode) {
      debugPrint(
        '[NLB] parseHistoryTable: rows=${rows.length} parsed=${parsed.length} type=${requestedType.name}',
      );
      if (parsed.isEmpty) {
        final preview = rows
            .take(6)
            .map(
              (r) => r.text.replaceAll(RegExp(r'\s+'), ' ').trim(),
            )
            .where((t) => t.isNotEmpty)
            .toList();
        if (preview.isNotEmpty) {
          debugPrint('[NLB] parseHistoryTable preview: ${preview.join(' || ')}');
        }
      }
    }
    return parsed;
  }

  int? _extractNlbHistoryDrawNumber(String input) {
    final matches = RegExp(r'(\d{3,6})').allMatches(input);
    for (final match in matches) {
      final value = int.tryParse(match.group(1)!);
      if (value == null) continue;
      // Avoid accidentally taking the year.
      if (value >= 1900 && value <= 2100) continue;
      return value;
    }
    return null;
  }

  DateTime? _tryParseNlbHistoryDate(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    final candidates = <String>{
      cleaned,
    };

    final englishDate = RegExp(
      r'(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)\s+[A-Za-z]+\s+\d{1,2},\s+\d{4}',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (englishDate != null) {
      candidates.add(englishDate.group(0)!);
    }

    final monthDate = RegExp(
      r'[A-Za-z]+\s+\d{1,2},\s+\d{4}',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (monthDate != null) {
      candidates.add(monthDate.group(0)!);
    }

    final isoLike = RegExp(
      r'\d{4}-[A-Za-z]{3}-\d{1,2}\s+(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)',
      caseSensitive: false,
    ).firstMatch(cleaned);
    if (isoLike != null) {
      candidates.add(isoLike.group(0)!);
    }

    const formats = [
      'EEEE MMMM d, y',
      'MMMM d, y',
      'yyyy-MMM-dd EEEE',
    ];

    for (final candidate in candidates) {
      for (final fmt in formats) {
        try {
          return DateFormat(fmt, 'en_US').parseStrict(candidate);
        } catch (_) {}
      }
    }
    return null;
  }

  List<String> _tokenizeNlbHistoryValueLine(String line) {
    final cleaned = line.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), ' ');
    return cleaned
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  _NlbParsedValues _parseNlbHistoryTokens(
    List<String> tokens, {
    LotteryType? lotteryType,
  }) {
    final numbers = <int>[];
    String? sign;
    final expectedCount = lotteryType == null
        ? null
        : LotteryConfig.getConfig(lotteryType)?.numbersCount;

    for (final raw in tokens) {
      final token = raw.trim();
      if (token.isEmpty) continue;

      final n = int.tryParse(token);
      if (n != null) {
        if (n >= 0 && n <= 99) {
          numbers.add(n);
        } else if (RegExp(r'^\d+$').hasMatch(token)) {
          _appendDigitSequence(
            token,
            expectedCount: expectedCount,
            numbers: numbers,
          );
        }
        continue;
      }

      final letterDigits = RegExp(r'^([A-Za-z]{1,16})(\d+)$').firstMatch(token);
      if (letterDigits != null) {
        sign ??= letterDigits.group(1);
        _appendDigitSequence(
          letterDigits.group(2)!,
          expectedCount: expectedCount,
          numbers: numbers,
        );
        continue;
      }

      final digitsLetters = RegExp(r'^(\d+)([A-Za-z]{1,16})$').firstMatch(token);
      if (digitsLetters != null) {
        _appendDigitSequence(
          digitsLetters.group(1)!,
          expectedCount: expectedCount,
          numbers: numbers,
        );
        sign ??= digitsLetters.group(2);
        continue;
      }

      final lower = token.toLowerCase();
      if (_isIgnoredNlbLabel(lower)) continue;
      sign ??= token;
    }

    return _NlbParsedValues(numbers: numbers, sign: sign);
  }

  void _appendDigitSequence(
    String digits, {
    required int? expectedCount,
    required List<int> numbers,
  }) {
    if (digits.isEmpty) return;

    if (expectedCount != null && digits.length == expectedCount) {
      for (final code in digits.codeUnits) {
        numbers.add(code - 48);
      }
      return;
    }

    if (expectedCount != null && digits.length == expectedCount * 2) {
      for (var i = 0; i < digits.length; i += 2) {
        final value = int.tryParse(digits.substring(i, i + 2));
        if (value != null) {
          numbers.add(value);
        }
      }
      return;
    }

    // Fallback: parse one digit at a time when we cannot infer fixed-width groups.
    for (final code in digits.codeUnits) {
      numbers.add(code - 48);
    }
  }

  _NlbParsedValues _extractNlbNumbersAndSign(dom.Element box) {
    final numberLis = box.querySelectorAll('li');
    final numbers = <int>[];
    String? sign;
    var startedNumbers = false;

    for (final li in numberLis) {
      final text = li.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) continue;

      final normalized = text.toLowerCase();
      final title = (li.attributes['title'] ?? '').toLowerCase().trim();
      final hasNumberHint = title.startsWith('number') ||
          li.classes.any((c) => c.toLowerCase().startsWith('number'));
      final n = int.tryParse(text);

      if (n != null && hasNumberHint) {
        numbers.add(n);
        startedNumbers = true;
        continue;
      }

      // Some NLB rows omit a number title/class for one or more balls.
      if (n != null && startedNumbers) {
        numbers.add(n);
        continue;
      }

      if (startedNumbers) {
        // Stop at the first non-numeric token after the main number run.
        break;
      }

      if (sign == null && n == null && !_isIgnoredNlbLabel(normalized)) {
        sign = text;
      }
    }

    return _NlbParsedValues(numbers: numbers, sign: sign);
  }

  bool _isIgnoredNlbLabel(String text) {
    final lower = text.toLowerCase();
    return lower.contains('promotional') ||
        lower.contains('special draw') ||
        lower == 'draw' ||
        lower == 'result' ||
        lower == 'more';
  }

  DateTime _parseNlbDate(String input) {
    // Example: "Saturday January 24, 2026"
    final cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    try {
      return DateFormat('EEEE MMMM d, y', 'en_US').parse(cleaned);
    } catch (_) {
      try {
        return DateFormat('MMMM d, y', 'en_US').parse(cleaned);
      } catch (_) {
        return DateTime.now();
      }
    }
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

  List<LotteryResultWithMeta> _parseAllLatestResultsWithMetaFromResultsPage(
    dom.Document document,
  ) {
    final resultBoxes = document.querySelectorAll('li.lbox');
    if (kDebugMode) {
      debugPrint('[NLB] parseAllMeta: lbox count=${resultBoxes.length}');
    }

    final results = <LotteryResultWithMeta>[];
    for (final box in resultBoxes) {
      final titleSpans = box.querySelectorAll('h4 > span');
      if (titleSpans.length < 3) continue;

      final lotteryName = titleSpans[0].text.trim();
      final type = LotteryType.fromString(lotteryName);
      if (type == LotteryType.unknown) continue;

      final drawNumber = int.tryParse(titleSpans[1].text.trim()) ?? 0;
      final drawDateText = titleSpans[2].text.trim();
      final drawDate = _parseNlbDate(drawDateText);

      final img = box.querySelector('img');
      final logoPath = (img?.attributes['data-src'] ?? img?.attributes['src'] ?? '').trim();
      final logoUrl = logoPath.isEmpty
          ? null
          : (logoPath.startsWith('http')
              ? logoPath
              : '${AppConstants.nlbBaseUrl}/${logoPath.replaceFirst(RegExp(r'^/+'), '')}');

      final parsedValues = _extractNlbNumbersAndSign(box);
      final numbers = parsedValues.numbers;
      final sign = parsedValues.sign;

      final config = LotteryConfig.getConfig(type);
      final winningNumbers =
          config == null ? numbers : numbers.take(config.numbersCount).toList();

      if (winningNumbers.isEmpty) continue;

      results.add(
        LotteryResultWithMeta(
          result: LotteryResult(
            id: '${type.name}_$drawNumber',
            lotteryType: type,
            drawNumber: drawNumber,
            drawDate: drawDate,
            winningNumbers: winningNumbers,
            prizes: {
              for (final p in (config?.prizes ?? const <Prize>[]))
                p.name: p.estimatedAmount,
            },
            fetchedAt: DateTime.now(),
          ),
          sign: sign,
          logoUrl: logoUrl,
        ),
      );
    }

    results.sort((a, b) => b.result.drawDate.compareTo(a.result.drawDate));
    if (kDebugMode) {
      debugPrint('[NLB] parseAllMeta: results count=${results.length}');
    }
    return results;
  }
}

class LotteryResultWithMeta {
  final LotteryResult result;
  final String? sign;
  final String? logoUrl;

  const LotteryResultWithMeta({
    required this.result,
    this.sign,
    this.logoUrl,
  });
}

class _NlbParsedValues {
  final List<int> numbers;
  final String? sign;

  const _NlbParsedValues({
    required this.numbers,
    required this.sign,
  });
}
