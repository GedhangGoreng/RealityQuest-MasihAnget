// lib/features/home/widgets/coin_display.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/database/models/user_model.dart';

class CoinDisplay extends StatelessWidget {
  final int completed;
  final int total;

  const CoinDisplay({
    required this.completed,
    required this.total,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserModel>('userBox').listenable(),
      builder: (context, Box<UserModel> box, _) {
        // Ambil user pertama dari box
        final user = box.values.isNotEmpty ? box.values.first : null;
        final coins = user?.totalCoins ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🪙 = $coins',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$completed / $total Misi'),
              ),
            ],
          ),
        );
      },
    );
  }
}