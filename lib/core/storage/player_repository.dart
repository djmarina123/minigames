import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../economy/economy_config.dart';
import '../economy/level_curve.dart';
import '../models/player_profile.dart';

/// Resultado de [PlayerRepository.recordGameSession] — níveis ganhos e bônus.
class GameSessionRecord {
  const GameSessionRecord({
    this.previousLevel = 1,
    this.newLevel = 1,
    this.levelUpCoins = 0,
  });

  final int previousLevel;
  final int newLevel;

  int get levelsGained => newLevel - previousLevel;
  final int levelUpCoins;

  bool get didLevelUp => levelsGained > 0;
}

class PlayerRepository extends ChangeNotifier {
  PlayerRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'player_profile';

  PlayerProfile _profile = const PlayerProfile();
  PlayerProfile get profile => _profile;

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      try {
        _profile = PlayerProfile.fromJson(
          jsonDecode(raw) as Map<String, Object?>,
        );
      } catch (e, st) {
        debugPrint('PlayerRepository.load: perfil inválido, usando default — $e');
        debugPrint('$st');
        _profile = const PlayerProfile();
      }
    }
    await _ensureStarterCoins();
    notifyListeners();
  }

  /// Jogadores sem histórico recebem o saldo inicial (inclui perfis antigos com 0).
  Future<void> _ensureStarterCoins() async {
    if (_profile.gamesPlayed == 0 &&
        _profile.coins < EconomyConfig.startingCoins) {
      _profile = _profile.copyWith(coins: EconomyConfig.startingCoins);
      await _prefs.setString(_key, jsonEncode(_profile.toJson()));
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  bool get canClaimDaily {
    final last = _profile.lastDailyClaim;
    if (last == null) return true;
    return !_isSameDay(last, DateTime.now());
  }

  /// Sequência que o jogador terá após resgatar hoje (1 se primeira vez ou quebra).
  int get nextDailyStreak {
    if (!canClaimDaily) return _profile.dailyStreak;
    final last = _profile.lastDailyClaim;
    final now = DateTime.now();
    if (last != null && _isYesterday(last, now)) {
      return (_profile.dailyStreak + 1).clamp(1, EconomyConfig.dailyStreakCap);
    }
    return 1;
  }

  int get dailyRewardAmount =>
      EconomyConfig.dailyRewardForStreak(nextDailyStreak);

  /// Primeira partida do dia civil (para bônus de XP).
  bool get isFirstGameToday {
    final last = _profile.lastGamePlayed;
    if (last == null) return true;
    return !_isSameDay(last, DateTime.now());
  }

  Future<int?> claimDailyReward() async {
    if (!canClaimDaily) return null;

    final now = DateTime.now();
    final newStreak = nextDailyStreak;
    final reward = dailyRewardAmount;

    _profile = _profile.copyWith(
      coins: _profile.coins + reward,
      lastDailyClaim: now,
      dailyStreak: newStreak,
    );
    await _save();
    return reward;
  }

  /// Registra o fim de uma partida (moedas, XP, nível e contador de partidas).
  Future<GameSessionRecord> recordGameSession({
    required int coinsEarned,
    required int xpEarned,
  }) async {
    final previousLevel = _profile.level;
    final now = DateTime.now();
    final newXp = _profile.xp + xpEarned;
    final newLevel = levelFromXp(newXp);
    final levelUpCoins = totalLevelUpCoins(
      fromLevel: previousLevel,
      toLevel: newLevel,
    );

    _profile = _profile.copyWith(
      coins: _profile.coins + coinsEarned + levelUpCoins,
      xp: newXp,
      gamesPlayed: _profile.gamesPlayed + 1,
      lastGamePlayed: now,
    );
    await _save();

    return GameSessionRecord(
      previousLevel: previousLevel,
      newLevel: newLevel,
      levelUpCoins: levelUpCoins,
    );
  }

  /// Bônus sem incrementar partidas (anúncio, recompensa mid-game, etc.).
  Future<void> addBonusCoins(int amount) async {
    if (amount <= 0) return;
    _profile = _profile.copyWith(coins: _profile.coins + amount);
    await _save();
  }

  /// Gasta moedas se houver saldo — retorna `false` se insuficiente.
  bool trySpendCoins(int amount) {
    if (amount <= 0 || _profile.coins < amount) return false;
    _profile = _profile.copyWith(coins: _profile.coins - amount);
    unawaited(_save());
    return true;
  }

  bool isFavorite(String gameId) =>
      _profile.favoriteGameIds.contains(gameId);

  Future<void> toggleFavorite(String gameId) async {
    final current = _profile.favoriteGameIds;
    final updated = current.contains(gameId)
        ? current.where((id) => id != gameId).toList(growable: false)
        : [...current, gameId];
    _profile = _profile.copyWith(favoriteGameIds: updated);
    await _save();
  }

  Future<void> setAdsRemoved(bool removed) async {
    if (_profile.adsRemoved == removed) return;
    _profile = _profile.copyWith(adsRemoved: removed);
    await _save();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isYesterday(DateTime last, DateTime now) {
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _isSameDay(last, yesterday);
  }
}