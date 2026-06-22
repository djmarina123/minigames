import 'package:flutter/widgets.dart';

import 'game_metadata.dart';
import 'game_prep.dart';
import 'game_session_callbacks.dart';
import 'game_session_config.dart';

/// Contrato que todo jogo do hub deve implementar.
abstract class HubGame {
  GameMetadata get metadata;

  /// Tela intermediária (opções + ajuda). `null` = abre direto o runner.
  GamePrepDefinition? get prep => null;

  /// Constrói a UI do jogo. O jogo deve chamar os callbacks ao terminar ou pontuar.
  Widget buildGame(
    BuildContext context,
    GameSessionCallbacks callbacks, {
    GameSessionConfig config = const GameSessionConfig(),
  });
}
