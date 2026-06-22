import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/hub_game.dart';

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
  Widget buildGame(BuildContext context, GameSessionCallbacks callbacks) {
    return GameWidget(
      game: _MemoryFlameGame(callbacks: callbacks),
    );
  }
}

class _MemoryFlameGame extends FlameGame with TapCallbacks {
  _MemoryFlameGame({required this.callbacks});

  final GameSessionCallbacks callbacks;
  static const _symbols = ['🎮', '🎯', '🎲', '🎪'];
  static const _cols = 4;
  static const _rows = 2;

  final _random = Random();
  late DateTime _startedAt;
  bool _finished = false;

  int _pairsFound = 0;
  int _moves = 0;
  _MemoryCard? _firstPick;
  _MemoryCard? _secondPick;
  bool _lockInput = false;

  @override
  Color backgroundColor() => const Color(0xFF16213E);

  bool _gridBuilt = false;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
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
    final symbols = [..._symbols, ..._symbols]..shuffle(_random);
    const cardSize = 72.0;
    const gap = 12.0;
    final gridW = _cols * cardSize + (_cols - 1) * gap;
    final gridH = _rows * cardSize + (_rows - 1) * gap;
    final offsetX = (size.x - gridW) / 2;
    final offsetY = (size.y - gridH) / 2 + 20;

    for (var i = 0; i < symbols.length; i++) {
      final col = i % _cols;
      final row = i ~/ _cols;
      add(
        _MemoryCard(
          symbol: symbols[i],
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

  Future<void> _onCardTap(_MemoryCard card) async {
    if (_lockInput || _finished || card.isFaceUp || card.isMatched) return;

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
      callbacks.onScoreUpdate(_pairsFound * 100 - _moves * 5);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _resetPick();
      if (_pairsFound == _symbols.length) {
        _finish();
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 600));
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
    if (_finished) return;
    _finished = true;
    final score = (_pairsFound * 100 - _moves * 5).clamp(0, 9999);
    callbacks.onGameOver(
      GameResult(
        score: score,
        duration: DateTime.now().difference(_startedAt),
        coinsEarned: score ~/ 20,
        xpEarned: score ~/ 2,
      ),
    );
  }
}

class _MemoryCard extends PositionComponent with TapCallbacks {
  _MemoryCard({
    required this.symbol,
    required super.position,
    required super.size,
    required this.onTap,
  });

  final String symbol;
  final Future<void> Function(_MemoryCard) onTap;

  bool isFaceUp = false;
  bool isMatched = false;

  void reveal() => isFaceUp = true;
  void hide() => isFaceUp = false;
  void markMatched() {
    isMatched = true;
    isFaceUp = true;
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final bg = isMatched
        ? const Color(0xFF00B894)
        : isFaceUp
            ? const Color(0xFFdfe6e9)
            : const Color(0xFF6C5CE7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = bg,
    );

    if (isFaceUp) {
      final painter = TextPainter(
        text: TextSpan(text: symbol, style: const TextStyle(fontSize: 32)),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          (size.x - painter.width) / 2,
          (size.y - painter.height) / 2,
        ),
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    onTap(this);
  }
}
