import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/game_sdk/game_session_hud_actions.dart';

void main() {
  group('GameSessionHudActionBar', () {
    test('reservedHeight cobre painel com barra + botões', () {
      expect(
        GameSessionHudActionBar.reservedHeight,
        greaterThan(90),
      );
    });

    test('layout alinha botões à direita em ordem da lista', () {
      const canvas = Size(390, 844);
      const actions = [
        GameSessionHudAction(
          id: 'undo',
          icon: Icons.undo_rounded,
          enabled: true,
        ),
        GameSessionHudAction(
          id: 'hint',
          icon: Icons.lightbulb_outline_rounded,
          enabled: true,
        ),
        GameSessionHudAction(
          id: 'erase',
          icon: Icons.backspace_outlined,
          enabled: false,
        ),
      ];

      final bar = GameSessionHudActionBar.layout(
        canvas,
        actions: actions,
        withProgressBar: true,
      );

      final undo = bar.rects['undo']!;
      final hint = bar.rects['hint']!;
      final erase = bar.rects['erase']!;

      expect(undo.left, lessThan(hint.left));
      expect(hint.left, lessThan(erase.left));
      expect(erase.right, lessThanOrEqualTo(canvas.width - 16));
      expect(undo.height, GameSessionHudActionBar.buttonSize);
    });

    test('hitTest retorna id só dentro do retângulo do botão', () {
      const canvas = Size(390, 844);
      const actions = [
        GameSessionHudAction(
          id: 'undo',
          icon: Icons.undo_rounded,
          enabled: true,
        ),
        GameSessionHudAction(
          id: 'hint',
          icon: Icons.lightbulb_outline_rounded,
          enabled: true,
        ),
      ];

      final bar = GameSessionHudActionBar.layout(
        canvas,
        actions: actions,
        withProgressBar: true,
      );
      final undo = bar.rects['undo']!;

      expect(bar.hitTest(undo.center), 'undo');
      expect(bar.hitTest(const Offset(0, 0)), isNull);
    });
  });
}
