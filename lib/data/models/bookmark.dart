class Bookmark {
  final String id;
  final int surahNumber;
  final String surahEnglishName;
  final int ayahNumberInSurah;
  final String ayahText;
  final String? ayahTranslation;
  final DateTime updatedAt;

  const Bookmark({
    required this.id,
    required this.surahNumber,
    required this.surahEnglishName,
    required this.ayahNumberInSurah,
    required this.ayahText,
    required this.updatedAt,
    this.ayahTranslation,
  });

  /// Stable id so re-bookmarking the same ayah updates rather than duplicates.
  static String idFor(int surahNumber, int ayahNumberInSurah) =>
      '$surahNumber:$ayahNumberInSurah';

  Map<String, dynamic> toJson() => {
        'id': id,
        'surahNumber': surahNumber,
        'surahEnglishName': surahEnglishName,
        'ayahNumberInSurah': ayahNumberInSurah,
        'ayahText': ayahText,
        'ayahTranslation': ayahTranslation,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      surahEnglishName: json['surahEnglishName'] as String,
      ayahNumberInSurah: json['ayahNumberInSurah'] as int,
      ayahText: json['ayahText'] as String,
      ayahTranslation: json['ayahTranslation'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
