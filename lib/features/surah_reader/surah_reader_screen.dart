import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/ayah.dart';
import '../../data/models/surah.dart';
import '../../providers/bookmark_providers.dart';
import '../../providers/quran_providers.dart';
import '../../providers/settings_providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_list_skeleton.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int? scrollToAyah;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    this.scrollToAyah,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    final surah = ref.read(surahDetailProvider(widget.surahNumber)).value;
    if (surah == null) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    // index 0 is the header card; ayah at list-index i is surah.ayahs[i - 1].
    final topItem = positions
        .where((p) => p.itemLeadingEdge < 1 && p.itemTrailingEdge > 0)
        .reduce((a, b) => a.itemLeadingEdge < b.itemLeadingEdge ? a : b);
    final ayahIndex = topItem.index - 1;
    if (ayahIndex < 0 || ayahIndex >= surah.ayahs.length) return;

    ref.read(lastReadProvider.notifier).update(
          surah.number,
          surah.englishName,
          surah.ayahs[ayahIndex].numberInSurah,
        );
  }

  void _maybeScrollToInitialAyah(Surah surah) {
    if (_didInitialScroll) return;
    _didInitialScroll = true;
    final target = widget.scrollToAyah;
    if (target == null) return;
    final index = surah.ayahs.indexWhere((a) => a.numberInSurah == target);
    if (index == -1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_itemScrollController.isAttached) return;
      _itemScrollController.jumpTo(index: index + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final surahAsync = ref.watch(surahDetailProvider(widget.surahNumber));

    return Scaffold(
      appBar: AppBar(
        title: surahAsync.maybeWhen(
          data: (s) => Text(s.englishName),
          orElse: () => const Text('Surah'),
        ),
      ),
      body: surahAsync.when(
        loading: () => const LoadingListSkeleton(itemCount: 10),
        error: (err, _) => ErrorView(
          message: 'Could not load this surah.\n$err',
          onRetry: () =>
              ref.invalidate(surahDetailProvider(widget.surahNumber)),
        ),
        data: (surah) {
          _maybeScrollToInitialAyah(surah);

          return ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: surah.ayahs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _SurahHeader(surah: surah);
              return _AyahTile(surah: surah, ayah: surah.ayahs[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  final Surah surah;
  const _SurahHeader({required this.surah});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(surah.name, style: arabicTextStyle(context, size: 32)),
            const SizedBox(height: 8),
            Text(
              '${surah.englishName} · ${surah.englishNameTranslation}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${surah.revelationType} · ${surah.ayahs.length} ayahs',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahTile extends ConsumerWidget {
  final Surah surah;
  final Ayah ayah;
  const _AyahTile({required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    ref.watch(bookmarksProvider); // rebuild when bookmarks change
    final bookmarked = ref
        .read(bookmarkRepositoryProvider)
        .isBookmarked(surah.number, ayah.numberInSurah);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (ayah.sajda) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.self_improvement_rounded,
                      size: 18, color: scheme.tertiary),
                ],
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: bookmarked ? scheme.primary : scheme.outline,
                  ),
                  onPressed: () => ref.read(bookmarkRepositoryProvider).toggleBookmark(
                        surahNumber: surah.number,
                        surahEnglishName: surah.englishName,
                        ayahNumberInSurah: ayah.numberInSurah,
                        ayahText: ayah.text,
                        ayahTranslation: ayah.translation,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ayah.text,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: arabicTextStyle(context),
            ),
            if (ayah.translation != null) ...[
              const SizedBox(height: 12),
              Text(
                ayah.translation!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
