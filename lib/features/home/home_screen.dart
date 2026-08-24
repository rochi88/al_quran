import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/settings_providers.dart';
import 'verse_of_the_day.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastRead = ref.watch(lastReadProvider);
    final verse = verseForToday(DateTime.now());
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("The Holy Qur'an")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (lastRead != null) ...[
            Card(
              color: scheme.primaryContainer,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(Icons.menu_book_rounded, color: scheme.onPrimaryContainer),
                title: Text(
                  'Continue reading',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
                subtitle: Text(
                  '${lastRead.surahEnglishName} · Ayah ${lastRead.ayahNumberInSurah}',
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
                trailing: Icon(Icons.arrow_forward_rounded, color: scheme.onPrimaryContainer),
                onTap: () => context.push(
                  '/surah/${lastRead.surahNumber}?ayah=${lastRead.ayahNumberInSurah}',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _QuickLinks(),
          const SizedBox(height: 16),
          _VerseOfTheDayCard(verse: verse),
        ],
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickLinkTile(
            icon: Icons.menu_book_rounded,
            label: 'Surah Index',
            onTap: () => context.go('/surahs'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickLinkTile(
            icon: Icons.self_improvement_rounded,
            label: 'Sajda Index',
            onTap: () => context.go('/sajda'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickLinkTile(
            icon: Icons.bookmark_rounded,
            label: 'Bookmarks',
            onTap: () => context.go('/bookmarks'),
          ),
        ),
      ],
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLinkTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseOfTheDayCard extends StatelessWidget {
  final DailyVerse verse;
  const _VerseOfTheDayCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          '/surah/${verse.surahNumber}?ayah=${verse.ayahNumberInSurah}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verse of the day',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                verse.text,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: arabicTextStyle(context, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                verse.translation,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '— ${verse.surahEnglishName} ${verse.surahNumber}:${verse.ayahNumberInSurah}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
