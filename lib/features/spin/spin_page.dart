import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization/app_locale.dart';
import '../../core/database/locale_preference.dart';
import '../../core/utils/spin_logic.dart';
import '../../core/database/models/reward_model.dart';
import '../../core/database/hive_service.dart';

class SpinPage extends StatefulWidget {
  const SpinPage({super.key});

  @override
  State<SpinPage> createState() => _SpinPageState();
}

class _SpinPageState extends State<SpinPage> with SingleTickerProviderStateMixin {
  static const int _rewardCount = 5;
  final int _zonkIndex = 0;
  final SpinLogic _logic = SpinLogic();

  final List<TextEditingController> _controllers =
      List.generate(_rewardCount, (index) => TextEditingController());
  final List<File?> _images = List.generate(_rewardCount, (index) => null);
  final List<String> _rewards = List.generate(_rewardCount, (index) => "Hadiah ${index + 1}");

  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousAngle = 0;
  bool _isSpinning = false;
  int _currentCoins = 0;
  bool _isEnglish = false;
  late AppLocale _locale;

  final List<Color> _wheelColors = const [
    Colors.orange,
    Colors.pinkAccent,
    Colors.amber,
    Colors.teal,
    Colors.deepPurpleAccent,
    Colors.redAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadLocale();
    
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animation = const AlwaysStoppedAnimation(0);

    _loadRewardsFromHive();
    _loadCurrentCoins();
  }

  Future<void> _loadLocale() async {
    final isEnglish = await LocalePreference.getIsEnglish();
    setState(() {
      _isEnglish = isEnglish;
      _locale = AppLocale(isEnglish);
      _rewards[_zonkIndex] = _locale.zonkReward;
      if (_controllers[_zonkIndex].text != _locale.zonkReward) {
        _controllers[_zonkIndex].text = _locale.zonkReward;
      }
    });
  }

  Future<void> _loadCurrentCoins() async {
    final user = await HiveService().getUser();
    if (mounted) {
      setState(() {
        _currentCoins = user.totalCoins;
      });
    }
  }

  Future<void> _loadRewardsFromHive() async {
    final rewards = await _logic.getRewards();
    if (rewards.isNotEmpty) {
      setState(() {
        for (int i = 0; i < _rewardCount && i < rewards.length; i++) {
          _rewards[i] = rewards[i].name;
          _controllers[i].text = rewards[i].name;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    if (index == _zonkIndex) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _images[index] = File(picked.path);
      });
    }
  }

  Future<void> _saveRewardsToHive() async {
    for (int i = 0; i < _rewards.length; i++) {
      await _logic.addReward(
        _rewards[i],
        value: i == _zonkIndex ? 0 : 1,
      );
    }
  }

  Future<void> _startSpin() async {
    if (_isSpinning) return;

    final hive = HiveService();
    final user = await hive.getUser();
    
    if (user.totalCoins < 1) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_locale.isEnglish 
              ? 'Not enough coins! Complete missions first.' 
              : 'Koin tidak cukup! Selesaikan misi dulu.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    await hive.addCoins(-1);
    await _loadCurrentCoins();
    await _saveRewardsToHive();
    setState(() => _isSpinning = true);

    const double minRotations = 5;
    final random = Random();
    final randomAngle = random.nextDouble() * (2 * pi * minRotations) + (2 * pi);

    _animation = Tween<double>(begin: _previousAngle, end: _previousAngle + randomAngle)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _controller.forward(from: 0).whenComplete(() async {
      setState(() {
        _previousAngle += randomAngle;
        _isSpinning = false;
      });

      final result = await _logic.spinOnce();

      if (result == null) {
        final fallback = Reward(name: _rewards[random.nextInt(_rewards.length)], value: 1);
        if (!mounted) return;
        _showResultDialog(fallback);
      } else {
        if (!mounted) return;
        _showResultDialog(result);
      }
    });
  }

  void _showResultDialog(Reward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _locale.congratulations,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _locale.youGot,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              reward.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_locale.ok),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheel(double size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _animation.value;
        return Transform.rotate(
          angle: angle,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(_rewards.length, (index) {
              final startAngle = (2 * pi / _rewards.length) * index;
              final sweepAngle = 2 * pi / _rewards.length;
              final color = index == _zonkIndex
                  ? Colors.green.shade800
                  : _wheelColors[index % _wheelColors.length];

              return CustomPaint(
                painter: _SlicePainter(color, startAngle, sweepAngle),
                child: Transform.rotate(
                  angle: startAngle + sweepAngle / 2,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: size * 0.15),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: size * 0.3),
                        child: _images[index] != null && index != _zonkIndex
                            ? ClipOval(
                                child: Image.file(
                                  _images[index]!,
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                _rewards[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildRewardInput() {
    return Column(
      children: List.generate(_controllers.length, (index) {
        final isZonk = index == _zonkIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: IgnorePointer(
                  ignoring: isZonk,
                  child: TextField(
                    controller: _controllers[index],
                    style: TextStyle(
                      color: isZonk ? Colors.grey.shade600 : Colors.black87,
                      fontWeight: isZonk ? FontWeight.bold : FontWeight.normal,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isZonk ? Colors.grey.shade200 : Colors.white,
                      labelText: isZonk 
                          ? (_locale.isEnglish ? "**FIXED REWARD (ZONK)**" : "**HADIAH PATEN (ZONK)**")
                          : "${_locale.rewardItem} ${index + 1}",
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _rewards[index] = value.isEmpty ? "${_locale.rewardItem} ${index + 1}" : value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IgnorePointer(
                ignoring: isZonk,
                child: Container(
                  decoration: BoxDecoration(
                    color: isZonk ? Colors.grey : Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _images[index] != null ? Icons.image_outlined : Icons.image,
                      color: Colors.white,
                    ),
                    onPressed: () => _pickImage(index),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(_locale.spinAndWin, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(width: size, height: size, child: _buildWheel(size)),
            const Icon(Icons.arrow_drop_up, color: Colors.redAccent, size: 50),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _currentCoins >= 1 && !_isSpinning ? _startSpin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                disabledBackgroundColor: Colors.grey.shade600,
              ),
              child: Text(
                _isSpinning
                    ? (_locale.isEnglish ? "Spinning..." : "Memutar...")
                    : "${_locale.spinReward} (${_locale.isEnglish ? 'Coins left' : 'Sisa Koin'}: $_currentCoins)",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 30),
            Text(
              _locale.setRewards,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRewardInput(),
          ],
        ),
      ),
    );
  }
}

class _SlicePainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;

  const _SlicePainter(this.color, this.startAngle, this.sweepAngle);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, true, fillPaint);
    canvas.drawLine(center,
        center + Offset(radius * cos(startAngle), radius * sin(startAngle)), borderPaint);
    canvas.drawLine(center,
        center + Offset(radius * cos(startAngle + sweepAngle), radius * sin(startAngle + sweepAngle)), borderPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SlicePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.startAngle != startAngle ||
      oldDelegate.sweepAngle != sweepAngle;
}