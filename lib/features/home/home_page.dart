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
  AppLocale? _locale;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // ✅ LOAD LOCALE DULU, BARU LOAD QUESTS
    _loadLocale().then((_) {
      if (mounted) {
        Future.microtask(() {
          Provider.of<QuestProvider>(context, listen: false).loadQuests();
          setState(() => _isLoading = false);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadLocale() async {
    final isEnglish = await LocalePreference.getIsEnglish();
    if (mounted) {
      setState(() {
        _isEnglish = isEnglish;
        _locale = AppLocale(isEnglish);
      });
    }
  }

  Future<void> _toggleLanguage() async {
    final newValue = !_isEnglish;
    await LocalePreference.setIsEnglish(newValue);
    if (mounted) {
      setState(() {
        _isEnglish = newValue;
        _locale = AppLocale(newValue);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _locale != null) {
      Provider.of<QuestProvider>(context, listen: false).refreshExpiredStatus();
    }
  }

  void openAddPage() {
    if (_locale == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddQuestPage(
          locale: _locale!,
          onSave: (quest) async {
            await Provider.of<QuestProvider>(context, listen: false).addQuest(quest);
          },
        ),
      ),
    );
  }

  // ✅ VERSI FIX DENGAN UPDATE BY KEY
  void openEditPage(int index) {
    if (_locale == null) return;
    final questProvider = Provider.of<QuestProvider>(context, listen: false);
    // Kita ambil objek quest lama berdasarkan index list yang di-tap
    final quest = questProvider.quests[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddQuestPage(
          initial: quest,
          locale: _locale!,
          onSave: (newQuest) async {
            // ✅ PAKAI UPDATE BY KEY (SOLUSI PROFESIONAL)
            // Tidak perlu delete & add lagi, langsung update ke key aslinya
            await questProvider.updateQuestByKey(
              questKey: quest.key, // Hive key sebagai unique identifier
              newQuest: newQuest,
            );
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
          _locale!.noMissions,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final activeQuests = allQuests.where((q) => !q.isCompleted && !q.isExpired).toList();
    final expiredQuests = allQuests.where((q) => !q.isCompleted && q.isExpired).toList();
    final completedQuests = allQuests.where((q) => q.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (activeQuests.isNotEmpty) ...[
          _buildSectionHeader(_locale!.activeSection, Colors.blue),
          ...activeQuests.map((quest) {
            final index = allQuests.indexOf(quest);
            return MissionCard(
              mission: quest,
              locale: _locale!,
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
          _buildSectionHeader(_locale!.expiredSection, Colors.red),
          ...expiredQuests.map((quest) {
            final index = allQuests.indexOf(quest);
            return MissionCard(
              mission: quest,
              locale: _locale!,
              onDone: () {}, // Disabled untuk expired
              onFail: () {},
              onEdit: () => openEditPage(index),
              onDelete: () => questProvider.deleteQuest(index),
            );
          }).toList(),
        ],
        
        if (completedQuests.isNotEmpty) ...[
          _buildSectionHeader(_locale!.completedSection, Colors.green),
          ...completedQuests.map((quest) {
            final index = allQuests.indexOf(quest);
            return MissionCard(
              mission: quest,
              locale: _locale!,
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
    // ✅ LOADING SCREEN
    if (_isLoading || _locale == null) {
      return Scaffold(
        backgroundColor: Colors.purple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Loading RealityQuest...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final questProvider = Provider.of<QuestProvider>(context);
    final missions = questProvider.allQuests;
    final completed = missions.where((m) => m.isCompleted).length;
    final expiredCount = questProvider.expiredCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_locale!.appTitle, style: const TextStyle(color: Colors.white)),
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
                    '$expiredCount ${_locale!.overdueCount}',
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
            label: Text(_locale!.addMission, style: const TextStyle(color: Colors.black)),
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
              child: Text(
                _locale!.spinReward,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}