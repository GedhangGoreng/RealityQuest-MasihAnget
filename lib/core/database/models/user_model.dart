import 'package:hive/hive.dart';

part 'user_model.g.dart'; // pastiin path-nya sama foldernya

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  int totalCoins;

  UserModel({
    required this.username,
    this.totalCoins = 0,
  });
}
