import 'package:hive/hive.dart';

part 'reward_model.g.dart';

@HiveType(typeId: 1)
class Reward extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int value; // bisa jumlah coin atau nilai reward lain

  @HiveField(2)
  bool isTaken;

  @HiveField(3)
  DateTime? takenAt; // nullable biar aman

  Reward({
    required this.name,
    required this.value,
    this.isTaken = false,
    this.takenAt,
  });
}
