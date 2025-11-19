// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LotteryResultModelAdapter extends TypeAdapter<LotteryResultModel> {
  @override
  final int typeId = 1;

  @override
  LotteryResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LotteryResultModel(
      modelId: fields[0] as String,
      lotteryTypeName: fields[1] as String,
      modelDrawNumber: fields[2] as int,
      modelDrawDate: fields[3] as DateTime,
      modelWinningNumbers: (fields[4] as List).cast<int>(),
      modelBonusNumber: fields[5] as int?,
      modelPrizes: (fields[6] as Map).cast<String, double>(),
      modelFetchedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LotteryResultModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.modelId)
      ..writeByte(1)
      ..write(obj.lotteryTypeName)
      ..writeByte(2)
      ..write(obj.modelDrawNumber)
      ..writeByte(3)
      ..write(obj.modelDrawDate)
      ..writeByte(4)
      ..write(obj.modelWinningNumbers)
      ..writeByte(5)
      ..write(obj.modelBonusNumber)
      ..writeByte(6)
      ..write(obj.modelPrizes)
      ..writeByte(7)
      ..write(obj.modelFetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotteryResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
