// lib/core/database/models/quest_model.dart
import 'package:hive/hive.dart';

part 'quest_model.g.dart';

@HiveType(typeId: 0)
class Quest extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime deadline;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  int rewardCoins;

  Quest({
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    this.rewardCoins = 0,
  });

  // ✅ TAMBAHAN: Cek apakah misi sudah lewat deadline
  bool get isExpired {
    return DateTime.now().isAfter(deadline);
  }

  int get uniqueId {
    return key ?? title.hashCode;
  }
}