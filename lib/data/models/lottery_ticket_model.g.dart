// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_ticket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LotteryTicketModelAdapter extends TypeAdapter<LotteryTicketModel> {
  @override
  final int typeId = 0;

  @override
  LotteryTicketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LotteryTicketModel(
      modelId: fields[0] as String,
      lotteryTypeName: fields[1] as String,
      modelDrawNumber: fields[2] as int,
      modelDrawDate: fields[3] as DateTime,
      modelNumberSets: (fields[4] as List)
          .map((dynamic e) => (e as List).cast<int>())
          .toList(),
      modelSerialNumber: fields[5] as String?,
      modelBarcode: fields[6] as String?,
      modelImageUrl: fields[7] as String?,
      modelScannedAt: fields[8] as DateTime,
      modelIsChecked: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LotteryTicketModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.modelId)
      ..writeByte(1)
      ..write(obj.lotteryTypeName)
      ..writeByte(2)
      ..write(obj.modelDrawNumber)
      ..writeByte(3)
      ..write(obj.modelDrawDate)
      ..writeByte(4)
      ..write(obj.modelNumberSets)
      ..writeByte(5)
      ..write(obj.modelSerialNumber)
      ..writeByte(6)
      ..write(obj.modelBarcode)
      ..writeByte(7)
      ..write(obj.modelImageUrl)
      ..writeByte(8)
      ..write(obj.modelScannedAt)
      ..writeByte(9)
      ..write(obj.modelIsChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotteryTicketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
