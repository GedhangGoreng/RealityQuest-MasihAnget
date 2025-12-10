// lib/features/quest/quest_provider.dart
import 'package:flutter/foundation.dart';
import '../../core/database/hive_service.dart';
import '../../core/database/models/quest_model.dart';
import '../../core/services/notification_service.dart';

class QuestProvider with ChangeNotifier {
  final HiveService _hive = HiveService();
  final NotificationService _notif = NotificationService();
  final List<Quest> _quests = [];

  List<Quest> get quests => List.unmodifiable(_quests);

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

  /// ✅ MODIFIED: Toggle completion cuma bisa kalo belum expired
  Future<void> toggleCompletion(int index) async {
    if (index < 0 || index >= _quests.length) return;
    
    final quest = _quests[index];
    
    // ✅ CEK: Kalo udah expired, gabisa di-toggle sama sekali
    if (quest.isExpired) {
      print('⚠️ Quest "${quest.title}" sudah kedaluarsa, tidak bisa diubah!');
      return;
    }
    
    final becameCompleted = !quest.isCompleted;
    quest.isCompleted = becameCompleted;
    
    await _hive.updateQuest(index, quest);
    
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
    if (index < 0 || index >= _quests.length) return;
    
    final quest = _quests[index];
    await _notif.cancelAllForQuest(quest.uniqueId);
    await _hive.deleteQuest(index);
    _quests.removeAt(index);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _notif.cancelAll();
    await _hive.clearQuests();
    _quests.clear();
    notifyListeners();
  }

  /// ✅ TAMBAHAN: Helper buat cek ada expired quest
  int get expiredCount {
    return _quests.where((quest) => quest.isExpired && !quest.isCompleted).length;
  }

  /// ✅ TAMBAHAN: Auto-refresh status expired
  void refreshExpiredStatus() {
    notifyListeners();
  }
}