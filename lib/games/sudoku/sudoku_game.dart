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
import 'components/sudoku_fx.dart';
import 'sudoku_config.dart';

class SudokuGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'sudoku',
        title: 'Sudoku',
        description: 'Preencha o grid 9×9 sem repetir números.',
        category: 'Puzzle',
        icon: '🧩',
        featured: true,
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: GameHelpContent(
          howToPlay:
              'Toque uma célula vazia e escolha um número de 1 a 9. Cada linha, '
              'coluna e bloco 3×3 deve conter todos os dígitos sem repetição. '
              'DICA custa ${EconomyConfig.hintCoinCostSudoku} moedas e revela uma célula. '
              'Use APAGAR para limpar. A partida termina ao completar o grid ou após 5 erros.',
          scoring:
              'Cada acerto vale +12 pts. Erro −15 pts. '
              'Complete o puzzle para +500 pts, bônus de tempo (até 300 pts) '
              'e +100 pts se terminar sem erros nem dicas pagas.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Dificuldade',
            optionKey: SudokuConfig.optionKeyDifficulty,
            choices: const [
              GamePrepChoice(label: 'Fácil', subtitle: '42 pistas', value: 'easy'),
              GamePrepChoice(label: 'Médio', subtitle: '32 pistas', value: 'medium'),
              GamePrepChoice(label: 'Difícil', subtitle: '26 pistas', value: 'hard'),
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
      SudokuConfig.optionKeyDifficulty,
      'easy',
    );
    final difficulty = sudokuDifficultyFromValue(difficultyValue);
    return GameWidget(
      game: SudokuFlameGame(
        callbacks: callbacks,
        difficulty: difficulty,
      ),
    );
  }
}

enum _Phase { playing, finished }

class SudokuFlameGame extends FlameGame with TapCallbacks {
  SudokuFlameGame({
    required this.callbacks,
    required this.difficulty,
  }) : _state = sudokuNewGame(Random(), difficulty: difficulty);

  final GameSessionCallbacks callbacks;
  final SudokuDifficulty difficulty;

  late DateTime _startedAt;
  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;

  SudokuState _state;
  final List<SudokuState> _undo = [];
  int? _selectedRow;
  int? _selectedCol;
  GameSessionHudActionBar? _actionBar;
  double _shakeT = 0;
  double _flashT = 0;
  final Set<String> _pulseKeys = {};
  double _pulseT = 0;

  @override
  Color backgroundColor() => SudokuConfig.bgBottom;

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
      _shakeT = (_shakeT - dt / SudokuConfig.shakeSec).clamp(0.0, 1.0);
    }
    if (_flashT > 0) {
      _flashT = (_flashT - dt / SudokuConfig.flashSec).clamp(0.0, 1.0);
    }
    if (_pulseKeys.isNotEmpty) {
      _pulseT += dt;
      if (_pulseT >= SudokuConfig.pulseSec) {
        _pulseT = 0;
        _pulseKeys.clear();
      }
    }
  }

  SudokuBoardLayout _layout() => sudokuBoardLayout(
        screenW: size.x,
        screenH: size.y,
      );

  @override
  void onTapDown(TapDownEvent event) {
    if (_phase != _Phase.playing || !_sessionStarted) return;
    final pos = Offset(event.localPosition.x, event.localPosition.y);
    if (_handleHudTap(pos)) return;
    if (_handleNumPadTap(pos)) return;
    _handleCellTap(pos);
  }

  bool _handleHudTap(Offset pos) {
    final actionId = _actionBar?.hitTest(pos);
    if (actionId == null) return false;
    switch (actionId) {
      case 'undo':
        _undoMove();
      case 'hint':
        _useHint();
      case 'erase':
        _eraseSelected();
    }
    return true;
  }

  List<GameSessionHudAction> _hudActions() {
    final coins = callbacks.currentCoins?.call() ?? 0;
    final canAffordHint = coins >= EconomyConfig.hintCoinCostSudoku;
    return [
        GameSessionHudAction(
          id: 'undo',
          icon: GameSessionHudActionIcons.undo,
          enabled: _undo.isNotEmpty,
        ),
        GameSessionHudAction(
          id: 'hint',
          icon: GameSessionHudActionIcons.hint,
          enabled: _hasHintTarget() && canAffordHint,
          accent: SudokuConfig.successGlow,
          coinCost: EconomyConfig.hintCoinCostSudoku,
        ),
        GameSessionHudAction(
          id: 'erase',
          icon: GameSessionHudActionIcons.erase,
          enabled: _canEraseSelected(),
          accent: SudokuConfig.accentSoft,
        ),
      ];
  }

  bool _handleNumPadTap(Offset pos) {
    final layout = _layout();
    for (var i = 0; i < layout.numPadRects.length; i++) {
      if (layout.numPadRects[i].contains(pos)) {
        _placeNumber(sudokuNumPadDigitForIndex(i));
        return true;
      }
    }
    if (layout.eraseRect.contains(pos)) {
      _eraseSelected();
      return true;
    }
    return false;
  }

  void _handleCellTap(Offset pos) {
    final layout = _layout();
    final localX = pos.dx - layout.boardLeft;
    final localY = pos.dy - layout.boardTop;
    if (localX < 0 ||
        localY < 0 ||
        localX >= layout.boardSize ||
        localY >= layout.boardSize) {
      return;
    }
    final row = (localY / layout.cellSize).floor().clamp(0, 8);
    final col = (localX / layout.cellSize).floor().clamp(0, 8);
    _selectedRow = row;
    _selectedCol = col;
  }

  void _pushUndo() {
    if (_undo.length >= 40) _undo.removeAt(0);
    _undo.add(_copyState(_state));
  }

  SudokuState _copyState(SudokuState state) {
    return SudokuState(
      solution: state.solution,
      givens: sudokuCopyGivens(state.givens),
      player: sudokuCopyGrid(state.player),
      difficulty: state.difficulty,
      moves: state.moves,
      mistakes: state.mistakes,
      hintsUsed: state.hintsUsed,
      score: state.score,
      scoredCells: Set<String>.from(state.scoredCells),
    );
  }

  void _undoMove() {
    if (_undo.isEmpty) return;
    _state = _undo.removeLast();
    _updateScore();
  }

  void _useHint() {
    final spend = callbacks.trySpendCoins;
    if (spend == null || !spend(EconomyConfig.hintCoinCostSudoku)) {
      final layout = _layout();
      add(SudokuFloatingLabel(
        position: Vector2(size.x / 2, layout.boardTop - 8),
        text: '${EconomyConfig.hintCoinCostSudoku} moedas',
        color: SudokuConfig.missRed,
      ));
      return;
    }

    final result = sudokuHintPaid(_state);
    if (result == null) return;
    _pushUndo();
    _state = result.state;
    _selectedRow = result.row;
    _selectedCol = result.col;
    _pulseKeys.add('${result.row}_${result.col}');
    _pulseT = 0;
    final layout = _layout();
    final cx = layout.boardLeft +
        (result.col + 0.5) * layout.cellSize;
    final cy = layout.boardTop +
        (result.row + 0.5) * layout.cellSize;
    add(SudokuFloatingLabel(
      position: Vector2(cx, cy),
      text: 'Dica!',
      color: SudokuConfig.successGlow,
    ));
    _updateScore();
    if (sudokuIsSolved(_state)) {
      _finishGame(won: true);
    }
  }

  void _eraseSelected() {
    final row = _selectedRow;
    final col = _selectedCol;
    if (row == null || col == null) return;
    final result = sudokuTryErase(_state, row, col);
    if (result == null) return;
    _pushUndo();
    _state = result.state;
    _updateScore();
  }

  void _placeNumber(int value) {
    final row = _selectedRow;
    final col = _selectedCol;
    if (row == null || col == null) return;
    if (!sudokuCanEditCell(_state, row, col)) return;

    final result = sudokuTryPlace(_state, row, col, value);
    if (result == null) return;

    _pushUndo();
    _state = result.state;

    final layout = _layout();
    final cx = layout.boardLeft + (col + 0.5) * layout.cellSize;
    final cy = layout.boardTop + (row + 0.5) * layout.cellSize;

    if (result.correct) {
      _pulseKeys.add('${row}_$col');
      _pulseT = 0;
      if (result.scoreDelta > 0) {
        add(SudokuCellBurst(position: Vector2(cx, cy)));
        add(SudokuFloatingLabel(
          position: Vector2(cx, cy - 8),
          text: '+${result.scoreDelta}',
          color: SudokuConfig.successGlow,
        ));
      }
    } else if (result.mistake) {
      _shakeT = 1;
      _flashT = 1;
      add(SudokuFloatingLabel(
        position: Vector2(cx, cy - 8),
        text: '${result.scoreDelta}',
        color: SudokuConfig.missRed,
      ));
    }

    _updateScore();

    if (result.won) {
      _finishGame(won: true);
    } else if (sudokuIsGameOver(_state)) {
      _finishGame(won: false);
    }
  }

  void _updateScore() {
    if (!_sessionActive) return;
    callbacks.onScoreUpdate(sudokuProgressScore(_state));
  }

  void _finishGame({required bool won}) {
    if (_phase == _Phase.finished) return;
    _phase = _Phase.finished;
    if (!_sessionActive) return;

    final duration = DateTime.now().difference(_startedAt);
    final score = sudokuFinalScore(
      state: _state,
      duration: duration,
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
          'cellsFilled': _state.filledCount(),
          'timeBonus': won ? sudokuTimeBonusRemaining(duration) : 0,
          'won': won,
          'performanceTier': sudokuPerformanceTier(
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
    _paintBoard(canvas);
    _paintNumPad(canvas);
    _paintHud(canvas);
    if (_flashT > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color = SudokuConfig.missRed.withValues(alpha: _flashT * 0.12),
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
          colors: [SudokuConfig.bgTop, SudokuConfig.bgBottom],
        ).createShader(rect),
    );

    final bubbles = [
      (0.88, 0.12, 0.38, 0.10),
      (0.10, 0.28, 0.24, 0.08),
      (0.72, 0.78, 0.48, 0.06),
    ];
    for (final (fx, fy, fr, alpha) in bubbles) {
      canvas.drawCircle(
        Offset(size.x * fx, size.y * fy),
        size.x * fr,
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
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
        layout.boardSize,
        layout.boardSize,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(boardRect, Paint()..color = SudokuConfig.boardBg);
    canvas.drawRRect(
      boardRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final conflicts = sudokuConflictMask(_state);
    final selRow = _selectedRow;
    final selCol = _selectedCol;
    final selValue = selRow != null && selCol != null
        ? _state.displayValue(selRow, selCol)
        : 0;

    for (var r = 0; r < SudokuConfig.gridSize; r++) {
      for (var c = 0; c < SudokuConfig.gridSize; c++) {
        final cellRect = Rect.fromLTWH(
          layout.boardLeft + c * layout.cellSize,
          layout.boardTop + r * layout.cellSize,
          layout.cellSize,
          layout.cellSize,
        );

        final isSelected = r == selRow && c == selCol;
        final isPeer = selRow != null &&
            selCol != null &&
            (r == selRow ||
                c == selCol ||
                (r ~/ 3 == selRow ~/ 3 && c ~/ 3 == selCol ~/ 3));
        final value = _state.displayValue(r, c);
        final isSameValue = selValue > 0 && value == selValue;

        Color? fill;
        if (conflicts[r][c]) {
          fill = SudokuConfig.cellConflict;
        } else if (isSelected) {
          fill = SudokuConfig.cellSelected;
        } else if (isSameValue) {
          fill = SudokuConfig.accentSoft.withValues(alpha: 0.35);
        } else if (isPeer) {
          fill = SudokuConfig.cellHighlight;
        }

        if (fill != null) {
          canvas.drawRect(cellRect, Paint()..color = fill);
        }

        if (value > 0) {
          final isGiven = _state.givens[r][c];
          final isWrong =
              !isGiven && value != _state.solution[r][c];
          final pulse = _pulseKeys.contains('${r}_$c');
          final scale = pulse ? 1 + (1 - _pulseT / SudokuConfig.pulseSec) * 0.12 : 1.0;

          _paintDigit(
            canvas,
            cellRect.center,
            '$value',
            fontSize: sudokuCellFontSize(layout.cellSize) * scale,
            color: isWrong
                ? SudokuConfig.missRed
                : isGiven
                    ? SudokuConfig.cellGiven
                    : SudokuConfig.cellPlayer,
            bold: isGiven,
          );
        }
      }
    }

    for (var i = 0; i <= SudokuConfig.gridSize; i++) {
      final isBold = i % SudokuConfig.boxSize == 0;
      final stroke = isBold ? 2.5 : 1.0;
      final color = isBold ? SudokuConfig.gridLineBold : SudokuConfig.gridLine;

      final x = layout.boardLeft + i * layout.cellSize;
      canvas.drawLine(
        Offset(x, layout.boardTop),
        Offset(x, layout.boardTop + layout.boardSize),
        Paint()
          ..color = color
          ..strokeWidth = stroke,
      );

      final y = layout.boardTop + i * layout.cellSize;
      canvas.drawLine(
        Offset(layout.boardLeft, y),
        Offset(layout.boardLeft + layout.boardSize, y),
        Paint()
          ..color = color
          ..strokeWidth = stroke,
      );
    }

    canvas.restore();
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

  void _paintNumPad(Canvas canvas) {
    final layout = _layout();
    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        layout.boardLeft - 4,
        layout.numPadTop - 6,
        layout.numPadWidth + 8,
        SudokuConfig.layoutNumPadHeight + 8,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      panel,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    for (var i = 0; i < layout.numPadRects.length; i++) {
      _paintPadButton(
        canvas,
        layout.numPadRects[i],
        '${sudokuNumPadDigitForIndex(i)}',
      );
    }
    _paintPadButton(canvas, layout.eraseRect, 'Apagar', compact: true);
  }

  void _paintPadButton(
    Canvas canvas,
    Rect rect,
    String label, {
    bool compact = false,
  }) {
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(
      rr,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: SudokuConfig.hudText,
          fontSize: compact ? 14 : 22,
          fontWeight: FontWeight.w700,
          letterSpacing: compact ? 0.2 : 0,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: rect.width - 8);
    painter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - painter.width) / 2,
        rect.top + (rect.height - painter.height) / 2,
      ),
    );
  }

  void _paintHud(Canvas canvas) {
    if (_phase == _Phase.finished) return;

    final elapsed = DateTime.now().difference(_startedAt);
    final timeBonus = sudokuTimeBonusRemaining(elapsed);
    final progress = sudokuProgressScore(_state);

    const palette = GameSessionHudPalette(
      text: SudokuConfig.hudText,
      muted: SudokuConfig.hudMuted,
      accent: SudokuConfig.accentSoft,
    );

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      palette,
      columns: [
        GameSessionHudStat(
          caption: 'Pontos',
          value: '$progress',
          footnote: sudokuHudTimeBonusLabel(timeBonus),
          footnoteColor: SudokuConfig.accentSoft,
        ),
        GameSessionHudStat(
          caption: 'Tempo',
          value: sudokuHudElapsedLabel(elapsed),
          footnote: '${_state.moves} jogadas',
          captionColor: SudokuConfig.hudMuted,
        ),
        GameSessionHudStat(
          caption: 'Progresso',
          value: sudokuHudProgressLabel(_state),
          footnote: '${_state.mistakes}/${SudokuConfig.maxMistakes} erros',
          footnoteColor: _state.mistakes >= 3
              ? SudokuConfig.missRed
              : SudokuConfig.hudMuted,
        ),
      ],
      progress: GameSessionHudProgress(
        ratio: timeBonus / SudokuConfig.timeBonusMax,
        color: SudokuConfig.successGlow.withValues(alpha: 0.85),
        lowColor: SudokuConfig.missRed.withValues(alpha: 0.85),
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

  bool _hasHintTarget() {
    for (var r = 0; r < SudokuConfig.gridSize; r++) {
      for (var c = 0; c < SudokuConfig.gridSize; c++) {
        if (!_state.givens[r][c] && _state.player[r][c] == 0) return true;
      }
    }
    return false;
  }

  bool _canEraseSelected() {
    final row = _selectedRow;
    final col = _selectedCol;
    if (row == null || col == null) return false;
    return sudokuCanEditCell(_state, row, col) && _state.player[row][col] > 0;
  }
}
