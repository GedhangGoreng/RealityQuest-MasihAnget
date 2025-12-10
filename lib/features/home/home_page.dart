// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../quest/quest_provider.dart';
import '../quest/add_quest_page.dart';
import '../spin/spin_page.dart';
import 'widgets/mission_card.dart';
import 'widgets/coin_display.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    Future.microtask(() {
      Provider.of<QuestProvider>(context, listen: false).loadQuests();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Provider.of<QuestProvider>(context, listen: false).refreshExpiredStatus();
    }
  }

  void openAddPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddQuestPage(
          onSave: (quest) async {
            await Provider.of<QuestProvider>(context, listen: false).addQuest(quest);
          },
        ),
      ),
    );
  }

  void openEditPage(int index) {
    final questProvider = Provider.of<QuestProvider>(context, listen: false);
    final quest = questProvider.quests[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddQuestPage(
          initial: quest,
          onSave: (newQuest) async {
            await questProvider.deleteQuest(index);
            await questProvider.addQuest(newQuest);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);
    final missions = questProvider.quests;
    final completed = missions.where((m) => m.isCompleted).length;
    final expiredCount = questProvider.expiredCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RealityQuest', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          
          CoinDisplay(completed: completed, total: missions.length),
          
          // ✅ Info misi kedaluarsa
          if (expiredCount > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_off, color: Colors.grey.shade600, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$expiredCount misi kedaluarsa',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
                ],
              ),
            ),
          
          const SizedBox(height: 6),
          
          ElevatedButton.icon(
            onPressed: openAddPage,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('Tambah Misi', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: missions.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada misi.\nTekan "Tambah Misi" untuk mulai!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: missions.length,
                    itemBuilder: (context, index) {
                      final quest = missions[index];
                      return MissionCard(
                        mission: quest,
                        onDone: () async {
                          await questProvider.toggleCompletion(index);
                        },
                        onFail: () async {
                          if (quest.isCompleted) {
                            await questProvider.toggleCompletion(index);
                          }
                        },
                        onEdit: () => openEditPage(index),
                        onDelete: () => questProvider.deleteQuest(index),
                      );
                    },
                  ),
          ),
          
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SpinPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Spin Reward',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}