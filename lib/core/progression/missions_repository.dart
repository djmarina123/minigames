import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/player_repository.dart';
import 'mission_models.dart';
import 'missions_catalog.dart';
import 'progression_models.dart';

/// Progresso e resgate de missões diárias.
class MissionsRepository extends ChangeNotifier {
  MissionsRepository(this._prefs, this._playerRepo);

  final SharedPreferences _prefs;
  final PlayerRepository _playerRepo;

  static const _stateKey = 'daily_missions_state';

  DateTime? _day;
  final Map<String, int> _progress = {};
  final Set<String> _claimed = {};

  Future<void> load() async {
    _day = null;
    _progress.clear();
    _claimed.clear();

    final raw = _prefs.getString(_stateKey);
    if (raw == null) {
      notifyListeners();
      return;
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final dayStr = json['day'] as String?;
      final day = dayStr != null ? DateTime.tryParse(dayStr) : null;
      if (day != null && _isSameDay(day, DateTime.now())) {
        _day = day;
        final progress = json['progress'];
        if (progress is Map) {
          for (final entry in progress.entries) {
            _progress[entry.key.toString()] = (entry.value as num).round();
          }
        }
        final claimed = json['claimed'];
        if (claimed is List) {
          _claimed.addAll(claimed.whereType<String>());
        }
      }
    } catch (e, st) {
      debugPrint('MissionsRepository.load: $e');
      debugPrint('$st');
    }

    notifyListeners();
  }

  List<MissionProgress> get todayMissions {
    _ensureToday();
    return MissionsCatalog.daily
        .map(
          (def) => MissionProgress(
            definition: def,
            current: _progress[def.id] ?? 0,
            claimed: _claimed.contains(def.id),
          ),
        )
        .toList(growable: false);
  }

  bool get hasClaimable =>
      todayMissions.any((mission) => mission.canClaim);

  Future<void> onSession(SessionEvent event) async {
    _ensureToday();
    var changed = false;

    for (final def in MissionsCatalog.daily) {
      if (_claimed.contains(def.id)) continue;

      final before = _progress[def.id] ?? 0;
      final after = switch (def.kind) {
        MissionKind.gamesPlayedToday => before + 1,
        MissionKind.scoreToday => before + event.score,
        MissionKind.goldToday =>
          before + (event.tierName == 'gold' ? 1 : 0),
      };

      if (after != before) {
        _progress[def.id] = after;
        changed = true;
      }
    }

    if (changed) {
      await _save();
      notifyListeners();
    }
  }

  Future<int?> claimMission(String missionId) async {
    _ensureToday();
    final def = MissionsCatalog.daily
        .where((item) => item.id == missionId)
        .firstOrNull;
    if (def == null) return null;

    final current = _progress[def.id] ?? 0;
    if (current < def.target || _claimed.contains(def.id)) return null;

    _claimed.add(def.id);
    await _playerRepo.addBonusCoins(def.coinReward);
    await _save();
    notifyListeners();
    return def.coinReward;
  }

  void _ensureToday() {
    final now = DateTime.now();
    if (_day != null && _isSameDay(_day!, now)) return;
    _day = DateTime(now.year, now.month, now.day);
    _progress.clear();
    _claimed.clear();
  }

  Future<void> _save() async {
    final now = DateTime.now();
    _day ??= DateTime(now.year, now.month, now.day);
    await _prefs.setString(
      _stateKey,
      jsonEncode({
        'day': _day!.toIso8601String(),
        'progress': _progress,
        'claimed': _claimed.toList(),
      }),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
