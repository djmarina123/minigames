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
import 'components/snake_fx.dart';
import '../../core/l10n/l10n_scope.dart';
import 'snake_config.dart';

class SnakeGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'snake',
        title: 'Cobra',
        description: 'Deslize para guiar a cobra — não bata nas paredes!',
        category: 'Arcade',
        icon: '🐍',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Deslize na tela para mudar a direção da cobra. Coma as frutas '
              'douradas para crescer e ganhar pontos. Evite bater nas paredes '
              'ou no próprio corpo — isso encerra a partida. Vence quem '
              'preencher todo o tabuleiro. A velocidade aumenta com o tempo.',
          scoring:
              'Cada fruta vale 20 pts (+5 a cada 5 frutas comidas). O tempo '
              'só aumenta a velocidade da cobra — não soma pontos. Pontos não '
              'definem vitória; só encher o tabuleiro vence.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Velocidade',
            optionKey: SnakeConfig.optionKeySpeedMode,
            choices: const [
              GamePrepChoice(label: 'Normal', value: 0),
              GamePrepChoice(label: 'Rápida', value: 1),
              GamePrepChoice(label: 'Insana', value: 2),
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
    final speedMode = config.value(SnakeConfig.optionKeySpeedMode, 0);
    return GameWidget(
      game: SnakeFlameGame(
        callbacks: callbacks,
        speedModeIndex: speedMode,
      ),
    );
  }
}

enum _Phase { countdown, playing, finished }

class SnakeFlameGame extends FlameGame with DragCallbacks, KeyboardEvents {
  SnakeFlameGame({
    required this.callbacks,
    required this.speedModeIndex,
  });

  final GameSessionCallbacks callbacks;
  final int speedModeIndex;

  _Phase _phase = _Phase.countdown;
  double _countdownLeft = SnakeConfig.countdownSec.toDouble();
  double _elapsed = 0;
  late DateTime _startedAt;

  bool _sessionStarted = false;
  bool _sessionActive = true;

  List<(int col, int row)> _segments = snakeInitialSegments();
  SnakeDirection _direction = SnakeDirection.right;
  SnakeDirection _queuedDirection = SnakeDirection.right;
  (int col, int row)? _food;

  int _foodEaten = 0;
  int _score = 0;
  int _lastReportedScore = -1;

  double _moveTimer = 0;
  double _crashFlash = 0;
  double _foodPulse = 0;

  SnakeBoardLayout? _layout;
  final _random = Random();

  double get _modeMultiplier => snakeSpeedModeMultiplier(speedModeIndex);

  int get _snakeLength => _segments.length;

  @override
  Color backgroundColor() => SnakeConfig.bgTop;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
    _spawnFood();
    callbacks.onScoreUpdate(0);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0) return;
    _layout = snakeBoardLayout(screenW: size.x, screenH: size.y);
    if (!_sessionStarted) _sessionStarted = true;
  }

  void _spawnFood() {
    _food = snakeSpawnFood(_segments, (max) => _random.nextInt(max));
  }

  void _reportScore() {
    final next = snakeProgressScore(foodEaten: _foodEaten);
    if (next != _lastReportedScore) {
      _lastReportedScore = next;
      _score = next;
      if (_sessionActive) callbacks.onScoreUpdate(_score);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_sessionStarted || _phase == _Phase.finished) return;

    _foodPulse += dt * 4;

    if (_crashFlash > 0) {
      _crashFlash = (_crashFlash - dt).clamp(0.0, 1.0);
    }

    switch (_phase) {
      case _Phase.countdown:
        _countdownLeft -= dt;
        if (_countdownLeft <= 0) {
          _phase = _Phase.playing;
          _startedAt = DateTime.now();
          _moveTimer = snakeTickInterval(0, modeMultiplier: _modeMultiplier);
        }
      case _Phase.playing:
        _elapsed += dt;
        _moveTimer -= dt;
        final tick = snakeTickInterval(_elapsed, modeMultiplier: _modeMultiplier);
        while (_moveTimer <= 0 && _phase == _Phase.playing) {
          _moveTimer += tick;
          _stepSnake();
        }
        _reportScore();
      case _Phase.finished:
        break;
    }
  }

  void _queueDirection(SnakeDirection next) {
    if (_phase != _Phase.playing) return;
    if (snakeOpposite(_queuedDirection) == next) return;
    _queuedDirection = next;
  }

  void _stepSnake() {
    _direction = _queuedDirection;
    final head = _segments.first;
    final (nextCol, nextRow) =
        snakeNextHead(head.$1, head.$2, _direction);

    if (snakeHitsWall(nextCol, nextRow)) {
      _crash(at: _layout?.cellRect(head.$1, head.$2).center ?? Offset.zero);
      return;
    }

    final bodyWithoutTail = _segments.sublist(0, _segments.length - 1);
    if (bodyWithoutTail.any((s) => s.$1 == nextCol && s.$2 == nextRow)) {
      _crash(at: _layout?.cellRect(nextCol, nextRow).center ?? Offset.zero);
      return;
    }

    final ate = _food != null && _food!.$1 == nextCol && _food!.$2 == nextRow;
    _segments = [(nextCol, nextRow), ..._segments];
    if (!ate) {
      _segments.removeLast();
    } else {
      _foodEaten++;
      final pts = snakePointsForFood(_foodEaten - 1);
      final cell = _layout?.cellRect(nextCol, nextRow);
      if (cell != null) {
        add(
          SnakeEatBurst(
            position: Vector2(cell.center.dx, cell.center.dy),
            color: SnakeConfig.foodCore,
          ),
        );
        add(
          SnakeFloatingLabel(
            position: Vector2(cell.center.dx, cell.center.dy - 8),
            text: '+$pts',
            color: SnakeConfig.eatGold,
          ),
        );
      }
      _spawnFood();
      if (_food == null) {
        _finish(won: true);
        return;
      }
    }
  }

  void _crash({required Offset at}) {
    if (_phase != _Phase.playing) return;
    _phase = _Phase.finished;
    _crashFlash = 1;
    add(
      SnakeFloatingLabel(
        position: Vector2(at.dx, at.dy),
        text: L10nScope.of.gameSnakeCrashed,
        color: SnakeConfig.crashRed,
      ),
    );
    _finish(won: false);
  }

  void _finish({required bool won}) {
    if (!_sessionActive) return;
    _sessionActive = false;
    _reportScore();
    callbacks.onGameOver(
      GameResult(
        score: _score,
        duration: DateTime.now().difference(_startedAt),
        metadata: {
          'foodEaten': _foodEaten,
          'snakeLength': _snakeLength,
          'speedLevel': snakeSpeedLevel(_elapsed),
          'won': won,
          'performanceTier': snakePerformanceTier(
            won: won,
            snakeLength: _snakeLength,
          ).name,
        },
      ),
    );
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragStart = event.localPosition.clone();
    _dragDelta = Vector2.zero();
  }

  Vector2? _dragStart;
  Vector2 _dragDelta = Vector2.zero();

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dragStart == null) return;
    _dragDelta += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (_dragStart == null) return;
    final dir = snakeDirectionFromDelta(_dragDelta.x, _dragDelta.y);
    _dragStart = null;
    _dragDelta = Vector2.zero();
    if (dir != null) _queueDirection(dir);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_phase != _Phase.playing || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final dir = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowUp => SnakeDirection.up,
      LogicalKeyboardKey.arrowDown => SnakeDirection.down,
      LogicalKeyboardKey.arrowLeft => SnakeDirection.left,
      LogicalKeyboardKey.arrowRight => SnakeDirection.right,
      _ => null,
    };
    if (dir != null) {
      _queueDirection(dir);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    if (_layout != null) {
      _paintBoard(canvas, _layout!);
      _paintFood(canvas, _layout!);
      _paintSnake(canvas, _layout!);
    }
    super.render(canvas);
    if (_crashFlash > 0) {
      canvas.drawRect(
        Offset.zero & Size(size.x, size.y),
        Paint()
          ..color = SnakeConfig.crashRed.withValues(alpha: _crashFlash * 0.22),
      );
    }
    _paintHud(canvas);
  }

  void _paintBackground(Canvas canvas) {
    final rect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SnakeConfig.bgTop, SnakeConfig.bgBottom],
        ).createShader(rect),
    );

    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (var i = 0; i < 5; i++) {
      final x = size.x * (0.12 + i * 0.19);
      final y = size.y * (0.18 + (i % 3) * 0.22);
      canvas.drawCircle(Offset(x, y), 18 + i * 4.0, bubblePaint);
    }
  }

  void _paintBoard(Canvas canvas, SnakeBoardLayout layout) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.boardRect,
        Radius.circular(layout.cellSize * 0.12),
      ),
      Paint()..color = SnakeConfig.boardFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.boardRect,
        Radius.circular(layout.cellSize * 0.12),
      ),
      Paint()
        ..color = SnakeConfig.boardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final linePaint = Paint()..color = SnakeConfig.gridLine;
    for (var c = 1; c < SnakeConfig.gridCols; c++) {
      final x = layout.origin.dx + c * layout.cellSize;
      canvas.drawLine(
        Offset(x, layout.boardRect.top),
        Offset(x, layout.boardRect.bottom),
        linePaint,
      );
    }
    for (var r = 1; r < SnakeConfig.gridRows; r++) {
      final y = layout.origin.dy + r * layout.cellSize;
      canvas.drawLine(
        Offset(layout.boardRect.left, y),
        Offset(layout.boardRect.right, y),
        linePaint,
      );
    }
  }

  void _paintSnake(Canvas canvas, SnakeBoardLayout layout) {
    for (var i = _segments.length - 1; i >= 0; i--) {
      final (col, row) = _segments[i];
      final cell = layout.cellRect(col, row);
      final pad = layout.cellSize * 0.08;
      final inner = cell.deflate(pad);
      final isHead = i == 0;
      final t = i / (_segments.length - 1).clamp(1, 999);
      final color = Color.lerp(SnakeConfig.snakeHead, SnakeConfig.snakeTail, t)!;

      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, Radius.circular(layout.cellSize * 0.22)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, Radius.circular(layout.cellSize * 0.22)),
        Paint()..color = isHead ? SnakeConfig.snakeHead : color,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(inner, Radius.circular(layout.cellSize * 0.22)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      if (isHead) _paintHeadEyes(canvas, inner);
    }
  }

  void _paintHeadEyes(Canvas canvas, Rect head) {
    final eyeR = head.width * 0.1;
    final offset = head.width * 0.18;
    Offset eyeCenter(double dx, double dy) =>
        Offset(head.center.dx + dx, head.center.dy + dy);

    final (dx, dy) = switch (_direction) {
      SnakeDirection.up => (0.0, -offset),
      SnakeDirection.down => (0.0, offset),
      SnakeDirection.left => (-offset, 0.0),
      SnakeDirection.right => (offset, 0.0),
    };

    for (final side in [-1.0, 1.0]) {
      final perp = _direction == SnakeDirection.up ||
              _direction == SnakeDirection.down
          ? Offset(side * offset * 0.55, 0)
          : Offset(0, side * offset * 0.55);
      final center = eyeCenter(dx, dy) + perp;
      canvas.drawCircle(center, eyeR, Paint()..color = Colors.white);
      canvas.drawCircle(
        center + Offset(dx.sign * eyeR * 0.25, dy.sign * eyeR * 0.25),
        eyeR * 0.55,
        Paint()..color = SnakeConfig.snakeEye,
      );
    }
  }

  void _paintFood(Canvas canvas, SnakeBoardLayout layout) {
    final food = _food;
    if (food == null) return;

    final cell = layout.cellRect(food.$1, food.$2);
    final pulse = 0.88 + sin(_foodPulse) * 0.08;
    final r = cell.width * 0.28 * pulse;
    final center = cell.center;

    canvas.drawCircle(
      center,
      r + 4,
      Paint()..color = SnakeConfig.foodGlow.withValues(alpha: 0.35),
    );
    canvas.drawCircle(center, r, Paint()..color = SnakeConfig.foodCore);
    canvas.drawCircle(
      center + Offset(-r * 0.2, -r * 0.35),
      r * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(r * 0.15, -r * 0.75),
        width: r * 0.9,
        height: r * 0.55,
      ),
      Paint()..color = SnakeConfig.foodLeaf,
    );
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.countdown) {
      GameSessionHud.paintText(
        canvas,
        _countdownLeft.ceil().clamp(1, SnakeConfig.countdownSec).toString(),
        Offset(size.x / 2, size.y / 2),
        72,
        SnakeConfig.hudText,
        align: GameSessionHudAlign.center,
      );
      GameSessionHud.paintText(
        canvas,
        L10nScope.of.gameSwipeToPlay,
        Offset(size.x / 2, size.y / 2 + 50),
        16,
        SnakeConfig.hudMuted.withValues(alpha: 0.9),
        align: GameSessionHudAlign.center,
      );
      return;
    }

    if (_phase == _Phase.finished) return;

    final palette = GameSessionHudPalette(
      text: SnakeConfig.hudText,
      muted: SnakeConfig.hudMuted,
      accent: SnakeConfig.accentColor,
      panel: SnakeConfig.hudPanel,
    );

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      palette,
      columns: [
        GameSessionHudStat(
          caption: L10nScope.of.hudSize,
          value: '$_snakeLength',
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudFruits,
          value: '$_foodEaten',
          footnote: L10nScope.of.hudNextPoints(snakeNextFoodPoints(_foodEaten)),
          footnoteColor: SnakeConfig.eatGold,
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudSpeed,
          value: 'Nv. ${snakeSpeedLevel(_elapsed)}',
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudTime,
          value: snakeHudElapsedLabel(Duration(seconds: _elapsed.floor())),
        ),
      ],
      progress: GameSessionHudProgress(
        ratio: 1 - snakeProgress(_elapsed),
        color: SnakeConfig.speedBar,
        lowColor: SnakeConfig.speedBarLow,
        lowThreshold: 0.35,
      ),
    );
  }
}
