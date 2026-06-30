import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../core/theme/hub_background.dart';
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
      backgroundColor: HubTheme.backgroundMid,
      body: HubBackground(
        child: IndexedStack(
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
          animationDuration: HubTheme.navInteractionDuration,
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

/// Ícone da bottom nav — pulso 100→112→100 ms ao selecionar aba.
class _NavBarIcon extends StatefulWidget {
  const _NavBarIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;

  @override
  State<_NavBarIcon> createState() => _NavBarIconState();
}

class _NavBarIconState extends State<_NavBarIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: HubTheme.navInteractionDuration,
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));
    if (widget.isSelected) {
      _pulseController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_NavBarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        final scale = widget.isSelected ? _pulseScale.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Icon(widget.isSelected ? widget.selectedIcon : widget.icon),
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
