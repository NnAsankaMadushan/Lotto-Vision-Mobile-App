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
      if (result.drawNumber != drawNumber) {
        throw const ResultsNotFoundException('Result not found for this draw');
      }
      return result;
    } catch (e) {
      throw ServerException('Failed to fetch result: ${e.toString()}');
    }
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
      case LotteryType.unknown:
        return '';
    }
  }

  LotteryResult _parseLatestResultFromResultsPage(
    dom.Document document,
    LotteryType requestedType,
  ) {
    final resultBoxes = document.querySelectorAll('li.lbox');
    if (kDebugMode) {
      debugPrint('[NLB] parse: lbox count=${resultBoxes.length} type=${requestedType.name}');
    }

    for (final box in resultBoxes) {
      final titleSpans = box.querySelectorAll('h4 > span');
      if (titleSpans.length < 3) continue;

      final lotteryName = titleSpans[0].text.trim();
      final type = LotteryType.fromString(lotteryName);
      if (type != requestedType) continue;

      final drawNumber = int.tryParse(titleSpans[1].text.trim()) ?? 0;
      final drawDateText = titleSpans[2].text.trim();
      final drawDate = _parseNlbDate(drawDateText);

      final numberLis = box.querySelectorAll('li');
      final numbers = <int>[];
      for (final li in numberLis) {
        final title = (li.attributes['title'] ?? '').toLowerCase().trim();
        final isNumber = title.startsWith('number') ||
            li.classes.any((c) => c.toLowerCase().startsWith('number'));
        if (!isNumber) continue;
        final n = int.tryParse(li.text.trim());
        if (n != null) numbers.add(n);
      }

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
          '[NLB] parsed ${requestedType.name} draw=$drawNumber date="$drawDateText" numbers=$winningNumbers',
        );
      }
      return LotteryResult(
        id: '${requestedType.name}_$drawNumber',
        lotteryType: requestedType,
        drawNumber: drawNumber,
        drawDate: drawDate,
        winningNumbers: winningNumbers,
        prizes: {
          for (final p in (config?.prizes ?? const <Prize>[]))
            p.name: p.estimatedAmount,
        },
        fetchedAt: DateTime.now(),
      );
    }

    if (kDebugMode) {
      debugPrint('[NLB] parse: no matching lbox found for type=${requestedType.name}');
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

      final numberLis = box.querySelectorAll('li');
      final numbers = <int>[];
      for (final li in numberLis) {
        final title = (li.attributes['title'] ?? '').toLowerCase().trim();
        final isNumber = title.startsWith('number') ||
            li.classes.any((c) => c.toLowerCase().startsWith('number'));
        if (!isNumber) continue;
        final n = int.tryParse(li.text.trim());
        if (n != null) numbers.add(n);
      }

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

      final numberLis = box.querySelectorAll('li');
      final numbers = <int>[];
      String? sign;
      for (final li in numberLis) {
        final title = (li.attributes['title'] ?? '').toLowerCase().trim();
        final isNumber = title.startsWith('number') ||
            li.classes.any((c) => c.toLowerCase().startsWith('number'));

        final text = li.text.trim();
        final n = int.tryParse(text);
        if (isNumber && n != null) {
          numbers.add(n);
          continue;
        }

        // First non-number label in the block (e.g. Zodiac or Letter badge).
        if (sign == null && text.isNotEmpty && n == null) {
          sign = text;
        }
      }

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
