import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/economy/economy_config.dart';
import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_session_hud.dart';
import '../../core/game_sdk/game_session_hud_actions.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/hub_game.dart';
import '../../core/l10n/l10n_scope.dart';
import 'components/minesweeper_fx.dart';
import 'minesweeper_config.dart';

class MinesweeperGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'minesweeper',
        title: 'Campo Minado',
        description: 'Revele células seguras e marque todas as minas.',
        category: 'Puzzle',
        icon: '💣',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: GameHelpContent(
          howToPlay:
              'Toque para revelar uma célula. O número indica minas vizinhas. '
              'Use BANDEIRA para marcar suspeitas ou segure para alternar bandeira. '
              'DICA custa ${EconomyConfig.hintCoinCostMinesweeper} moedas e revela uma célula segura. '
              'A primeira jogada nunca acerta mina. Vença revelando todas as células seguras.',
          scoring:
              'Cada célula revelada vale +8 pts. Complete o tabuleiro para +400 pts, '
              'bônus de tempo (até 250 pts) e +80 pts sem dicas pagas.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Dificuldade',
            optionKey: MinesweeperConfig.optionKeyDifficulty,
            choices: const [
              GamePrepChoice(label: 'Fácil', subtitle: '10 minas', value: 'easy'),
              GamePrepChoice(
                label: 'Médio',
                subtitle: '20 minas',
                value: 'medium',
              ),
              GamePrepChoice(
                label: 'Difícil',
                subtitle: '35 minas',
                value: 'hard',
              ),
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
    final difficultyValue = config.value(
      MinesweeperConfig.optionKeyDifficulty,
      'easy',
    );
    final difficulty = minesweeperDifficultyFromValue(difficultyValue);
    return GameWidget(
      game: MinesweeperFlameGame(
        callbacks: callbacks,
        difficulty: difficulty,
      ),
    );
  }
}

enum _Phase { playing, finished }

class MinesweeperFlameGame extends FlameGame with TapCallbacks {
  MinesweeperFlameGame({
    required this.callbacks,
    required this.difficulty,
  }) : _state = minesweeperNewGame(difficulty);

  final GameSessionCallbacks callbacks;
  final MinesweeperDifficulty difficulty;
  final Random _random = Random();

  late DateTime _startedAt;
  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;

  MinesweeperState _state;
  bool _flagMode = false;
  GameSessionHudActionBar? _actionBar;

  double _shakeT = 0;
  double _flashT = 0;
  final Set<String> _pulseKeys = {};
  double _pulseT = 0;

  Offset? _longPressOrigin;
  double _longPressTimer = 0;
  static const _longPressSec = 0.42;

  @override
  Color backgroundColor() => MinesweeperConfig.bgBottom;

  @override
  Future<void> onLoad() async {
    _startedAt = DateTime.now();
    callbacks.onScoreUpdate(0);
  }

  @override
  void onRemove() {
    _sessionActive = false;
    super.onRemove();
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
    if (_shakeT > 0) {
      _shakeT = (_shakeT - dt / MinesweeperConfig.shakeSec).clamp(0.0, 1.0);
    }
    if (_flashT > 0) {
      _flashT = (_flashT - dt / MinesweeperConfig.flashSec).clamp(0.0, 1.0);
    }
    if (_pulseKeys.isNotEmpty) {
      _pulseT += dt;
      if (_pulseT >= MinesweeperConfig.pulseSec) {
        _pulseT = 0;
        _pulseKeys.clear();
      }
    }

    if (_longPressOrigin != null && _phase == _Phase.playing) {
      _longPressTimer += dt;
      if (_longPressTimer >= _longPressSec) {
        _handleLongPress(_longPressOrigin!);
        _longPressOrigin = null;
        _longPressTimer = 0;
      }
    }
  }

  MinesweeperBoardLayout _layout() => minesweeperBoardLayout(
        screenW: size.x,
        screenH: size.y,
        rows: _state.rows,
        cols: _state.cols,
      );

  @override
  void onTapDown(TapDownEvent event) {
    if (_phase != _Phase.playing || !_sessionStarted) return;
    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if (_handleHudTap(pos)) return;

    final cell = _layout().cellAt(pos);
    if (cell == null) return;

    _longPressOrigin = pos;
    _longPressTimer = 0;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_longPressOrigin == null) return;
    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if ((pos - _longPressOrigin!).distance > 12) {
      _longPressOrigin = null;
      return;
    }
    if (_longPressTimer >= _longPressSec) {
      _longPressOrigin = null;
      return;
    }
    _longPressOrigin = null;

    if (_phase != _Phase.playing || !_sessionStarted) return;
    if (_handleHudTap(pos)) return;

    final cell = _layout().cellAt(pos);
    if (cell == null) return;

    if (_flagMode) {
      _toggleFlag(cell.$1, cell.$2);
    } else {
      _revealCell(cell.$1, cell.$2);
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _longPressOrigin = null;
    _longPressTimer = 0;
  }

  void _handleLongPress(Offset pos) {
    final cell = _layout().cellAt(pos);
    if (cell == null) return;
    _toggleFlag(cell.$1, cell.$2);
  }

  bool _handleHudTap(Offset pos) {
    final actionId = _actionBar?.hitTest(pos);
    if (actionId == null) return false;
    switch (actionId) {
      case 'flag':
        _flagMode = !_flagMode;
      case 'hint':
        _useHint();
    }
    return true;
  }

  List<GameSessionHudAction> _hudActions() {
    final coins = callbacks.currentCoins?.call() ?? 0;
    final canAffordHint = coins >= EconomyConfig.hintCoinCostMinesweeper;
    return [
      GameSessionHudAction(
        id: 'flag',
        icon: Icons.flag_rounded,
        enabled: true,
        accent: _flagMode ? MinesweeperConfig.flagCloth : MinesweeperConfig.hudMuted,
      ),
      GameSessionHudAction(
        id: 'hint',
        icon: GameSessionHudActionIcons.hint,
        enabled: _state.minesPlaced && canAffordHint && !_state.won && !_state.lost,
        accent: MinesweeperConfig.accentSoft,
        coinCost: EconomyConfig.hintCoinCostMinesweeper,
      ),
    ];
  }

  void _toggleFlag(int row, int col) {
    final result = minesweeperTryToggleFlag(_state, row, col);
    if (result == null) return;
    _state = result.state;
  }

  void _revealCell(int row, int col) {
    final result = minesweeperTryReveal(_state, row, col, _random);
    if (result == null) return;

    _state = result.state;
    final layout = _layout();

    if (result.mineHit) {
      _shakeT = 1;
      _flashT = 1;
      final rect = layout.cellRect(row, col);
      add(MinesweeperFloatingLabel(
        position: Vector2(rect.center.dx, rect.center.dy - 8),
        text: L10nScope.of.gameMinesweeperMineHit,
        color: MinesweeperConfig.missRed,
      ));
      _finishGame(won: false);
      return;
    }

    for (final (r, c) in result.revealedCells) {
      _pulseKeys.add('${r}_$c');
      _pulseT = 0;
      if (result.scoreDelta <= 0) continue;
      final rect = layout.cellRect(r, c);
      add(MinesweeperCellBurst(
        position: Vector2(rect.center.dx, rect.center.dy),
      ));
    }

    if (result.scoreDelta > 0) {
      final anchor = layout.cellRect(row, col);
      add(MinesweeperFloatingLabel(
        position: Vector2(anchor.center.dx, anchor.center.dy - 8),
        text: '+${result.scoreDelta}',
        color: MinesweeperConfig.successGlow,
      ));
    }

    _updateScore();

    if (result.won) {
      _finishGame(won: true);
    }
  }

  void _useHint() {
    final spend = callbacks.trySpendCoins;
    if (spend == null || !spend(EconomyConfig.hintCoinCostMinesweeper)) {
      final layout = _layout();
      add(MinesweeperFloatingLabel(
        position: Vector2(size.x / 2, layout.boardTop - 8),
        text: L10nScope.of
            .gameHintCostCoins(EconomyConfig.hintCoinCostMinesweeper),
        color: MinesweeperConfig.missRed,
      ));
      return;
    }

    final result = minesweeperHintSafe(_state, _random);
    if (result == null) return;

    _state = result.state;
    final layout = _layout();

    for (final (r, c) in result.revealedCells) {
      _pulseKeys.add('${r}_$c');
      _pulseT = 0;
      final rect = layout.cellRect(r, c);
      add(MinesweeperCellBurst(
        position: Vector2(rect.center.dx, rect.center.dy),
        color: MinesweeperConfig.accentSoft,
      ));
    }

    if (result.revealedCells.isNotEmpty) {
      final (r, c) = result.revealedCells.first;
      final rect = layout.cellRect(r, c);
      add(MinesweeperFloatingLabel(
        position: Vector2(rect.center.dx, rect.center.dy - 8),
        text: L10nScope.of.gameHintUsed,
        color: MinesweeperConfig.accentSoft,
      ));
    }

    _updateScore();

    if (result.won) {
      _finishGame(won: true);
    }
  }

  void _updateScore() {
    if (!_sessionActive) return;
    callbacks.onScoreUpdate(minesweeperProgressScore(_state));
  }

  void _finishGame({required bool won}) {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;
    if (!_sessionActive) return;

    final duration = DateTime.now().difference(_startedAt);
    final score = minesweeperFinalScore(
      state: _state,
      won: won,
    );

    callbacks.onGameOver(
      GameResult(
        score: score,
        duration: duration,
        metadata: {
          'moves': _state.moves,
          'revealed': _state.revealedCount,
          'flagsPlaced': _state.flagsPlaced,
          'hintsUsed': _state.hintsUsed,
          'won': won,
          'performanceTier': minesweeperPerformanceTier(
            won: won,
            hintsUsed: _state.hintsUsed,
          ).name,
        },
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    super.render(canvas);
    if (!_sessionStarted) return;
    _paintBoard(canvas);
    _paintHud(canvas);
    if (_flashT > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color = MinesweeperConfig.missRed.withValues(alpha: _flashT * 0.14),
      );
    }
  }

  void _paintBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MinesweeperConfig.bgTop, MinesweeperConfig.bgBottom],
        ).createShader(rect),
    );

    canvas.drawCircle(
      Offset(size.x * 0.12, size.y * 0.18),
      size.x * 0.08,
      Paint()..color = MinesweeperConfig.accentSoft.withValues(alpha: 0.08),
    );
    canvas.drawCircle(
      Offset(size.x * 0.88, size.y * 0.72),
      size.x * 0.11,
      Paint()..color = MinesweeperConfig.accentColor.withValues(alpha: 0.06),
    );
  }

  void _paintBoard(Canvas canvas) {
    final layout = _layout();
    final shakeDx = _shakeT > 0 ? sin(_shakeT * pi * 8) * _shakeT * 4 : 0.0;

    canvas.save();
    canvas.translate(shakeDx, 0);

    final boardRect = Rect.fromLTWH(
      layout.boardLeft - 6,
      layout.boardTop - 6,
      layout.boardWidth + 12,
      layout.boardHeight + 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(10)),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    for (var r = 0; r < _state.rows; r++) {
      for (var c = 0; c < _state.cols; c++) {
        _paintCell(canvas, layout, r, c);
      }
    }

    canvas.restore();
  }

  void _paintCell(
    Canvas canvas,
    MinesweeperBoardLayout layout,
    int row,
    int col,
  ) {
    final cellRect = layout.cellRect(row, col).deflate(1);
    final visibility = _state.visibility[row][col];
    final isMine = _state.mines[row][col];
    final showMines = _state.lost || _state.won;

    if (visibility == CellVisibility.hidden) {
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          MinesweeperConfig.cellHiddenTop,
          MinesweeperConfig.cellHiddenBottom,
        ],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, Radius.circular(cellRect.width * 0.12)),
        Paint()..shader = gradient.createShader(cellRect),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, Radius.circular(cellRect.width * 0.12)),
        Paint()
          ..color = MinesweeperConfig.cellBorder.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      return;
    }

    if (visibility == CellVisibility.flagged) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect, Radius.circular(cellRect.width * 0.12)),
        Paint()..color = MinesweeperConfig.cellHiddenBottom,
      );
      _paintFlag(canvas, cellRect);
      return;
    }

    final exploded = _state.lost && isMine;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cellRect, Radius.circular(cellRect.width * 0.08)),
      Paint()
        ..color = exploded
            ? MinesweeperConfig.mineExploded
            : MinesweeperConfig.cellRevealed,
    );

    if (isMine && (exploded || showMines)) {
      _paintMine(canvas, cellRect.center, cellRect.width * 0.28);
      return;
    }

    final count = _state.adjacency[row][col];
    if (count > 0) {
      final pulse = _pulseKeys.contains('${row}_$col');
      final scale =
          pulse ? 1 + (1 - _pulseT / MinesweeperConfig.pulseSec) * 0.14 : 1.0;
      _paintDigit(
        canvas,
        cellRect.center,
        '$count',
        fontSize: minesweeperCellFontSize(layout.cellSize) * scale,
        color: minesweeperNumberColor(count),
      );
    }
  }

  void _paintFlag(Canvas canvas, Rect cellRect) {
    final cx = cellRect.center.dx;
    final cy = cellRect.center.dy;
    final h = cellRect.height * 0.42;
    canvas.drawLine(
      Offset(cx - h * 0.35, cy + h * 0.45),
      Offset(cx - h * 0.35, cy - h * 0.5),
      Paint()
        ..color = MinesweeperConfig.flagPole
        ..strokeWidth = 2,
    );
    final path = Path()
      ..moveTo(cx - h * 0.35, cy - h * 0.45)
      ..lineTo(cx + h * 0.35, cy - h * 0.25)
      ..lineTo(cx - h * 0.35, cy - h * 0.05)
      ..close();
    canvas.drawPath(path, Paint()..color = MinesweeperConfig.flagCloth);
  }

  void _paintMine(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = MinesweeperConfig.mineColor,
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final dx = cos(angle) * radius * 1.35;
      final dy = sin(angle) * radius * 1.35;
      canvas.drawLine(
        center,
        Offset(center.dx + dx, center.dy + dy),
        Paint()
          ..color = MinesweeperConfig.mineColor
          ..strokeWidth = 1.5,
      );
    }
  }

  void _paintDigit(
    Canvas canvas,
    Offset center,
    String text, {
    required double fontSize,
    required Color color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.finished) return;

    const palette = GameSessionHudPalette(
      text: MinesweeperConfig.hudText,
      muted: MinesweeperConfig.hudMuted,
      accent: MinesweeperConfig.accentSoft,
    );

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      palette,
      columns: [
        GameSessionHudStat(
          caption: L10nScope.of.hudProgress,
          value: minesweeperHudProgressLabel(_state),
          footnote: minesweeperHudMinesLabel(_state),
          footnoteColor: MinesweeperConfig.hudMuted,
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudMoves,
          value: '${_state.moves}',
        ),
      ],
      progress: GameSessionHudProgress(
        ratio: minesweeperCompletionRatio(_state),
        color: MinesweeperConfig.successGlow.withValues(alpha: 0.85),
      ),
    );

    final canvasSize = Size(size.x, size.y);
    final actions = _hudActions();
    _actionBar = GameSessionHudActionBar.layout(
      canvasSize,
      actions: actions,
      withProgressBar: true,
    );
    GameSessionHudActionBar.paint(canvas, palette, _actionBar!, actions);
  }
}
