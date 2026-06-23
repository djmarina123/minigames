import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/player_profile.dart';
import '../../../core/storage/player_repository.dart';
import '../../../core/theme/hub_theme.dart';

/// Barra superior do hub: menu, nível, moedas, remover ads.
class HubHeader extends StatelessWidget {
  const HubHeader({
    super.key,
    this.onMenuTap,
    this.onProfileTap,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerRepository>().profile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: const Icon(Icons.menu_rounded, size: 28),
            color: HubTheme.headerIcon,
          ),
          const Spacer(),
          _LevelPill(
            profile: profile,
            onTap: onProfileTap,
          ),
          const SizedBox(width: 6),
          _CoinPill(coins: profile.coins),
          const SizedBox(width: 6),
          _RemoveAdsButton(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compra "Remover ads" — em breve na Fase 2'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({
    required this.profile,
    this.onTap,
  });

  final PlayerProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HubTheme.levelPillBg,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: _LevelRing(
            level: profile.level,
            progress: profile.levelProgress,
          ),
        ),
      ),
    );
  }
}

class _LevelRing extends StatelessWidget {
  const _LevelRing({
    required this.level,
    required this.progress,
  });

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: 2.5,
            backgroundColor: HubTheme.removeAdsPurple.withValues(alpha: 0.18),
            color: HubTheme.removeAdsPurple,
          ),
          Text(
            '$level',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: HubTheme.removeAdsPurple,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: HubTheme.coinPillBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: HubTheme.coinGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(HubTheme.coinIcon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            '$coins',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: HubTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveAdsButton extends StatelessWidget {
  const _RemoveAdsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Remover anúncios',
      child: Material(
        color: HubTheme.removeAdsPurple,
        borderRadius: BorderRadius.circular(14),
        elevation: 2,
        shadowColor: HubTheme.removeAdsPurple.withValues(alpha: 0.4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.campaign_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
