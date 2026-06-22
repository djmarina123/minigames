import 'package:flutter/material.dart';

import '../game_metadata.dart';
import '../game_result.dart';
import '../../theme/game_card_art.dart';
import '../../theme/game_ui.dart';
import '../../theme/hub_theme.dart';

/// Placar final estilizado — exibido ao terminar qualquer jogo.
class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.metadata,
    required this.result,
    required this.onExit,
    this.onDoubleCoins,
  });

  final GameMetadata metadata;
  final GameResult result;
  final VoidCallback onExit;
  final Future<void> Function()? onDoubleCoins;

  @override
  Widget build(BuildContext context) {
    final maxCombo = _metaInt(result.metadata['maxCombo']);
    final hits = _metaInt(result.metadata['hits']);
    final misses = _metaInt(result.metadata['misses']);
    final moves = _metaInt(result.metadata['moves']);
    final timeBonus = _metaInt(result.metadata['timeBonus']);
    final perfectBonus = _metaInt(result.metadata['perfectBonus']);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GameUi.surfaceCard, GameUi.surfaceDark],
            ),
            border: Border.all(color: GameUi.purple.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: GameUi.purple.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ResultHeader(metadata: metadata),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        _ScoreHero(score: result.score),
                        const SizedBox(height: 20),
                        _RewardRow(
                          coins: result.coinsEarned,
                          xp: result.xpEarned,
                          duration: result.duration,
                        ),
                        if ((maxCombo != null && maxCombo > 1) ||
                            hits != null ||
                            (misses != null && misses > 0) ||
                            moves != null ||
                            (timeBonus != null && timeBonus > 0) ||
                            (perfectBonus != null && perfectBonus > 0)) ...[
                          const SizedBox(height: 16),
                          _StatsChips(
                            maxCombo: maxCombo,
                            hits: hits,
                            misses: misses,
                            moves: moves,
                            timeBonus: timeBonus,
                            perfectBonus: perfectBonus,
                          ),
                        ],
                        const SizedBox(height: 24),
                        _ActionButtons(
                          onExit: onExit,
                          onDoubleCoins: onDoubleCoins,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.metadata});

  final GameMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameUi.purple.withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          GameCatalogThumbnail(
            gameId: metadata.id,
            theme: HubTheme.themeFor(metadata),
            size: 52,
          ),
          const SizedBox(height: 8),
          Text(
            'Fim de jogo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metadata.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameUi.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            'PONTUAÇÃO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: GameUi.gold.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, child) => Text(
              value.round().toString(),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                height: 1,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.emoji_events_rounded, color: GameUi.gold.withValues(alpha: 0.9), size: 28),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.coins,
    required this.xp,
    required this.duration,
  });

  final int coins;
  final int xp;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.monetization_on_rounded,
            iconColor: GameUi.gold,
            label: 'Moedas',
            value: '+$coins',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.bolt_rounded,
            iconColor: GameUi.teal,
            label: 'XP',
            value: '+$xp',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            iconColor: GameUi.purpleLight,
            label: 'Tempo',
            value: _formatDuration(duration),
          ),
        ),
      ],
    );
  }

  static String _formatDuration(Duration d) {
    if (d.inMinutes >= 1) {
      return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inSeconds}s';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsChips extends StatelessWidget {
  const _StatsChips({
    this.maxCombo,
    this.hits,
    this.misses,
    this.moves,
    this.timeBonus,
    this.perfectBonus,
  });

  final int? maxCombo;
  final int? hits;
  final int? misses;
  final int? moves;
  final int? timeBonus;
  final int? perfectBonus;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (maxCombo != null && maxCombo! > 1)
          _Chip(label: 'Combo máx.', value: 'x$maxCombo', color: GameUi.gold),
        if (hits != null)
          _Chip(label: 'Acertos', value: '$hits', color: GameUi.teal),
        if (misses != null && misses! > 0)
          _Chip(label: 'Erros', value: '$misses', color: GameUi.purpleLight),
        if (moves != null)
          _Chip(label: 'Jogadas', value: '$moves', color: GameUi.purpleLight),
        if (timeBonus != null && timeBonus! > 0)
          _Chip(label: 'Bônus tempo', value: '+$timeBonus', color: GameUi.teal),
        if (perfectBonus != null && perfectBonus! > 0)
          _Chip(label: 'Perfeito', value: '+$perfectBonus', color: GameUi.gold),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatefulWidget {
  const _ActionButtons({
    required this.onExit,
    this.onDoubleCoins,
  });

  final VoidCallback onExit;
  final Future<void> Function()? onDoubleCoins;

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _doubling = false;

  Future<void> _handleDoubleCoins() async {
    if (_doubling || widget.onDoubleCoins == null) return;
    setState(() => _doubling = true);
    try {
      await widget.onDoubleCoins!();
    } finally {
      if (mounted) setState(() => _doubling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _doubling ? null : widget.onExit,
          icon: const Icon(Icons.home_rounded, size: 20),
          label: const Text('Voltar ao hub'),
          style: FilledButton.styleFrom(
            backgroundColor: GameUi.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        if (widget.onDoubleCoins != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _doubling ? null : _handleDoubleCoins,
            icon: _doubling
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: GameUi.gold.withValues(alpha: 0.9),
                    ),
                  )
                : const Icon(Icons.play_circle_outline_rounded, size: 20),
            label: Text(_doubling ? 'Carregando anúncio…' : 'Dobrar moedas (anúncio)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: GameUi.gold,
              side: BorderSide(color: GameUi.gold.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

int? _metaInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return null;
}

/// Exibe o placar final com animação de entrada.
Future<void> showGameResultDialog({
  required BuildContext context,
  required GameMetadata metadata,
  required GameResult result,
  required VoidCallback onExit,
  Future<void> Function()? onDoubleCoins,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => GameResultDialog(
      metadata: metadata,
      result: result,
      onExit: onExit,
      onDoubleCoins: onDoubleCoins,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: curve, child: child),
      );
    },
  );
}
