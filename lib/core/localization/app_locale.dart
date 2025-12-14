// lib/core/localization/app_locale.dart
class AppLocale {
  final bool isEnglish;

  AppLocale(this.isEnglish);

  // === HOME PAGE ===
  String get appTitle => 'RealityQuest';
  String get addMission => isEnglish ? 'Add Mission' : 'Tambah Misi';
  String get spinReward => isEnglish ? 'Spin Reward' : 'Putar Hadiah';
  String get noMissions => isEnglish 
      ? 'No missions yet.\nPress "Add Mission" to start!' 
      : 'Belum ada misi.\nTekan "Tambah Misi" untuk mulai!';
  
  // === MISSION CARD ===
  String get deadlineLabel => isEnglish ? 'Deadline' : 'Deadline';
  String get expiredBadge => isEnglish ? 'EXPIRED' : 'KEDALUARSA';
  String get completedBadge => isEnglish ? 'COMPLETED' : 'SELESAI';
  String get overdueCount => isEnglish ? 'missions expired' : 'misi kedaluarsa';
  
  // === ADD/EDIT QUEST PAGE ===
  String get addQuestTitle => isEnglish ? 'Add Mission' : 'Tambah Misi';
  String get editQuestTitle => isEnglish ? 'Edit Mission' : 'Edit Misi';
  String get missionName => isEnglish ? 'Mission Name' : 'Nama Misi';
  String get missionHint => isEnglish ? 'Enter mission name...' : 'Masukkan nama misi...';
  String get deadlineDate => isEnglish ? 'Deadline Date' : 'Tanggal Deadline';
  String get deadlineTime => isEnglish ? 'Deadline Time' : 'Waktu Deadline';
  String get selectDate => isEnglish ? 'Select Date' : 'Pilih Tanggal';
  String get selectTime => isEnglish ? 'Select Time' : 'Pilih Waktu';
  String get reward => isEnglish ? 'Reward' : 'Reward';
  String get saveMission => isEnglish ? 'Save Mission' : 'Simpan Misi';
  String get oneCoin => isEnglish ? '1 Coin' : '1 Koin';
  
  // === SPIN PAGE ===
  String get spinAndWin => isEnglish ? 'Spin & Win' : 'Spin & Win';
  String get setRewards => isEnglish ? 'Set Rewards' : 'Atur Hadiah';
  String get rewardItem => isEnglish ? 'Reward' : 'Hadiah';
  String get zonkReward => isEnglish ? 'ZONK 😭' : 'ZONK 😭';
  String get congratulations => isEnglish ? 'Congratulations!' : 'Selamat!';
  String get youGot => isEnglish ? 'You got:' : 'Kamu mendapatkan:';
  
  // === ALARM SCREEN ===
  String get deadlineAlarm => isEnglish ? 'DEADLINE!' : 'DEADLINE!';
  String get turnOffAlarm => isEnglish ? 'TURN OFF ALARM' : 'MATIKAN ALARM';
  String get alarmHint => isEnglish 
      ? 'Press button to stop alarm' 
      : 'Tekan tombol untuk menghentikan alarm';
  
  // === BUTTONS & ACTIONS ===
  String get ok => isEnglish ? 'OK' : 'OK';
  String get edit => isEnglish ? 'Edit' : 'Edit';
  String get delete => isEnglish ? 'Delete' : 'Hapus';
  String get done => isEnglish ? 'Done' : 'Selesai';
  
  // === SECTION HEADERS ===
  String get activeSection => isEnglish ? 'Active Missions' : 'Misi Aktif';
  String get expiredSection => isEnglish ? 'Expired Missions' : 'Misi Kedaluarsa';
  String get completedSection => isEnglish ? 'Completed Missions' : 'Misi Selesai';
}