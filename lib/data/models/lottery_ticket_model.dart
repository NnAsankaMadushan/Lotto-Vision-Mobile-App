import 'package:hive/hive.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_ticket.dart';

part 'lottery_ticket_model.g.dart';

@HiveType(typeId: 0)
class LotteryTicketModel extends LotteryTicket {
  @HiveField(0)
  final String modelId;

  @HiveField(1)
  final String lotteryTypeName;

  @HiveField(2)
  final int modelDrawNumber;

  @HiveField(3)
  final DateTime modelDrawDate;

  @HiveField(4)
  final List<List<int>> modelNumberSets;

  @HiveField(5)
  final String? modelLuckyLetter;

  @HiveField(6)
  final String? modelSerialNumber;

  @HiveField(7)
  final String? modelBarcode;

  @HiveField(8)
  final String? modelImageUrl;

  @HiveField(9)
  final DateTime modelScannedAt;

  @HiveField(10)
  final bool modelIsChecked;

  @HiveField(11)
  final Map? modelCheckResultMap;

  LotteryTicketModel({
    required this.modelId,
    required this.lotteryTypeName,
    required this.modelDrawNumber,
    required this.modelDrawDate,
    required this.modelNumberSets,
    this.modelLuckyLetter,
    this.modelSerialNumber,
    this.modelBarcode,
    this.modelImageUrl,
    required this.modelScannedAt,
    this.modelIsChecked = false,
    this.modelCheckResultMap,
  }) : super(
          id: modelId,
          lotteryType: LotteryType.unknown,
          drawNumber: modelDrawNumber,
          drawDate: modelDrawDate,
          numberSets: modelNumberSets,
          luckyLetter: modelLuckyLetter,
          serialNumber: modelSerialNumber,
          barcode: modelBarcode,
          imageUrl: modelImageUrl,
          scannedAt: modelScannedAt,
          isChecked: modelIsChecked,
          checkResult: modelCheckResultMap != null
              ? CheckResult.fromMap(Map<String, dynamic>.from(modelCheckResultMap!))
              : null,
        );

  factory LotteryTicketModel.fromEntity(LotteryTicket ticket) {
    return LotteryTicketModel(
      modelId: ticket.id,
      lotteryTypeName: ticket.lotteryType.name,
      modelDrawNumber: ticket.drawNumber,
      modelDrawDate: ticket.drawDate,
      modelNumberSets: ticket.numberSets,
      modelLuckyLetter: ticket.luckyLetter,
      modelSerialNumber: ticket.serialNumber,
      modelBarcode: ticket.barcode,
      modelImageUrl: ticket.imageUrl,
      modelScannedAt: ticket.scannedAt,
      modelIsChecked: ticket.isChecked,
      modelCheckResultMap: ticket.checkResult?.toMap(),
    );
  }

  LotteryTicket toEntity() {
    return LotteryTicket(
      id: modelId,
      lotteryType: LotteryType.values.firstWhere(
        (e) => e.name == lotteryTypeName,
        orElse: () => LotteryType.unknown,
      ),
      drawNumber: modelDrawNumber,
      drawDate: modelDrawDate,
      numberSets: modelNumberSets,
      luckyLetter: modelLuckyLetter,
      serialNumber: modelSerialNumber,
      barcode: modelBarcode,
      imageUrl: modelImageUrl,
      scannedAt: modelScannedAt,
      isChecked: modelIsChecked,
      checkResult: modelCheckResultMap != null
          ? CheckResult.fromMap(Map<String, dynamic>.from(modelCheckResultMap!))
          : null,
    );
  }

  factory LotteryTicketModel.fromMap(DataMap map) {
    return LotteryTicketModel(
      modelId: map['id'] as String,
      lotteryTypeName: map['lotteryType'] as String,
      modelDrawNumber: map['drawNumber'] as int,
      modelDrawDate: DateTime.parse(map['drawDate'] as String),
      modelNumberSets: (map['numberSets'] as List)
          .map((set) => (set as List).map((n) => n as int).toList())
          .toList(),
      modelLuckyLetter: map['luckyLetter'] as String?,
      modelSerialNumber: map['serialNumber'] as String?,
      modelBarcode: map['barcode'] as String?,
      modelImageUrl: map['imageUrl'] as String?,
      modelScannedAt: DateTime.parse(map['scannedAt'] as String),
      modelIsChecked: map['isChecked'] as bool? ?? false,
      modelCheckResultMap: map['checkResult'] as Map?,
    );
  }

  DataMap toMap() {
    return {
      'id': modelId,
      'lotteryType': lotteryTypeName,
      'drawNumber': modelDrawNumber,
      'drawDate': modelDrawDate.toIso8601String(),
      'numberSets': modelNumberSets,
      'luckyLetter': modelLuckyLetter,
      'serialNumber': modelSerialNumber,
      'barcode': modelBarcode,
      'imageUrl': modelImageUrl,
      'scannedAt': modelScannedAt.toIso8601String(),
      'isChecked': modelIsChecked,
      'checkResult': modelCheckResultMap,
    };
  }
}
