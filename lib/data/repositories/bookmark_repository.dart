import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bookmark.dart';
import 'auth_repository.dart';

/// Local-first bookmarks: Hive is always the source of truth for the UI (so
/// toggling a bookmark feels instant and works offline). When a Firebase user
/// is signed in (and the platform supports Firebase — see
/// [isFirebaseSupportedOnThisPlatform]), changes are also pushed to
/// `users/{uid}/bookmarks` in Firestore, and remote changes are merged in by
/// last-write-wins on `updatedAt`.
class BookmarkRepository {
  static const _boxName = 'bookmarks';

  final AuthRepository _auth;
  final _controller = StreamController<List<Bookmark>>.broadcast();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;

  BookmarkRepository({AuthRepository? auth}) : _auth = auth ?? AuthRepository() {
    _emitLocal();
    _box.watch().listen((_) => _emitLocal());
    _authSub = _auth.authStateChanges.listen(_onAuthChanged);
  }

  static Future<void> init() => Hive.openBox(_boxName);

  Box get _box => Hive.box(_boxName);

  Stream<List<Bookmark>> watchBookmarks() => _controller.stream;

  bool isBookmarked(int surahNumber, int ayahNumberInSurah) =>
      _box.containsKey(Bookmark.idFor(surahNumber, ayahNumberInSurah));

  Future<void> toggleBookmark({
    required int surahNumber,
    required String surahEnglishName,
    required int ayahNumberInSurah,
    required String ayahText,
    String? ayahTranslation,
  }) async {
    final id = Bookmark.idFor(surahNumber, ayahNumberInSurah);
    if (_box.containsKey(id)) {
      await _remove(id);
      return;
    }
    final bookmark = Bookmark(
      id: id,
      surahNumber: surahNumber,
      surahEnglishName: surahEnglishName,
      ayahNumberInSurah: ayahNumberInSurah,
      ayahText: ayahText,
      ayahTranslation: ayahTranslation,
      updatedAt: DateTime.now(),
    );
    await _box.put(id, bookmark.toJson());
    unawaited(_pushToFirestore(bookmark));
  }

  Future<void> _remove(String id) async {
    await _box.delete(id);
    unawaited(_deleteFromFirestore(id));
  }

  void _emitLocal() {
    if (_controller.isClosed) return;
    _controller.add(_readLocal());
  }

  List<Bookmark> _readLocal() {
    final list = _box.values
        .map((e) => Bookmark.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<void> _onAuthChanged(User? user) async {
    await _firestoreSub?.cancel();
    _firestoreSub = null;
    if (user == null) return;

    final collection = _remoteCollection(user.uid);

    // Push any bookmarks that only exist locally (e.g. made before sign-in).
    for (final bookmark in _readLocal()) {
      final doc = await collection.doc(bookmark.id).get();
      if (!doc.exists) {
        await collection.doc(bookmark.id).set(bookmark.toJson());
      }
    }

    _firestoreSub = collection.snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        final id = change.doc.id;
        if (change.type == DocumentChangeType.removed) {
          if (_box.containsKey(id)) await _box.delete(id);
          continue;
        }
        final remote = Bookmark.fromJson(change.doc.data()!);
        final localRaw = _box.get(id);
        final local = localRaw != null
            ? Bookmark.fromJson(Map<String, dynamic>.from(localRaw as Map))
            : null;
        if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
          await _box.put(id, remote.toJson());
        }
      }
    });
  }

  CollectionReference<Map<String, dynamic>> _remoteCollection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bookmarks');

  Future<void> _pushToFirestore(Bookmark bookmark) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _remoteCollection(user.uid).doc(bookmark.id).set(bookmark.toJson());
  }

  Future<void> _deleteFromFirestore(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _remoteCollection(user.uid).doc(id).delete();
  }

  void dispose() {
    _authSub?.cancel();
    _firestoreSub?.cancel();
    _controller.close();
  }
}
