import '../datasources/quran_local_datasource.dart';
import '../datasources/quran_remote_datasource.dart';
import '../models/sajda.dart';
import '../models/surah.dart';

/// Cache-first-then-network: yields the cached value immediately if one exists,
/// then fetches from the network and yields the fresh value (updating the cache).
/// If there's no cache, only the network value is yielded (or an error).
class QuranRepository {
  final QuranRemoteDataSource _remote;
  final QuranLocalDataSource _local;

  QuranRepository({
    QuranRemoteDataSource? remote,
    QuranLocalDataSource? local,
  })  : _remote = remote ?? QuranRemoteDataSource(),
        _local = local ?? QuranLocalDataSource();

  Stream<List<SurahMeta>> watchSurahList() async* {
    final cached = _local.readSurahList();
    if (cached != null) yield cached;

    final fresh = await _remote.fetchSurahList();
    await _local.writeSurahList(fresh);
    yield fresh;
  }

  Stream<Surah> watchSurah(int number) async* {
    final cached = _local.readSurah(number);
    if (cached != null) yield cached;

    final fresh = await _remote.fetchSurah(number);
    await _local.writeSurah(fresh);
    yield fresh;
  }

  Stream<List<SajdaEntry>> watchSajdaList() async* {
    final cached = _local.readSajdaList();
    if (cached != null) yield cached;

    final fresh = await _remote.fetchSajdaList();
    await _local.writeSajdaList(fresh);
    yield fresh;
  }
}
