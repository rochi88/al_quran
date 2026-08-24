class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final String? translation;
  final int juz;
  final int manzil;
  final int ruku;
  final int page;
  final bool sajda;

  const Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.juz,
    required this.manzil,
    required this.ruku,
    required this.page,
    required this.sajda,
    this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json, {String? translation}) {
    final sajdaField = json['sajda'];
    return Ayah(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      juz: json['juz'] as int,
      manzil: json['manzil'] as int,
      ruku: json['ruku'] as int,
      page: json['page'] as int,
      sajda: sajdaField is bool ? sajdaField : sajdaField != null,
      translation: translation,
    );
  }

  Ayah copyWith({String? translation}) {
    return Ayah(
      number: number,
      numberInSurah: numberInSurah,
      text: text,
      juz: juz,
      manzil: manzil,
      ruku: ruku,
      page: page,
      sajda: sajda,
      translation: translation ?? this.translation,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'numberInSurah': numberInSurah,
        'text': text,
        'translation': translation,
        'juz': juz,
        'manzil': manzil,
        'ruku': ruku,
        'page': page,
        'sajda': sajda,
      };

  factory Ayah.fromCacheJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      text: json['text'] as String,
      translation: json['translation'] as String?,
      juz: json['juz'] as int,
      manzil: json['manzil'] as int,
      ruku: json['ruku'] as int,
      page: json['page'] as int,
      sajda: json['sajda'] as bool,
    );
  }
}
