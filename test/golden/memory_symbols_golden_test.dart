import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/games/memory/memory_config.dart';
import 'package:minigames_hub/games/memory/memory_symbols.dart';

import '../helpers/load_test_fonts.dart';

/// Prévia das cartas viradas — mesmo tamanho aproximado do grid in-game (4×2).
class _MemorySymbolsPreview extends StatelessWidget {
  const _MemorySymbolsPreview();

  static const cardSize = 72.0;
  static const gap = 12.0;
  static const cols = 3;

  @override
  Widget build(BuildContext context) {
    final symbols = MemoryConfig.symbolPool;
    final rows = (symbols.length / cols).ceil();
    final w = cols * cardSize + (cols - 1) * gap + 32;
    final h = rows * cardSize + (rows - 1) * gap + 32;

    return ColoredBox(
      color: MemoryConfig.bgBottom,
      child: SizedBox(
        width: w,
        height: h,
        child: CustomPaint(
          painter: _MemorySymbolsPreviewPainter(
            symbols: symbols,
            cardSize: cardSize,
            gap: gap,
            cols: cols,
          ),
        ),
      ),
    );
  }
}

class _MemorySymbolsPreviewPainter extends CustomPainter {
  _MemorySymbolsPreviewPainter({
    required this.symbols,
    required this.cardSize,
    required this.gap,
    required this.cols,
  });

  final List<MemorySymbolId> symbols;
  final double cardSize;
  final double gap;
  final int cols;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 16.0;
    for (var i = 0; i < symbols.length; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final left = pad + col * (cardSize + gap);
      final top = pad + row * (cardSize + gap);
      final rect = Rect.fromLTWH(left, top, cardSize, cardSize);
      final radius = Radius.circular(cardSize * 0.14);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.shift(const Offset(0, 3)), radius),
        Paint()..color = Colors.black.withValues(alpha: 0.22),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()..color = MemoryConfig.faceFront,
      );
      paintMemorySymbol(canvas, rect, symbols[i]);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()
          ..color = MemoryConfig.cardBorder.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = cardSize * 0.05,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MemorySymbolsPreviewPainter oldDelegate) =>
      false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestFonts);

  testWidgets('memory symbols preview', (tester) async {
    await tester.binding.setSurfaceSize(const Size(280, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: _MemorySymbolsPreview()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(_MemorySymbolsPreview),
      matchesGoldenFile('../goldens/memory_symbols.png'),
    );
  });
}
