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
import 'components/cross_sums_fx.dart';
import 'components/cross_sums_tool_icons.dart';
import 'cross_sums_config.dart';

class CrossSumsGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'cross_sums',
        title: 'Cross Sums',
        description: 'Marque os números certos para bater as somas.',
        category: 'Puzzle',
        icon: '➕',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: GameHelpContent(
          howToPlay:
              'Remova ou marque números na grade para que a soma dos ativos '
              'em cada linha e coluna bata com os alvos à esquerda e acima. '
              'Use a BORRACHA para remover e o LÁPIS para restaurar. '
              'DICA custa ${EconomyConfig.hintCoinCostCrossSums} moedas. '
              'Termine ao acertar todas as células ou após 5 erros.',
          scoring:
              'Cada acerto vale +15 pts. Erro −18 pts. Complete o puzzle para '
              '+450 pts, bônus de tempo (até 280 pts) e +120 pts se terminar '
              'sem erros nem dicas pagas.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Dificuldade',
            optionKey: CrossSumsConfig.optionKeyDifficulty,
            choices: const [
              GamePrepChoice(label: 'Fácil', subtitle: '4×4', value: 'easy'),
              GamePrepChoice(label: 'Médio', subtitle: '5×5', value: 'medium'),
              GamePrepChoice(label: 'Difícil', subtitle: '6×6', value: 'hard'),
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
      CrossSumsConfig.optionKeyDifficulty,
      'easy',
    );
    final difficulty = crossSumsDifficultyFromValue(difficultyValue);
    return GameWidget(
      game: CrossSumsFlameGame(
        callbacks: callbacks,
        difficulty: difficulty,
      ),
    );
  }
}

enum _Phase { playing, finished }

class CrossSumsFlameGame extends FlameGame with TapCallbacks {
  CrossSumsFlameGame({
    required this.callbacks,
    required this.difficulty,
  }) : _state = crossSumsNewGame(Random(), difficulty: difficulty);

  final GameSessionCallbacks callbacks;
  final CrossSumsDifficulty difficulty;

  late DateTime _startedAt;
  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;

  CrossSumsState _state;
  final List<CrossSumsState> _undo = [];
  CrossSumsTool _tool = CrossSumsTool.eraser;
  int? _selectedRow;
  int? _selectedCol;
  GameSessionHudActionBar? _actionBar;
  double _shakeT = 0;
  double _flashT = 0;
  final Set<String> _pulseKeys = {};
  double _pulseT = 0;

  @override
  Color backgroundColor() => CrossSumsConfig.bgBottom;

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
      _shakeT = (_shakeT - dt / CrossSumsConfig.shakeSec).clamp(0.0, 1.0);
    }
    if (_flashT > 0) {
      _flashT = (_flashT - dt / CrossSumsConfig.flashSec).clamp(0.0, 1.0);
    }
    if (_pulseKeys.isNotEmpty) {
      _pulseT += dt;
      if (_pulseT >= CrossSumsConfig.pulseSec) {
        _pulseT = 0;
        _pulseKeys.clear();
      }
    }
  }

  CrossSumsBoardLayout _layout() => crossSumsBoardLayout(
        gridSize: _state.size,
        screenW: size.x,
        screenH: size.y,
      );

  @override
  void onTapDown(TapDownEvent event) {
    if (_phase != _Phase.playing || !_sessionStarted) return;
    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if (_handleHudTap(pos)) return;
    if (_handleToolTap(pos)) return;
    _handleBoardTap(pos);
  }

  bool _handleHudTap(Offset pos) {
    final actionId = _actionBar?.hitTest(pos);
    if (actionId == null) return false;
    if (actionId == 'hint') {
      _useHint();
    }
    return true;
  }

  List<GameSessionHudAction> _hudActions() {
    final coins = callbacks.currentCoins?.call() ?? 0;
    final canAffordHint = coins >= EconomyConfig.hintCoinCostCrossSums;
    return [
      GameSessionHudAction(
        id: 'hint',
        icon: GameSessionHudActionIcons.hint,
        enabled: _hasHintTarget() && canAffordHint,
        accent: CrossSumsConfig.successGlow,
        coinCost: EconomyConfig.hintCoinCostCrossSums,
      ),
    ];
  }

  bool _handleToolTap(Offset pos) {
    final layout = _layout();

    if (layout.eraserKnobRect.contains(pos)) {
      _tool = CrossSumsTool.eraser;
      return true;
    }
    if (layout.pencilKnobRect.contains(pos)) {
      _tool = CrossSumsTool.pencil;
      return true;
    }
    if (layout.toolToggleRect.contains(pos)) {
      _tool = _tool == CrossSumsTool.eraser
          ? CrossSumsTool.pencil
          : CrossSumsTool.eraser;
      return true;
    }
    return false;
  }

  void _handleBoardTap(Offset pos) {
    final layout = _layout();
    final localX = pos.dx - layout.boardLeft;
    final localY = pos.dy - layout.boardTop;
    if (localX < 0 ||
        localY < 0 ||
        localX >= layout.boardExtent ||
        localY >= layout.boardExtent) {
      return;
    }

    final boardRow = (localY / layout.cellSize).floor();
    final boardCol = (localX / layout.cellSize).floor();
    final playable = layout.playableAt(boardRow, boardCol);
    if (playable == null) return;

    final (row, col) = playable;
    _selectedRow = row;
    _selectedCol = col;

    final result = crossSumsTryToggle(_state, row, col, _tool);
    if (result == null) return;

    _pushUndo();
    _state = result.state;

    final cellRect = layout.cellRect(boardRow, boardCol);
    final cx = cellRect.center.dx;
    final cy = cellRect.center.dy;

    if (result.correct) {
      _pulseKeys.add('${row}_$col');
      _pulseT = 0;
      if (result.scoreDelta > 0) {
        add(CrossSumsCellBurst(position: Vector2(cx, cy)));
        add(CrossSumsFloatingLabel(
          position: Vector2(cx, cy - 8),
          text: '+${result.scoreDelta}',
          color: CrossSumsConfig.successGlow,
        ));
      }
    } else if (result.mistake) {
      _shakeT = 1;
      _flashT = 1;
      add(CrossSumsFloatingLabel(
        position: Vector2(cx, cy - 8),
        text: '${result.scoreDelta}',
        color: CrossSumsConfig.missRed,
      ));
    }

    _updateScore();

    if (result.won) {
      _finishGame(won: true);
    } else if (crossSumsIsGameOver(_state)) {
      _finishGame(won: false);
    }
  }

  void _pushUndo() {
    if (_undo.length >= 40) _undo.removeAt(0);
    _undo.add(_copyState(_state));
  }

  CrossSumsState _copyState(CrossSumsState state) {
    return CrossSumsState(
      size: state.size,
      rowTargets: state.rowTargets,
      colTargets: state.colTargets,
      values: state.values,
      kept: crossSumsCopyBoolGrid(state.kept),
      solution: state.solution,
      difficulty: state.difficulty,
      puzzleNumber: state.puzzleNumber,
      moves: state.moves,
      mistakes: state.mistakes,
      hintsUsed: state.hintsUsed,
      score: state.score,
      scoredCells: Set<String>.from(state.scoredCells),
    );
  }

  void _useHint() {
    final spend = callbacks.trySpendCoins;
    if (spend == null || !spend(EconomyConfig.hintCoinCostCrossSums)) {
      final layout = _layout();
      add(CrossSumsFloatingLabel(
        position: Vector2(size.x / 2, layout.boardTop - 8),
        text: L10nScope.of
            .gameHintCostCoins(EconomyConfig.hintCoinCostCrossSums),
        color: CrossSumsConfig.missRed,
      ));
      return;
    }

    final result = crossSumsHintPaid(_state);
    if (result == null) return;
    _pushUndo();
    _state = result.state;
    _selectedRow = result.row;
    _selectedCol = result.col;
    _pulseKeys.add('${result.row}_${result.col}');
    _pulseT = 0;

    final layout = _layout();
    final cellRect = layout.cellRect(result.row + 1, result.col + 1);
    add(CrossSumsFloatingLabel(
      position: Vector2(cellRect.center.dx, cellRect.center.dy),
      text: L10nScope.of.gameHintUsed,
      color: CrossSumsConfig.successGlow,
    ));
    _updateScore();
    if (crossSumsIsSolved(_state)) {
      _finishGame(won: true);
    }
  }

  void _updateScore() {
    if (!_sessionActive) return;
    callbacks.onScoreUpdate(crossSumsProgressScore(_state));
  }

  void _finishGame({required bool won}) {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;
    if (!_sessionActive) return;

    final duration = DateTime.now().difference(_startedAt);
    final score = crossSumsFinalScore(
      state: _state,
      won: won,
    );

    callbacks.onGameOver(
      GameResult(
        score: score,
        duration: duration,
        metadata: {
          'moves': _state.moves,
          'mistakes': _state.mistakes,
          'hintsUsed': _state.hintsUsed,
          'cellsCorrect': _state.correctCount(),
          'won': won,
          'performanceTier': crossSumsPerformanceTier(
            won: won,
            mistakes: _state.mistakes,
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
    _paintHeader(canvas);
    _paintBoard(canvas);
    _paintTools(canvas);
    _paintStats(canvas);
    if (_flashT > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color = CrossSumsConfig.missRed.withValues(alpha: _flashT * 0.10),
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
          colors: [CrossSumsConfig.bgTop, CrossSumsConfig.bgBottom],
        ).createShader(rect),
    );
  }

  void _paintHeader(Canvas canvas) {
    final centerX = size.x / 2;

    final badgeText = crossSumsDifficultyLabel(_state.difficulty).toUpperCase();
    final badgePainter = TextPainter(
      text: TextSpan(
        text: badgeText,
        style: const TextStyle(
          color: CrossSumsConfig.badgeText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final badgeW = badgePainter.width + 20;
    final badgeH = 22.0;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, CrossSumsConfig.layoutHudHeight + 10),
        width: badgeW,
        height: badgeH,
      ),
      const Radius.circular(11),
    );
    canvas.drawRRect(badgeRect, Paint()..color = CrossSumsConfig.badgeBg);
    badgePainter.paint(
      canvas,
      Offset(
        centerX - badgePainter.width / 2,
        CrossSumsConfig.layoutHudHeight + 10 - badgePainter.height / 2,
      ),
    );

    final levelText = L10nScope.of.gameCrossSumsLevel(_state.puzzleNumber);
    final levelPainter = TextPainter(
      text: TextSpan(
        text: levelText,
        style: const TextStyle(
          color: CrossSumsConfig.hudText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    levelPainter.paint(
      canvas,
      Offset(
        centerX - levelPainter.width / 2,
        CrossSumsConfig.layoutHudHeight + 24,
      ),
    );

    final heartsLeft =
        CrossSumsConfig.maxMistakes - _state.mistakes.clamp(0, 999);
    if (heartsLeft > 0) {
      const heartSize = 16.0;
      final heartsW = heartsLeft * heartSize + (heartsLeft - 1) * 4;
      var heartX = centerX - heartsW / 2;
      for (var i = 0; i < heartsLeft; i++) {
        _paintHeart(
          canvas,
          Offset(heartX + heartSize / 2, CrossSumsConfig.layoutHudHeight + 52),
          heartSize,
        );
        heartX += heartSize + 4;
      }
    }
  }

  void _paintHeart(Canvas canvas, Offset center, double size) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.28)
      ..cubicTo(
        center.dx - size * 0.5,
        center.dy - size * 0.12,
        center.dx - size * 0.5,
        center.dy - size * 0.55,
        center.dx,
        center.dy - size * 0.28,
      )
      ..cubicTo(
        center.dx + size * 0.5,
        center.dy - size * 0.55,
        center.dx + size * 0.5,
        center.dy - size * 0.12,
        center.dx,
        center.dy + size * 0.28,
      );
    canvas.drawPath(path, Paint()..color = CrossSumsConfig.heartColor);
  }

  void _paintBoard(Canvas canvas) {
    final layout = _layout();
    final shakeDx = _shakeT > 0 ? sin(_shakeT * pi * 8) * 4 * _shakeT : 0.0;

    canvas.save();
    canvas.translate(shakeDx, 0);

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        layout.boardLeft,
        layout.boardTop,
        layout.boardExtent,
        layout.boardExtent,
      ),
      Radius.circular(layout.cellSize * 0.12),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    final selRow = _selectedRow;
    final selCol = _selectedCol;

    for (var br = 0; br <= layout.gridSize; br++) {
      for (var bc = 0; bc <= layout.gridSize; bc++) {
        final cellRect = layout.cellRect(br, bc);
        final playable = layout.playableAt(br, bc);

        if (playable == null) {
          _paintHeaderCell(canvas, cellRect, br, bc, layout);
          continue;
        }

        final (row, col) = playable;
        final isSelected = row == selRow && col == selCol;
        final kept = _state.kept[row][col];
        final value = _state.values[row][col];
        final pulse = _pulseKeys.contains('${row}_$col');
        final scale = pulse
            ? 1 + (1 - _pulseT / CrossSumsConfig.pulseSec) * 0.10
            : 1.0;

        Color fill = kept ? CrossSumsConfig.cellBg : CrossSumsConfig.cellRemovedBg;
        if (isSelected) fill = CrossSumsConfig.cellSelected;
        if (selRow == row || selCol == col) {
          fill = Color.lerp(fill, CrossSumsConfig.cellHighlight, 0.45)!;
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(cellRect.deflate(1.5), const Radius.circular(6)),
          Paint()..color = fill,
        );

        final textColor =
            kept ? CrossSumsConfig.cellText : CrossSumsConfig.cellRemovedText;
        final fontSize = crossSumsCellFontSize(layout.cellSize) * scale;
        _paintDigit(
          canvas,
          cellRect.center,
          '$value',
          fontSize: fontSize,
          color: textColor.withValues(alpha: kept ? 1 : 0.55),
          bold: kept,
        );

        if (!kept) {
          canvas.drawLine(
            cellRect.center - Offset(cellRect.width * 0.28, 0),
            cellRect.center + Offset(cellRect.width * 0.28, 0),
            Paint()
              ..color = CrossSumsConfig.cellRemovedText.withValues(alpha: 0.7)
              ..strokeWidth = 2,
          );
        }
      }
    }

    canvas.restore();
  }

  void _paintHeaderCell(
    Canvas canvas,
    Rect cellRect,
    int boardRow,
    int boardCol,
    CrossSumsBoardLayout layout,
  ) {
    if (boardRow == 0 && boardCol == 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cellRect.deflate(1.5), const Radius.circular(6)),
        Paint()..color = CrossSumsConfig.cornerBg,
      );
      return;
    }

    var bg = CrossSumsConfig.headerCellBg;
    String? label;

    if (boardRow == 0 && boardCol > 0) {
      final col = boardCol - 1;
      label = '${_state.colTargets[col]}';
      final sum = crossSumsColSum(_state, col);
      if (sum == _state.colTargets[col]) {
        bg = CrossSumsConfig.headerCellMatch;
      } else if (sum > _state.colTargets[col]) {
        bg = CrossSumsConfig.headerCellOver;
      }
    } else if (boardCol == 0 && boardRow > 0) {
      final row = boardRow - 1;
      label = '${_state.rowTargets[row]}';
      final sum = crossSumsRowSum(_state, row);
      if (sum == _state.rowTargets[row]) {
        bg = CrossSumsConfig.headerCellMatch;
      } else if (sum > _state.rowTargets[row]) {
        bg = CrossSumsConfig.headerCellOver;
      }
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(cellRect.deflate(1.5), const Radius.circular(6)),
      Paint()..color = bg,
    );

    if (label != null) {
      _paintDigit(
        canvas,
        cellRect.center,
        label,
        fontSize: crossSumsHeaderFontSize(layout.cellSize),
        color: CrossSumsConfig.cellText,
        bold: true,
      );
    }
  }

  void _paintTools(Canvas canvas) {
    final layout = _layout();
    final eraserActive = _tool == CrossSumsTool.eraser;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        layout.toolToggleRect,
        Radius.circular(layout.toolToggleRect.height / 2),
      ),
      Paint()..color = CrossSumsConfig.toolTrack,
    );

    final activeKnob =
        eraserActive ? layout.eraserKnobRect : layout.pencilKnobRect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeKnob, Radius.circular(activeKnob.height / 2)),
      Paint()
        ..color = CrossSumsConfig.toolActive
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeKnob, Radius.circular(activeKnob.height / 2)),
      Paint()..color = CrossSumsConfig.toolActive,
    );

    _paintToolIcon(
      canvas,
      layout.eraserKnobRect,
      CrossSumsToolIcons.eraser,
      eraserActive,
    );
    _paintToolIcon(
      canvas,
      layout.pencilKnobRect,
      CrossSumsToolIcons.pencil,
      !eraserActive,
    );
  }

  void _paintToolIcon(
    Canvas canvas,
    Rect rect,
    IconData icon,
    bool active,
  ) {
    GameSessionHudActionBar.paintIcon(
      canvas,
      rect,
      icon,
      active ? CrossSumsConfig.cellText : CrossSumsConfig.hudMuted,
      size: rect.height * 0.52,
    );
  }

  void _paintStats(Canvas canvas) {
    if (_phase == _Phase.finished) return;

    const palette = GameSessionHudPalette(
      text: CrossSumsConfig.hudText,
      muted: CrossSumsConfig.hudMuted,
      accent: CrossSumsConfig.successGlow,
    );

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      palette,
      columns: [
        GameSessionHudStat(
          caption: L10nScope.of.hudProgress,
          value: crossSumsHudProgressLabel(_state),
          footnote: L10nScope.of.hudMistakesCount(
            _state.mistakes,
            CrossSumsConfig.maxMistakes,
          ),
          footnoteColor: _state.mistakes >= 3
              ? CrossSumsConfig.missRed
              : CrossSumsConfig.hudMuted,
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudMoves,
          value: '${_state.moves}',
        ),
      ],
      progress: GameSessionHudProgress(
        ratio: crossSumsCompletionRatio(_state),
        color: CrossSumsConfig.successGlow.withValues(alpha: 0.85),
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

  void _paintDigit(
    Canvas canvas,
    Offset center,
    String text, {
    required double fontSize,
    required Color color,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  bool _hasHintTarget() {
    for (var r = 0; r < _state.size; r++) {
      for (var c = 0; c < _state.size; c++) {
        if (_state.kept[r][c] != _state.solution[r][c]) return true;
      }
    }
    return false;
  }
}
