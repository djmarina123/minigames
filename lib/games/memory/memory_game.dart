import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';
import 'components/memory_card.dart';
import 'components/memory_fx.dart';
import 'memory_config.dart';
import 'memory_symbols.dart';

class MemoryGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'memory',
        title: 'Jogo da Memória',
        description: 'Encontre todos os pares de ícones.',
        category: 'Puzzle',
        icon: '🧠',
        featured: false,
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Toque em uma carta para virá-la. Toque em outra para tentar '
              'formar um par. Cartas iguais ficam abertas; diferentes voltam '
              'a fechar. Encontre todos os pares para vencer.',
          scoring:
              'Cada par vale 150 pts. Cada jogada (tentativa de par) tira 10 pts. '
              'Termine rápido para ganhar até 200 pts de bônus de tempo. '
              'Acertar todos os pares no mínimo de jogadas dá +100 pts extra.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Cartas',
            optionKey: MemoryConfig.optionKeyPairCount,
            choices: const [
              GamePrepChoice(label: '8', subtitle: '4 pares', value: 4),
              GamePrepChoice(label: '12', subtitle: '6 pares', value: 6),
              GamePrepChoice(label: '16', subtitle: '8 pares', value: 8),
            ],
          ),
        ],
      );

  @override
  Widget buildGame(
    BuildContext context,
    GameSessionCallbacks callbacks, {
    GameSessionConfig config = const GameSessionConfig(),
  }) {
    final pairCount = config.value(
      MemoryConfig.optionKeyPairCount,
      4,
    );
    return GameWidget(
      game: _MemoryFlameGame(
        callbacks: callbacks,
        pairCount: pairCount,
      ),
    );
  }
}

class _MemoryFlameGame extends FlameGame with TapCallbacks {
  _MemoryFlameGame({
    required this.callbacks,
    required this.pairCount,
  }) : _symbols = MemoryConfig.symbolPool.take(pairCount).toList();

  final GameSessionCallbacks callbacks;
  final int pairCount;
  final List<MemorySymbolId> _symbols;

  final _random = Random();
  late DateTime _startedAt;
  bool _finished = false;
  bool _sessionActive = true;

  int _pairsFound = 0;
  int _moves = 0;
  MemoryCard? _firstPick;
  MemoryCard? _secondPick;
  bool _lockInput = false;
  double _missFlash = 0;

  bool _gridBuilt = false;

  @override
  Color backgroundColor() => MemoryConfig.bgBottom;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
  }

  @override
  void onRemove() {
    _sessionActive = false;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_missFlash > 0) {
      _missFlash = (_missFlash - dt * 3).clamp(0.0, 1.0);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_gridBuilt && size.x > 0 && size.y > 0) {
      _gridBuilt = true;
      _buildGrid();
    }
  }

  void _buildGrid() {
    final deck = [..._symbols, ..._symbols]..shuffle(_random);
    final (cols, rows) = memoryGridForPairs(pairCount);
    const gap = 12.0;
    const minCard = 52.0;
    const gridPadding = 20.0;
    final gridW = size.x - gridPadding * 2;
    final gridH = size.y - gridPadding * 2;
    final cardW = (gridW - (cols - 1) * gap) / cols;
    final cardH = (gridH - (rows - 1) * gap) / rows;
    final cardSize = max(minCard, min(cardW, cardH));
    final totalW = cols * cardSize + (cols - 1) * gap;
    final totalH = rows * cardSize + (rows - 1) * gap;
    final offsetX = (size.x - totalW) / 2;
    final offsetY = (size.y - totalH) / 2;

    for (var i = 0; i < deck.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      add(
        MemoryCard(
          symbolId: deck[i],
          position: Vector2(
            offsetX + col * (cardSize + gap),
            offsetY + row * (cardSize + gap),
          ),
          size: Vector2.all(cardSize),
          onTap: _onCardTap,
        ),
      );
    }
  }

  Future<void> _onCardTap(MemoryCard card) async {
    if (!_sessionActive ||
        _lockInput ||
        _finished ||
        card.isFaceUp ||
        card.isMatched ||
        !card.isFlipSettled) {
      return;
    }

    card.reveal();

    if (_firstPick == null) {
      _firstPick = card;
      return;
    }

    if (_firstPick == card) return;

    _secondPick = card;
    _lockInput = true;
    _moves++;

    await _waitForFlip(_firstPick!, _secondPick!);
    if (!_sessionActive || _finished) return;

    if (_firstPick!.symbolId == _secondPick!.symbolId) {
      await _handleMatch();
    } else {
      await _handleMismatch();
    }
  }

  Future<void> _handleMatch() async {
    final a = _firstPick!;
    final b = _secondPick!;

    a.markMatched();
    b.markMatched();
    _pairsFound++;

    final mid = Vector2(
      (a.absoluteCenter.x + b.absoluteCenter.x) / 2,
      (a.absoluteCenter.y + b.absoluteCenter.y) / 2,
    );
    add(MemoryMatchBurst(position: mid.clone()));
    add(
      MemoryFloatingLabel(
        position: mid.clone()..y -= 24,
        text: '+${MemoryConfig.pointsPerPair}',
        color: MemoryConfig.matchGlow,
      ),
    );

    if (_sessionActive && !_finished) {
      callbacks.onScoreUpdate(
        memoryProgressScore(pairsFound: _pairsFound, moves: _moves),
      );
    }

    await Future<void>.delayed(
      Duration(milliseconds: (MemoryConfig.matchSettleSec * 1000).round()),
    );
    if (!_sessionActive || _finished) return;

    _resetPick();
    if (_pairsFound == pairCount) {
      _finish();
    }
  }

  Future<void> _handleMismatch() async {
    final a = _firstPick!;
    final b = _secondPick!;

    a.shake();
    b.shake();
    _missFlash = 1;

    add(
      MemoryFloatingLabel(
        position: Vector2(size.x / 2, size.y * 0.22),
        text: 'Tente de novo',
        color: MemoryConfig.missRed,
      ),
    );

    await Future<void>.delayed(
      Duration(milliseconds: (MemoryConfig.mismatchViewSec * 1000).round()),
    );
    if (!_sessionActive || _finished) return;

    a.hide();
    b.hide();
    await _waitForFlip(a, b);
    if (!_sessionActive || _finished) return;

    _resetPick();
  }

  Future<void> _waitForFlip(MemoryCard a, MemoryCard b) async {
    while (_sessionActive &&
        !_finished &&
        (!a.isFlipSettled || !b.isFlipSettled)) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  void _resetPick() {
    _firstPick = null;
    _secondPick = null;
    _lockInput = false;
  }

  void _finish() {
    if (_finished || !_sessionActive) return;
    _finished = true;
    final duration = DateTime.now().difference(_startedAt);
    final breakdown = memoryFinalScore(
      pairCount: pairCount,
      pairsFound: _pairsFound,
      moves: _moves,
      duration: duration,
    );
    callbacks.onGameOver(
      GameResult(
        score: breakdown.score,
        duration: duration,
        metadata: {
          'pairCount': pairCount,
          'moves': _moves,
          'timeBonus': breakdown.timeBonus,
          'perfectBonus': breakdown.perfectBonus,
          'performanceTier': memoryPerformanceTier(
            pairCount: pairCount,
            moves: _moves,
            perfectBonus: breakdown.perfectBonus,
          ).name,
        },
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    super.render(canvas);
    if (_missFlash > 0) {
      canvas.drawRect(
        Offset.zero & Size(size.x, size.y),
        Paint()
          ..color = MemoryConfig.missRed.withValues(alpha: _missFlash * 0.12),
      );
    }
  }

  void _paintBackground(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MemoryConfig.bgTop, MemoryConfig.bgBottom],
        ).createShader(rect),
    );

    final bubblePaint = Paint()
      ..color = MemoryConfig.blendColor.withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.x * 0.12, size.y * 0.18),
      size.x * 0.22,
      bubblePaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.88, size.y * 0.72),
      size.x * 0.28,
      bubblePaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.75, size.y * 0.12),
      size.x * 0.1,
      Paint()..color = MemoryConfig.accentSoft.withValues(alpha: 0.1),
    );
  }
}
