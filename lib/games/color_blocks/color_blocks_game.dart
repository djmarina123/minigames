import 'dart:math' show Random, min, max, pi, sin;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/game_sdk/game_metadata.dart';
import '../../core/game_sdk/game_prep.dart';
import '../../core/game_sdk/game_result.dart';
import '../../core/game_sdk/game_session_callbacks.dart';
import '../../core/game_sdk/game_session_config.dart';
import '../../core/game_sdk/game_session_hud.dart';
import '../../core/game_sdk/hub_game.dart';
import '../../core/l10n/l10n_scope.dart';
import 'color_blocks_config.dart';
import 'components/color_blocks_fx.dart';

class ColorBlocksGame implements HubGame {
  @override
  GameMetadata get metadata => const GameMetadata(
        id: 'color_blocks',
        title: 'Color Blocks',
        description: 'Encaixe blocos coloridos e limpe linhas completas!',
        category: 'Puzzle',
        icon: '🧱',
      );

  @override
  GamePrepDefinition get prep => GamePrepDefinition(
        help: const GameHelpContent(
          howToPlay:
              'Arraste as peças da bandeja para o tabuleiro. Linhas ou colunas '
              'completas desaparecem. A partida termina quando nenhuma peça '
              'cabe no grid.',
          scoring:
              'Cada célula colocada vale pontos. Limpar linhas dá bônus; '
              'várias linhas de uma vez aumentam o combo.',
        ),
        optionGroups: [
          GamePrepOptionGroup(
            label: 'Tabuleiro',
            optionKey: ColorBlocksConfig.optionKeyGridSize,
            choices: const [
              GamePrepChoice(label: '8×8', subtitle: 'padrão', value: 8),
              GamePrepChoice(label: '10×10', subtitle: 'desafio', value: 10),
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
    final gridSize = config.value(
      ColorBlocksConfig.optionKeyGridSize,
      ColorBlocksConfig.defaultGridSize,
    );
    return GameWidget(
      game: ColorBlocksFlameGame(
        callbacks: callbacks,
        gridSize: gridSize,
      ),
    );
  }
}

enum _Phase { playing, finished }

class ColorBlocksFlameGame extends FlameGame with DragCallbacks, TapCallbacks {
  ColorBlocksFlameGame({
    required this.callbacks,
    required this.gridSize,
  })  : _board = colorBlocksEmptyBoard(gridSize),
        _tray = colorBlocksNewTray(Random()) {
    _startedAt = DateTime.now();
  }

  final GameSessionCallbacks callbacks;
  final int gridSize;

  late DateTime _startedAt;

  _Phase _phase = _Phase.playing;
  bool _sessionStarted = false;
  bool _sessionActive = true;
  bool _inputLocked = false;

  ColorBlocksBoard _board;
  List<ColorBlockPiece?> _tray;
  final _random = Random();

  int _score = 0;
  int _moves = 0;
  int _linesCleared = 0;
  int _bestCombo = 0;

  int? _dragTrayIndex;
  Vector2? _dragPos;
  (int row, int col)? _ghostAnchor;
  bool _ghostValid = false;
  Set<int> _previewRows = {};
  Set<int> _previewCols = {};
  int _previewLineCount = 0;
  Set<(int row, int col)> _ghostConflicts = {};
  ColorBlocksInvalidKind _ghostInvalidKind = ColorBlocksInvalidKind.none;
  double _previewPulse = 0;

  bool _isClearing = false;
  double _clearProgress = 0;
  Set<int> _clearRows = {};
  Set<int> _clearCols = {};
  ColorBlocksBoard? _boardAfterClear;

  double _invalidFlash = 0;
  double _shakeT = 0;
  (int row, int col)? _invalidFlashAnchor;
  ColorBlockPiece? _invalidFlashPiece;
  Set<(int row, int col)> _invalidFlashConflicts = {};

  static const _hudHeight = GameSessionHud.reservedHeight;

  @override
  Color backgroundColor() => ColorBlocksConfig.bgBottom;

  @override
  Future<void> onLoad() async {
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

    if (_isClearing) {
      _clearProgress += dt / ColorBlocksConfig.clearAnimSec;
      if (_clearProgress >= 1) {
        _completeClear();
      }
      return;
    }

    if (_invalidFlash > 0) {
      _invalidFlash =
          (_invalidFlash - dt / ColorBlocksConfig.invalidFlashSec).clamp(
        0.0,
        1.0,
      );
      if (_invalidFlash <= 0) {
        _invalidFlashAnchor = null;
        _invalidFlashPiece = null;
        _invalidFlashConflicts = {};
      }
    }

    if (_shakeT > 0) {
      _shakeT = (_shakeT - dt / ColorBlocksConfig.shakeSec).clamp(0.0, 1.0);
    }

    if (_dragTrayIndex != null) {
      _previewPulse += dt / ColorBlocksConfig.linePreviewPulseSec;
      if (_previewPulse > 1) _previewPulse -= 1;
    } else {
      _previewPulse = 0;
    }
  }

  void _completeClear() {
    _isClearing = false;
    _clearProgress = 0;
    if (_boardAfterClear != null) {
      _board = _boardAfterClear!;
      _boardAfterClear = null;
    }
    _clearRows = {};
    _clearCols = {};
    _inputLocked = false;
    _checkGameOver();
  }

  void _checkGameOver() {
    if (!colorBlocksHasAnyMove(_board, _tray)) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (_sessionActive) _finish();
      });
    }
  }

  void _finish() {
    if (_phase == _Phase.finished || !_sessionActive) return;
    _phase = _Phase.finished;
    callbacks.onGameOver(
      GameResult(
        score: _score.clamp(0, ColorBlocksConfig.maxScore),
        duration: DateTime.now().difference(_startedAt),
        metadata: {
          'moves': _moves,
          'linesCleared': _linesCleared,
          'bestCombo': _bestCombo,
          'gridSize': gridSize,
          'performanceTier': colorBlocksPerformanceTier(
            score: _score,
            linesCleared: _linesCleared,
            gridSize: gridSize,
          ).name,
        },
      ),
    );
  }

  @override
  void onRemove() {
    _sessionActive = false;
    super.onRemove();
  }

  ColorBlockPiece? get _activePiece =>
      _dragTrayIndex != null ? _tray[_dragTrayIndex!] : null;

  void _updateGhost() {
    final piece = _activePiece;
    final pos = _dragPos;
    if (piece == null || pos == null) {
      _ghostAnchor = null;
      _ghostValid = false;
      _previewRows = {};
      _previewCols = {};
      _previewLineCount = 0;
      _ghostConflicts = {};
      _ghostInvalidKind = ColorBlocksInvalidKind.none;
      return;
    }
    final layout = _boardLayout();
    final anchor = colorBlocksSnapAnchor(
      piece,
      layout.originX,
      layout.originY,
      layout.cell,
      layout.gap,
      pos.x,
      pos.y,
    );
    _ghostAnchor = anchor;
    final analysis = colorBlocksAnalyzePlacement(
      _board,
      piece,
      anchor.$1,
      anchor.$2,
    );
    _ghostValid = analysis.kind == ColorBlocksInvalidKind.none;
    _ghostConflicts = analysis.conflictCells;
    _ghostInvalidKind = analysis.kind;

    if (_ghostValid) {
      final preview = colorBlocksPreviewClears(
        _board,
        piece,
        anchor.$1,
        anchor.$2,
      );
      _previewRows = preview.clearedRows;
      _previewCols = preview.clearedCols;
      _previewLineCount = preview.linesCleared;
    } else {
      _previewRows = {};
      _previewCols = {};
      _previewLineCount = 0;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!_sessionStarted ||
        _phase == _Phase.finished ||
        _inputLocked ||
        _isClearing) {
      return;
    }
    final index = _trayIndexAt(event.localPosition);
    if (index == null || _tray[index] == null) return;
    _dragTrayIndex = index;
    _dragPos = event.localPosition.clone();
    _updateGhost();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (_dragTrayIndex == null) return;
    _dragPos = event.localEndPosition.clone();
    _updateGhost();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _tryPlaceDraggedPiece();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _cancelDrag();
  }

  void _cancelDrag() {
    _dragTrayIndex = null;
    _dragPos = null;
    _ghostAnchor = null;
    _ghostValid = false;
    _previewRows = {};
    _previewCols = {};
    _previewLineCount = 0;
    _ghostConflicts = {};
    _ghostInvalidKind = ColorBlocksInvalidKind.none;
  }

  String _invalidMessage(ColorBlocksInvalidKind kind) {
    return switch (kind) {
      ColorBlocksInvalidKind.outOfBounds =>
        L10nScope.of.gameColorBlocksOutOfBounds,
      ColorBlocksInvalidKind.overlap => L10nScope.of.gameColorBlocksOverlap,
      ColorBlocksInvalidKind.none => L10nScope.of.gameColorBlocksNoFit,
    };
  }

  void _triggerInvalidFeedback(
    ColorBlockPiece piece,
    (int row, int col) anchor,
    ColorBlocksInvalidKind kind,
  ) {
    final analysis = colorBlocksAnalyzePlacement(
      _board,
      piece,
      anchor.$1,
      anchor.$2,
    );
    _invalidFlash = 1;
    _shakeT = 1;
    _invalidFlashAnchor = anchor;
    _invalidFlashPiece = piece;
    _invalidFlashConflicts = analysis.conflictCells;

    final layout = _boardLayout();
    final center = _pieceBoardCenter(piece, anchor.$1, anchor.$2, layout);
    add(
      ColorBlocksFloatingLabel(
        position: center,
        text: _invalidMessage(kind),
        color: ColorBlocksConfig.conflictRed,
        emphasis: true,
      ),
    );
    add(ColorBlocksInvalidBurst(position: center.clone()));

    for (final (row, col) in analysis.conflictCells) {
      if (row < 0 || col < 0 || row >= gridSize || col >= gridSize) continue;
      final x = layout.originX + layout.gap + col * (layout.cell + layout.gap);
      final y = layout.originY + layout.gap + row * (layout.cell + layout.gap);
      add(
        ColorBlocksInvalidBurst(
          position: Vector2(x + layout.cell / 2, y + layout.cell / 2),
        ),
      );
    }
  }

  void _tryPlaceDraggedPiece() {
    final piece = _activePiece;
    final anchor = _ghostAnchor;
    final trayIndex = _dragTrayIndex;
    final invalidKind = _ghostInvalidKind;

    if (piece == null || anchor == null || trayIndex == null) {
      _cancelDrag();
      return;
    }

    if (!_ghostValid) {
      _triggerInvalidFeedback(piece, anchor, invalidKind);
      _cancelDrag();
      return;
    }

    _cancelDrag();
    _placePiece(piece, trayIndex, anchor.$1, anchor.$2);
  }

  void _placePiece(
    ColorBlockPiece piece,
    int trayIndex,
    int anchorRow,
    int anchorCol,
  ) {
    _inputLocked = true;
    _moves++;

    final placedBoard =
        colorBlocksPlaceBoard(_board, piece, anchorRow, anchorCol);
    final clearResult = colorBlocksClearFullLines(placedBoard);
    final delta = colorBlocksTurnScoreDelta(
      cellCount: piece.cells.length,
      linesCleared: clearResult.linesCleared,
    );
    final previousScore = _score;
    _score = (_score + delta).clamp(0, ColorBlocksConfig.maxScore);
    _linesCleared += clearResult.linesCleared;
    if (clearResult.linesCleared > _bestCombo) {
      _bestCombo = clearResult.linesCleared;
    }

    _board = placedBoard;
    _tray[trayIndex] = colorBlocksRandomPiece(_random);

    final layout = _boardLayout();
    final center = _pieceBoardCenter(
      piece,
      anchorRow,
      anchorCol,
      layout,
    );
    add(
      ColorBlocksFloatingLabel(
        position: center,
        text: '+${ _score - previousScore}',
        color: clearResult.linesCleared > 0
            ? ColorBlocksConfig.lineGlow
            : ColorBlocksConfig.accentSoft,
      ),
    );

    callbacks.onScoreUpdate(_score);

    if (clearResult.linesCleared > 0) {
      _startClearAnim(clearResult);
      for (final row in clearResult.clearedRows) {
        final y = layout.originY +
            layout.gap +
            row * (layout.cell + layout.gap) +
            layout.cell / 2;
        add(
          ColorBlocksLineBurst(
            position: Vector2(
              layout.originX + layout.boardSize / 2,
              y,
            ),
          ),
        );
      }
      for (final col in clearResult.clearedCols) {
        final x = layout.originX +
            layout.gap +
            col * (layout.cell + layout.gap) +
            layout.cell / 2;
        add(
          ColorBlocksLineBurst(
            position: Vector2(
              x,
              layout.originY + layout.boardSize / 2,
            ),
          ),
        );
      }
    } else {
      _inputLocked = false;
      _checkGameOver();
    }
  }

  void _startClearAnim(ColorBlocksClearResult result) {
    _isClearing = true;
    _clearProgress = 0;
    _clearRows = result.clearedRows;
    _clearCols = result.clearedCols;
    _boardAfterClear = result.board;
  }

  Vector2 _pieceBoardCenter(
    ColorBlockPiece piece,
    int anchorRow,
    int anchorCol,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
  ) {
    final (centerR, centerC) = colorBlocksPieceCenter(piece.cells);
    final stride = layout.cell + layout.gap;
    return Vector2(
      layout.originX +
          layout.gap +
          (anchorCol + centerC) * stride +
          layout.cell / 2,
      layout.originY +
          layout.gap +
          (anchorRow + centerR) * stride +
          layout.cell / 2,
    );
  }

  int? _trayIndexAt(Vector2 pos) {
    final layout = _trayLayout();
    for (var i = 0; i < ColorBlocksConfig.traySize; i++) {
      if (_tray[i] == null) continue;
      if (layout.slotRects[i].contains(Offset(pos.x, pos.y))) return i;
    }
    return null;
  }

  ({
    double originX,
    double originY,
    double cell,
    double gap,
    double boardSize,
  }) _boardLayout() {
    const margin = 16.0;
    const gap = 6.0;
    final tray = _trayLayout();
    final top = _hudHeight + 10;
    final bottom = tray.top - 10;
    final availH = (bottom - top).clamp(120.0, size.y);
    final availW = size.x - margin * 2;
    final boardSize = min(availW, availH);
    final cell = (boardSize - gap * (gridSize + 1)) / gridSize;
    return (
      originX: (size.x - boardSize) / 2,
      originY: top + (availH - boardSize) / 2,
      cell: cell,
      gap: gap,
      boardSize: boardSize,
    );
  }

  ({
    double top,
    double height,
    List<Rect> slotRects,
  }) _trayLayout() {
    const margin = 16.0;
    const height = 108.0;
    final top = size.y - height - 8;
    final slotW = (size.x - margin * 2) / ColorBlocksConfig.traySize;
    final slotRects = List.generate(ColorBlocksConfig.traySize, (i) {
      return Rect.fromLTWH(
        margin + i * slotW,
        top + 8,
        slotW,
        height - 16,
      );
    });
    return (top: top, height: height, slotRects: slotRects);
  }

  @override
  void render(Canvas canvas) {
    _paintBackground(canvas);
    super.render(canvas);
    if (!_sessionStarted) return;
    _paintBoard(canvas);
    _paintTray(canvas);
    if (_dragTrayIndex != null && _dragPos != null && _activePiece != null) {
      _paintDraggingPiece(canvas);
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
          colors: [ColorBlocksConfig.bgTop, ColorBlocksConfig.bgBottom],
        ).createShader(rect),
    );
    if (!_sessionStarted) return;
    final bubbles = [
      (0.1, 0.18, 0.16),
      (0.9, 0.28, 0.12),
      (0.82, 0.72, 0.2),
    ];
    for (final (fx, fy, fr) in bubbles) {
      canvas.drawCircle(
        Offset(size.x * fx, size.y * fy),
        size.x * fr,
        Paint()..color = Colors.white.withValues(alpha: 0.06),
      );
    }
  }

  void _paintBoard(Canvas canvas) {
    final layout = _boardLayout();
    final shakeDx =
        _shakeT > 0 ? sin(_shakeT * pi * 8) * 5 * _shakeT : 0.0;
    canvas.save();
    canvas.translate(shakeDx, 0);

    final boardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        layout.originX,
        layout.originY,
        layout.boardSize,
        layout.boardSize,
      ),
      Radius.circular(layout.cell * 0.16),
    );
    canvas.drawRRect(
      boardRect.shift(const Offset(0, 4)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      boardRect,
      Paint()..color = ColorBlocksConfig.boardBg,
    );

    if (_invalidFlash > 0) {
      canvas.drawRRect(
        boardRect,
        Paint()
          ..color = ColorBlocksConfig.conflictRed
              .withValues(alpha: 0.22 * _invalidFlash),
      );
      canvas.drawRRect(
        boardRect,
        Paint()
          ..color = ColorBlocksConfig.missRed
              .withValues(alpha: 0.75 * _invalidFlash)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    for (var row = 0; row < gridSize; row++) {
      for (var col = 0; col < gridSize; col++) {
        final x =
            layout.originX + layout.gap + col * (layout.cell + layout.gap);
        final y =
            layout.originY + layout.gap + row * (layout.cell + layout.gap);
        final colorIndex = _board[row][col];
        if (colorIndex == null) {
          _paintEmptyCell(canvas, x, y, layout.cell);
        } else {
          var alpha = 1.0;
          if (_isClearing &&
              (_clearRows.contains(row) || _clearCols.contains(col))) {
            alpha = 1 - _clearProgress;
          }
          _paintBlock(
            canvas,
            x,
            y,
            layout.cell,
            ColorBlocksConfig.blockColors[
                colorIndex % ColorBlocksConfig.blockColors.length],
            alpha: alpha,
          );
        }

        final showBoardConflict = _board[row][col] != null &&
            ((_dragTrayIndex != null &&
                    _ghostConflicts.contains((row, col))) ||
                (_invalidFlash > 0 &&
                    _invalidFlashConflicts.contains((row, col))));
        if (showBoardConflict) {
          _paintConflictOverlay(
            canvas,
            x,
            y,
            layout.cell,
            pulse: _dragTrayIndex != null,
          );
        }
      }
    }

    _paintLinePreview(canvas, layout);

    final flashPiece = _invalidFlashPiece ?? _activePiece;
    final flashAnchor = _invalidFlashAnchor ?? _ghostAnchor;
    final flashConflicts =
        _invalidFlash > 0 ? _invalidFlashConflicts : _ghostConflicts;
    final showingFlashGhost = _invalidFlash > 0 &&
        flashPiece != null &&
        flashAnchor != null;

    final ghostPiece = showingFlashGhost ? flashPiece : _activePiece;
    final ghost = showingFlashGhost ? flashAnchor : _ghostAnchor;
    final ghostIsValid =
        showingFlashGhost ? false : _ghostValid;
    final ghostConflicts = showingFlashGhost ? flashConflicts : _ghostConflicts;

    if (ghostPiece != null && ghost != null && !_isClearing) {
      for (final (dr, dc) in ghostPiece.cells) {
        final row = ghost.$1 + dr;
        final col = ghost.$2 + dc;
        if (row < 0 || col < 0 || row >= gridSize || col >= gridSize) {
          if (!ghostIsValid) {
            _paintOutOfBoundsGhost(
              canvas,
              layout,
              ghostPiece,
              ghost,
              dr,
              dc,
            );
          }
          continue;
        }
        final x =
            layout.originX + layout.gap + col * (layout.cell + layout.gap);
        final y =
            layout.originY + layout.gap + row * (layout.cell + layout.gap);
        if (!ghostIsValid && ghostConflicts.contains((row, col))) {
          _paintConflictOverlay(canvas, x, y, layout.cell);
        }
        _paintBlock(
          canvas,
          x,
          y,
          layout.cell,
          ghostPiece.color,
          alpha: ghostIsValid
              ? ColorBlocksConfig.ghostAlpha
              : 0.55 * (_invalidFlash > 0 ? _invalidFlash : 1),
          tint: ghostIsValid
              ? ColorBlocksConfig.ghostValid
              : ColorBlocksConfig.ghostInvalid,
        );
        if (!ghostIsValid) {
          _paintInvalidMark(canvas, x, y, layout.cell);
        }
      }
    }

    if (_previewLineCount > 0 && _ghostValid && _dragTrayIndex != null) {
      _paintLinePreviewLabel(canvas, layout);
    }

    if (_isClearing && _clearProgress > 0) {
      final flashAlpha = sin(_clearProgress * pi) * 0.35;
      for (final row in _clearRows) {
        final y = layout.originY + layout.gap + row * (layout.cell + layout.gap);
        canvas.drawRect(
          Rect.fromLTWH(
            layout.originX + layout.gap,
            y,
            layout.boardSize - layout.gap * 2,
            layout.cell,
          ),
          Paint()..color = ColorBlocksConfig.lineGlow.withValues(alpha: flashAlpha),
        );
      }
      for (final col in _clearCols) {
        final x = layout.originX + layout.gap + col * (layout.cell + layout.gap);
        canvas.drawRect(
          Rect.fromLTWH(
            x,
            layout.originY + layout.gap,
            layout.cell,
            layout.boardSize - layout.gap * 2,
          ),
          Paint()..color = ColorBlocksConfig.lineGlow.withValues(alpha: flashAlpha),
        );
      }
    }

    canvas.restore();
  }

  void _paintLinePreview(
    Canvas canvas,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
  ) {
    if (_previewLineCount <= 0 || !_ghostValid) return;

    final pulse = 0.45 + sin(_previewPulse * pi * 2) * 0.2;
    final stride = layout.cell + layout.gap;

    for (final row in _previewRows) {
      final y = layout.originY + layout.gap + row * stride;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            layout.originX + layout.gap,
            y,
            layout.boardSize - layout.gap * 2,
            layout.cell,
          ),
          Radius.circular(layout.cell * 0.12),
        ),
        Paint()
          ..color = ColorBlocksConfig.linePreview.withValues(alpha: pulse),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            layout.originX + layout.gap,
            y,
            layout.boardSize - layout.gap * 2,
            layout.cell,
          ),
          Radius.circular(layout.cell * 0.12),
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    for (final col in _previewCols) {
      final x = layout.originX + layout.gap + col * stride;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            layout.originY + layout.gap,
            layout.cell,
            layout.boardSize - layout.gap * 2,
          ),
          Radius.circular(layout.cell * 0.12),
        ),
        Paint()
          ..color = ColorBlocksConfig.linePreview.withValues(alpha: pulse),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            layout.originY + layout.gap,
            layout.cell,
            layout.boardSize - layout.gap * 2,
          ),
          Radius.circular(layout.cell * 0.12),
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _paintLinePreviewLabel(
    Canvas canvas,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
  ) {
    final text = L10nScope.of.gameColorBlocksLinesPreview(_previewLineCount);
    final bonus = colorBlocksLineClearPoints(_previewLineCount);
    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Color(0x99000000), blurRadius: 4),
              ],
            ),
          ),
          TextSpan(
            text: '  +$bonus',
            style: TextStyle(
              color: ColorBlocksConfig.linePreview.withValues(alpha: 0.95),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              shadows: const [
                Shadow(color: Color(0x99000000), blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          layout.originX + layout.boardSize / 2,
          layout.originY - 10,
        ),
        width: painter.width + 24,
        height: 28,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      badgeRect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()..color = ColorBlocksConfig.linePreview.withValues(alpha: 0.92),
    );
    painter.paint(
      canvas,
      Offset(
        badgeRect.left + (badgeRect.width - painter.width) / 2,
        badgeRect.top + (badgeRect.height - painter.height) / 2,
      ),
    );
  }

  void _paintConflictOverlay(
    Canvas canvas,
    double x,
    double y,
    double cell, {
    bool pulse = false,
  }) {
    final alpha = pulse
        ? 0.35 + sin(_previewPulse * pi * 2) * 0.15
        : 0.55 * (_invalidFlash > 0 ? _invalidFlash : 1);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.14),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = ColorBlocksConfig.conflictRed.withValues(alpha: alpha),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  void _paintInvalidMark(Canvas canvas, double x, double y, double cell) {
    final inset = cell * 0.28;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(x + inset, y + inset),
      Offset(x + cell - inset, y + cell - inset),
      paint,
    );
    canvas.drawLine(
      Offset(x + cell - inset, y + inset),
      Offset(x + inset, y + cell - inset),
      paint,
    );
  }

  void _paintOutOfBoundsGhost(
    Canvas canvas,
    ({
      double originX,
      double originY,
      double cell,
      double gap,
      double boardSize,
    }) layout,
    ColorBlockPiece piece,
    (int row, int col) anchor,
    int dr,
    int dc,
  ) {
    final row = anchor.$1 + dr;
    final col = anchor.$2 + dc;
    final stride = layout.cell + layout.gap;
    final anchorX = layout.originX + layout.gap + col * stride;
    final anchorY = layout.originY + layout.gap + row * stride;
    final clip = Rect.fromLTWH(
      layout.originX,
      layout.originY,
      layout.boardSize,
      layout.boardSize,
    );
    final ghostRect = Rect.fromLTWH(
      anchorX,
      anchorY,
      layout.cell,
      layout.cell,
    );
    if (!ghostRect.overlaps(clip)) return;
    final drawRect = ghostRect.intersect(clip);
    canvas.drawRRect(
      RRect.fromRectAndRadius(drawRect, Radius.circular(layout.cell * 0.14)),
      Paint()
        ..color = ColorBlocksConfig.conflictRed.withValues(alpha: 0.35),
    );
  }

  void _paintEmptyCell(Canvas canvas, double x, double y, double cell) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.14),
    );
    canvas.drawRRect(rect, Paint()..color = ColorBlocksConfig.cellEmpty);
  }

  void _paintBlock(
    Canvas canvas,
    double x,
    double y,
    double cell,
    Color color, {
    double alpha = 1,
    Color? tint,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, cell, cell),
      Radius.circular(cell * 0.14),
    );
    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.16 * alpha),
    );
    final fill = tint != null ? Color.lerp(color, tint, 0.35)! : color;
    canvas.drawRRect(
      rect,
      Paint()..color = fill.withValues(alpha: alpha),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.42 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintTray(Canvas canvas) {
    final layout = _trayLayout();
    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(12, layout.top, size.x - 24, layout.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      panelRect,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );

    for (var i = 0; i < ColorBlocksConfig.traySize; i++) {
      final slot = layout.slotRects[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          slot.deflate(6),
          const Radius.circular(12),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.06),
      );

      final piece = _tray[i];
      if (piece == null || i == _dragTrayIndex) continue;
      _paintTrayPiece(canvas, piece, slot);
    }
  }

  void _paintTrayPiece(Canvas canvas, ColorBlockPiece piece, Rect slot) {
    final (minR, maxR, minC, maxC) = _pieceBounds(piece.cells);
    final rows = maxR - minR + 1;
    final cols = maxC - minC + 1;
    final maxDim = max(rows, cols);
    final cell = min(slot.width, slot.height) * 0.62 / maxDim;
    final pieceW = cols * cell;
    final pieceH = rows * cell;
    final originX = slot.center.dx - pieceW / 2 - minC * cell;
    final originY = slot.center.dy - pieceH / 2 - minR * cell;

    for (final (dr, dc) in piece.cells) {
      _paintBlock(
        canvas,
        originX + dc * cell,
        originY + dr * cell,
        cell * 0.92,
        piece.color,
      );
    }
  }

  void _paintDraggingPiece(Canvas canvas) {
    final piece = _activePiece;
    final pos = _dragPos;
    if (piece == null || pos == null) return;

    final (minR, maxR, minC, maxC) = _pieceBounds(piece.cells);
    final rows = maxR - minR + 1;
    final cols = maxC - minC + 1;
    final maxDim = max(rows, cols);
    final cell = min(size.x, size.y) * 0.075 / maxDim * 1.15;
    final (centerR, centerC) = colorBlocksPieceCenter(piece.cells);
    final originX = pos.x - (centerC + 0.5) * cell;
    final originY = pos.y - (centerR + 0.5) * cell;

    for (final (dr, dc) in piece.cells) {
      _paintBlock(
        canvas,
        originX + dc * cell,
        originY + dr * cell,
        cell * 0.92,
        piece.color,
      );
    }
  }

  (int minR, int maxR, int minC, int maxC) _pieceBounds(
    List<(int, int)> cells,
  ) {
    var minR = cells.first.$1;
    var maxR = cells.first.$1;
    var minC = cells.first.$2;
    var maxC = cells.first.$2;
    for (final (row, col) in cells) {
      if (row < minR) minR = row;
      if (row > maxR) maxR = row;
      if (col < minC) minC = col;
      if (col > maxC) maxC = col;
    }
    return (minR, maxR, minC, maxC);
  }

  void _paintHud(Canvas canvas) {
    final comboPreview = _bestCombo > 1
        ? L10nScope.of.gameColorBlocksComboPreview(_bestCombo)
        : null;

    GameSessionHud.paintStatsBar(
      canvas,
      Size(size.x, size.y),
      const GameSessionHudPalette(
        text: ColorBlocksConfig.hudText,
        muted: ColorBlocksConfig.hudMuted,
        accent: ColorBlocksConfig.accentSoft,
      ),
      columns: [
        GameSessionHudStat(
          caption: L10nScope.of.hudLines,
          value: '$_linesCleared',
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudMoves,
          value: '$_moves',
        ),
        GameSessionHudStat(
          caption: L10nScope.of.hudPoints,
          value: '$_score',
          footnote: comboPreview,
          footnoteColor: _bestCombo > 1
              ? ColorBlocksConfig.lineGlow
              : ColorBlocksConfig.hudMuted.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}
