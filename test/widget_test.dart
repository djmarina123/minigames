import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/app.dart';
import 'package:minigames_hub/core/game_sdk/game_registry.dart';
import 'package:minigames_hub/games/demo/demo_game.dart';

void main() {
  setUp(() {
    GameRegistry.instance.register(DemoGame());
  });

  testWidgets('Home exibe jogo demo no catálogo', (tester) async {
    await tester.pumpWidget(const MinigamesApp());
    await tester.pumpAndSettle();

    expect(find.text('Minigames Hub'), findsOneWidget);
    expect(find.text('Demo Tap'), findsOneWidget);
    expect(find.textContaining('Toque o botão'), findsOneWidget);
  });

  testWidgets('abre o jogo demo ao tocar no card', (tester) async {
    await tester.pumpWidget(const MinigamesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Demo Tap'));
    await tester.pumpAndSettle();

    expect(find.text('10 s'), findsOneWidget);
  });
}
