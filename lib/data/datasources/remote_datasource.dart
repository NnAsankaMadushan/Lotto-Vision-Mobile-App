import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/domain/entities/lottery_result.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';
import 'package:lotto_vision/services/lottery/lottery_results_service.dart';
import 'package:lotto_vision/services/ocr/lottery_parser.dart';
import 'package:lotto_vision/services/ocr/ocr_service.dart';
import 'package:uuid/uuid.dart';

abstract class RemoteDataSource {
  Future<LotteryTicket> scanTicket(String imagePath);
  Future<LotteryResult> fetchLatestResult(LotteryType type);
  Future<LotteryResult> fetchResultByDraw(LotteryType type, int drawNumber);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final OCRService ocrService;
  final LotteryParser lotteryParser;
  final LotteryResultsService resultsService;
  final Uuid uuid;

  RemoteDataSourceImpl({
    required this.ocrService,
    required this.lotteryParser,
    required this.resultsService,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<LotteryTicket> scanTicket(String imagePath) async {
    // Preprocess image for better OCR
    final enhancedPath = await ocrService.preprocessImage(imagePath);

    // Extract text from image
    final text = await ocrService.extractText(enhancedPath);

    // Parse lottery ticket information
    final ticketId = uuid.v4();
    final ticket = lotteryParser.parseTicket(text, ticketId, imagePath);

    return ticket;
  }

  @override
  Future<LotteryResult> fetchLatestResult(LotteryType type) async {
    return await resultsService.fetchLatestResult(type);
  }

  @override
  Future<LotteryResult> fetchResultByDraw(LotteryType type, int drawNumber) async {
    return await resultsService.fetchResultByDraw(type, drawNumber);
  }
}
