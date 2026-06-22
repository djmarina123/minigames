/// Configuração escolhida na tela de preparação e passada à partida.
class GameSessionConfig {
  const GameSessionConfig({this.values = const {}});

  final Map<String, Object?> values;

  T value<T>(String key, T fallback) {
    final raw = values[key];
    return raw is T ? raw : fallback;
  }
}
