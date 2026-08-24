import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef _Destination = ({IconData icon, IconData selectedIcon, String label});

const _destinations = <_Destination>[
  (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
  (
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: 'Surahs',
  ),
  (
    icon: Icons.self_improvement_outlined,
    selectedIcon: Icons.self_improvement_rounded,
    label: 'Sajda',
  ),
  (
    icon: Icons.bookmark_outline_rounded,
    selectedIcon: Icons.bookmark_rounded,
    label: 'Bookmarks',
  ),
  (
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

/// Wraps the five main sections in a Material 3 `NavigationBar` on narrow
/// (phone) layouts and a `NavigationRail` on wide (tablet/desktop/web)
/// layouts, so the same routes/screens work everywhere.
class AdaptiveScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveScaffold({super.key, required this.navigationShell});

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
