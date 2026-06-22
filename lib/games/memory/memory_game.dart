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
import 'memory_config.dart';

class MemoryGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'memory',
        title: 'Jogo da Memória',
        description: 'Encontre todos os pares de emoji.',
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
  final List<String> _symbols;

  final _random = Random();
  late DateTime _startedAt;
  bool _finished = false;
  bool _sessionActive = true;

  int _pairsFound = 0;
  int _moves = 0;
  MemoryCard? _firstPick;
  MemoryCard? _secondPick;
  bool _lockInput = false;

  @override
  Color backgroundColor() => const Color(0xFF16213E);

  bool _gridBuilt = false;

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
    const gap = 10.0;
    const maxCard = 72.0;
    final gridW = size.x - 32;
    final gridH = size.y - 80;
    final cardW = min(maxCard, (gridW - (cols - 1) * gap) / cols);
    final cardH = min(maxCard, (gridH - (rows - 1) * gap) / rows);
    final cardSize = min(cardW, cardH);
    final totalW = cols * cardSize + (cols - 1) * gap;
    final totalH = rows * cardSize + (rows - 1) * gap;
    final offsetX = (size.x - totalW) / 2;
    final offsetY = (size.y - totalH) / 2 + 16;

    for (var i = 0; i < deck.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      add(
        MemoryCard(
          symbol: deck[i],
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
    if (!_sessionActive || _lockInput || _finished || card.isFaceUp || card.isMatched) {
      return;
    }

    card.reveal();

    if (_firstPick == null) {
      _firstPick = card;
      return;
    }

    _secondPick = card;
    _lockInput = true;
    _moves++;

    if (_firstPick!.symbol == _secondPick!.symbol) {
      _firstPick!.markMatched();
      _secondPick!.markMatched();
      _pairsFound++;
      if (_sessionActive && !_finished) {
        callbacks.onScoreUpdate(
          memoryProgressScore(pairsFound: _pairsFound, moves: _moves),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!_sessionActive || _finished) return;
      _resetPick();
      if (_pairsFound == pairCount) {
        _finish();
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!_sessionActive || _finished) return;
      _firstPick?.hide();
      _secondPick?.hide();
      _resetPick();
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
        coinsEarned: breakdown.score ~/ 15,
        xpEarned: breakdown.score ~/ 2,
        metadata: {
          'pairCount': pairCount,
          'moves': _moves,
          'timeBonus': breakdown.timeBonus,
          'perfectBonus': breakdown.perfectBonus,
        },
      ),
    );
  }
}
