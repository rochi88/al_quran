import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../providers/auth_providers.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m!),
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('System default'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Light'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('Dark'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Account'),
          if (!isFirebaseSupportedOnThisPlatform)
            const ListTile(
              leading: Icon(Icons.info_outline_rounded),
              title: Text('Sync unavailable on this platform'),
              subtitle: Text('Bookmarks are saved on this device only.'),
            )
          else
            authState.when(
              loading: () => const ListTile(title: Text('Loading…')),
              error: (e, _) => ListTile(title: Text('Auth error: $e')),
              data: (user) {
                final auth = ref.read(authRepositoryProvider);
                if (user != null && auth.isLinkedToGoogle) {
                  return ListTile(
                    leading: const Icon(Icons.cloud_done_rounded),
                    title: Text(user.displayName ?? user.email ?? 'Signed in'),
                    subtitle: const Text('Bookmarks sync across your devices.'),
                    trailing: TextButton(
                      onPressed: () => auth.signOut(),
                      child: const Text('Sign out'),
                    ),
                  );
                }
                return ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Bookmarks are saved on this device'),
                  subtitle: const Text('Sign in with Google to sync across devices.'),
                  trailing: FilledButton.tonal(
                    onPressed: () => auth.linkWithGoogle(),
                    child: const Text('Sign in'),
                  ),
                );
              },
            ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text("The Holy Qur'an"),
            subtitle: Text('Text and translation courtesy of alquran.cloud.'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
