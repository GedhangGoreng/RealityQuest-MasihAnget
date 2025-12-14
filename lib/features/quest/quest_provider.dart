// lib/features/quest/quest_provider.dart
import 'package:flutter/foundation.dart';
import '../../core/database/hive_service.dart';
import '../../core/database/models/quest_model.dart';
import '../../core/services/notification_service.dart';

class QuestProvider with ChangeNotifier {
  final HiveService _hive = HiveService();
  final NotificationService _notif = NotificationService();
  final List<Quest> _quests = [];

  List<Quest> get quests {
    // Return sorted list: Active -> Expired -> Completed
    final List<Quest> sorted = [];
    
    // 1. Active quests (not completed, not expired)
    final active = _quests.where((q) => !q.isCompleted && !q.isExpired).toList();
    active.sort((a, b) => a.deadline.compareTo(b.deadline));
    sorted.addAll(active);
    
    // 2. Expired quests (not completed, expired)
    final expired = _quests.where((q) => !q.isCompleted && q.isExpired).toList();
    expired.sort((a, b) => a.deadline.compareTo(b.deadline));
    sorted.addAll(expired);
    
    // 3. Completed quests
    final completed = _quests.where((q) => q.isCompleted).toList();
    completed.sort((a, b) => a.deadline.compareTo(b.deadline));
    sorted.addAll(completed);
    
    return List.unmodifiable(sorted);
  }

  // Getter untuk backward compatibility
  List<Quest> get allQuests => List.unmodifiable(_quests);

  Future<void> loadQuests() async {
    final loaded = await _hive.getQuests();
    _quests
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> addQuest(Quest quest) async {
    await _hive.addQuest(quest);
    await loadQuests();
    
    final addedQuest = _quests.last;
    await _notif.scheduleAllForQuest(
      addedQuest.uniqueId, 
      addedQuest.title, 
      addedQuest.deadline,
    );
    
    notifyListeners();
  }

  Future<void> toggleCompletion(int index) async {
    // Index mengacu ke sorted quests
    final sorted = quests;
    if (index < 0 || index >= sorted.length) return;
    
    final quest = sorted[index];
    
    if (quest.isExpired) {
      print('⚠️ Quest "${quest.title}" sudah kedaluarsa, tidak bisa diubah!');
      return;
    }
    
    // Cari index asli di _quests
    final originalIndex = _quests.indexWhere((q) => q.key == quest.key || q.title == quest.title);
    if (originalIndex == -1) return;
    
    final becameCompleted = !quest.isCompleted;
    _quests[originalIndex].isCompleted = becameCompleted;
    
    await _hive.updateQuest(originalIndex, _quests[originalIndex]);
    
    if (quest.rewardCoins != 0) {
      await _hive.addCoins(becameCompleted ? quest.rewardCoins : -quest.rewardCoins);
    }
    
    if (becameCompleted) {
      await _notif.cancelAllForQuest(quest.uniqueId);
    } else {
      await _notif.scheduleAllForQuest(
        quest.uniqueId, 
        quest.title, 
        quest.deadline,
      );
    }
    
    notifyListeners();
  }

  Future<void> deleteQuest(int index) async {
    // Index mengacu ke sorted quests
    final sorted = quests;
    if (index < 0 || index >= sorted.length) return;
    
    final quest = sorted[index];
    
    // Cari index asli di _quests
    final originalIndex = _quests.indexWhere((q) => q.key == quest.key || q.title == quest.title);
    if (originalIndex == -1) return;
    
    await _notif.cancelAllForQuest(quest.uniqueId);
    await _hive.deleteQuest(originalIndex);
    _quests.removeAt(originalIndex);
    
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _notif.cancelAll();
    await _hive.clearQuests();
    _quests.clear();
    notifyListeners();
  }

  int get expiredCount {
    return _quests.where((quest) => quest.isExpired && !quest.isCompleted).length;
  }

  void refreshExpiredStatus() {
    notifyListeners();
  }
}