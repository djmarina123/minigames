# Game SDK

## Contrato `HubGame`

```dart
abstract class HubGame {
  GameMetadata get metadata;
  GamePrepDefinition? get prep => null;
  Widget buildGame(context, callbacks, {GameSessionConfig config});
}
```

Registrar em `registerBundledGames()` (`lib/bootstrap/games.dart`).

## Callbacks

| Callback | Quando |
|---|---|
| `onScoreUpdate(int)` | Durante partida (score de **ranking**) |
| `onGameOver(GameResult)` | Fim — `metadata['performanceTier']`; `metadata['won']` se vitória/derrota |
| `onExit()` | Desistência |
| `trySpendCoins(amount)` | Dicas pagas mid-game |
| `currentCoins()` | Habilitar botões pagos no HUD |
| `onRewardEarned` | Reservado (ads mid-game) |

`GameRunnerScreen` resolve moedas/XP via `resolveSessionReward()` **antes** de `recordGameSession`. Placar com `ValueNotifier`.

## Game Prep

```
Home → GamePrepScreen (se prep != null) → GameRunnerScreen
     → GameRunnerScreen direto (se prep == null)
```

| Arquivo | Papel |
|---|---|
| `game_prep.dart` | `GamePrepDefinition`, `GameHelpContent` |
| `game_session_config.dart` | Valores escolhidos (`.value(key, fallback)`) |
| `game_prep_screen.dart` | UI + botão JOGAR (texto via `l10n.gamePrepPlay`) |
| `game_help_dialog.dart` | Modal **?** (títulos via `l10n`; corpo via `HubL10n.gameHelp`) |

Opções atuais: Memória (pares 4/6/8), Tap Rush (15/30/60 s). Regras de pontuação no help — não no ranking. Labels de prep localizados em `HubL10n.prepGroupLabel` / `prepChoiceLabel` — ver [`i18n.md`](i18n.md).

Jogos com `implements HubGame` devem sobrescrever `prep` explicitamente.

## Ranking local

Melhor score **por jogo** (`LeaderboardRepository.allBest`), `shared_preferences`.

- `submitScore` ao fim da partida; repo é `ChangeNotifier`.
- Aba Ranking: `watch` + reload em `isActive`.
- Ordenação por **título do jogo**; sem medalhas cross-game.
- Linhas com `GameCatalogThumbnail` + `HubTheme.themeFor()` + título via `localizedMetadata()`.

## Economia

| Sistema | Fonte | Uso |
|---|---|---|
| Score | `*_config.dart` | Ranking |
| Moedas/XP | `session_rewards.dart` | Perfil, dicas, level up |

Cada jogo: `*PerformanceRatio()` → `tierFromRatio()` (`performance_tier.dart`).

| Faixa | Ratio |
|---|---|
| Ouro | ≥ 0.85 |
| Prata | ≥ 0.55 |
| Bronze | resto |

Calibração por jogo (ratio `1.0` = excelente): ver tabela em `performance_tier` / testes de cada `*_config_test.dart`.

### `PlayerRepository`

`recordGameSession`, `addBonusCoins` (não conta partida), `trySpendCoins`, `claimDailyReward`, `isFirstGameToday`.

Saldo inicial: `EconomyConfig.startingCoins` (50).

### `EconomyConfig` (principais)

| Item | Valor |
|---|---|
| Moedas/partida | 8 + tier (+4/+8) + 10 recorde — cap 20 |
| XP/partida | 20 + tier (+5/+10) + 15 recorde + 10 1ª do dia — cap 45 |
| Daily | 15 + 3×streak (cap 105) |
| Dica Sudoku / Paciência | 25 / 20 moedas |
| Level up | +(10 + nível) moedas |

Textos de economia: ARB (`economyHowCoins`, etc.) + modal `economy_help_dialog.dart` — ver [`i18n.md`](i18n.md). Curva: `level_curve.dart`.
