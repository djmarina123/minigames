import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_session_hud.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';
import 'components/game_2048_fx.dart';
import 'game_2048_config.dart';

class Game2048Game implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'game_2048',
        title: '2048',
        description: 'Deslize e combine peças até criar a peça-alvo!',
        category: 'Puzzle',
        icon: '🔢',
        featured: true,
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Deslize para cima, baixo, esquerda ou direita para mover todas '
              'as peças. Duas peças iguais na mesma linha ou coluna se fundem '
              'em uma só com o dobro do valor. A partida termina quando não '
              'houver mais movimentos possíveis.',
          scoring:
              'Cada fusão soma o valor da peça criada ao placar. Peças altas '
              'dão bônus no final: a partir de 64, cada nível extra vale até '
              '+300 pts de bônus.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Objetivo',
            optionKey: Game2048Config.optionKeyTargetTile,
            choices: const [
              GamePrepChoice(label: '1024', subtitle: 'peça-alvo', value: 1024),
              GamePrepChoice(label: '2048', subtitle: 'peça-alvo', value: 2048),
              GamePrepChoice(label: '4096', subtitle: 'peça-alvo', value: 4096),
            ],
            defaultIndex: 1,
          ),
        ],
      );

  @override
  Widget buildGame(
    BuildContext context,
    GameSessionCallbacks callbacks, {
    GameSessionConfig config = const GameSessionConfig(),
  }) {
    final targetTile = config.value(
      Game2048Config.optionKeyTargetTile,
      Game2048Config.defaultTargetTile,
    );
    return GameWidget(
      game: Game2048FlameGame(
        callbacks: callbacks,
        targetTile: targetTile,
      ),
    );
  }
}

enum _Phase { playing, finished }

class Game2048FlameGame extends FlameGame with DragCallbacks, KeyboardEvents {
  Game2048FlameGame({
    required this.callbacks,
    required this.targetTile,
  }) : _grid = game2048NewGrid(Random()) {
    _highestTile = game2048HighestTile(_grid);
  }

  final GameSessionCallbacks callbacks;
  final int targetTile;

  final _random = Random();
  late DateTime _startedAt;

  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;
  bool _inputLocked = false;

  List<List<int>> _grid;
  int _mergeScore = 0;
  int _moves = 0;
  int _highestTile = 0;
  int _mergeCount = 0;
  bool _targetReached = false;

  bool _isSliding = false;
  double _slideProgress = 0;
  List<Game2048TileMotion> _slideMotions = const [];
  Game2048MoveResult? _pendingMove;

  double _invalidFlash = 0;
  final Set<String> _mergePulseKeys = {};
  double _mergePulseT = 0;
  final Set<String> _spawnKeys = {};
  double _spawnT = 0;

  Vector2? _dragStart;
  Vector2 _dragDelta = Vector2.zero();

  static const _hudHeight = GameSessionHud.reservedHeight;

  @override
  Color backgroundColor() => Game2048Config.bgBottom;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
    callbacks.onScoreUpdate(0);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_sessionStarted || size.x <= 0) return;
    _sessionStarted = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_sessionStarted || _phase == _Phase.finished) return;

    if (_isSliding) {
      _slideProgress += dt / Game2048Config.slideAnimSec;
      if (_slideProgress >= 1) {
        _slideProgress = 1;
        _completeSlide();
      }
    }

    if (_invalidFlash > 0) {
      _invalidFlash =
          (_invalidFlash - dt / Game2048Config.invalidFlashSec).clamp(0.0, 1.0);
    }

    if (_mergePulseKeys.isNotEmpty) {
      _mergePulseT += dt;
      if (_mergePulseT >= Game2048Config.mergePulseSec) {
        _mergePulseKeys.clear();
        _mergePulseT = 0;
      }
    }

    if (_spawnKeys.isNotEmpty) {
      _spawnT += dt;
      if (_spawnT >= Game2048Config.spawnScaleSec) {
        _spawnKeys.clear();
        _spawnT = 0;
        _inputLocked = false;
      }
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_phase != _Phase.playing || _inputLocked) return;
    _dragStart = event.localPosition.clone();
    _dragDelta = Vector2.zero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStart == null) return;
    _dragDelta += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_phase != _Phase.playing || _inputLocked || _dragStart == null) return;
    final dir = game2048DirectionFromDelta(_dragDelta.x, _dragDelta.y);
    _dragStart = null;
    _dragDelta = Vector2.zero();
    if (dir != null) _tryMove(dir);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_phase != _Phase.playing || _inputLocked || _isSliding) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final dir = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => Game2048Direction.left,
      LogicalKeyboardKey.arrowRight => Game2048Direction.right,
      LogicalKeyboardKey.arrowUp => Game2048Direction.up,
      LogicalKeyboardKey.arrowDown => Game2048Direction.down,
      _ => null,
    };
    if (dir == null) return KeyEventResult.ignored;
    _tryMove(dir);
    return KeyEventResult.handled;
  }

  void _tryMove(Game2048Direction direction) {
    if (_phase != _Phase.playing || _inputLocked || _isSliding) return;

    final snapshot = game2048CopyGrid(_grid);
    final result = game2048Move(snapshot, direction);
    if (!result.changed) {
      _invalidFlash = 1;
      return;
    }

    _inputLocked = true;
    _pendingMove = result;
    _slideMotions = game2048ComputeMotions(snapshot, direction);
    _slideProgress = 0;
    _isSliding = true;
  }

  void _completeSlide() {
    final result = _pendingMove;
    if (result == null || !_sessionActive) return;

    _isSliding = false;
    _slideMotions = const [];
    _pendingMove = null;
    _grid = game2048CopyGrid(result.grid);

    _mergeScore += result.scoreGained;
    _moves++;
    _mergeCount += result.merges.length;

    for (final merge in result.merges) {
      _mergePulseKeys.add('${merge.row}_${merge.col}');
      _mergePulseT = 0;
      final cellCenter = _cellCenter(merge.row, merge.col);
      add(Game2048MergeBurst(position: cellCenter));
      add(
        Game2048FloatingLabel(
          position: cellCenter.clone()..y -= 8,
          text: '+${merge.points}',
          color: Game2048Config.mergeGlow,
        ),
      );
    }

    final highest = game2048HighestTile(_grid);
    if (highest > _highestTile) _highestTile = highest;
    if (!_targetReached && game2048ReachedTarget(_grid, targetTile)) {
      _targetReached = true;
      add(
        Game2048FloatingLabel(
          position: Vector2(size.x / 2, size.y * 0.28),
          text: 'Peça $targetTile!',
          color: Game2048Config.accentColor,
        ),
      );
    }

    callbacks.onScoreUpdate(game2048ProgressScore(_mergeScore));

    final beforeSpawn = game2048CopyGrid(_grid);
    game2048SpawnRandom(_grid, _random);
    var spawned = false;
    for (var r = 0; r < Game2048Config.gridSize; r++) {
      for (var c = 0; c < Game2048Config.gridSize; c++) {
        if (beforeSpawn[r][c] == 0 && _grid[r][c] > 0) {
          _spawnKeys.add('${r}_$c');
          spawned = true;
        }
      }
    }
    if (spawned) {
      _spawnT = 0;
      _inputLocked = true;
    } else {
      _inputLocked = false;
    }

    if (!game2048CanMove(_grid)) {
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (_sessionActive) _finish();
      });
    }
  }

  void _finish() {
    if (_phase == _Phase.finished || !_sessionActive) return;
    _phase = _Phase.finished;
    final score = game2048FinalScore(
      mergeScore: _mergeScore,
      highestTile: _highestTile,
    );
    callbacks.onGameOver(
      GameResult(
        score: score,
        duration: DateTime.now().difference(_startedAt),
        metadata: {
          'moves': _moves,
          'highestTile': _highestTile,
          'mergeCount': _mergeCount,
          'tileBonus': game2048TileBonus(_highestTile),
          'targetTile': targetTile,
          'targetReached': _targetReached,
          'performanceTier': game2048PerformanceTier(_highestTile).name,
        },
      ),
    );
  }

  @override
  void onRemove() {
    _sessionActive = false;
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    super.render(canvas);
    if (_sessionStarted) {
      _paintBoard(canvas);
      _paintHud(canvas);
    }
  }

  void _paintBackground(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Game2048Config.bgTop, Game2048Config.bgBottom],
        ).createShader(rect),
    );
    if (!_sessionStarted) return;
    final bubbles = [
      (0.12, 0.22, 0.18),
      (0.88, 0.35, 0.14),
      (0.75, 0.78, 0.22),
    ];
    for (final (fx, fy, fr) in bubbles) {
      canvas.drawCircle(
        Offset(size.x * fx, size.y * fy),
        size.x * fr,
        Paint()..color = Colors.white.withValues(alpha: 0.07),
      );
    }
  }

  ({double originX, double originY, double cell, double gap, double boardSize})
      _boardLayout() {
    const margin = 16.0;
    const gap = 8.0;
    final top = _hudHeight + 12;
    final availW = size.x - margin * 2;
    final availH = size.y - top - margin;
    final boardSize = min(availW, availH);
    final cell = (boardSize - gap * (Game2048Config.gridSize + 1)) /
        Game2048Config.gridSize;
    final originX = (size.x - boardSize) / 2;
    final originY = top + (availH - boardSize) / 2;
    return (
      originX: originX,
      originY: originY,
      cell: cell,
      gap: gap,
      boardSize: boardSize,
    );
  }

  Vector2 _cellCenter(int row, int col) {
    final layout = _boardLayout();
    final x = layout.originX +
        layout.gap +
        col * (layout.cell + layout.gap) +
        layout.cell / 2;
    final y = layout.originY +
        layout.gap +
        row * (layout.cell + layout.gap) +
        layout.cell / 2;
    return Vector2(x, y);
  }

  void _paintBoard(Canvas canvas) {
    final layout = _boardLayout();

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        layout.originX,
        layout.originY,
        layout.boardSize,
        layout.boardSize,
      ),
      Radius.circular(layout.cell * 0.18),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      boardRect,
      Paint()..color = Game2048Config.boardBg,
    );

    if (_invalidFlash > 0) {
      canvas.drawRRect(
        boardRect,
        Paint()
          ..color = Game2048Config.missRed
              .withValues(alpha: 0.14 * _invalidFlash),
      );
    }

    _paintEmptyGrid(canvas, layout);

    if (_isSliding) {
      _paintSlidingTiles(canvas, layout);
    } else {
      _paintStaticTiles(canvas, layout);
    }
  }

  void _paintEmptyGrid(
    Canvas canvas,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
  ) {
    for (var r = 0; r < Game2048Config.gridSize; r++) {
      for (var c = 0; c < Game2048Config.gridSize; c++) {
        final x = layout.originX + layout.gap + c * (layout.cell + layout.gap);
        final y = layout.originY + layout.gap + r * (layout.cell + layout.gap);
        _paintEmptyCell(canvas, x, y, layout.cell);
      }
    }
  }

  void _paintSlidingTiles(
    Canvas canvas,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
  ) {
    final t = game2048SlideEase(_slideProgress);
    final stride = layout.cell + layout.gap;

    for (final motion in _slideMotions) {
      final fromX = layout.originX + layout.gap + motion.fromCol * stride;
      final fromY = layout.originY + layout.gap + motion.fromRow * stride;
      final toX = layout.originX + layout.gap + motion.toCol * stride;
      final toY = layout.originY + layout.gap + motion.toRow * stride;
      final x = fromX + (toX - fromX) * t;
      final y = fromY + (toY - fromY) * t;

      var alpha = 1.0;
      if (!motion.isSurvivor) {
        alpha = (1 - t * 1.4).clamp(0.0, 1.0);
        if (alpha <= 0) continue;
      }

      final value = motion.isSurvivor && motion.mergedValue != null && t > 0.92
          ? motion.mergedValue!
          : motion.slideValue;

      var scale = 1.0;
      if (motion.isSurvivor && motion.mergedValue != null && t > 0.92) {
        final pop = ((t - 0.92) / 0.08).clamp(0.0, 1.0);
        scale = 1.0 + sin(pop * pi) * 0.08;
      }

      _paintTile(
        canvas,
        x,
        y,
        layout.cell,
        value,
        scale,
        alpha: alpha,
      );
    }
  }

  void _paintStaticTiles(
    Canvas canvas,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
  ) {
    final stride = layout.cell + layout.gap;

    for (var r = 0; r < Game2048Config.gridSize; r++) {
      for (var c = 0; c < Game2048Config.gridSize; c++) {
        final value = _grid[r][c];
        if (value == 0) continue;

        final x = layout.originX + layout.gap + c * stride;
        final y = layout.originY + layout.gap + r * stride;
        final key = '${r}_$c';

        var scale = 1.0;
        if (_mergePulseKeys.contains(key)) {
          final pt =
              (_mergePulseT / Game2048Config.mergePulseSec).clamp(0.0, 1.0);
          scale = 1.0 + sin(pt * pi) * 0.1;
        } else if (_spawnKeys.contains(key)) {
          final pt = (_spawnT / Game2048Config.spawnScaleSec).clamp(0.0, 1.0);
          scale = game2048SlideEase(pt);
        }

        _paintTile(canvas, x, y, layout.cell, value, scale);
      }
    }
  }

  void _paintEmptyCell(Canvas canvas, double x, double y, double cellSize) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cellSize, cellSize),
      Radius.circular(cellSize * 0.12),
    );
    canvas.drawRRect(rect, Paint()..color = Game2048Config.cellEmpty);
  }

  void _paintTile(
    Canvas canvas,
    double x,
    double y,
    double cellSize,
    int value,
    double scale, {
    double alpha = 1.0,
  }) {
    final center = Offset(x + cellSize / 2, y + cellSize / 2);
    final side = cellSize * scale;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: side, height: side),
      Radius.circular(cellSize * 0.12),
    );

    final (bg, fg) = game2048TileColors(value);
    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.12 * alpha),
    );
    canvas.drawRRect(rect, Paint()..color = bg.withValues(alpha: alpha));
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final fontSize = game2048TileFontSize(value, cellSize) * scale;
    final painter = TextPainter(
      text: TextSpan(
        text: '$value',
        style: TextStyle(
          color: fg.withValues(alpha: alpha),
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy - painter.height / 2,
      ),
    );
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.finished) return;

    final bonusPreview = game2048TileBonus(_highestTile);
    final footnote = game2048HudRightFootnote(
      moves: _moves,
      bonusPreview: bonusPreview,
    );

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      const GameSessionHudPalette(
        text: Game2048Config.hudText,
        muted: Game2048Config.hudMuted,
        accent: Game2048Config.accentSoft,
      ),
      columns: [
        GameSessionHudStat(
          caption: 'Jogadas',
          value: '$_moves',
        ),
        GameSessionHudStat(
          caption: 'Objetivo',
          value: '$targetTile',
          valueColor: Game2048Config.accentColor,
        ),
        GameSessionHudStat(
          caption: 'Máx.',
          value: '$_highestTile',
          footnote: footnote,
          footnoteColor: bonusPreview > 0
              ? Game2048Config.mergeGlow
              : Game2048Config.hudMuted.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}
