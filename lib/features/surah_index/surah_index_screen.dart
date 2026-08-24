import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/surah.dart';
import '../../providers/quran_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_list_skeleton.dart';

class SurahIndexScreen extends ConsumerStatefulWidget {
  const SurahIndexScreen({super.key});

  @override
  ConsumerState<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends ConsumerState<SurahIndexScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Surah Index')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search surahs…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: surahsAsync.when(
              loading: () => const LoadingListSkeleton(),
              error: (err, _) => ErrorView(
                message: 'Could not load the surah list.\n$err',
                onRetry: () => ref.invalidate(surahListProvider),
              ),
              data: (surahs) {
                final filtered = _query.isEmpty
                    ? surahs
                    : surahs
                        .where((s) =>
                            s.englishName.toLowerCase().contains(_query) ||
                            s.englishNameTranslation
                                .toLowerCase()
                                .contains(_query) ||
                            s.name.contains(_query) ||
                            s.number.toString() == _query)
                        .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off_rounded,
                    message: 'No surahs match your search.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _SurahTile(surah: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  final SurahMeta surah;
  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Text('${surah.number}'),
      ),
      title: Text(surah.englishName),
      subtitle: Text(
        '${surah.englishNameTranslation} · ${surah.revelationType} · ${surah.numberOfAyahs} ayahs',
      ),
      trailing: Text(
        surah.name,
        style: const TextStyle(fontSize: 20),
        textDirection: TextDirection.rtl,
      ),
      onTap: () => context.push('/surah/${surah.number}'),
    );
  }
}
