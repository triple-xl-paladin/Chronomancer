// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimerEntryAdapter extends TypeAdapter<TimerEntry> {
  @override
  final int typeId = 0;

  @override
  TimerEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimerEntry(
      label: fields[0] as String,
      originalSeconds: fields[1] as int,
      remainingSeconds: fields[2] as int,
      isRunning: fields[3] as bool,
      groupName: fields[4] as String?,
      nextTimerId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TimerEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.originalSeconds)
      ..writeByte(2)
      ..write(obj.remainingSeconds)
      ..writeByte(3)
      ..write(obj.isRunning)
      ..writeByte(4)
      ..write(obj.groupName)
      ..writeByte(5)
      ..write(obj.nextTimerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
