// lib/features/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/database/locale_preference.dart';
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
  bool _isEnglish = false;
  late AppLocale _locale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocale();
    
    Future.microtask(() {
      Provider.of<QuestProvider>(context, listen: false).loadQuests();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLocale() async {
    final isEnglish = await LocalePreference.getIsEnglish();
    setState(() {
      _isEnglish = isEnglish;
      _locale = AppLocale(isEnglish);
    });
  }

  Future<void> _toggleLanguage() async {
    final newValue = !_isEnglish;
    await LocalePreference.setIsEnglish(newValue);
    setState(() {
      _isEnglish = newValue;
      _locale = AppLocale(newValue);
    });
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
          locale: _locale,
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
          locale: _locale,
          onSave: (newQuest) async {
            // Cari dan hapus quest lama
            final oldIndex = questProvider.allQuests.indexWhere((q) => q.key == quest.key || q.title == quest.title);
            if (oldIndex != -1) {
              await questProvider.deleteQuest(oldIndex);
            }
            await questProvider.addQuest(newQuest);
          },
        ),
      ),
    );
  }

  Widget _buildQuestList() {
    final questProvider = Provider.of<QuestProvider>(context);
    final allQuests = questProvider.quests;
    
    if (allQuests.isEmpty) {
      return Center(
        child: Text(
          _locale.noMissions,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Kelompokkan quest
    final activeQuests = allQuests.where((q) => !q.isCompleted && !q.isExpired).toList();
    final expiredQuests = allQuests.where((q) => !q.isCompleted && q.isExpired).toList();
    final completedQuests = allQuests.where((q) => q.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (activeQuests.isNotEmpty) ...[
          _buildSectionHeader(_locale.activeSection, Colors.blue),
          ...activeQuests.map((quest) {
            final index = allQuests.indexOf(quest);
            return MissionCard(
              mission: quest,
              locale: _locale,
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
          }).toList(),
        ],
        
        if (expiredQuests.isNotEmpty) ...[
          _buildSectionHeader(_locale.expiredSection, Colors.red),
          ...expiredQuests.map((quest) {
            final index = allQuests.indexOf(quest);
            return MissionCard(
              mission: quest,
              locale: _locale,
              onDone: () {}, // Disabled untuk expired
              onFail: () {},
              onEdit: () => openEditPage(index),
              onDelete: () => questProvider.deleteQuest(index),
            );
          }).toList(),
        ],
        
        if (completedQuests.isNotEmpty) ...[
          _buildSectionHeader(_locale.completedSection, Colors.green),
          ...completedQuests.map((quest) {
            final index = allQuests.indexOf(quest);
            return MissionCard(
              mission: quest,
              locale: _locale,
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
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context);
    final missions = questProvider.allQuests;
    final completed = missions.where((m) => m.isCompleted).length;
    final expiredCount = questProvider.expiredCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_locale.appTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isEnglish ? Icons.language : Icons.translate,
              color: Colors.white,
            ),
            onPressed: _toggleLanguage,
            tooltip: _isEnglish ? 'Switch to Indonesian' : 'Ganti ke Inggris',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          
          CoinDisplay(completed: completed, total: missions.length),
          
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
                    '$expiredCount ${_locale.overdueCount}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 6),
          
          ElevatedButton.icon(
            onPressed: openAddPage,
            icon: const Icon(Icons.add, color: Colors.black),
            label: Text(_locale.addMission, style: const TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _buildQuestList(),
          ),
          
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SpinPage()),
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
              child: Text(
                _locale.spinReward,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}