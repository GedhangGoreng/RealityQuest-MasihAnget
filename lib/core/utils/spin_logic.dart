// lib/core/utils/spin_logic.dart
import 'dart:math';
import '../../core/database/hive_service.dart';
import '../../core/database/models/reward_model.dart';

class SpinLogic {
  final HiveService _hive = HiveService();
  final Random _random = Random();

  Future<List<Reward>> getRewards() async {
    return await _hive.getRewards();
  }

  Future<Reward?> spinOnce() async {
    final rewards = await _hive.getRewards();
    final available = rewards.where((r) => r.isTaken == false).toList();

    if (available.isEmpty) return null;

    final selected = available[_random.nextInt(available.length)];

    // tandai dan simpan
    selected.isTaken = true;
    selected.takenAt = DateTime.now();
    await selected.save();

    // ✅ PENTING: JANGAN tambah koin disini!
    // Koin udah di-spend di _startSpin()
    // Kalau reward kasih bonus koin (selain ZONK), baru tambah:
    // if (selected.value > 0) {
    //   await _hive.addCoins(selected.value);
    // }

    return selected;
  }

  Future<void> addReward(String name, {int value = 0}) async {
    final r = Reward(name: name, value: value, isTaken: false, takenAt: null);
    await _hive.addReward(r);
  }

  Future<void> resetAllRewards() async {
    final rewards = await _hive.getRewards();
    for (var r in rewards) {
      r.isTaken = false;
      r.takenAt = null;
      await r.save();
    }
  }
}