import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/sajda.dart';
import '../data/models/surah.dart';
import '../data/repositories/quran_repository.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final surahListProvider = StreamProvider.autoDispose<List<SurahMeta>>((ref) {
  return ref.watch(quranRepositoryProvider).watchSurahList();
});

final surahDetailProvider =
    StreamProvider.autoDispose.family<Surah, int>((ref, number) {
  return ref.watch(quranRepositoryProvider).watchSurah(number);
});

final sajdaListProvider = StreamProvider.autoDispose<List<SajdaEntry>>((ref) {
  return ref.watch(quranRepositoryProvider).watchSajdaList();
});
