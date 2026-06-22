import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _prefix = 'leaderboard_';
  static const maxEntries = 10;

  String _key(String gameId) => '$_prefix$gameId';

  Future<List<LeaderboardEntry>> getEntries(String gameId) async {
    final raw = _prefs.getString(_key(gameId));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, Object?>))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  Future<List<LeaderboardEntry>> getAllBest() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix));
    final best = <LeaderboardEntry>[];

    for (final key in keys) {
      final entries = await getEntries(key.substring(_prefix.length));
      if (entries.isNotEmpty) {
        best.add(entries.first);
      }
    }

    best.sort((a, b) => b.score.compareTo(a.score));
    return best;
  }

  Future<void> submitScore({
    required String gameId,
    required String gameTitle,
    required int score,
  }) async {
    final entries = await getEntries(gameId);
    entries.add(
      LeaderboardEntry(
        gameId: gameId,
        gameTitle: gameTitle,
        score: score,
        recordedAt: DateTime.now(),
      ),
    );
    entries.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = entries.take(maxEntries).toList();
    await _prefs.setString(
      _key(gameId),
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }
}
