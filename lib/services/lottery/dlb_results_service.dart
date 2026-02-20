import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';

class DlbResultsService {
  final Dio _dio;
  final Map<LotteryType, String> _resolvedResultPaths = {};
  final Map<String, String> _cookies = {};

  DlbResultsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://www.dlb.lk',
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {
                  'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
              ),
            );

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

  Future<Response<String>> _dlbGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final mergedHeaders = <String, dynamic>{
      if (_cookies.isNotEmpty) 'Cookie': _cookieHeaderValue(),
      ...?headers,
    };
    final response = await _dio.get<String>(
      path,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.plain,
        headers: mergedHeaders.isEmpty ? null : mergedHeaders,
      ),
    );
    _mergeSetCookieHeaders(response.headers.map['set-cookie']);
    return response;
  }

  Future<Response<String>> _dlbPost(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
    String? contentType,
  }) async {
    final mergedHeaders = <String, dynamic>{
      if (_cookies.isNotEmpty) 'Cookie': _cookieHeaderValue(),
      ...?headers,
    };
    final response = await _dio.post<String>(
      path,
      data: data,
      options: Options(
        responseType: ResponseType.plain,
        contentType: contentType,
        headers: mergedHeaders.isEmpty ? null : mergedHeaders,
      ),
    );
    _mergeSetCookieHeaders(response.headers.map['set-cookie']);
    return response;
  }

  Future<List<DlbResultWithMeta>> fetchAllLatestResultsWithMeta() async {
    try {
      final response = await _dlbGet('/home/');

      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch DLB results: ${response.statusCode}');
      }

      final html = response.data ?? '';
      final document = html_parser.parse(html);
      return _parseLatestResults(document);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      throw ServerException('Failed to fetch DLB results: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch DLB results: ${e.toString()}');
    }
  }

  Future<List<DlbResultWithMeta>> fetchResultsPage(int page) async {
    Object? lastError;
    for (final path in _resultsPagePaths(page)) {
      try {
        final response = await _dlbGet(path);

        if (response.statusCode != 200) {
          continue;
        }

        final html = response.data ?? '';
        if (html.trim().isEmpty) continue;

        final document = html_parser.parse(html);
        final parsed = _parseResultsPage(document);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      } catch (e) {
        lastError = e;
        if (kDebugMode) {
          debugPrint('[DLB] fetch page=$page path=$path failed err=$e');
        }
      }
    }

    if (lastError is DioException) {
      final dioError = lastError as DioException;
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      throw ServerException('Failed to fetch DLB results: ${dioError.message}');
    }

    try {
      // Final attempt with canonical path for better error visibility.
      final fallbackPath = _resultsPagePaths(page).first;
      final response = await _dlbGet(fallbackPath);
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch DLB results page: ${response.statusCode}');
      }
      final html = response.data ?? '';
      final document = html_parser.parse(html);
      final parsed = _parseResultsPage(document);
      if (parsed.isNotEmpty) {
        return parsed;
      }
      throw const ServerException('Failed to parse DLB results page');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      throw ServerException('Failed to fetch DLB results: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch DLB results: ${e.toString()}');
    }
  }

  Future<List<DlbResultWithMeta>> fetchResultsByPath(String path) async {
    try {
      final response = await _dlbGet(path);
      if (response.statusCode != 200) {
        throw ServerException('Failed to fetch DLB results page: ${response.statusCode}');
      }
      final html = response.data ?? '';
      if (html.trim().isEmpty) {
        throw const ServerException('Failed to fetch DLB results page: empty body');
      }
      final document = html_parser.parse(html);
      return _parseResultsPage(document);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      throw ServerException('Failed to fetch DLB results: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to fetch DLB results: ${e.toString()}');
    }
  }

  Future<List<String>> fetchHistoryPathsForType(
    LotteryType type, {
    int maxPages = 120,
  }) async {
    if (maxPages <= 0) return const [];

    final basePath = await _resolveResultPathForType(type);
    final firstPage = await _fetchDocument(basePath);
    final paginationPaths = _extractPaginationPaths(
      firstPage,
      basePath: basePath,
      maxPages: maxPages - 1,
    );

    final paths = <String>[basePath, ...paginationPaths];
    if (kDebugMode) {
      debugPrint('[DLB] historyPaths type=${type.name} count=${paths.length} base=$basePath');
    }
    return paths;
  }

  Future<DlbHistoryBatch> fetchHistoryForType(
    LotteryType type, {
    int limit = 100,
    int maxPages = 140,
  }) async {
    if (limit <= 0) {
      return const DlbHistoryBatch(
        results: [],
        pagesFetched: 0,
        attempts: 0,
      );
    }

    const basePath = '/result/';
    final preferredLastSegment = _fallbackLastSegmentForType(type);
    final firstDoc = await _fetchDocument(basePath);

    var attempts = 1;
    var pagesFetched = 1;
    final dedup = <int, DlbResultWithMeta>{};

    void mergeResults(
      List<DlbResultWithMeta> items, {
      bool trustType = false,
    }) {
      for (final item in items) {
        if (item.drawNumber <= 0) continue;
        if (trustType) {
          final normalized = item.copyWith(name: type.displayName);
          dedup.putIfAbsent(normalized.drawNumber, () => normalized);
          if (dedup.length >= limit) break;
          continue;
        }
        final mapped = LotteryType.fromString(item.name);
        if (mapped != LotteryType.unknown && mapped != type) continue;
        final normalized = mapped == LotteryType.unknown
            ? item.copyWith(name: type.displayName)
            : item;
        dedup.putIfAbsent(normalized.drawNumber, () => normalized);
        if (dedup.length >= limit) break;
      }
    }

    final landingLatest = _parseLandingLatestForType(firstDoc, type);
    final expectedLatestDraw = landingLatest.isNotEmpty
        ? landingLatest.first.drawNumber
        : null;
    mergeResults(
      landingLatest,
      trustType: true,
    );
    if (dedup.length >= limit) {
      return DlbHistoryBatch(
        results: _dedupeAndSort(dedup.values.toList()).take(limit).toList(),
        pagesFetched: pagesFetched,
        attempts: attempts,
      );
    }

    var pagination = _extractPaginationContext(
      firstDoc,
      basePath: basePath,
      requestedMaxPages: maxPages,
      preferredLastSegment: preferredLastSegment,
    );
    pagination ??= await _discoverPaginationContext(
      document: firstDoc,
      refererPath: basePath,
      requestedMaxPages: maxPages,
      preferredLastSegment: preferredLastSegment,
      expectedLatestDraw: expectedLatestDraw,
      type: type,
    );
    if (pagination == null || pagination.maxPage <= 1) {
      return DlbHistoryBatch(
        results: _dedupeAndSort(dedup.values.toList()).take(limit).toList(),
        pagesFetched: pagesFetched,
        attempts: attempts,
      );
    }

    var emptyHits = 0;
    for (var pageNo = 1; pageNo <= pagination.maxPage; pageNo++) {
      if (dedup.length >= limit) break;
      attempts++;

      final pageResults = await _fetchPaginationResults(
        pagination: pagination,
        pageNo: pageNo,
        refererPath: basePath,
      );

      if (pageResults.isEmpty) {
        emptyHits++;
        if (emptyHits >= 10) break;
        continue;
      }

      final before = dedup.length;
      mergeResults(pageResults, trustType: true);
      if (dedup.length == before) {
        emptyHits++;
        if (emptyHits >= 10) break;
        continue;
      }
      emptyHits = 0;
      pagesFetched++;
    }

    return DlbHistoryBatch(
      results: _dedupeAndSort(dedup.values.toList()).take(limit).toList(),
      pagesFetched: pagesFetched,
      attempts: attempts,
    );
  }

  List<DlbResultWithMeta> _parseLatestResults(dom.Document document) {
    // The /home page shows a "LATEST RESULT" section with repeating blocks:
    // "<Lottery Name> - <draw> | <date>" followed by an image and a list of "######" items.
    final text = document.body?.text ?? '';
    if (kDebugMode) {
      debugPrint('[DLB] parse: bodyLen=${text.length}');
    }

    final results = <DlbResultWithMeta>[];

    // Heuristic: find headings that contain " - <digits> | <date>"
    final headings = document.querySelectorAll('h1, h2, h3, h4, p, div');
    final headerPattern = RegExp(
      r'^\s*([A-Za-z][A-Za-z\s]+?)\s*-\s*(\d+)\s*\|\s*([0-9]{4}-[A-Za-z]{3}-[0-9]{2}\s+[A-Za-z]+)\s*$',
    );

    for (final node in headings) {
      final line = node.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      final match = headerPattern.firstMatch(line);
      if (match == null) continue;

      final name = match.group(1)!.trim();
      final drawNumber = int.tryParse(match.group(2)!) ?? 0;
      final dateText = match.group(3)!.trim();
      final drawDate = _parseDlbDate(dateText);

      // Try to find a nearby image (logo) and the list of "######" items.
      dom.Element? cursor = node;
      dom.Element? logoImg;
      final values = <String>[];

      for (var i = 0; i < 20 && cursor != null; i++) {
        cursor = cursor.nextElementSibling;
        if (cursor == null) break;

        logoImg ??= cursor.querySelector('img');

        // The "######" items are rendered as list entries with that text prefix.
        final candidates = cursor.querySelectorAll('li');
        for (final li in candidates) {
          final v = li.text.replaceAll('#', '').trim();
          if (v.isEmpty) continue;
          if (v.length > 12) continue;
          values.add(v);
        }

        if (values.isNotEmpty) break;
      }

      final logoUrl = _toAbsoluteUrl(logoImg?.attributes['src']);
      String? sign;
      for (final value in values) {
        if (int.tryParse(value) == null) {
          sign = value;
          break;
        }
      }

      results.add(
        DlbResultWithMeta(
          name: name,
          drawNumber: drawNumber,
          drawDate: drawDate,
          values: values,
          sign: sign,
          logoUrl: logoUrl,
        ),
      );
    }

    // Deduplicate by name+draw.
    final seen = <String>{};
    final deduped = <DlbResultWithMeta>[];
    for (final r in results) {
      final key = '${r.name}_${r.drawNumber}';
      if (seen.add(key)) deduped.add(r);
    }

    if (kDebugMode) {
      debugPrint('[DLB] parse: results=${deduped.length}');
    }

    return deduped;
  }

  Future<dom.Document> _fetchDocument(String path) async {
    final response = await _dlbGet(path);
    if (response.statusCode != 200) {
      throw ServerException('Failed to fetch DLB results page: ${response.statusCode}');
    }
    final html = response.data ?? '';
    if (html.trim().isEmpty) {
      throw const ServerException('Failed to fetch DLB results page: empty body');
    }
    return html_parser.parse(html);
  }

  Future<String> _resolveResultPathForType(LotteryType type) async {
    final cached = _resolvedResultPaths[type];
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final document = await _fetchDocument('/result/');
      final anchors = document.querySelectorAll('a[href]');
      for (final anchor in anchors) {
        final text = anchor.text.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (text.isEmpty) continue;
        final mapped = LotteryType.fromString(text);
        if (mapped == LotteryType.unknown) continue;

        final normalizedPath = _normalizeResultPath(
          href: anchor.attributes['href'],
          basePath: '/result/',
        );
        if (normalizedPath == null) continue;
        if (!RegExp(r'^/result/\d+/?(?:\?.*)?$', caseSensitive: false)
            .hasMatch(normalizedPath)) {
          continue;
        }
        _resolvedResultPaths.putIfAbsent(mapped, () => normalizedPath);
      }
    } catch (_) {
      // Fallback below.
    }

    final resolved = _resolvedResultPaths[type] ?? _fallbackResultPathForType(type);
    _resolvedResultPaths[type] = resolved;
    return resolved;
  }

  List<String> _extractPaginationPaths(
    dom.Document document, {
    required String basePath,
    required int maxPages,
  }) {
    if (maxPages <= 0) return const [];

    final withPageNum = <_PagePath>[];
    final anchors = document.querySelectorAll('a[href]');
    for (final a in anchors) {
      final label = a.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (!RegExp(r'^\d{1,4}$').hasMatch(label)) continue;

      final normalized = _normalizeResultPath(
        href: a.attributes['href'],
        basePath: basePath,
      );
      if (normalized == null) continue;
      if (!normalized.startsWith('/result/')) continue;

      final pageNo = int.tryParse(label);
      if (pageNo == null || pageNo <= 1) continue;
      withPageNum.add(_PagePath(pageNo: pageNo, path: normalized));
    }

    withPageNum.sort((a, b) => a.pageNo.compareTo(b.pageNo));
    final deduped = <String>[];
    final seen = <String>{basePath};
    for (final item in withPageNum) {
      if (seen.add(item.path)) {
        deduped.add(item.path);
      }
      if (deduped.length >= maxPages) break;
    }
    return deduped;
  }

  String _fallbackResultPathForType(LotteryType type) {
    return '/result/';
  }

  int _fallbackLastSegmentForType(LotteryType type) {
    switch (type) {
      case LotteryType.adaKotipathi:
        return 1;
      case LotteryType.superBall:
        return 5;
      case LotteryType.lagnaWasana:
        return 11;
      case LotteryType.shanida:
        return 17;
      default:
        return 17;
    }
  }

  String? _normalizeResultPath({
    required String? href,
    required String basePath,
  }) {
    if (href == null) return null;
    final trimmed = href.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('javascript:')) return null;
    if (trimmed == '#') return null;

    final baseUri = Uri.parse('https://www.dlb.lk$basePath');
    final resolved = baseUri.resolve(trimmed);
    final path = resolved.path;
    if (path.isEmpty) return null;
    if (resolved.hasQuery) {
      return '$path?${resolved.query}';
    }
    return path;
  }

  _DlbPaginationContext? _extractPaginationContext(
    dom.Document document, {
    required String basePath,
    required int requestedMaxPages,
    int? preferredLastSegment,
  }) {
    final calls = _extractPaginationCalls(document);
    if (calls.isNotEmpty) {
      final scopedCalls = preferredLastSegment == null
          ? calls
          : calls.where((c) => c.lastSegment == preferredLastSegment).toList();
      final selectedPool = scopedCalls.isNotEmpty ? scopedCalls : calls;
      final selected = selectedPool.reduce((a, b) => a.pageNo >= b.pageNo ? a : b);
      final maxFromCalls = selectedPool
          .map((c) => c.pageNo)
          .fold<int>(0, (a, b) => a > b ? a : b);
      final maxPage = maxFromCalls <= 0
          ? requestedMaxPages
          : (maxFromCalls < requestedMaxPages ? maxFromCalls : requestedMaxPages);

      final ctx = _DlbPaginationContext(
        resultId: selected.resultId,
        lotteryId: selected.lotteryId,
        lastSegment: selected.lastSegment,
        maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
        ajaxAction: selected.ajaxAction,
        ajaxFunction: selected.functionName,
      );
      if (kDebugMode) {
        final preview = calls
            .take(4)
            .map(
              (c) =>
                  'p=${c.pageNo},r=${c.resultId},l=${c.lotteryId},s=${c.lastSegment},fn=${c.functionName ?? '-'}',
            )
            .join(' | ');
        debugPrint(
          '[DLB] pagination context from onclick base=$basePath preferredLastSegment=$preferredLastSegment scopedCalls=${scopedCalls.length} resultId=${ctx.resultId} lotteryId=${ctx.lotteryId} lastSegment=${ctx.lastSegment} maxPage=${ctx.maxPage} ajaxAction=${ctx.ajaxAction ?? '-'} fn=${ctx.ajaxFunction ?? '-'}',
        );
        debugPrint('[DLB] pagination calls preview: $preview');
      }
      return ctx;
    }

    final fromHtml = _extractPaginationContextFromHtml(
      document,
      basePath: basePath,
      requestedMaxPages: requestedMaxPages,
      preferredLastSegment: preferredLastSegment,
    );
    if (fromHtml != null) {
      if (kDebugMode) {
        debugPrint(
          '[DLB] pagination context from html base=$basePath resultId=${fromHtml.resultId} lotteryId=${fromHtml.lotteryId} lastSegment=${fromHtml.lastSegment} maxPage=${fromHtml.maxPage} ajaxAction=${fromHtml.ajaxAction ?? '-'} fn=${fromHtml.ajaxFunction ?? '-'}',
        );
      }
      return fromHtml;
    }

    final bodyText = document.body?.text ?? '';
    final resultId = _extractNumericToken(
      document,
      bodyText,
      keys: const ['resultID', 'resultId', 'resultid'],
    );
    final lotteryId = _extractNumericToken(
      document,
      bodyText,
      keys: const ['lotteryID', 'lotteryId', 'lotteryid'],
    );
    final lastSegment = _extractNumericToken(
      document,
      bodyText,
      keys: const ['lastsegment', 'lastSegment'],
    ) ??
        preferredLastSegment ??
        _extractLastSegmentFromPath(basePath);

    final maxFromButtons = _extractMaxPaginationNumber(document);
    final maxPage = maxFromButtons == null
        ? requestedMaxPages
        : (maxFromButtons < requestedMaxPages ? maxFromButtons : requestedMaxPages);

    if (resultId == null || lotteryId == null || lastSegment == null) {
      if (kDebugMode) {
        final resultCandidates = _extractNumericCandidatesFromHtml(
          document,
          keys: const ['resultID', 'resultId', 'resultid'],
        );
        final lotteryCandidates = _extractNumericCandidatesFromHtml(
          document,
          keys: const ['lotteryID', 'lotteryId', 'lotteryid'],
        );
        debugPrint(
          '[DLB] pagination context missing base=$basePath resultId=$resultId lotteryId=$lotteryId lastSegment=$lastSegment',
        );
        debugPrint(
          '[DLB] pagination token candidates resultId=${resultCandidates.take(8).toList()} lotteryId=${lotteryCandidates.take(8).toList()}',
        );
      }
      return null;
    }

    final ctx = _DlbPaginationContext(
      resultId: resultId,
      lotteryId: lotteryId,
      lastSegment: lastSegment,
      maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
      ajaxAction: _extractAjaxActionPath(document),
      ajaxFunction: null,
    );
    if (kDebugMode) {
      debugPrint(
        '[DLB] pagination context base=$basePath resultId=${ctx.resultId} lotteryId=${ctx.lotteryId} lastSegment=${ctx.lastSegment} maxPage=${ctx.maxPage} ajaxAction=${ctx.ajaxAction ?? '-'}',
      );
    }
    return ctx;
  }

  _DlbPaginationContext? _extractPaginationContextFromHtml(
    dom.Document document, {
    required String basePath,
    required int requestedMaxPages,
    int? preferredLastSegment,
  }) {
    final html = document.documentElement?.outerHtml ?? '';
    if (html.isEmpty) return null;

    final maxFromButtons = _extractMaxPaginationNumber(document);
    final maxPage = maxFromButtons == null
        ? requestedMaxPages
        : (maxFromButtons < requestedMaxPages ? maxFromButtons : requestedMaxPages);
    final defaultLastSegment =
        preferredLastSegment ?? _extractLastSegmentFromPath(basePath);

    // Some DLB pages embed ticket context in link onclicks, e.g.
    // someFn(resultID, lotteryID, lastsegment).
    final ticketCtx = _extractTicketContextFromHtml(
      html,
      preferredLastSegment: preferredLastSegment,
    );
    if (ticketCtx != null) {
      if (kDebugMode) {
        debugPrint(
          '[DLB] pagination context from ticket onclick resultId=${ticketCtx.resultId} lotteryId=${ticketCtx.lotteryId} lastSegment=${ticketCtx.lastSegment} fn=${ticketCtx.ajaxFunction ?? '-'}',
        );
      }
      return _DlbPaginationContext(
        resultId: ticketCtx.resultId,
        lotteryId: ticketCtx.lotteryId,
        lastSegment: ticketCtx.lastSegment,
        maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
        ajaxAction: _extractAjaxActionPath(document),
        ajaxFunction: ticketCtx.ajaxFunction,
      );
    }

    final callPattern = RegExp(
      r'([A-Za-z_][A-Za-z0-9_]*pagination[A-Za-z0-9_]*)\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)',
      caseSensitive: false,
    );
    final callMatch = callPattern.firstMatch(html);
    if (callMatch != null) {
      final resultId = int.tryParse(callMatch.group(3) ?? '');
      final lotteryId = int.tryParse(callMatch.group(4) ?? '');
      final lastSegment = int.tryParse(callMatch.group(5) ?? '') ?? defaultLastSegment;
      if (resultId != null && lotteryId != null && lastSegment != null) {
        if (preferredLastSegment != null && lastSegment != preferredLastSegment) {
          // Keep searching for a call that matches requested lottery segment.
        } else {
          return _DlbPaginationContext(
            resultId: resultId,
            lotteryId: lotteryId,
            lastSegment: lastSegment,
            maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
            ajaxAction: null,
            ajaxFunction: callMatch.group(1),
          );
        }
      }
    }

    final callMatches = callPattern.allMatches(html);
    for (final m in callMatches) {
      final resultId = int.tryParse(m.group(3) ?? '');
      final lotteryId = int.tryParse(m.group(4) ?? '');
      final lastSegment = int.tryParse(m.group(5) ?? '') ?? defaultLastSegment;
      if (resultId == null || lotteryId == null || lastSegment == null) continue;
      if (preferredLastSegment != null && lastSegment != preferredLastSegment) {
        continue;
      }
      return _DlbPaginationContext(
        resultId: resultId,
        lotteryId: lotteryId,
        lastSegment: lastSegment,
        maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
        ajaxAction: null,
        ajaxFunction: m.group(1),
      );
    }

    final objectPatterns = <RegExp>[
      RegExp(
        'resultID\\s*[:=]\\s*["\']?(\\d+)["\']?[^<>\\n]{0,300}?lotteryID\\s*[:=]\\s*["\']?(\\d+)["\']?[^<>\\n]{0,300}?lastsegment\\s*[:=]\\s*["\']?(\\d+)',
        caseSensitive: false,
      ),
      RegExp(
        'lotteryID\\s*[:=]\\s*["\']?(\\d+)["\']?[^<>\\n]{0,300}?resultID\\s*[:=]\\s*["\']?(\\d+)["\']?[^<>\\n]{0,300}?lastsegment\\s*[:=]\\s*["\']?(\\d+)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in objectPatterns) {
      for (final match in pattern.allMatches(html)) {
        int? resultId;
        int? lotteryId;
        int? lastSegment;
        final isResultFirst = pattern.pattern.startsWith('resultID');
        if (isResultFirst) {
          resultId = int.tryParse(match.group(1) ?? '');
          lotteryId = int.tryParse(match.group(2) ?? '');
          lastSegment = int.tryParse(match.group(3) ?? '');
        } else {
          lotteryId = int.tryParse(match.group(1) ?? '');
          resultId = int.tryParse(match.group(2) ?? '');
          lastSegment = int.tryParse(match.group(3) ?? '');
        }

        lastSegment ??= defaultLastSegment;
        if (resultId == null || lotteryId == null || lastSegment == null) continue;
        if (preferredLastSegment != null && lastSegment != preferredLastSegment) {
          continue;
        }

        return _DlbPaginationContext(
          resultId: resultId,
          lotteryId: lotteryId,
          lastSegment: lastSegment,
          maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
          ajaxAction: null,
          ajaxFunction: null,
        );
      }
    }

    return null;
  }

  _DlbPaginationContext? _extractTicketContextFromHtml(
    String html, {
    required int? preferredLastSegment,
  }) {
    final callPattern = RegExp(
      r'([A-Za-z_][A-Za-z0-9_]*)\s*\(([^)]{0,160})\)',
      caseSensitive: false,
    );

    _DlbPaginationContext? best;
    var bestScore = -1;

    for (final match in callPattern.allMatches(html)) {
      final fn = match.group(1);
      final argsText = match.group(2) ?? '';
      if (fn == null || argsText.trim().isEmpty) continue;
      final nums = RegExp(r'\d+')
          .allMatches(argsText)
          .map((m) => int.tryParse(m.group(0) ?? ''))
          .whereType<int>()
          .toList();
      if (nums.length < 3) continue;

      for (var i = 0; i <= nums.length - 3; i++) {
        final resultId = nums[i];
        final lotteryId = nums[i + 1];
        final lastSegment = nums[i + 2];
        if (lotteryId <= 0 || lotteryId > 50) continue;
        if (lastSegment <= 0 || lastSegment > 300) continue;
        if (preferredLastSegment != null && lastSegment != preferredLastSegment) {
          continue;
        }

        var score = 0;
        if (resultId >= 1000) score += 5;
        if (resultId < 100) score -= 2;
        if (lotteryId <= 10) score += 1;
        if (lotteryId > 12) score -= 2;
        if (fn.toLowerCase().contains('result')) score += 3;
        if (fn.toLowerCase().contains('load')) score += 2;
        if (fn.toLowerCase().contains('pagination')) score -= 2;

        if (score > bestScore) {
          bestScore = score;
          best = _DlbPaginationContext(
            resultId: resultId,
            lotteryId: lotteryId,
            lastSegment: lastSegment,
            maxPage: 1,
            ajaxAction: null,
            ajaxFunction: fn,
          );
        }
      }
    }
    return best;
  }

  Future<_DlbPaginationContext?> _discoverPaginationContext({
    required dom.Document document,
    required String refererPath,
    required int requestedMaxPages,
    required int preferredLastSegment,
    required int? expectedLatestDraw,
    required LotteryType type,
  }) async {
    final maxFromButtons = _extractMaxPaginationNumber(document);
    final maxPage = maxFromButtons == null
        ? requestedMaxPages
        : (maxFromButtons < requestedMaxPages ? maxFromButtons : requestedMaxPages);

    final resultCandidates = _buildResultIdCandidates(
      document,
      preferredLastSegment: preferredLastSegment,
      expectedLatestDraw: expectedLatestDraw,
    );
    final lotteryCandidates = _buildLotteryIdCandidates(
      document,
      type: type,
    );
    final ajaxAction = _extractAjaxActionPath(document);

    if (kDebugMode) {
      debugPrint(
        '[DLB] probing pagination context segment=$preferredLastSegment resultCandidates=${resultCandidates.take(10).toList()} lotteryCandidates=${lotteryCandidates.take(10).toList()} ajaxAction=${ajaxAction ?? '-'}',
      );
    }

    final probePostPaths = _buildPaginationPostPaths(
      pagination: _DlbPaginationContext(
        resultId: resultCandidates.first,
        lotteryId: lotteryCandidates.first,
        lastSegment: preferredLastSegment,
        maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
        ajaxAction: ajaxAction,
        ajaxFunction: null,
      ),
      refererPath: refererPath,
    );

    final cappedResult = resultCandidates.take(24).toList();
    final cappedLottery = lotteryCandidates.take(16).toList();
    var tries = 0;
    _DlbPaginationContext? bestContext;
    var bestScore = -1000000;

    for (final lotteryId in cappedLottery) {
      for (final resultId in cappedResult) {
        final payload = <String, dynamic>{
          'pageId': 1,
          'pagId': 1,
          'resultID': resultId,
          'resultId': resultId,
          'lotteryID': lotteryId,
          'lotteryId': lotteryId,
          'lastsegment': preferredLastSegment,
          'lastSegment': preferredLastSegment,
        };

        for (final postPath in probePostPaths) {
          tries++;
          try {
            final response = await _dlbPost(
              postPath,
              data: payload,
              contentType: Headers.formUrlEncodedContentType,
              headers: {
                'X-Requested-With': 'XMLHttpRequest',
                'Referer': 'https://www.dlb.lk$refererPath',
              },
            );
            if (response.statusCode != 200) continue;

            final body = _extractHtmlFromMaybeJson(response.data ?? '');
            if (body.trim().isEmpty) continue;
            final parsed = _parseResultsPage(html_parser.parse(body));
            if (parsed.isEmpty) continue;
            final score = _scorePaginationSample(
              parsed,
              expectedLatestDraw: expectedLatestDraw,
            );

            if (kDebugMode) {
              debugPrint(
                '[DLB] discovered pagination candidate tries=$tries path=$postPath resultId=$resultId lotteryId=$lotteryId segment=$preferredLastSegment parsed=${parsed.length} score=$score',
              );
            }
            final candidate = _DlbPaginationContext(
              resultId: resultId,
              lotteryId: lotteryId,
              lastSegment: preferredLastSegment,
              maxPage: maxPage <= 0 ? requestedMaxPages : maxPage,
              ajaxAction: ajaxAction,
              ajaxFunction: null,
            );
            if (score > bestScore) {
              bestScore = score;
              bestContext = candidate;
            }
            if (score >= 240) {
              return candidate;
            }
          } catch (_) {
            // keep probing
          }
        }
      }
    }

    if (bestContext != null) {
      if (expectedLatestDraw == null || bestScore >= 0) {
        if (kDebugMode) {
          debugPrint(
            '[DLB] selected best pagination context score=$bestScore resultId=${bestContext.resultId} lotteryId=${bestContext.lotteryId} segment=${bestContext.lastSegment}',
          );
        }
        return bestContext;
      }
      if (kDebugMode) {
        debugPrint(
          '[DLB] best pagination context rejected score=$bestScore expectedLatestDraw=$expectedLatestDraw',
        );
      }
    }

    if (kDebugMode) {
      debugPrint('[DLB] failed to discover pagination context after tries=$tries');
    }
    return null;
  }

  List<int> _buildResultIdCandidates(
    dom.Document document, {
    required int preferredLastSegment,
    required int? expectedLatestDraw,
  }) {
    final fromHtml = _extractNumericCandidatesFromHtml(
      document,
      keys: const ['resultID', 'resultId', 'resultid'],
    );
    final out = <int>{...fromHtml};
    if (expectedLatestDraw != null && expectedLatestDraw > 0) {
      out.add(expectedLatestDraw);
      out.add(expectedLatestDraw - 1);
      out.add(expectedLatestDraw + 1);
    }
    out.add(preferredLastSegment);
    out.add(0);
    out.add(1);
    return out.where((n) => n >= 0 && n <= 50000).toList();
  }

  List<int> _buildLotteryIdCandidates(
    dom.Document document, {
    required LotteryType type,
  }) {
    final fromHtml = _extractNumericCandidatesFromHtml(
      document,
      keys: const ['lotteryID', 'lotteryId', 'lotteryid'],
    );
    final out = <int>{};
    final preferred = _preferredLotteryIdForType(type);
    if (preferred != null) {
      out.add(preferred);
    }
    out.addAll(fromHtml);
    if (out.isEmpty) {
      for (var i = 1; i <= 16; i++) {
        out.add(i);
      }
    } else {
      for (var i = 1; i <= 16; i++) {
        out.add(i);
      }
    }
    return out.where((n) => n > 0 && n <= 200).toList();
  }

  int? _preferredLotteryIdForType(LotteryType type) {
    switch (type) {
      case LotteryType.lagnaWasana:
        return 2;
      case LotteryType.adaKotipathi:
        return 1;
      default:
        return null;
    }
  }

  int _scorePaginationSample(
    List<DlbResultWithMeta> parsed, {
    required int? expectedLatestDraw,
  }) {
    if (parsed.isEmpty) return -1000000;
    if (expectedLatestDraw == null || expectedLatestDraw <= 0) {
      return parsed.length;
    }

    var minDiff = 1000000;
    var containsPrevDraw = false;
    var futureHits = 0;
    var inRangeHits = 0;
    for (final item in parsed) {
      final draw = item.drawNumber;
      if (draw <= 0) continue;
      final diff = (draw - (expectedLatestDraw - 1)).abs();
      if (diff < minDiff) {
        minDiff = diff;
      }
      if (draw == expectedLatestDraw - 1) {
        containsPrevDraw = true;
      }
      if (draw > expectedLatestDraw + 10) {
        futureHits++;
      }
      if (draw <= expectedLatestDraw && draw >= expectedLatestDraw - 400) {
        inRangeHits++;
      }
    }

    var score = 0;
    score += inRangeHits * 20;
    score -= minDiff;
    score -= futureHits * 60;
    if (containsPrevDraw) {
      score += 240;
    }
    return score;
  }

  List<_DlbPaginationCall> _extractPaginationCalls(dom.Document document) {
    final calls = <_DlbPaginationCall>[];
    final clickables = document.querySelectorAll('[onclick]');
    for (final node in clickables) {
      final label = node.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      final pageNo = int.tryParse(label);
      if (pageNo == null || pageNo < 2 || pageNo > 700) continue;

      final onclick = node.attributes['onclick'] ?? '';
      if (onclick.trim().isEmpty) continue;
      final numbers = RegExp(r'\d+')
          .allMatches(onclick)
          .map((m) => int.tryParse(m.group(0) ?? ''))
          .whereType<int>()
          .toList();
      if (numbers.length < 4) continue;

      final functionName = RegExp(r'([A-Za-z_][A-Za-z0-9_]*)\s*\(')
          .firstMatch(onclick)
          ?.group(1);

      int? resultId;
      int? lotteryId;
      int? lastSegment;

      for (var i = 0; i <= numbers.length - 4; i++) {
        final possiblePage = numbers[i];
        final possibleResultId = numbers[i + 1];
        final possibleLotteryId = numbers[i + 2];
        final possibleLastSegment = numbers[i + 3];
        if (possiblePage != pageNo) continue;
        if (possibleResultId <= 0 ||
            possibleLotteryId <= 0 ||
            possibleLotteryId > 200 ||
            possibleLastSegment <= 0 ||
            possibleLastSegment > 300) {
          continue;
        }
        resultId = possibleResultId;
        lotteryId = possibleLotteryId;
        lastSegment = possibleLastSegment;
        break;
      }

      if (resultId == null || lotteryId == null || lastSegment == null) {
        final fallback = numbers.take(4).toList();
        if (fallback.length == 4) {
          resultId = fallback[1];
          lotteryId = fallback[2];
          lastSegment = fallback[3];
        }
      }

      if (resultId == null || lotteryId == null || lastSegment == null) {
        continue;
      }

      calls.add(
        _DlbPaginationCall(
          pageNo: pageNo,
          resultId: resultId,
          lotteryId: lotteryId,
          lastSegment: lastSegment,
          functionName: functionName,
          ajaxAction: _extractAjaxPathFromText(onclick),
        ),
      );
    }
    return calls;
  }

  String? _extractAjaxActionPath(dom.Document document) {
    final scripts = document.querySelectorAll('script');
    for (final script in scripts) {
      final path = _extractAjaxPathFromText(script.text);
      if (path != null) return path;
    }
    return null;
  }

  String? _extractAjaxPathFromText(String text) {
    if (text.trim().isEmpty) return null;

    final patterns = <RegExp>[
      RegExp('url\\s*:\\s*["\']([^"\']+)["\']', caseSensitive: false),
      RegExp('\\\$\\.post\\(\\s*["\']([^"\']+)["\']', caseSensitive: false),
      RegExp('\\\$\\.get\\(\\s*["\']([^"\']+)["\']', caseSensitive: false),
      RegExp('["\'](/[^"\']*pagination[^"\']*)["\']', caseSensitive: false),
      RegExp('["\']([^"\']*pagination_re[^"\']*)["\']', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      final raw = match?.group(1);
      if (raw == null || raw.trim().isEmpty) continue;
      if (raw.startsWith('http')) {
        final uri = Uri.tryParse(raw);
        if (uri != null && uri.path.isNotEmpty) {
          return uri.path;
        }
      }

      final normalized = _normalizeResultPath(
        href: raw,
        basePath: '/result/',
      );
      if (normalized != null) return normalized;
    }
    return null;
  }

  int? _extractNumericToken(
    dom.Document document,
    String bodyText, {
    required List<String> keys,
  }) {
    final loweredKeys = keys.map((k) => k.toLowerCase()).toList();

    for (final key in keys) {
      final byId = document.querySelector('#$key');
      if (byId != null) {
        final value = byId.attributes['value'] ?? byId.text;
        final n = int.tryParse(value.trim());
        if (n != null) return n;
      }
      final byName = document.querySelector('[name="$key"]');
      if (byName != null) {
        final value = byName.attributes['value'] ?? byName.text;
        final n = int.tryParse(value.trim());
        if (n != null) return n;
      }
    }

    for (final node in document.querySelectorAll('*')) {
      if (node.attributes.isEmpty) continue;
      for (final entry in node.attributes.entries) {
        final attrName = '${entry.key}'.toLowerCase();
        final attrValue = '${entry.value}'.trim();
        if (attrValue.isEmpty) continue;

        for (final key in loweredKeys) {
          if (attrName.contains(key)) {
            final exact = int.tryParse(attrValue);
            if (exact != null) return exact;

            final compact = RegExp(r'\d+').firstMatch(attrValue)?.group(0);
            final compactN = int.tryParse(compact ?? '');
            if (compactN != null) return compactN;
          }

          final embedded = RegExp(
            '$key\\s*[:=]\\s*[\'"]?(\\d+)',
            caseSensitive: false,
          ).firstMatch(attrValue);
          final embeddedN = int.tryParse(embedded?.group(1) ?? '');
          if (embeddedN != null) return embeddedN;
        }
      }
    }

    final scripts = document.querySelectorAll('script');
    for (final script in scripts) {
      final text = script.text;
      for (final key in keys) {
        final pattern = RegExp(
          '$key\\s*[:=]\\s*[\'"]?(\\d+)',
          caseSensitive: false,
        );
        final match = pattern.firstMatch(text);
        final n = int.tryParse(match?.group(1) ?? '');
        if (n != null) return n;
      }
    }

    for (final key in keys) {
      final pattern = RegExp(
        '$key\\s*[:=]\\s*[\'"]?(\\d+)',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(bodyText);
      final n = int.tryParse(match?.group(1) ?? '');
      if (n != null) return n;
    }

    final outerHtml = document.documentElement?.outerHtml ?? '';
    if (outerHtml.isNotEmpty) {
      for (final key in keys) {
        final patterns = <RegExp>[
          RegExp(
            '$key\\s*[:=]\\s*[\'"]?(\\d+)',
            caseSensitive: false,
          ),
          RegExp(
            'name\\s*=\\s*[\'"][^\'"]*$key[^\'"]*[\'"][^>]{0,200}?value\\s*=\\s*[\'"]?(\\d+)',
            caseSensitive: false,
          ),
          RegExp(
            'value\\s*=\\s*[\'"]?(\\d+)[\'"]?[^>]{0,200}?name\\s*=\\s*[\'"][^\'"]*$key[^\'"]*[\'"]',
            caseSensitive: false,
          ),
        ];
        for (final pattern in patterns) {
          final match = pattern.firstMatch(outerHtml);
          final n = int.tryParse(match?.group(1) ?? '');
          if (n != null) return n;
        }
      }
    }
    return null;
  }

  List<int> _extractNumericCandidatesFromHtml(
    dom.Document document, {
    required List<String> keys,
  }) {
    final outerHtml = document.documentElement?.outerHtml ?? '';
    if (outerHtml.isEmpty) return const [];

    final found = <int>{};
    for (final key in keys) {
      final patterns = <RegExp>[
        RegExp(
          '$key\\s*[:=]\\s*[\'"]?(\\d+)',
          caseSensitive: false,
        ),
        RegExp(
          '$key[^0-9]{0,80}(\\d+)',
          caseSensitive: false,
        ),
      ];
      for (final pattern in patterns) {
        for (final match in pattern.allMatches(outerHtml)) {
          final n = int.tryParse(match.group(1) ?? '');
          if (n != null) {
            found.add(n);
          }
        }
      }
    }

    final sorted = found.toList()..sort();
    return sorted.reversed.toList();
  }

  int? _extractLastSegmentFromPath(String path) {
    final m = RegExp(r'/result/(\d+)/?').firstMatch(path);
    return int.tryParse(m?.group(1) ?? '');
  }

  int? _extractMaxPaginationNumber(dom.Document document) {
    final values = <int>[];
    for (final node in document.querySelectorAll('a, button, li, span')) {
      final text = node.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      final n = int.tryParse(text);
      if (n == null) continue;
      if (n < 2 || n > 500) continue;
      values.add(n);
    }
    if (values.isEmpty) return null;
    values.sort();
    return values.last;
  }

  Future<List<DlbResultWithMeta>> _fetchPaginationResults({
    required _DlbPaginationContext pagination,
    required int pageNo,
    required String refererPath,
  }) async {
    final payload = <String, dynamic>{
      'pageId': pageNo,
      'pagId': pageNo,
      'resultID': pagination.resultId,
      'resultId': pagination.resultId,
      'lotteryID': pagination.lotteryId,
      'lotteryId': pagination.lotteryId,
      'lastsegment': pagination.lastSegment,
      'lastSegment': pagination.lastSegment,
    };

    final candidatePaths = _buildPaginationPostPaths(
      pagination: pagination,
      refererPath: refererPath,
    );

    for (final postPath in candidatePaths) {
      try {
        final response = await _dlbPost(
          postPath,
          data: payload,
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Referer': 'https://www.dlb.lk$refererPath',
          },
        );
        if (response.statusCode != 200) continue;

        final decodedBody = _extractHtmlFromMaybeJson(response.data ?? '');
        if (decodedBody.trim().isEmpty) continue;
        final parsed = _parseResultsPage(html_parser.parse(decodedBody));
        if (parsed.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('[DLB] pagination page=$pageNo path=$postPath parsed=${parsed.length}');
          }
          return parsed;
        }
      } catch (_) {
        // try next candidate
      }
    }
    return const [];
  }

  List<String> _buildPaginationPostPaths({
    required _DlbPaginationContext pagination,
    required String refererPath,
  }) {
    final paths = <String>[
      '/result/pagination_re',
      '/result/pagination_re/',
      '/result/pagination_re.php',
      '/result/${pagination.lastSegment}/pagination_re',
      '/result/${pagination.lastSegment}/pagination_re/',
      '/pagination_re',
      '/pagination_re/',
      if (pagination.ajaxAction != null) pagination.ajaxAction!,
      if (pagination.ajaxFunction != null) '/result/${pagination.ajaxFunction}',
      if (pagination.ajaxFunction != null) '/result/${pagination.ajaxFunction}/',
      if (pagination.ajaxFunction != null) '/${pagination.ajaxFunction}',
      if (pagination.ajaxFunction != null) '/${pagination.ajaxFunction}/',
    ];

    final dedup = <String>[];
    final seen = <String>{};
    for (final raw in paths) {
      var normalized = _normalizeResultPath(href: raw, basePath: refererPath) ?? raw;
      normalized = normalized.replaceAll('/result/result/', '/result/');
      if (seen.add(normalized)) {
        dedup.add(normalized);
      }
    }
    return dedup;
  }

  String _extractHtmlFromMaybeJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return '';
    if (!trimmed.startsWith('{')) return trimmed;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        for (final value in decoded.values) {
          if (value is String && value.contains('<')) {
            return value;
          }
        }
      }
    } catch (_) {}
    return trimmed;
  }

  List<DlbResultWithMeta> _parseResultsPage(dom.Document document) {
    final tableParsed = _parseResultsPageFromTable(document);
    if (tableParsed.isNotEmpty) {
      return tableParsed;
    }

    final regexParsed = _parseResultsPageFromRegex(document);
    if (regexParsed.isNotEmpty) {
      return regexParsed;
    }

    final lines = (document.body?.text ?? '').split('\n');
    if (kDebugMode) {
      debugPrint('[DLB] parsePage: lines=${lines.length}');
    }

    final results = <DlbResultWithMeta>[];
    String? currentName;
    int? currentDraw;
    DateTime? currentDate;
    final values = <String>[];

    void flush() {
      if (currentName == null ||
          currentDraw == null ||
          currentDate == null ||
          values.isEmpty) {
        values.clear();
        currentDraw = null;
        currentDate = null;
        return;
      }

      final sign = values.firstWhere(
        (v) => int.tryParse(v) == null,
        orElse: () => '',
      );

      results.add(
        DlbResultWithMeta(
          name: currentName!,
          drawNumber: currentDraw!,
          drawDate: currentDate!,
          values: List<String>.from(values),
          sign: sign.isEmpty ? null : sign,
          logoUrl: null,
        ),
      );

      values.clear();
      currentDraw = null;
      currentDate = null;
    }

    for (final raw in lines) {
      final trimmed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (trimmed.isEmpty) continue;

      if (_isSectionMarker(trimmed)) {
        if (trimmed.toUpperCase() == 'MORE') {
          flush();
          currentName = null;
        }
        continue;
      }

      final drawMatch = RegExp(
        r'Draw Number\s*-\s*(\d+)\s*\|\s*(.+)$',
        caseSensitive: false,
      ).firstMatch(trimmed);
      if (drawMatch != null) {
        currentDraw = int.tryParse(drawMatch.group(1) ?? '');
        currentDate = _parseDlbDate(drawMatch.group(2) ?? '');
        values.clear();
        continue;
      }

      final type = LotteryType.fromString(trimmed);
      if (type != LotteryType.unknown ||
          _looksLikeLotteryName(trimmed)) {
        if (currentName != null) {
          flush();
        }
        currentName = trimmed;
        continue;
      }

      if (currentDraw != null) {
        final value = _extractValue(trimmed);
        if (value != null) {
          values.add(value);
        }
      }
    }

    flush();
    if (kDebugMode) {
      debugPrint('[DLB] parsePage: results=${results.length}');
    }
    return results;
  }

  List<DlbResultWithMeta> _parseLandingLatestForType(
    dom.Document document,
    LotteryType type,
  ) {
    final body = document.body?.text ?? '';
    if (body.trim().isEmpty) return const [];
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const [];

    final escapedName = RegExp.escape(type.displayName);
    final pattern = RegExp(
      '$escapedName\\s+Draw\\s*Number\\s*-\\s*(\\d+)\\s*\\|\\s*([0-9]{4}-[A-Za-z]{3,9}-[0-9]{1,2}\\s*[A-Za-z]*)\\s+(.{1,140}?)(?=\\s+MORE\\b)',
      caseSensitive: false,
    );

    final match = pattern.firstMatch(normalized);
    if (match == null) return const [];

    final drawNumber = int.tryParse(match.group(1) ?? '');
    if (drawNumber == null || drawNumber <= 0) return const [];

    final drawDate = _parseDlbDate(match.group(2) ?? '');
    final tail = match.group(3) ?? '';
    final tokens = RegExp(r'[A-Za-z0-9]{1,12}')
        .allMatches(tail)
        .map((m) => m.group(0)!)
        .map(_extractValue)
        .whereType<String>()
        .toList();
    if (tokens.isEmpty) return const [];

    final sign = tokens.firstWhere(
      (v) => int.tryParse(v) == null,
      orElse: () => '',
    );

    return [
      DlbResultWithMeta(
        name: type.displayName,
        drawNumber: drawNumber,
        drawDate: drawDate,
        values: tokens,
        sign: sign.isEmpty ? null : sign,
        logoUrl: null,
      ),
    ];
  }

  List<DlbResultWithMeta> _parseResultsPageFromRegex(dom.Document document) {
    final rawText = document.body?.text ?? '';
    if (rawText.trim().isEmpty) return const [];

    final normalized = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const [];

    final pageLotteryName = _extractDlbPageLotteryName(
      rawText
          .split('\n')
          .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
          .where((line) => line.isNotEmpty)
          .toList(),
    );

    // Typical row shape:
    // 913 | 2026-Feb-18 Wednesday 09 28 48 MORE
    final pattern = RegExp(
      r'(\d{3,6})\s*\|\s*([0-9]{4}-[A-Za-z]{3}-[0-9]{2}\s+[A-Za-z]+)\s+(.{2,120}?)(?=\s+MORE\b)',
      caseSensitive: false,
    );

    final results = <DlbResultWithMeta>[];
    for (final match in pattern.allMatches(normalized)) {
      final drawNumber = int.tryParse(match.group(1) ?? '');
      if (drawNumber == null || drawNumber <= 0) continue;
      final drawDate = _parseDlbDate(match.group(2) ?? '');

      final tail = match.group(3) ?? '';
      final tokens = RegExp(r'[A-Za-z0-9]{1,12}')
          .allMatches(tail)
          .map((m) => m.group(0)!)
          .toList();
      final values = <String>[];
      for (final token in tokens) {
        final extracted = _extractValue(token);
        if (extracted != null) values.add(extracted);
      }
      if (values.isEmpty) continue;

      final sign = values.firstWhere(
        (v) => int.tryParse(v) == null,
        orElse: () => '',
      );

      results.add(
        DlbResultWithMeta(
          name: pageLotteryName,
          drawNumber: drawNumber,
          drawDate: drawDate,
          values: values,
          sign: sign.isEmpty ? null : sign,
          logoUrl: null,
        ),
      );
    }

    final deduped = _dedupeAndSort(results);
    if (kDebugMode) {
      debugPrint(
        '[DLB] parsePageRegex: parsed=${deduped.length} name=$pageLotteryName',
      );
    }
    return deduped;
  }

  List<DlbResultWithMeta> _parseResultsPageFromTable(dom.Document document) {
    final rows = document.querySelectorAll('table tr');
    if (rows.isEmpty) return const [];

    final lines = (document.body?.text ?? '')
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final pageLotteryName = _extractDlbPageLotteryName(lines);

    final results = <DlbResultWithMeta>[];
    for (final row in rows) {
      final cells = row.querySelectorAll('td');
      if (cells.length < 2) continue;

      var drawText = cells[0].text.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (drawText.isEmpty) {
        drawText = row.text.replaceAll(RegExp(r'\s+'), ' ').trim();
      }
      final drawMatch = RegExp(
        r'(\d+)\s*\|\s*([0-9]{4}-[A-Za-z]{3,9}-[0-9]{1,2}(?:\s*[A-Za-z]+)?)',
        caseSensitive: false,
      ).firstMatch(drawText);
      if (drawMatch == null) continue;

      final drawNumber = int.tryParse(drawMatch.group(1) ?? '');
      if (drawNumber == null || drawNumber <= 0) continue;
      final drawDate = _parseDlbDate(drawMatch.group(2) ?? '');

      var bestValues = <String>[];
      var bestNumericCount = 0;
      String? sign;

      for (var i = 1; i < cells.length; i++) {
        final tokens = _extractValueTokensFromCell(cells[i]);
        if (tokens.isEmpty) continue;

        final numericCount = tokens.where((t) => int.tryParse(t) != null).length;
        if (numericCount > bestNumericCount) {
          bestNumericCount = numericCount;
          bestValues = tokens;
        }

        sign ??= tokens.firstWhere(
          (t) => int.tryParse(t) == null,
          orElse: () => '',
        );
        if (sign != null && sign!.isEmpty) {
          sign = null;
        }
      }

      if (bestNumericCount == 0 || bestValues.isEmpty) continue;

      results.add(
        DlbResultWithMeta(
          name: pageLotteryName,
          drawNumber: drawNumber,
          drawDate: drawDate,
          values: bestValues,
          sign: sign,
          logoUrl: null,
        ),
      );
    }

    if (kDebugMode) {
      debugPrint(
        '[DLB] parsePageTable: rows=${rows.length} parsed=${results.length} name=$pageLotteryName',
      );
      if (results.isEmpty) {
        final preview = rows
            .take(6)
            .map((r) => r.text.replaceAll(RegExp(r'\s+'), ' ').trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (preview.isNotEmpty) {
          debugPrint('[DLB] parsePageTable preview: ${preview.join(' || ')}');
        }
      }
    }

    return _dedupeAndSort(results);
  }

  List<String> _extractValueTokensFromCell(dom.Element cell) {
    final bag = <String>[];

    final text = cell.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isNotEmpty) {
      bag.add(text);
    }

    for (final img in cell.querySelectorAll('img')) {
      final alt = (img.attributes['alt'] ?? '').trim();
      if (alt.isNotEmpty) bag.add(alt);
      final title = (img.attributes['title'] ?? '').trim();
      if (title.isNotEmpty) bag.add(title);
    }

    final out = <String>[];
    for (final part in bag) {
      final tokens = RegExp(r'[A-Za-z0-9]{1,12}')
          .allMatches(part)
          .map((m) => m.group(0)!)
          .map(_extractValue)
          .whereType<String>();
      out.addAll(tokens);
    }
    return out;
  }

  String _extractDlbPageLotteryName(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].toLowerCase().contains('draw number -')) continue;
      final sameLine = _cleanLotteryNameCandidate(lines[i]);
      if (sameLine != null) return sameLine;
      for (var j = i - 1; j >= 0 && j >= i - 6; j--) {
        final cleaned = _cleanLotteryNameCandidate(lines[j]);
        if (cleaned != null) return cleaned;
      }
    }

    for (final line in lines) {
      final cleaned = _cleanLotteryNameCandidate(line);
      if (cleaned != null) return cleaned;
    }
    return 'Unknown';
  }

  String? _cleanLotteryNameCandidate(String line) {
    var cleaned = line.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return null;

    cleaned = cleaned.replaceAll(
      RegExp(r'Draw\s*Number\s*-\s*\d+\s*\|.*$', caseSensitive: false),
      ' ',
    );
    cleaned = cleaned.replaceAll(
      RegExp(r'\b(MORE|RESULTS|MAIN|DRAW|SIGN|SPECIAL|CHANCE)\b', caseSensitive: false),
      ' ',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\b\d+\b'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (_looksLikeLotteryName(cleaned)) {
      return cleaned;
    }
    return null;
  }

  List<DlbResultWithMeta> _dedupeAndSort(List<DlbResultWithMeta> input) {
    final seen = <String>{};
    final deduped = <DlbResultWithMeta>[];
    for (final item in input) {
      final key = '${item.name}_${item.drawNumber}';
      if (seen.add(key)) {
        deduped.add(item);
      }
    }
    deduped.sort((a, b) {
      final byDate = b.drawDate.compareTo(a.drawDate);
      if (byDate != 0) return byDate;
      return b.drawNumber.compareTo(a.drawNumber);
    });
    return deduped;
  }

  DateTime _parseDlbDate(String input) {
    // Example from site: "2026-Jan-24 Saturday"
    var cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    cleaned = cleaned.replaceAll(
      RegExp(
        r'(\d{1,2})(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)',
        caseSensitive: false,
      ),
      r'$1 $2',
    );
    cleaned = cleaned.replaceAll(
      RegExp(
        r'([A-Za-z]{3,9})(Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday)',
        caseSensitive: false,
      ),
      r'$1 $2',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    const formats = [
      'yyyy-MMM-dd EEEE',
      'yyyy-MMMM-dd EEEE',
      'yyyy-MMM-dd',
      'yyyy-MMMM-dd',
    ];

    for (final fmt in formats) {
      try {
        return DateFormat(fmt, 'en_US').parseStrict(cleaned);
      } catch (_) {}
    }

    final rawDate = RegExp(r'(\d{4}-[A-Za-z]{3,9}-\d{1,2})')
        .firstMatch(cleaned)
        ?.group(1);
    if (rawDate != null) {
      for (final fmt in const ['yyyy-MMM-dd', 'yyyy-MMMM-dd']) {
        try {
          return DateFormat(fmt, 'en_US').parseStrict(rawDate);
        } catch (_) {}
      }
    }

    return DateTime.now();
  }

  List<String> _resultsPagePaths(int page) {
    if (page <= 1) {
      return const [
        '/result/1/',
        '/result/1/en',
        '/result/en',
        '/result/',
        '/result',
      ];
    }

    return [
      '/result/$page/en',
      '/result/$page/',
      '/result/$page',
    ];
  }

  bool _isSectionMarker(String line) {
    final upper = line.toUpperCase();
    if (upper == 'RESULTS' ||
        upper == 'DRAW NUMBER AND DATE' ||
        upper == 'MAIN DRAW SIGN' ||
        upper == 'MORE') {
      return true;
    }
    if (upper.contains('SPECIAL DRAW')) return true;
    return false;
  }

  bool _looksLikeLotteryName(String line) {
    if (line.length < 3 || line.length > 40) return false;
    if (line.contains(RegExp(r'\d'))) return false;
    if (line.toUpperCase() == line) return false;
    return line.contains(RegExp(r'[A-Za-z]'));
  }

  String? _extractValue(String line) {
    if (line.toUpperCase() == 'MORE') return null;
    final cleaned = line.replaceAll(RegExp(r'^#+'), '').trim();
    if (cleaned.isEmpty) return null;
    if (cleaned.length > 12) return null;
    const stopWords = {
      'DRAW',
      'NUMBER',
      'DATE',
      'RESULTS',
      'MAIN',
      'SIGN',
      'SPECIAL',
      'CHANCE',
      'MORE',
    };
    final upper = cleaned.toUpperCase();
    if (stopWords.contains(upper)) return null;
    if (RegExp(
      r'^(SUNDAY|MONDAY|TUESDAY|WEDNESDAY|THURSDAY|FRIDAY|SATURDAY)$',
      caseSensitive: false,
    ).hasMatch(cleaned)) {
      return null;
    }
    return cleaned;
  }

  String? _toAbsoluteUrl(String? src) {
    if (src == null) return null;
    final s = src.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;
    return 'https://www.dlb.lk/${s.replaceFirst(RegExp(r'^/+'), '')}';
  }
}

class DlbResultWithMeta {
  final String name;
  final int drawNumber;
  final DateTime drawDate;
  final List<String> values;
  final String? sign;
  final String? logoUrl;

  const DlbResultWithMeta({
    required this.name,
    required this.drawNumber,
    required this.drawDate,
    required this.values,
    this.sign,
    this.logoUrl,
  });

  DlbResultWithMeta copyWith({
    String? name,
    int? drawNumber,
    DateTime? drawDate,
    List<String>? values,
    String? sign,
    String? logoUrl,
  }) {
    return DlbResultWithMeta(
      name: name ?? this.name,
      drawNumber: drawNumber ?? this.drawNumber,
      drawDate: drawDate ?? this.drawDate,
      values: values ?? this.values,
      sign: sign ?? this.sign,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}

class _PagePath {
  final int pageNo;
  final String path;

  const _PagePath({
    required this.pageNo,
    required this.path,
  });
}

class _DlbPaginationContext {
  final int resultId;
  final int lotteryId;
  final int lastSegment;
  final int maxPage;
  final String? ajaxAction;
  final String? ajaxFunction;

  const _DlbPaginationContext({
    required this.resultId,
    required this.lotteryId,
    required this.lastSegment,
    required this.maxPage,
    required this.ajaxAction,
    required this.ajaxFunction,
  });
}

class _DlbPaginationCall {
  final int pageNo;
  final int resultId;
  final int lotteryId;
  final int lastSegment;
  final String? functionName;
  final String? ajaxAction;

  const _DlbPaginationCall({
    required this.pageNo,
    required this.resultId,
    required this.lotteryId,
    required this.lastSegment,
    required this.functionName,
    required this.ajaxAction,
  });
}

class DlbHistoryBatch {
  final List<DlbResultWithMeta> results;
  final int pagesFetched;
  final int attempts;

  const DlbHistoryBatch({
    required this.results,
    required this.pagesFetched,
    required this.attempts,
  });
}
