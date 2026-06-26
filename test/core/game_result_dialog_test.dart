import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minigames_hub/core/game_sdk/game_metadata.dart';
import 'package:minigames_hub/core/game_sdk/game_result.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minigames_hub/l10n/app_localizations.dart';
import 'package:minigames_hub/core/locale/locale_repository.dart';
import 'package:minigames_hub/core/game_sdk/widgets/game_result_dialog.dart';
import 'package:minigames_hub/core/l10n/l10n_scope.dart';

void main() {
  const metadata = GameMetadata(
    id: 'domino',
    title: 'Dominó',
    description: 'Teste',
    category: 'Estratégia',
  );

  Widget pumpDialog(GameResult result, {bool isNewRecord = false}) {
    return MaterialApp(
      locale: const Locale('pt'),
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          L10nScope.wrap(context, child ?? const SizedBox.shrink()),
      home: Scaffold(
        body: GameResultDialog(
          metadata: metadata,
          result: result,
          onExit: () {},
          isNewRecord: isNewRecord,
        ),
      ),
    );
  }

  group('gameResultOutcomeWon', () {
    test('true quando metadata won é true', () {
      expect(gameResultOutcomeWon(const {'won': true}), isTrue);
    });

    test('false quando metadata won é false', () {
      expect(gameResultOutcomeWon(const {'won': false}), isFalse);
    });

    test('null quando metadata não tem won', () {
      expect(gameResultOutcomeWon(const {}), isNull);
      expect(gameResultOutcomeWon(const {'moves': 12}), isNull);
    });
  });

  group('GameResultDialog outcome', () {
    testWidgets('jogo sem won mostra Partida encerrada sem banner', (tester) async {
      await tester.pumpWidget(
        pumpDialog(
          const GameResult(
            score: 120,
            duration: Duration(seconds: 30),
            metadata: {'moves': 8},
          ),
        ),
      );

      expect(find.text('Partida encerrada'), findsOneWidget);
      expect(find.text('VITÓRIA'), findsNothing);
      expect(find.text('DERROTA'), findsNothing);
    });

    testWidgets('vitória mostra banner e subtítulo', (tester) async {
      await tester.pumpWidget(
        pumpDialog(
          const GameResult(
            score: 420,
            duration: Duration(minutes: 2),
            metadata: {'won': true, 'moves': 10},
          ),
        ),
      );

      expect(find.text('VITÓRIA'), findsOneWidget);
      expect(find.text('Vitória!'), findsOneWidget);
      expect(find.text('Você venceu a partida!'), findsOneWidget);
      expect(find.text('DERROTA'), findsNothing);
    });

    testWidgets('derrota mostra banner e subtítulo', (tester) async {
      await tester.pumpWidget(
        pumpDialog(
          const GameResult(
            score: 80,
            duration: Duration(minutes: 1),
            metadata: {'won': false, 'moves': 6},
          ),
        ),
      );

      expect(find.text('DERROTA'), findsOneWidget);
      expect(find.text('Derrota'), findsOneWidget);
      expect(find.text('Não foi desta vez — tente de novo.'), findsOneWidget);
      expect(find.text('VITÓRIA'), findsNothing);
    });

    testWidgets('novo recorde mantém banner de derrota no corpo', (tester) async {
      await tester.pumpWidget(
        pumpDialog(
          const GameResult(
            score: 200,
            duration: Duration(minutes: 3),
            metadata: {'won': false},
          ),
          isNewRecord: true,
        ),
      );

      expect(find.text('Novo recorde!'), findsOneWidget);
      expect(find.text('DERROTA'), findsOneWidget);
    });

    testWidgets('voltar ao hub fica no header, não no rodapé', (tester) async {
      await tester.pumpWidget(
        pumpDialog(
          const GameResult(
            score: 100,
            duration: Duration(seconds: 45),
            metadata: {'won': true},
          ),
        ),
      );

      expect(find.byTooltip('Voltar ao hub'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Voltar ao hub'), findsNothing);
    });
  });
}
