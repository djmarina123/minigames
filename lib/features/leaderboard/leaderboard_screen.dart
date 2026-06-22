import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_registry.dart';
import '../../core/leaderboard/leaderboard_repository.dart';
import '../../core/models/leaderboard_entry.dart';
import '../../core/theme/hub_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, this.isActive = false});

  /// Recarrega quando a aba Ranking fica visível (IndexedStack mantém o estado).
  final bool isActive;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant LeaderboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = context.read<LeaderboardRepository>();
    final entries = await repo.getAllBest();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HubTheme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _LeaderboardHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: HubTheme.removeAdsPurple,
                      child: _entries.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [_EmptyRanking()],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: _entries.length,
                              itemBuilder: (context, index) {
                                final entry = _entries[index];
                                return _RankingCard(
                                  rank: index + 1,
                                  entry: entry,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardHeader extends StatelessWidget {
  const _LeaderboardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RANKING',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: const Color(0xFF2D3436),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seu melhor score em cada jogo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF636E72),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRanking extends StatelessWidget {
  const _EmptyRanking();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: HubTheme.removeAdsPurple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 44,
              color: HubTheme.removeAdsPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum score ainda',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2D3436),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete uma partida para aparecer aqui com seu melhor resultado.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF636E72),
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.rank,
    required this.entry,
  });

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final meta = GameRegistry.instance.findById(entry.gameId)?.metadata;
    final theme = HubTheme.themeFor(
      meta ??
          GameMetadata(
            id: entry.gameId,
            title: entry.gameTitle,
            description: '',
            category: '',
          ),
    );
    final icon = meta?.icon ?? '🎮';
    final medal = switch (rank) {
      1 => _Medal.gold,
      2 => _Medal.silver,
      3 => _Medal.bronze,
      _ => _Medal.none,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(HubTheme.cardRadius),
        border: Border.all(color: HubTheme.cardBorder, width: 4),
        boxShadow: [
          BoxShadow(
            color: theme.cardColor.withValues(alpha: 0.35),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _RankBadge(rank: rank, medal: medal),
            const SizedBox(width: 12),
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hubDisplayTitle(entry.gameTitle),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'PONTOS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _Medal { gold, silver, bronze, none }

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.medal});

  final int rank;
  final _Medal medal;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (medal) {
      _Medal.gold => (
          const Color(0xFFFDCB6E),
          const Color(0xFF6C4A00),
          '🥇',
        ),
      _Medal.silver => (
          const Color(0xFFDFE6E9),
          const Color(0xFF2D3436),
          '🥈',
        ),
      _Medal.bronze => (
          const Color(0xFFE17055),
          Colors.white,
          '🥉',
        ),
      _Medal.none => (
          Colors.white.withValues(alpha: 0.25),
          Colors.white,
          '$rank',
        ),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: medal == _Medal.none ? 16 : 20,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}
