// lib/features/spin/reward_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../core/database/models/user_model.dart';

class RewardProvider with ChangeNotifier {
  Box<UserModel>? _userBox;
  
  // ✅ Inisialisasi provider dengan Hive box
  RewardProvider() {
    _initBox();
  }

  Future<void> _initBox() async {
    _userBox = Hive.box<UserModel>('userBox');
    notifyListeners();
  }

  // ✅ Ambil coin dari Hive, bukan dari variable lokal
  int get currentCoins {
    if (_userBox == null || _userBox!.isEmpty) return 0;
    return _userBox!.values.first.totalCoins;
  }

  bool get canSpin => currentCoins >= 1;

  String get notEnoughCoinsMessage => 
      "Koin kamu belum mencukupi. Selesaikan misi terlebih dahulu.";

  // ✅ Tambah coin langsung ke Hive
  Future<void> addCoins(int amount) async {
    if (_userBox == null || _userBox!.isEmpty) {
      await _userBox!.add(UserModel(username: 'Player', totalCoins: amount));
    } else {
      final user = _userBox!.values.first;
      user.totalCoins += amount;
      await user.save();
    }
    notifyListeners();
  }

  // ✅ Spend coin langsung dari Hive
  Future<void> spendCoin() async {
    if (_userBox == null || _userBox!.isEmpty) return;
    final user = _userBox!.values.first;
    if (user.totalCoins >= 1) {
      user.totalCoins -= 1;
      await user.save();
      notifyListeners();
    }
  }

  // ✅ Refund coin
  Future<void> refundCoin() async {
    await addCoins(1);
  }

  // ✅ Reset coins
  Future<void> resetCoins() async {
    if (_userBox == null || _userBox!.isEmpty) return;
    final user = _userBox!.values.first;
    user.totalCoins = 0;
    await user.save();
    notifyListeners();
  }
}