// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    
    _initialized = true;
    print('✅ NotificationService initialized!');
  }

  Future<void> _requestPermissions() async {
    final notifStatus = await Permission.notification.request();
    print('📱 Notification: $notifStatus');
    
    if (await Permission.scheduleExactAlarm.isDenied) {
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('⏰ Exact alarm: $alarmStatus');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Tapped: ${response.payload}');
  }

  /// ✅ 1. NOTIFIKASI LANGSUNG SAAT INPUT < 30 MENIT
  Future<void> showImmediate30MinuteWarning(
    int questId,
    String questTitle,
    DateTime deadline,
  ) async {
    await _notifications.show(
      questId * 100 + 1,
      '⚠️ Deadline Dekat!',
      'Misi "$questTitle" deadline dalam 30 menit!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quest_immediate',
          'Deadline Warning',
          channelDescription: 'Notifikasi saat deadline dekat',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
    print('✅ Immediate 30min warning shown!');
  }

  /// ✅ 2. SCHEDULE NOTIF 30 MENIT SEBELUM DEADLINE
  Future<void> schedule30MinuteReminder(
    int questId,
    String questTitle,
    DateTime deadline,
  ) async {
    final scheduledTime = deadline.subtract(const Duration(minutes: 30));
    
    if (scheduledTime.isBefore(DateTime.now())) {
      print('⚠️ Schedule 30m skipped (already passed)');
      return;
    }

    await _notifications.zonedSchedule(
      questId * 100 + 2,
      '🚨 30 Menit Lagi!',
      'Misi "$questTitle" deadline dalam 30 menit!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quest_30m',
          '30 Minute Reminder',
          channelDescription: 'Reminder 30 menit sebelum deadline',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    print('✅ 30m reminder scheduled at $scheduledTime');
  }

  /// ✅ 3. SCHEDULE NOTIF DEADLINE (PASTI JALAN) - TANPA SOUND RESOURCE
  Future<void> scheduleDeadlineNotification(
    int questId,
    String questTitle,
    DateTime deadline,
  ) async {
    if (deadline.isBefore(DateTime.now())) {
      print('⚠️ Deadline skipped (already passed)');
      return;
    }

    await _notifications.zonedSchedule(
      questId * 100 + 3,
      '🔔 DEADLINE!',
      'Misi "$questTitle" sudah deadline!',
      tz.TZDateTime.from(deadline, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quest_deadline',
          'Deadline Alarm',
          channelDescription: 'Notifikasi saat deadline tiba',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          ongoing: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    print('✅ Deadline notification scheduled at $deadline');
  }

  /// ✅ 4. LOGIKA UTAMA
  Future<void> scheduleAllForQuest(
    int questId,
    String questTitle,
    DateTime deadline,
  ) async {
    final now = DateTime.now();
    final timeDiff = deadline.difference(now);
    final minutesDiff = timeDiff.inMinutes;
    
    print('\n🚀 SMART SCHEDULING QUEST: $questTitle');
    print('   Deadline: $deadline');
    print('   Time diff: ${timeDiff.inHours}h ${minutesDiff % 60}m');
    print('   Minutes diff: $minutesDiff minutes\n');

    // ✅ PASTIKAN DEADLINE NOTIF SELALU DI-SCHEDULE
    await scheduleDeadlineNotification(questId, questTitle, deadline);

    // ✅ LOGIKA UNTUK 30 MENIT:
    if (minutesDiff <= 30 && minutesDiff > 0) {
      // CASE A: Deadline < 30 menit dari sekarang → SHOW LANGSUNG
      print('📌 CASE A: Deadline < 30m → Show immediate warning');
      await showImmediate30MinuteWarning(questId, questTitle, deadline);
    } else if (minutesDiff > 30) {
      // CASE B: Deadline > 30 menit → SCHEDULE untuk 30 menit sebelum deadline
      print('📌 CASE B: Deadline > 30m → Schedule 30m reminder');
      await schedule30MinuteReminder(questId, questTitle, deadline);
    } else {
      // CASE C: Deadline sudah lewat → Skip
      print('📌 CASE C: Deadline already passed → Skip');
    }

    print('✅ All notifications scheduled for quest: $questTitle\n');
  }

  Future<void> cancelAllForQuest(int questId) async {
    print('🗑️ Canceling notifications for quest $questId');
    await _notifications.cancel(questId * 100 + 1);
    await _notifications.cancel(questId * 100 + 2);
    await _notifications.cancel(questId * 100 + 3);
    print('✅ Notifications canceled');
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// ✅ TEST NOTIFIKASI (debugging)
  Future<void> showTestNotification() async {
    await _notifications.show(
      99999,
      '🧪 Test Notification',
      'Notification service is working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'For testing notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
        ),
      ),
    );
    print('✅ Test notification sent!');
  }
}