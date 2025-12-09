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

  /// ✅ FIX CRITICAL: Tambah quest baru + schedule notifikasi smart
  Future<void> addQuest(Quest quest) async {
    // ✅ PENTING: Save dulu ke Hive biar dapet .key yang unique!
    await _hive.addQuest(quest);
    
    // ✅ Reload dari Hive biar dapet quest dengan key yang udah di-assign
    await loadQuests();
    
    // ✅ Ambil quest yang baru ditambahkan (yang terakhir di list)
    final addedQuest = _quests.last;
    
    // ✅ Schedule notifikasi SMART pakai uniqueId
    await _notif.scheduleAllForQuest(
      addedQuest.uniqueId, 
      addedQuest.title, 
      addedQuest.deadline,
    );
    
    notifyListeners();
  }

  /// Toggle completion + update coin
  Future<void> toggleCompletion(int index) async {
    if (index < 0 || index >= _quests.length) return;
    final quest = _quests[index];
    final becameCompleted = !quest.isCompleted;
    quest.isCompleted = becameCompleted;
    
    await _hive.updateQuest(index, quest);
    
    if (quest.rewardCoins != 0) {
      await _hive.addCoins(becameCompleted ? quest.rewardCoins : -quest.rewardCoins);
    }
    
    // ✅ FIX: Pakai uniqueId buat cancel/schedule notifikasi
    if (becameCompleted) {
      // Cancel semua notifikasi kalau quest selesai
      await _notif.cancelAllForQuest(quest.uniqueId);
    } else {
      // Re-schedule kalau di-unmark (dibatalin)
      await _notif.scheduleAllForQuest(
        quest.uniqueId, 
        quest.title, 
        quest.deadline,
      );
    }
    
    notifyListeners();
  }

  /// ✅ FIX: Delete quest + cancel notifikasinya pakai uniqueId
  Future<void> deleteQuest(int index) async {
    if (index < 0 || index >= _quests.length) return;
    
    final quest = _quests[index];
    
    // ✅ Cancel notifikasi pakai uniqueId SEBELUM delete
    await _notif.cancelAllForQuest(quest.uniqueId);
    
    await _hive.deleteQuest(index);
    _quests.removeAt(index);
    notifyListeners();
  }

  /// Clear all quests + cancel semua notifikasi
  Future<void> clearAll() async {
    await _notif.cancelAll();
    await _hive.clearQuests();
    _quests.clear();
    notifyListeners();
  }
}