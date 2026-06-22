import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/player_repository.dart';
import '../../../core/theme/hub_theme.dart';

/// Banner compacto de recompensa diária — abaixo do header.
class DailyRewardBanner extends StatelessWidget {
  const DailyRewardBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerRepository>();
    if (!player.canClaimDaily) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: HubTheme.removeAdsPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () async {
            final reward = await context.read<PlayerRepository>().claimDailyReward();
            if (context.mounted && reward != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('+$reward moedas resgatadas!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HubTheme.coinGold.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: HubTheme.coinGold),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Recompensa diária disponível!',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
                Text(
                  'Resgatar',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: HubTheme.removeAdsPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
