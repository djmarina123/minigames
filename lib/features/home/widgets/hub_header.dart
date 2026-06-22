import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/player_repository.dart';
import '../../../core/theme/hub_theme.dart';

/// Barra superior do hub: menu, moedas, remover ads.
class HubHeader extends StatelessWidget {
  const HubHeader({
    super.key,
    this.onMenuTap,
  });

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<PlayerRepository>().profile.coins;

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
          _CoinPill(coins: coins),
          const SizedBox(width: 8),
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
            child: const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            '$coins',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3436),
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
    return Material(
      color: HubTheme.removeAdsPurple,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: HubTheme.removeAdsPurple.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.campaign_rounded,
                size: 18,
                color: Colors.yellow.shade300,
              ),
              const SizedBox(width: 6),
              const Text(
                'REMOVER ADS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
