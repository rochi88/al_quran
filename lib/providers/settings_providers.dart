import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';
const _lastSurahKey = 'last_surah';
const _lastAyahKey = 'last_ayah';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModeKey);
    state = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// The last surah/ayah the user was reading, for the Home screen's
/// "Continue reading" card. Null fields mean nothing has been read yet.
class LastRead {
  final int surahNumber;
  final String surahEnglishName;
  final int ayahNumberInSurah;

  const LastRead({
    required this.surahNumber,
    required this.surahEnglishName,
    required this.ayahNumberInSurah,
  });
}

class LastReadNotifier extends Notifier<LastRead?> {
  @override
  LastRead? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_lastSurahKey);
    final ayah = prefs.getInt(_lastAyahKey);
    final name = prefs.getString('${_lastSurahKey}_name');
    if (surah != null && ayah != null && name != null) {
      state = LastRead(
        surahNumber: surah,
        surahEnglishName: name,
        ayahNumberInSurah: ayah,
      );
    }
  }

  Future<void> update(int surahNumber, String surahEnglishName, int ayahNumberInSurah) async {
    state = LastRead(
      surahNumber: surahNumber,
      surahEnglishName: surahEnglishName,
      ayahNumberInSurah: ayahNumberInSurah,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSurahKey, surahNumber);
    await prefs.setInt(_lastAyahKey, ayahNumberInSurah);
    await prefs.setString('${_lastSurahKey}_name', surahEnglishName);
  }
}

final lastReadProvider = NotifierProvider<LastReadNotifier, LastRead?>(
  LastReadNotifier.new,
);
