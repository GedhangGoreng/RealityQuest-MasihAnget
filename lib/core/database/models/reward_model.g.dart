// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

class RewardAdapter extends TypeAdapter<Reward> {
  @override
  final int typeId = 1;

  @override
  Reward read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reward(
      name: fields[0] as String,
      value: fields[1] as int,
      isTaken: fields[2] as bool,
      takenAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Reward obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.isTaken)
      ..writeByte(3)
      ..write(obj.takenAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
