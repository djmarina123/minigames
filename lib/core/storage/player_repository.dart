import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_profile.dart';

class PlayerRepository extends ChangeNotifier {
  PlayerRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'player_profile';

  PlayerProfile _profile = const PlayerProfile();
  PlayerProfile get profile => _profile;

  Future<void> load() async {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      _profile = PlayerProfile.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
    }
    notifyListeners();
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

  int get dailyRewardAmount {
    const base = 10;
    final bonus = (_profile.dailyStreak * 5).clamp(0, 50);
    return base + bonus;
  }

  Future<int?> claimDailyReward() async {
    if (!canClaimDaily) return null;

    final now = DateTime.now();
    final last = _profile.lastDailyClaim;
    final int newStreak;
    if (last != null && _isYesterday(last, now)) {
      newStreak = _profile.dailyStreak + 1;
    } else {
      newStreak = 1;
    }

    const base = 10;
    final bonus = ((newStreak - 1) * 5).clamp(0, 50);
    final reward = base + bonus;

    _profile = _profile.copyWith(
      coins: _profile.coins + reward,
      lastDailyClaim: now,
      dailyStreak: newStreak,
    );
    await _save();
    return reward;
  }

  Future<void> applyGameResult({
    required int coinsEarned,
    required int xpEarned,
  }) async {
    _profile = _profile.copyWith(
      coins: _profile.coins + coinsEarned,
      xp: _profile.xp + xpEarned,
      gamesPlayed: _profile.gamesPlayed + 1,
    );
    await _save();
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isYesterday(DateTime last, DateTime now) {
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    return _isSameDay(last, yesterday);
  }
}
