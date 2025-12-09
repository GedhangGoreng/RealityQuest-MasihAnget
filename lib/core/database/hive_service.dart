// lib/core/database/hive_service.dart
import 'package:hive/hive.dart';
import 'models/quest_model.dart';
import 'models/reward_model.dart';
import 'models/user_model.dart';

class HiveService {
  // Singleton pattern
  HiveService._internal();
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;

  // Box names
  static const String _questBox = 'quests';
  static const String _rewardBox = 'rewards';
  static const String _userBox = 'userBox';

  // ==== BOX GETTERS ====

  Box<Quest> get questBox {
    if (!Hive.isBoxOpen(_questBox)) {
      throw Exception("Hive box '$_questBox' belum dibuka. Pastikan dipanggil di main.dart sebelum digunakan.");
    }
    return Hive.box<Quest>(_questBox);
  }

  Box<Reward> get rewardBox {
    if (!Hive.isBoxOpen(_rewardBox)) {
      throw Exception("Hive box '$_rewardBox' belum dibuka. Pastikan dipanggil di main.dart sebelum digunakan.");
    }
    return Hive.box<Reward>(_rewardBox);
  }

  Box<UserModel> get userBox {
    if (!Hive.isBoxOpen(_userBox)) {
      throw Exception("Hive box '$_userBox' belum dibuka. Pastikan dipanggil di main.dart sebelum digunakan.");
    }
    return Hive.box<UserModel>(_userBox);
  }

  // ==== QUEST METHODS ====

  Future<List<Quest>> getQuests() async => questBox.values.toList();

  Future<void> addQuest(Quest quest) async => await questBox.add(quest);

  Future<void> updateQuest(int index, Quest updatedQuest) async =>
      await questBox.putAt(index, updatedQuest);

  Future<void> deleteQuest(int index) async => await questBox.deleteAt(index);

  Future<void> clearQuests() async => await questBox.clear();

  // ==== REWARD METHODS ====

  Future<List<Reward>> getRewards() async => rewardBox.values.toList();

  Future<void> addReward(Reward reward) async => await rewardBox.add(reward);

  Future<void> updateReward(int index, Reward reward) async =>
      await rewardBox.putAt(index, reward);

  Future<void> deleteReward(int index) async => await rewardBox.deleteAt(index);

  Future<void> clearRewards() async => await rewardBox.clear();

  // ==== USER METHODS ====

  /// Ambil user aktif pertama (karena app cuma 1 user)
  Future<UserModel> getUser() async {
    if (userBox.isEmpty) {
      final newUser = UserModel(username: 'Player', totalCoins: 0);
      await userBox.add(newUser);
      return newUser;
    }
    return userBox.values.first;
  }

  /// Tambah coin ke user aktif
  Future<void> addCoins(int amount) async {
    final user = await getUser();
    user.totalCoins += amount;
    await user.save();
  }

  /// Reset coin user (opsional)
  Future<void> resetCoins() async {
    final user = await getUser();
    user.totalCoins = 0;
    await user.save();
  }
}
