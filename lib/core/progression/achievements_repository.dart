import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/player_repository.dart';
import 'achievements_catalog.dart';
import 'progression_models.dart';

/// Persiste e avalia conquistas desbloqueadas.
class AchievementsRepository extends ChangeNotifier {
  AchievementsRepository(this._prefs, this._playerRepo);

  final SharedPreferences _prefs;
  final PlayerRepository _playerRepo;

  static const _unlocksKey = 'achievement_unlocks';
  static const _gamesKey = 'achievement_games_played';

  final Map<String, DateTime> _unlocks = {};
  final Set<String> _gamesPlayed = {};
  final List<UnlockedAchievement> _pendingNotifications = [];

  List<UnlockedAchievement> get pendingNotifications =>
      List.unmodifiable(_pendingNotifications);

  int get unlockedCount => _unlocks.length;
  int get totalCount => AchievementsCatalog.all.length;

  Future<void> load() async {
    _unlocks.clear();
    _gamesPlayed.clear();
    _pendingNotifications.clear();

    final rawUnlocks = _prefs.getString(_unlocksKey);
    if (rawUnlocks != null) {
      try {
        final map = jsonDecode(rawUnlocks) as Map<String, dynamic>;
        for (final entry in map.entries) {
          final at = DateTime.tryParse(entry.value as String? ?? '');
          if (at != null) _unlocks[entry.key] = at;
        }
      } catch (e, st) {
        debugPrint('AchievementsRepository.load unlocks: $e');
        debugPrint('$st');
      }
    }

    final rawGames = _prefs.getStringList(_gamesKey);
    if (rawGames != null) _gamesPlayed.addAll(rawGames);

    notifyListeners();
  }

  bool isUnlocked(String id) => _unlocks.containsKey(id);

  List<UnlockedAchievement> allUnlocked() {
    final items = _unlocks.entries
        .map((e) {
          final def = AchievementsCatalog.byId(e.key);
          if (def == null) return null;
          return UnlockedAchievement(definition: def, unlockedAt: e.value);
        })
        .whereType<UnlockedAchievement>()
        .toList();
    items.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return items;
  }

  List<AchievementDefinition> lockedDefinitions() {
    return AchievementsCatalog.all
        .where((def) => !isUnlocked(def.id))
        .toList(growable: false);
  }

  /// Avalia conquistas após uma partida. Retorna as recém-desbloqueadas.
  Future<List<UnlockedAchievement>> onSession(SessionEvent event) async {
    _gamesPlayed.add(event.gameId);
    await _prefs.setStringList(_gamesKey, _gamesPlayed.toList());

    final enriched = SessionEvent(
      gameId: event.gameId,
      score: event.score,
      tierName: event.tierName,
      isNewRecord: event.isNewRecord,
      gamesPlayed: event.gamesPlayed,
      level: event.level,
      dailyStreak: event.dailyStreak,
      uniqueGamesPlayed: _gamesPlayed.length,
      won: event.won,
    );

    final newlyUnlocked = <UnlockedAchievement>[];
    for (final def in AchievementsCatalog.all) {
      if (_unlocks.containsKey(def.id)) continue;
      if (!AchievementsCatalog.isUnlocked(def.id, enriched)) continue;

      final now = DateTime.now();
      _unlocks[def.id] = now;
      if (def.coinReward > 0) {
        await _playerRepo.addBonusCoins(def.coinReward);
      }
      final unlock = UnlockedAchievement(definition: def, unlockedAt: now);
      newlyUnlocked.add(unlock);
      _pendingNotifications.add(unlock);
    }

    if (newlyUnlocked.isNotEmpty) {
      await _saveUnlocks();
      notifyListeners();
    }

    return newlyUnlocked;
  }

  void clearPendingNotifications() {
    if (_pendingNotifications.isEmpty) return;
    _pendingNotifications.clear();
    notifyListeners();
  }

  Future<void> _saveUnlocks() async {
    final map = {
      for (final entry in _unlocks.entries)
        entry.key: entry.value.toIso8601String(),
    };
    await _prefs.setString(_unlocksKey, jsonEncode(map));
  }
}
