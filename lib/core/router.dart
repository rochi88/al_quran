import 'package:go_router/go_router.dart';

import '../features/bookmarks/bookmarks_screen.dart';
import '../features/home/home_screen.dart';
import '../features/sajda/sajda_index_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/adaptive_scaffold.dart';
import '../features/surah_index/surah_index_screen.dart';
import '../features/surah_reader/surah_reader_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdaptiveScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (c, s) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/surahs', builder: (c, s) => const SurahIndexScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/sajda', builder: (c, s) => const SajdaIndexScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/bookmarks', builder: (c, s) => const BookmarksScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/surah/:number',
      builder: (context, state) {
        final number = int.parse(state.pathParameters['number']!);
        final ayah = int.tryParse(state.uri.queryParameters['ayah'] ?? '');
        return SurahReaderScreen(surahNumber: number, scrollToAyah: ayah);
      },
    ),
  ],
);
