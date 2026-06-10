// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'food_entry.dart';

class FoodEntryAdapter extends TypeAdapter<FoodEntry> {
  @override
  final int typeId = 0;

  @override
  FoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mealTime: fields[2] as String,
      foodName: fields[3] as String,
      drink: fields[4] as String,
      portion: fields[5] as String,
      symptoms: (fields[6] as List).cast<String>(),
      painLevel: fields[7] as int,
      stomachCondition: fields[8] as String,
      notes: fields[9] as String,
      userId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodEntry obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mealTime)
      ..writeByte(3)
      ..write(obj.foodName)
      ..writeByte(4)
      ..write(obj.drink)
      ..writeByte(5)
      ..write(obj.portion)
      ..writeByte(6)
      ..write(obj.symptoms)
      ..writeByte(7)
      ..write(obj.painLevel)
      ..writeByte(8)
      ..write(obj.stomachCondition)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.userId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
