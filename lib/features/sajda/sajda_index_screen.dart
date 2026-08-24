import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/sajda.dart';
import '../../providers/quran_providers.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_list_skeleton.dart';

class SajdaIndexScreen extends ConsumerWidget {
  const SajdaIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sajdaAsync = ref.watch(sajdaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sajda Index'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(28),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'The 15 verses of prostration',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
      body: sajdaAsync.when(
        loading: () => const LoadingListSkeleton(itemCount: 6),
        error: (err, _) => ErrorView(
          message: 'Could not load the sajda list.\n$err',
          onRetry: () => ref.invalidate(sajdaListProvider),
        ),
        data: (entries) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SajdaCard(entry: entries[index]),
        ),
      ),
    );
  }
}

class _SajdaCard extends StatelessWidget {
  final SajdaEntry entry;
  const _SajdaCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '/surah/${entry.surahNumber}?ayah=${entry.ayah.numberInSurah}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.self_improvement_rounded,
                      size: 18, color: scheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${entry.surahEnglishName} · ${entry.surahEnglishNameTranslation}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    entry.surahName,
                    style: const TextStyle(fontSize: 16),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: arabicTextStyle(context, size: 20),
              ),
              if (entry.ayah.translation != null) ...[
                const SizedBox(height: 8),
                Text(
                  entry.ayah.translation!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
