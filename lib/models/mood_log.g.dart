// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'mood_log.dart';

class MoodLogAdapter extends TypeAdapter<MoodLog> {
  @override
  final int typeId = 1;

  @override
  MoodLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodLog(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      moodIndex: fields[2] as int,
      sleepHour: fields[3] as int,
      sleepMinute: fields[4] as int,
      wakeHour: fields[5] as int,
      wakeMinute: fields[6] as int,
      stressLevel: fields[7] as int,
      notes: fields[8] as String,
      userId: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MoodLog obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.moodIndex)
      ..writeByte(3)
      ..write(obj.sleepHour)
      ..writeByte(4)
      ..write(obj.sleepMinute)
      ..writeByte(5)
      ..write(obj.wakeHour)
      ..writeByte(6)
      ..write(obj.wakeMinute)
      ..writeByte(7)
      ..write(obj.stressLevel)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.userId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
