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

    final amount = player.dailyRewardAmount;
    final streakDay = player.nextDailyStreak;
    final streakLabel = streakDay > 1
        ? 'Dia $streakDay da sequência'
        : 'Comece sua sequência diária';

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            HubTheme.coinIcon,
                            size: 18,
                            color: HubTheme.coinGold,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Ganhe +$amount moedas',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: HubTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        streakLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: HubTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HubTheme.removeAdsPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Resgatar',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Colors.white,
                    ),
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
