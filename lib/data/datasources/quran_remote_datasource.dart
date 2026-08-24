import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sajda.dart';
import '../models/surah.dart';

/// The English translation edition used alongside the Arabic (quran-uthmani) text.
/// Kept as a single named constant so switching translations later is a one-line change.
const String kTranslationEdition = 'en.sahih';

class QuranApiException implements Exception {
  final String message;
  QuranApiException(this.message);

  @override
  String toString() => 'QuranApiException: $message';
}

/// Thin wrapper around the alquran.cloud REST API. Unlike the old reference app
/// (which fetched the entire Qur'an on every screen), every call here is scoped to
/// exactly what a screen needs.
class QuranRemoteDataSource {
  static const _base = 'https://api.alquran.cloud/v1';

  final http.Client _client;
  QuranRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await _client.get(Uri.parse('$_base$path'));
    if (response.statusCode != 200) {
      throw QuranApiException('Request to $path failed (${response.statusCode})');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  /// Metadata for all 114 surahs (no ayah text) — cheap enough to fetch every launch.
  Future<List<SurahMeta>> fetchSurahList() async {
    final body = await _getJson('/surah');
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => SurahMeta.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Arabic + translation text for a single surah.
  Future<Surah> fetchSurah(int number) async {
    final body = await _getJson(
      '/surah/$number/editions/quran-uthmani,$kTranslationEdition',
    );
    final editions = body['data'] as List<dynamic>;
    return Surah.fromEditionsJson(editions);
  }

  /// All 15 prostration ayahs, Arabic + translation, each paired with its surah.
  Future<List<SajdaEntry>> fetchSajdaList() async {
    final body = await _getJson(
      '/sajda/editions/quran-uthmani,$kTranslationEdition',
    );
    final editions = body['data'] as List<dynamic>;
    final arabicAyahs =
        (editions[0] as Map<String, dynamic>)['ayahs'] as List<dynamic>;
    final translationAyahs = editions.length > 1
        ? (editions[1] as Map<String, dynamic>)['ayahs'] as List<dynamic>?
        : null;

    return [
      for (var i = 0; i < arabicAyahs.length; i++)
        SajdaEntry.fromJson(
          arabicAyahs[i] as Map<String, dynamic>,
          translation: translationAyahs != null
              ? (translationAyahs[i] as Map<String, dynamic>)['text']
                  as String
              : null,
        ),
    ];
  }
}
