import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ✅ IMPORT INI YANG TADI KETINGGALAN
import 'core/database/models/quest_model.dart';
import 'core/database/models/reward_model.dart';
import 'core/database/models/user_model.dart';
import 'core/services/notification_service.dart';
import 'features/quest/quest_provider.dart';
import 'features/spin/reward_provider.dart';
import 'features/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Init Hive
  await Hive.initFlutter();
  
  // Register Adapters (Cek biar ga double register)
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(QuestAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(RewardAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserModelAdapter());
  
  // Open Boxes
  await Hive.openBox<Quest>('quests');
  await Hive.openBox<Reward>('rewards');
  await Hive.openBox<UserModel>('userBox');

  // 2. Init Database Check (User default)
  final userBox = Hive.box<UserModel>('userBox');
  if (userBox.isEmpty) {
    await userBox.add(UserModel(username: 'Player', totalCoins: 0));
  }

  // 3. Init Notification Service (PENTING: Await di sini biar siap sebelum app jalan)
  final notifService = NotificationService();
  await notifService.initialize();

  // 4. Load Providers
  final questProvider = QuestProvider();
  await questProvider.loadQuests(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => questProvider),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Sambungkan navigator key biar bisa navigasi dari notifikasi
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Reality Quest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: false, // Biar style agak tegas
      ),
      home: const HomePage(),
    );
  }
}