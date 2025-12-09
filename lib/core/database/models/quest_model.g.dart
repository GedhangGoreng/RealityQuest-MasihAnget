// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_model.dart';

class QuestAdapter extends TypeAdapter<Quest> {
  @override
  final int typeId = 0;

  @override
  Quest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quest(
      title: fields[0] as String,
      deadline: fields[1] as DateTime,
      isCompleted: fields[2] as bool,
      rewardCoins: fields.containsKey(3) ? fields[3] as int : 0,
    );
  }

  @override
  void write(BinaryWriter writer, Quest obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.deadline)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.rewardCoins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
