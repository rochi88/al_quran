import 'package:hive_flutter/hive_flutter.dart';

import '../models/sajda.dart';
import '../models/surah.dart';

/// Hive-backed cache. Boxes store plain JSON (Map/List), so no TypeAdapter
/// codegen is needed — models handle their own encode/decode.
class QuranLocalDataSource {
  static const _surahListBox = 'surah_list';
  static const _surahDetailBox = 'surah_detail';
  static const _sajdaListBox = 'sajda_list';
  static const _surahListKey = 'all';
  static const _sajdaListKey = 'all';

  static Future<void> init() async {
    await Hive.openBox(_surahListBox);
    await Hive.openBox(_surahDetailBox);
    await Hive.openBox(_sajdaListBox);
  }

  Box get _surahList => Hive.box(_surahListBox);
  Box get _surahDetail => Hive.box(_surahDetailBox);
  Box get _sajdaList => Hive.box(_sajdaListBox);

  List<SurahMeta>? readSurahList() {
    final raw = _surahList.get(_surahListKey) as List<dynamic>?;
    if (raw == null) return null;
    return raw
        .map((e) => SurahMeta.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> writeSurahList(List<SurahMeta> surahs) async {
    await _surahList.put(
      _surahListKey,
      surahs.map((s) => s.toJson()).toList(),
    );
  }

  Surah? readSurah(int number) {
    final raw = _surahDetail.get(number) as Map<dynamic, dynamic>?;
    if (raw == null) return null;
    return Surah.fromCacheJson(Map<String, dynamic>.from(raw));
  }

  Future<void> writeSurah(Surah surah) async {
    await _surahDetail.put(surah.number, surah.toCacheJson());
  }

  List<SajdaEntry>? readSajdaList() {
    final raw = _sajdaList.get(_sajdaListKey) as List<dynamic>?;
    if (raw == null) return null;
    return raw
        .map((e) => SajdaEntry.fromCacheJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> writeSajdaList(List<SajdaEntry> entries) async {
    await _sajdaList.put(
      _sajdaListKey,
      entries.map((e) => e.toCacheJson()).toList(),
    );
  }
}
