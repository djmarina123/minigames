import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/hub_theme.dart';
import '../home/home_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: HubTheme.background,
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
            onProfileTap: () => setState(() => _index = 2),
          ),
          LeaderboardScreen(isActive: _index == 1),
          const ProfileScreen(),
        ],
      ),
      drawer: _HubDrawer(
        selectedIndex: _index,
        onSelect: (i) {
          setState(() => _index = i);
          Navigator.of(context).pop();
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: HubTheme.appBarBackground,
            indicatorColor: HubTheme.removeAdsPurple.withValues(alpha: 0.22),
            elevation: 0,
            height: 68,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: selected ? 12 : 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected
                    ? HubTheme.removeAdsPurple
                    : HubTheme.textSecondary,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: selected ? 26 : 24,
                color: selected
                    ? HubTheme.removeAdsPurple
                    : HubTheme.textSecondary,
              );
            }),
          ),
        ),
        child: NavigationBar(
          backgroundColor: HubTheme.appBarBackground,
          indicatorColor: HubTheme.removeAdsPurple.withValues(alpha: 0.22),
          elevation: 0,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: _NavBarIcon(
                icon: Icons.sports_esports_outlined,
                selectedIcon: Icons.sports_esports,
                isSelected: _index == 0,
              ),
              selectedIcon: _NavBarIcon(
                icon: Icons.sports_esports_outlined,
                selectedIcon: Icons.sports_esports,
                isSelected: true,
              ),
              label: l10n.navGames,
            ),
            NavigationDestination(
              icon: _NavBarIcon(
                icon: Icons.leaderboard_outlined,
                selectedIcon: Icons.leaderboard,
                isSelected: _index == 1,
              ),
              selectedIcon: _NavBarIcon(
                icon: Icons.leaderboard_outlined,
                selectedIcon: Icons.leaderboard,
                isSelected: true,
              ),
              label: l10n.navRanking,
            ),
            NavigationDestination(
              icon: _NavBarIcon(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                isSelected: _index == 2,
              ),
              selectedIcon: _NavBarIcon(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                isSelected: true,
              ),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ícone da bottom nav — escala 110% e leve elevação quando ativo.
class _NavBarIcon extends StatelessWidget {
  const _NavBarIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? HubTheme.navIconSelectedScale : 1.0,
      duration: HubTheme.interactionDuration,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: HubTheme.interactionDuration,
        curve: Curves.easeOut,
        decoration: isSelected
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: HubTheme.removeAdsPurple.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Icon(isSelected ? selectedIcon : icon),
      ),
    );
  }
}

class _HubDrawer extends StatelessWidget {
  const _HubDrawer({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HubTheme.removeAdsPurple,
                    HubTheme.removeAdsPurple.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  l10n.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.sports_esports,
              label: l10n.navGames,
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            _DrawerTile(
              icon: Icons.leaderboard,
              label: l10n.navRanking,
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            _DrawerTile(
              icon: Icons.person,
              label: l10n.navProfile,
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? HubTheme.removeAdsPurple : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? HubTheme.removeAdsPurple : null,
        ),
      ),
      selected: selected,
      onTap: onTap,
    );
  }
}
