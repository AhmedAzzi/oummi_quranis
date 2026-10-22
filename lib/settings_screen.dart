import 'package:flutter/material.dart';
import 'package:saad_el_ghamidy/app_settings.dart';
import 'package:saad_el_ghamidy/audio_player_service.dart';
import 'package:saad_el_ghamidy/main.dart' show kPrimaryBrown, kGold;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoPlayNext = true;
  int _ayahRepeat = 1;
  int _surahRepeat = 1;
  double _speed = 1.7;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final autoNext = await AppSettings.getAutoPlayNext();
    final ayahRepeat = await AppSettings.getAyahRepeat();
    final surahRepeat = await AppSettings.getSurahRepeat();
    final speed = await AppSettings.getSpeed();
    if (!mounted) return;
    setState(() {
      _autoPlayNext = autoNext;
      _ayahRepeat = ayahRepeat;
      _surahRepeat = surahRepeat;
      _speed = speed;
      _loading = false;
    });
  }

  Future<void> _onToggle(bool value) async {
    setState(() => _autoPlayNext = value);
    await AppSettings.setAutoPlayNext(value);
  }

  Future<void> _onAyahRepeat(int value) async {
    setState(() => _ayahRepeat = value);
    await AppSettings.setAyahRepeat(value);
  }

  Future<void> _onSurahRepeat(int value) async {
    setState(() => _surahRepeat = value);
    await AppSettings.setSurahRepeat(value);
  }

  Future<void> _onSpeed(double value) async {
    setState(() => _speed = value);
    await AppSettings.setSpeed(value);
    try {
      await audioHandler.setSpeed(value);
    } catch (_) {}
  }

  String _repeatLabel(int n) {
    if (n == 1) return 'مرة واحدة';
    if (n == 2) return 'مرتان';
    return '$n مرات';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            color: kPrimaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Container(
          color: const Color(0xFFFFF9EC),
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: kPrimaryBrown),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: const Text(
                          'الانتقال التلقائي للسورة التالية',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryBrown,
                          ),
                        ),
                        subtitle: const Text(
                          'بعد إتمام السورة، انتقل مباشرة إلى السورة التالية',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        secondary: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _autoPlayNext
                                ? kPrimaryBrown.withValues(alpha: 0.12)
                                : Colors.grey.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _autoPlayNext
                                ? Icons.skip_next
                                : Icons.pause_circle_outline,
                            color: _autoPlayNext ? kPrimaryBrown : Colors.grey,
                          ),
                        ),
                        activeThumbColor: kGold,
                        value: _autoPlayNext,
                        onChanged: _onToggle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRepeatCard(
                      title: 'تكرار الآية',
                      subtitle: 'إعادة كل آية أثناء التشغيل (للحفظ والمراجعة)',
                      icon: Icons.repeat_one,
                      max: 100,
                      current: _ayahRepeat,
                      onPick: _onAyahRepeat,
                    ),
                    const SizedBox(height: 12),
                    _buildRepeatCard(
                      title: 'تكرار السورة',
                      subtitle: 'إعادة السورة كاملة قبل الانتقال للتي بعدها',
                      icon: Icons.repeat,
                      max: 100,
                      current: _surahRepeat,
                      onPick: _onSurahRepeat,
                    ),
                    const SizedBox(height: 12),
                    _buildSpeedCard(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRepeatCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required int max,
    required int current,
    required ValueChanged<int> onPick,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBrown,
                        ),
                      ),
                      Text(
                        subtitle,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kPrimaryBrown.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: kPrimaryBrown),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Free number: slider for speed, steppers for exact choice.
            Text(
              _repeatLabel(current),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kGold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: kPrimaryBrown,
                    size: 30,
                  ),
                  tooltip: 'إنقاص',
                  onPressed: current > 1 ? () => onPick(current - 1) : null,
                ),
                Expanded(
                  child: Slider(
                    value: current.clamp(1, max).toDouble(),
                    min: 1,
                    max: max.toDouble(),
                    divisions: max - 1,
                    activeColor: kPrimaryBrown,
                    inactiveColor: kPrimaryBrown.withValues(alpha: 0.2),
                    label: '$current',
                    onChanged: (v) => onPick(v.round()),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: kPrimaryBrown,
                    size: 30,
                  ),
                  tooltip: 'زيادة',
                  onPressed: current < max ? () => onPick(current + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedCard() {
    const quickSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.7, 2.0];
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'سرعة القراءة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryBrown,
                        ),
                      ),
                      Text(
                        'سرعة تشغيل الصوت الافتراضية',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kPrimaryBrown.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.speed, color: kPrimaryBrown),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_speed.toStringAsFixed(2)}x',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: kGold,
              ),
            ),
            Slider(
              value: _speed.clamp(0.5, 2.0),
              min: 0.5,
              max: 2.0,
              divisions: 15,
              activeColor: kPrimaryBrown,
              inactiveColor: kPrimaryBrown.withValues(alpha: 0.2),
              label: '${_speed.toStringAsFixed(1)}x',
              onChanged: (v) => _onSpeed(double.parse(v.toStringAsFixed(2))),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: quickSpeeds.map((s) {
                final selected = (_speed - s).abs() < 0.005;
                return ChoiceChip(
                  label: Text('${s}x'),
                  selected: selected,
                  onSelected: (_) => _onSpeed(s),
                  selectedColor: kPrimaryBrown,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : kPrimaryBrown,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Amiri',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
