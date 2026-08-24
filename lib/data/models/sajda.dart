import 'ayah.dart';

/// One of the 15 prostration (sajda) ayahs, with the surah it belongs to.
class SajdaEntry {
  final Ayah ayah;
  final int surahNumber;
  final String surahName;
  final String surahEnglishName;
  final String surahEnglishNameTranslation;
  final String revelationType;

  const SajdaEntry({
    required this.ayah,
    required this.surahNumber,
    required this.surahName,
    required this.surahEnglishName,
    required this.surahEnglishNameTranslation,
    required this.revelationType,
  });

  /// [json] is one ayah entry from `GET /v1/sajda/editions/quran-uthmani,en.sahih`'s
  /// first (Arabic) edition array; [translation] is the matching entry from the
  /// second (translation) edition array, matched by ayah `number`.
  factory SajdaEntry.fromJson(
    Map<String, dynamic> json, {
    String? translation,
  }) {
    final surah = json['surah'] as Map<String, dynamic>;
    return SajdaEntry(
      ayah: Ayah.fromJson(json, translation: translation),
      surahNumber: surah['number'] as int,
      surahName: surah['name'] as String,
      surahEnglishName: surah['englishName'] as String,
      surahEnglishNameTranslation: surah['englishNameTranslation'] as String,
      revelationType: surah['revelationType'] as String,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'ayah': ayah.toJson(),
        'surahNumber': surahNumber,
        'surahName': surahName,
        'surahEnglishName': surahEnglishName,
        'surahEnglishNameTranslation': surahEnglishNameTranslation,
        'revelationType': revelationType,
      };

  factory SajdaEntry.fromCacheJson(Map<String, dynamic> json) {
    return SajdaEntry(
      ayah: Ayah.fromCacheJson(json['ayah'] as Map<String, dynamic>),
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String,
      surahEnglishName: json['surahEnglishName'] as String,
      surahEnglishNameTranslation:
          json['surahEnglishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
    );
  }
}
