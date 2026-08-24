import 'package:flutter_test/flutter_test.dart';

import 'package:al_quran/data/models/ayah.dart';
import 'package:al_quran/data/models/bookmark.dart';
import 'package:al_quran/data/models/surah.dart';
import 'package:al_quran/features/home/verse_of_the_day.dart';

void main() {
  group('Surah.fromEditionsJson', () {
    test('pairs Arabic and translation ayahs by index', () {
      final editions = [
        {
          'number': 1,
          'name': 'الفاتحة',
          'englishName': 'Al-Faatiha',
          'englishNameTranslation': 'The Opening',
          'revelationType': 'Meccan',
          'ayahs': [
            {
              'number': 1,
              'numberInSurah': 1,
              'text': 'بِسْمِ اللَّهِ',
              'juz': 1,
              'manzil': 1,
              'ruku': 1,
              'page': 1,
              'sajda': false,
            },
          ],
        },
        {
          'ayahs': [
            {'text': 'In the name of Allah'},
          ],
        },
      ];

      final surah = Surah.fromEditionsJson(editions);

      expect(surah.number, 1);
      expect(surah.ayahs, hasLength(1));
      expect(surah.ayahs.first.text, 'بِسْمِ اللَّهِ');
      expect(surah.ayahs.first.translation, 'In the name of Allah');
    });
  });

  group('Surah cache round-trip', () {
    test('toCacheJson/fromCacheJson preserves data', () {
      const ayah = Ayah(
        number: 1,
        numberInSurah: 1,
        text: 'نص',
        translation: 'text',
        juz: 1,
        manzil: 1,
        ruku: 1,
        page: 1,
        sajda: true,
      );
      const surah = Surah(
        number: 1,
        name: 'الفاتحة',
        englishName: 'Al-Faatiha',
        englishNameTranslation: 'The Opening',
        revelationType: 'Meccan',
        ayahs: [ayah],
      );

      final restored = Surah.fromCacheJson(surah.toCacheJson());

      expect(restored.number, surah.number);
      expect(restored.ayahs.single.text, ayah.text);
      expect(restored.ayahs.single.sajda, isTrue);
    });
  });

  group('Bookmark.idFor', () {
    test('is stable for the same surah/ayah pair', () {
      expect(Bookmark.idFor(2, 255), Bookmark.idFor(2, 255));
      expect(Bookmark.idFor(2, 255), isNot(Bookmark.idFor(2, 256)));
    });
  });

  group('verseForToday', () {
    test('picks a verse deterministically for a given date', () {
      final a = verseForToday(DateTime(2026, 1, 1));
      final b = verseForToday(DateTime(2026, 1, 1));
      expect(a.surahNumber, b.surahNumber);
      expect(a.ayahNumberInSurah, b.ayahNumberInSurah);
    });

    test('stays within the curated list bounds', () {
      final verse = verseForToday(DateTime(2026, 12, 31));
      expect(dailyVerses, contains(verse));
    });
  });
}
