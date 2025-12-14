// lib/features/alarm/alarm_screen.dart
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../core/localization/app_locale.dart'; // ✅ IMPORT

class AlarmScreen extends StatefulWidget {
  final String questTitle;
  final DateTime deadline;
  final AppLocale locale; // ✅ TAMBAH PARAMETER

  const AlarmScreen({
    super.key,
    required this.questTitle,
    required this.deadline,
    required this.locale, // ✅ REQUIRED
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    
    WakelockPlus.enable();
    _playAlarmSound();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(UrlSource('https://www.soundjay.com/phone/sounds/telephone-ring-01a.mp3'));
      print('🔊 Alarm sound playing (looping)!');
    } catch (e) {
      print('❌ Error playing alarm: $e');
    }
  }

  Future<void> _stopAlarm() async {
    setState(() => _isPlaying = false);
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    await WakelockPlus.disable();
    
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _audioPlayer.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated bell icon
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: (_rotateController.value * 0.5 - 0.25) * (3.14159 / 2),
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseController.value * 0.3),
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.alarm,
                      size: 150,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Deadline text
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.7 + (_pulseController.value * 0.3),
                      child: child,
                    );
                  },
                  child: Text(
                    widget.locale.deadlineAlarm, // ✅ PAKAI LOCALE
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Quest title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    widget.questTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Deadline time
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.deadline.hour.toString().padLeft(2, '0')}:${widget.deadline.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.95),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Sound indicator
                if (_isPlaying)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.5 + (_pulseController.value * 0.5),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up, color: Colors.white70, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          widget.locale.isEnglish ? 'Alarm Ringing' : 'Alarm Berbunyi', // ✅ PAKAI LOCALE
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Stop button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: _stopAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        widget.locale.turnOffAlarm, // ✅ PAKAI LOCALE
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Hint text
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.4 + (_pulseController.value * 0.3),
                      child: child,
                    );
                  },
                  child: Text(
                    widget.locale.alarmHint, // ✅ PAKAI LOCALE
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}