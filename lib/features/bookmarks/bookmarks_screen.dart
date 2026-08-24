import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/bookmark.dart';
import '../../providers/bookmark_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(message: 'Could not load bookmarks.\n$err'),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_outline_rounded,
              message:
                  'No bookmarks yet.\nTap the bookmark icon on any ayah while reading to save it here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _BookmarkCard(bookmark: bookmarks[index]),
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends ConsumerWidget {
  final Bookmark bookmark;
  const _BookmarkCard({required this.bookmark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('${bookmark.surahEnglishName} · Ayah ${bookmark.ayahNumberInSurah}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.ayahText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 18, height: 1.8),
              ),
              if (bookmark.ayahTranslation != null) ...[
                const SizedBox(height: 6),
                Text(
                  bookmark.ayahTranslation!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () => ref.read(bookmarkRepositoryProvider).toggleBookmark(
                surahNumber: bookmark.surahNumber,
                surahEnglishName: bookmark.surahEnglishName,
                ayahNumberInSurah: bookmark.ayahNumberInSurah,
                ayahText: bookmark.ayahText,
                ayahTranslation: bookmark.ayahTranslation,
              ),
        ),
        onTap: () => context.push(
          '/surah/${bookmark.surahNumber}?ayah=${bookmark.ayahNumberInSurah}',
        ),
      ),
    );
  }
}
