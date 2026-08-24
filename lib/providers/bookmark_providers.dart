import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/bookmark.dart';
import '../data/repositories/bookmark_repository.dart';
import 'auth_providers.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  final repo = BookmarkRepository(auth: ref.watch(authRepositoryProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final bookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  return ref.watch(bookmarkRepositoryProvider).watchBookmarks();
});
