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

  // ✅ TAMBAHAN CRITICAL: Helper method untuk dapetin unique ID
  int get uniqueId {
    // Pakai key dari Hive (auto-generated oleh Hive, always unique)
    // Kalau belum di-save ke Hive, key = null, jadi pakai hashCode sebagai fallback
    return key ?? title.hashCode;
  }
}