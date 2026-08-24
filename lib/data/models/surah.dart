import 'ayah.dart';

/// Lightweight surah metadata, as returned by `GET /v1/surah` (the index list).
class SurahMeta {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;

  const SurahMeta({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  factory SurahMeta.fromJson(Map<String, dynamic> json) {
    return SurahMeta(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': name,
        'englishName': englishName,
        'englishNameTranslation': englishNameTranslation,
        'revelationType': revelationType,
        'numberOfAyahs': numberOfAyahs,
      };
}

/// Full surah detail, as returned by `GET /v1/surah/{n}/editions/quran-uthmani,en.sahih`.
class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.ayahs,
  });

  /// [editions] is the `data` array from the combined-editions endpoint:
  /// index 0 is the Arabic (quran-uthmani) edition, index 1 the translation.
  factory Surah.fromEditionsJson(List<dynamic> editions) {
    final arabic = editions[0] as Map<String, dynamic>;
    final translationEdition =
        editions.length > 1 ? editions[1] as Map<String, dynamic> : null;
    final arabicAyahs = arabic['ayahs'] as List<dynamic>;
    final translationAyahs =
        translationEdition?['ayahs'] as List<dynamic>?;

    final ayahs = <Ayah>[
      for (var i = 0; i < arabicAyahs.length; i++)
        Ayah.fromJson(
          arabicAyahs[i] as Map<String, dynamic>,
          translation: translationAyahs != null
              ? (translationAyahs[i] as Map<String, dynamic>)['text']
                  as String
              : null,
        ),
    ];

    return Surah(
      number: arabic['number'] as int,
      name: arabic['name'] as String,
      englishName: arabic['englishName'] as String,
      englishNameTranslation: arabic['englishNameTranslation'] as String,
      revelationType: arabic['revelationType'] as String,
      ayahs: ayahs,
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'number': number,
        'name': name,
        'englishName': englishName,
        'englishNameTranslation': englishNameTranslation,
        'revelationType': revelationType,
        'ayahs': ayahs.map((a) => a.toJson()).toList(),
      };

  factory Surah.fromCacheJson(Map<String, dynamic> json) {
    final ayahsJson = json['ayahs'] as List<dynamic>;
    return Surah(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
      ayahs: ayahsJson
          .map((a) => Ayah.fromCacheJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}
