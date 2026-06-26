import 'package:flutter/material.dart';

import '../game_metadata.dart';
import '../game_result.dart';
import '../../theme/game_card_art.dart';
import '../../economy/economy_copy.dart';
import '../../theme/hub_theme.dart';

/// Placar final estilizado — exibido ao terminar qualquer jogo.
class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.metadata,
    required this.result,
    required this.onExit,
    this.bestScore,
    this.isNewRecord = false,
    this.onPlayAgain,
    this.onDoubleCoins,
    this.levelUpLevels = 0,
    this.levelUpCoins = 0,
  });

  final GameMetadata metadata;
  final GameResult result;
  final VoidCallback onExit;
  /// Melhor pontuação já registrada neste jogo (após salvar a partida atual).
  final int? bestScore;
  final bool isNewRecord;
  final VoidCallback? onPlayAgain;
  final Future<void> Function()? onDoubleCoins;
  final int levelUpLevels;
  final int levelUpCoins;

  @override
  Widget build(BuildContext context) {
    final theme = HubTheme.themeFor(metadata);
    final maxCombo = _metaInt(result.metadata['maxCombo']);
    final hits = _metaInt(result.metadata['hits']);
    final misses = _metaInt(result.metadata['misses']);
    final moves = _metaInt(result.metadata['moves']);
    final timeBonus = _metaInt(result.metadata['timeBonus']);
    final perfectBonus = _metaInt(result.metadata['perfectBonus']);
    final highestTile = _metaInt(result.metadata['highestTile']);
    final tileBonus = _metaInt(result.metadata['tileBonus']);
    final obstaclesCleared = _metaInt(result.metadata['obstaclesCleared']);
    final distanceM = _metaInt(result.metadata['distanceM']);
    final speedLevel = _metaInt(result.metadata['speedLevel']);
    final foundationCards = _metaInt(result.metadata['foundationCards']);
    final foodEaten = _metaInt(result.metadata['foodEaten']);
    final snakeLength = _metaInt(result.metadata['snakeLength']);
    final mistakes = _metaInt(result.metadata['mistakes']);
    final hintsUsed = _metaInt(result.metadata['hintsUsed']);
    final cellsFilled = _metaInt(result.metadata['cellsFilled']);
    final outcomeWon = gameResultOutcomeWon(result.metadata);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: HubTheme.background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: theme.cardColor.withValues(alpha: 0.28),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ResultHeader(
                    metadata: metadata,
                    theme: theme,
                    isNewRecord: isNewRecord,
                    outcomeWon: outcomeWon,
                    bestScore: bestScore,
                    onExit: onExit,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      children: [
                        if (outcomeWon != null) ...[
                          _OutcomeBanner(won: outcomeWon),
                          const SizedBox(height: 14),
                        ],
                        _ScoreHero(
                          score: result.score,
                          bestScore: bestScore,
                          isNewRecord: isNewRecord,
                          cardColor: theme.cardColor,
                          accentColor: theme.accentColor,
                        ),
                        const SizedBox(height: 16),
                        _RewardRow(
                          coins: result.coinsEarned,
                          xp: result.xpEarned,
                          duration: result.duration,
                          accentColor: theme.accentColor,
                        ),
                        if (levelUpLevels > 0) ...[
                          const SizedBox(height: 10),
                          _LevelUpBanner(
                            levels: levelUpLevels,
                            bonusCoins: levelUpCoins,
                          ),
                        ],
                        if ((maxCombo != null && maxCombo > 1) ||
                            hits != null ||
                            (misses != null && misses > 0) ||
                            moves != null ||
                            (timeBonus != null && timeBonus > 0) ||
                            (perfectBonus != null && perfectBonus > 0) ||
                            (highestTile != null && highestTile > 0) ||
                            (tileBonus != null && tileBonus > 0) ||
                            (obstaclesCleared != null && obstaclesCleared > 0) ||
                            (distanceM != null && distanceM > 0) ||
                            (speedLevel != null && speedLevel > 0) ||
                            (foundationCards != null && foundationCards > 0) ||
                            (foodEaten != null && foodEaten > 0) ||
                            (snakeLength != null && snakeLength > 0) ||
                            (mistakes != null && mistakes > 0) ||
                            (hintsUsed != null && hintsUsed > 0) ||
                            (cellsFilled != null && cellsFilled > 0)) ...[
                          const SizedBox(height: 14),
                          _StatsChips(
                            cardColor: theme.cardColor,
                            accentColor: theme.accentColor,
                            maxCombo: maxCombo,
                            hits: hits,
                            misses: misses,
                            moves: moves,
                            timeBonus: timeBonus,
                            perfectBonus: perfectBonus,
                            highestTile: highestTile,
                            tileBonus: tileBonus,
                            obstaclesCleared: obstaclesCleared,
                            distanceM: distanceM,
                            speedLevel: speedLevel,
                            foundationCards: foundationCards,
                            foodEaten: foodEaten,
                            snakeLength: snakeLength,
                            mistakes: mistakes,
                            hintsUsed: hintsUsed,
                            cellsFilled: cellsFilled,
                          ),
                        ],
                        const SizedBox(height: 20),
                        _ActionButtons(
                          cardColor: theme.cardColor,
                          onPlayAgain: onPlayAgain,
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

class _OutcomeBanner extends StatelessWidget {
  const _OutcomeBanner({required this.won});

  final bool won;

  static const _victoryColor = Color(0xFF00B894);
  static const _defeatColor = HubTheme.featuredBadge;

  @override
  Widget build(BuildContext context) {
    final color = won ? _victoryColor : _defeatColor;
    final icon = won ? Icons.emoji_events_rounded : Icons.close_rounded;
    final title = won ? 'VITÓRIA' : 'DERROTA';
    final subtitle = won
        ? 'Você venceu a partida!'
        : 'Não foi desta vez — tente de novo.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HubTheme.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.metadata,
    required this.theme,
    required this.isNewRecord,
    required this.onExit,
    this.outcomeWon,
    this.bestScore,
  });

  final GameMetadata metadata;
  final HubGameTheme theme;
  final bool isNewRecord;
  final VoidCallback onExit;
  final bool? outcomeWon;
  final int? bestScore;

  String _subtitle() {
    if (isNewRecord) return 'Novo recorde!';
    if (outcomeWon == true) return 'Vitória!';
    if (outcomeWon == false) return 'Derrota';
    return 'Partida encerrada';
  }

  Color _subtitleColor() {
    if (isNewRecord) return theme.accentColor;
    if (outcomeWon == true) return const Color(0xFF00B894);
    if (outcomeWon == false) return HubTheme.featuredBadge;
    return Colors.white.withValues(alpha: 0.82);
  }

  @override
  Widget build(BuildContext context) {
    final titleLead = hubTitleLead(metadata.title);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.cardColor,
            Color.lerp(theme.cardColor, theme.accentColor, 0.35)!,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 12,
            top: -18,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -24,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: onExit,
                  tooltip: 'Voltar ao hub',
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    minimumSize: const Size(40, 40),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 6),
                GameCatalogThumbnail(
                  gameId: metadata.id,
                  theme: theme,
                  title: metadata.title,
                  size: 52,
                  showTitle: false,
                  showFeaturedBadge: metadata.featured,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hubDisplayTitle(metadata.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: hubUnderlineWidth(titleLead),
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _subtitle(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _subtitleColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                if (bestScore != null) ...[
                  const SizedBox(width: 8),
                  _BestScoreBadge(
                    bestScore: bestScore!,
                    accentColor: theme.accentColor,
                    highlight: isNewRecord,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BestScoreBadge extends StatelessWidget {
  const _BestScoreBadge({
    required this.bestScore,
    required this.accentColor,
    required this.highlight,
  });

  final int bestScore;
  final Color accentColor;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? HubTheme.coinGold.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? HubTheme.coinGold.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 16,
            color: highlight ? HubTheme.coinGold : Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 2),
          Text(
            'MELHOR',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          Text(
            '$bestScore',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
              color: highlight ? HubTheme.coinGold : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({
    required this.score,
    required this.bestScore,
    required this.isNewRecord,
    required this.cardColor,
    required this.accentColor,
  });

  final int score;
  final int? bestScore;
  final bool isNewRecord;
  final Color cardColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final gapToBest = bestScore != null && !isNewRecord && bestScore! > score
        ? bestScore! - score
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNewRecord
              ? HubTheme.coinGold.withValues(alpha: 0.65)
              : const Color(0xFFE8E0D5),
          width: isNewRecord ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isNewRecord ? HubTheme.coinGold : cardColor)
                .withValues(alpha: isNewRecord ? 0.18 : 0.08),
            blurRadius: isNewRecord ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isNewRecord ? 'NOVO RECORDE' : 'PONTUAÇÃO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: isNewRecord ? HubTheme.coinGold : HubTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score.toDouble()),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, child) => Text(
              value.round().toString(),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                height: 1,
                color: cardColor,
                letterSpacing: -1.5,
              ),
            ),
          ),
          if (gapToBest != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HubTheme.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Faltaram $gapToBest pts para o recorde',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HubTheme.textSecondary,
                ),
              ),
            ),
          ],
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
    required this.accentColor,
  });

  final int coins;
  final int xp;
  final Duration duration;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: HubTheme.coinIcon,
            iconColor: HubTheme.coinGold,
            label: 'Moedas',
            value: '+$coins',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: HubTheme.levelIcon,
            iconColor: HubTheme.removeAdsPurple,
            label: 'XP nível',
            value: EconomyCopy.sessionXpLabel(xp),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            iconColor: HubTheme.removeAdsPurple,
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

class _LevelUpBanner extends StatelessWidget {
  const _LevelUpBanner({
    required this.levels,
    required this.bonusCoins,
  });

  final int levels;
  final int bonusCoins;

  @override
  Widget build(BuildContext context) {
    final label = levels == 1 ? 'Nível up!' : '+$levels níveis!';
    final subtitle = bonusCoins > 0 ? '+$bonusCoins moedas de bônus' : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00B894), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(HubTheme.levelIcon, color: Color(0xFF00B894), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: HubTheme.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00B894),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E0D5), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: HubTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: HubTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsChips extends StatelessWidget {
  const _StatsChips({
    required this.cardColor,
    required this.accentColor,
    this.maxCombo,
    this.hits,
    this.misses,
    this.moves,
    this.timeBonus,
    this.perfectBonus,
    this.highestTile,
    this.tileBonus,
    this.obstaclesCleared,
    this.distanceM,
    this.speedLevel,
    this.foundationCards,
    this.foodEaten,
    this.snakeLength,
    this.mistakes,
    this.hintsUsed,
    this.cellsFilled,
  });

  final Color cardColor;
  final Color accentColor;
  final int? maxCombo;
  final int? hits;
  final int? misses;
  final int? moves;
  final int? timeBonus;
  final int? perfectBonus;
  final int? highestTile;
  final int? tileBonus;
  final int? obstaclesCleared;
  final int? distanceM;
  final int? speedLevel;
  final int? foundationCards;
  final int? foodEaten;
  final int? snakeLength;
  final int? mistakes;
  final int? hintsUsed;
  final int? cellsFilled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (maxCombo != null && maxCombo! > 1)
          _Chip(label: 'Combo máx.', value: 'x$maxCombo', color: HubTheme.coinGold),
        if (hits != null)
          _Chip(label: 'Acertos', value: '$hits', color: accentColor),
        if (misses != null && misses! > 0)
          _Chip(label: 'Erros', value: '$misses', color: cardColor),
        if (moves != null)
          _Chip(label: 'Jogadas', value: '$moves', color: cardColor),
        if (timeBonus != null && timeBonus! > 0)
          _Chip(label: 'Bônus tempo', value: '+$timeBonus', color: accentColor),
        if (perfectBonus != null && perfectBonus! > 0)
          _Chip(label: 'Perfeito', value: '+$perfectBonus', color: HubTheme.coinGold),
        if (highestTile != null && highestTile! > 0)
          _Chip(label: 'Maior peça', value: '$highestTile', color: accentColor),
        if (tileBonus != null && tileBonus! > 0)
          _Chip(label: 'Bônus peça', value: '+$tileBonus', color: HubTheme.coinGold),
        if (obstaclesCleared != null && obstaclesCleared! > 0)
          _Chip(label: 'Obstáculos', value: '$obstaclesCleared', color: accentColor),
        if (distanceM != null && distanceM! > 0)
          _Chip(label: 'Distância', value: '${distanceM}m', color: cardColor),
        if (speedLevel != null && speedLevel! > 1)
          _Chip(label: 'Velocidade', value: 'Nv. $speedLevel', color: HubTheme.coinGold),
        if (foundationCards != null && foundationCards! > 0)
          _Chip(label: 'Fundação', value: '$foundationCards/52', color: accentColor),
        if (foodEaten != null && foodEaten! > 0)
          _Chip(label: 'Frutas', value: '$foodEaten', color: accentColor),
        if (snakeLength != null && snakeLength! > 3)
          _Chip(label: 'Tamanho', value: '$snakeLength', color: cardColor),
        if (mistakes != null && mistakes! > 0)
          _Chip(label: 'Erros', value: '$mistakes', color: HubTheme.featuredBadge),
        if (hintsUsed != null && hintsUsed! > 0)
          _Chip(label: 'Dicas', value: '$hintsUsed', color: cardColor),
        if (cellsFilled != null && cellsFilled! > 0)
          _Chip(label: 'Células', value: '$cellsFilled/81', color: accentColor),
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontSize: 11,
                color: HubTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
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
    required this.cardColor,
    this.onPlayAgain,
    this.onDoubleCoins,
  });

  final Color cardColor;
  final VoidCallback? onPlayAgain;
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
    final busy = _doubling;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onPlayAgain != null) ...[
          FilledButton.icon(
            onPressed: busy ? null : widget.onPlayAgain,
            icon: const Icon(Icons.replay_rounded, size: 22),
            label: const Text('JOGAR NOVAMENTE'),
            style: FilledButton.styleFrom(
              backgroundColor: widget.cardColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: widget.cardColor.withValues(alpha: 0.45),
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shadowColor: widget.cardColor.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (widget.onDoubleCoins != null) ...[
          OutlinedButton.icon(
            onPressed: busy ? null : _handleDoubleCoins,
            icon: busy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: HubTheme.coinGold.withValues(alpha: 0.9),
                    ),
                  )
                : const Icon(Icons.play_circle_outline_rounded, size: 20),
            label: Text(
              busy ? 'Carregando anúncio…' : 'Dobrar moedas (anúncio)',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: HubTheme.textPrimary,
              side: BorderSide(color: HubTheme.coinGold.withValues(alpha: 0.65)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
  int? bestScore,
  bool isNewRecord = false,
  VoidCallback? onPlayAgain,
  Future<void> Function()? onDoubleCoins,
  int levelUpLevels = 0,
  int levelUpCoins = 0,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => GameResultDialog(
      metadata: metadata,
      result: result,
      onExit: onExit,
      bestScore: bestScore,
      isNewRecord: isNewRecord,
      onPlayAgain: onPlayAgain,
      onDoubleCoins: onDoubleCoins,
      levelUpLevels: levelUpLevels,
      levelUpCoins: levelUpCoins,
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
