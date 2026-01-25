import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:lotto_vision/core/errors/exceptions.dart';

class DlbResultsService {
  final Dio _dio;

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

  Future<List<DlbResultWithMeta>> fetchAllLatestResultsWithMeta() async {
    try {
      final response = await _dio.get<String>(
        '/home/',
        options: Options(responseType: ResponseType.plain),
      );

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
      final sign = values.isEmpty ? null : values.firstWhere(
          (v) => int.tryParse(v) == null,
          orElse: () => values.first);

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

  DateTime _parseDlbDate(String input) {
    // Example from site: "2026-Jan-24 Saturday"
    final cleaned = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    try {
      return DateFormat('yyyy-MMM-dd EEEE', 'en_US').parse(cleaned);
    } catch (_) {
      return DateTime.now();
    }
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
}
