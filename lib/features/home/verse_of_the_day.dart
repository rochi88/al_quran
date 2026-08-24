/// A small, hand-picked set of well-known ayahs shown on the Home screen,
/// rotating daily. Kept local (no network call) so it renders instantly.
class DailyVerse {
  final int surahNumber;
  final String surahEnglishName;
  final int ayahNumberInSurah;
  final String text;
  final String translation;

  const DailyVerse({
    required this.surahNumber,
    required this.surahEnglishName,
    required this.ayahNumberInSurah,
    required this.text,
    required this.translation,
  });
}

const dailyVerses = <DailyVerse>[
  DailyVerse(
    surahNumber: 94,
    surahEnglishName: 'Ash-Sharh',
    ayahNumberInSurah: 6,
    text: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    translation: 'Indeed, with hardship comes ease.',
  ),
  DailyVerse(
    surahNumber: 2,
    surahEnglishName: 'Al-Baqarah',
    ayahNumberInSurah: 286,
    text: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
    translation: 'Allah does not burden a soul beyond what it can bear.',
  ),
  DailyVerse(
    surahNumber: 15,
    surahEnglishName: 'Al-Hijr',
    ayahNumberInSurah: 9,
    text: 'إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ',
    translation:
        "Indeed, it is We who sent down the Qur'an, and indeed, We will be its guardian.",
  ),
  DailyVerse(
    surahNumber: 65,
    surahEnglishName: 'At-Talaq',
    ayahNumberInSurah: 3,
    text: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
    translation: 'And whoever relies upon Allah, He is sufficient for him.',
  ),
  DailyVerse(
    surahNumber: 3,
    surahEnglishName: 'Ali Imran',
    ayahNumberInSurah: 159,
    text: 'فَاعْفُ عَنْهُمْ وَاسْتَغْفِرْ لَهُمْ وَشَاوِرْهُمْ فِي الْأَمْرِ',
    translation:
        'So pardon them and ask forgiveness for them and consult them in the matter.',
  ),
  DailyVerse(
    surahNumber: 13,
    surahEnglishName: "Ar-Ra'd",
    ayahNumberInSurah: 28,
    text: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    translation: 'Unquestionably, by the remembrance of Allah hearts are assured.',
  ),
  DailyVerse(
    surahNumber: 39,
    surahEnglishName: 'Az-Zumar',
    ayahNumberInSurah: 53,
    text: 'لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
    translation: 'Do not despair of the mercy of Allah.',
  ),
];

DailyVerse verseForToday(DateTime now) {
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return dailyVerses[dayOfYear % dailyVerses.length];
}
