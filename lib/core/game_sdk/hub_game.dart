import 'package:flutter/widgets.dart';

import 'game_metadata.dart';
import 'game_session_callbacks.dart';

/// Contrato que todo jogo do hub deve implementar.
abstract class HubGame {
  GameMetadata get metadata;

  /// Constrói a UI do jogo. O jogo deve chamar os callbacks ao terminar ou pontuar.
  Widget buildGame(BuildContext context, GameSessionCallbacks callbacks);
}
