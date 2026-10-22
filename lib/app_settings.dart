import 'package:shared_preferences/shared_preferences.dart';

/// Centralized keys + helpers for app settings.
class AppSettings {
  static const String autoPlayNextKey = 'auto_play_next';
  static const String ayahRepeatKey = 'ayah_repeat';
  static const String surahRepeatKey = 'surah_repeat';
  static const String segmentRepeatKey = 'segment_repeat';
  static const String speedKey = 'speed';

  /// Default is true: after a surah completes, go to the next surah directly.
  static Future<bool> getAutoPlayNext() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(autoPlayNextKey) ?? true;
  }

  static Future<void> setAutoPlayNext(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(autoPlayNextKey, value);
  }

  /// How many times each ayah is repeated (1 = play once, no repeat).
  static Future<int> getAyahRepeat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ayahRepeatKey) ?? 1;
  }

  static Future<void> setAyahRepeat(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ayahRepeatKey, value);
  }

  /// How many times the whole surah is replayed (1 = play once).
  /// After the repeats finish, the auto-next setting applies.
  static Future<int> getSurahRepeat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(surahRepeatKey) ?? 1;
  }

  static Future<void> setSurahRepeat(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(surahRepeatKey, value);
  }

  /// How many times a chosen segment (مقطع) is replayed from its start
  /// (1 = play once, then stop). Only applies while a part is active.
  static Future<int> getSegmentRepeat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(segmentRepeatKey) ?? 1;
  }

  static Future<void> setSegmentRepeat(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(segmentRepeatKey, value);
  }

  /// Playback speed (default 1.7x). Persisted so it survives restarts.
  static Future<double> getSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(speedKey) ?? 1.7;
  }

  static Future<void> setSpeed(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(speedKey, value);
  }
}
