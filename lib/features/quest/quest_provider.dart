// lib/features/quest/quest_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/database/hive_service.dart';
import '../../core/database/models/quest_model.dart';
import '../../core/services/notification_service.dart';

class QuestProvider with ChangeNotifier {
  final HiveService _hive = HiveService();
  final NotificationService _notif = NotificationService();
  final List<Quest> _quests = [];
  Timer? _expiryTimer;
  
  // 🔥 FLAG UNTUK CEK APAKAH SUDAH NOTIFY TENTANG EXPIRED QUEST
  bool _hasExpiredNotified = false;

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

  QuestProvider() {
    // ✅ START TIMER 5 DETIK SAAT PROVIDER DIBUAT
    _startExpiryTimer();
  }

  void _startExpiryTimer() {
    // 🔥 CEK SETIAP 5 DETIK
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkForNewExpiredQuests();
    });
    if (kDebugMode) {
      print('⏰ Expiry timer started (1 aja seconds interval)');
    }
  }

  void _checkForNewExpiredQuests() {
    // Cek apakah ada quest yang expired dan belum completed
    final hasExpiredNow = _quests.any((quest) => 
        !quest.isCompleted && quest.isExpired);
    
    // 🔥 LOGIC: Hanya trigger notifyListeners() jika STATUS BERUBAH
    if (hasExpiredNow && !_hasExpiredNotified) {
      // ADA expired quest DAN BELUM PERNAH DI-NOTIFY
      if (kDebugMode) {
        print('🔄 First time expired detection - updating UI');
      }
      _hasExpiredNotified = true;
      notifyListeners();
    } 
    else if (!hasExpiredNow && _hasExpiredNotified) {
      // SEMUA expired quest sudah di-handle (completed atau deleted)
      // Reset flag untuk next time
      if (kDebugMode) {
        print('🔄 All expired quests handled, resetting flag');
      }
      _hasExpiredNotified = false;
    }
    // Kalau hasExpiredNow == true DAN _hasExpiredNotified == true
    // -> Sudah di-notify sebelumnya, skip (ga infinite loop)
  }

  Future<void> loadQuests() async {
    final loaded = await _hive.getQuests();
    _quests
      ..clear()
      ..addAll(loaded);
    
    // 🔥 RESET FLAG SETIAP LOAD QUESTS
    _hasExpiredNotified = _quests.any((q) => !q.isCompleted && q.isExpired);
    
    notifyListeners();
  }

  Future<void> addQuest(Quest quest) async {
    await _hive.addQuest(quest);
    await loadQuests(); // loadQuests() akan handle flag reset
    
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
      if (kDebugMode) {
        print('⚠️ Quest "${quest.title}" sudah kedaluarsa, tidak bisa diubah!');
      }
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
    
    // 🔥 CEK ULANG STATUS EXPIRED SETELAH TOGGLE
    _checkForNewExpiredQuests();
    
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
    
    // 🔥 CEK ULANG STATUS EXPIRED SETELAH DELETE
    _checkForNewExpiredQuests();
    
    notifyListeners();
  }

  /// ✅ NEW METHOD: Update quest by Hive key (robust, no duplicate)
  /// FIX 3 - Untuk menghilangkan bug duplikat saat edit
  Future<void> updateQuestByKey({
    required int? questKey,
    required Quest newQuest,
  }) async {
    if (questKey == null) {
      if (kDebugMode) {
        print('⚠️ Quest key is null, falling back to add');
      }
      await addQuest(newQuest);
      return;
    }
    
    // Cari quest lama berdasarkan Hive key
    final oldIndex = _quests.indexWhere((q) => q.key == questKey);
    if (oldIndex == -1) {
      if (kDebugMode) {
        print('⚠️ Old quest not found with key $questKey, adding new');
      }
      await addQuest(newQuest);
      return;
    }
    
    final oldQuest = _quests[oldIndex];
    
    if (kDebugMode) {
      print('🔄 Updating quest (key: $questKey): "${oldQuest.title}" → "${newQuest.title}"');
    }
    
    // Cancel notifikasi lama
    await _notif.cancelAllForQuest(oldQuest.uniqueId);
    
    // Delete quest lama dari Hive
    await _hive.deleteQuest(oldIndex);
    
    // Remove dari list lokal
    _quests.removeAt(oldIndex);
    
    // Add quest baru ke Hive
    await _hive.addQuest(newQuest);
    
    // Tambah ke list lokal
    _quests.add(newQuest);
    
    // Schedule notifikasi baru
    await _notif.scheduleAllForQuest(
      newQuest.uniqueId,
      newQuest.title,
      newQuest.deadline,
    );
    
    // Cek status expired
    _checkForNewExpiredQuests();
    
    // Update UI
    notifyListeners();
    
    if (kDebugMode) {
      print('✅ Quest updated successfully (key: $questKey)');
    }
  }

  /// ✅ HELPER: Get quest by Hive key
  Quest? getQuestByKey(int? key) {
    if (key == null) return null;
    try {
      return _quests.firstWhere((q) => q.key == key);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _notif.cancelAll();
    await _hive.clearQuests();
    _quests.clear();
    
    // 🔥 RESET FLAG
    _hasExpiredNotified = false;
    
    notifyListeners();
  }

  int get expiredCount {
    return _quests.where((quest) => quest.isExpired && !quest.isCompleted).length;
  }

  void refreshExpiredStatus() {
    // Manual refresh dari UI (seperti dari lifecycle)
    _checkForNewExpiredQuests();
    notifyListeners();
  }

  @override
  void dispose() {
    // ⚠️ JANGAN LUPA CANCEL TIMER SAAT PROVIDER DI-DISPOSE
    _expiryTimer?.cancel();
    if (kDebugMode) {
      print('⏰ Expiry timer stopped');
    }
    super.dispose();
  }
}