# Projeto MiniPlay

**Nome (lojas/UI):** MiniPlay · **Pacote Dart:** `minigames_hub` · **Application ID:** `com.miniplay.games`

Hub de minijogos casuais para mobile. Android primeiro, iOS depois.

Roadmap e backlog: [`PLANO.md`](../../PLANO.md).

## Identidade

| Item | Valor |
|---|---|
| Nome exibido | MiniPlay |
| Android / iOS bundle | `com.miniplay.games` |
| Ícone fonte | `assets/branding/miniplay_icon_512.png` |
| Web manifest | `background_color` `#F5F0E8`, `theme_color` `#E84393` |

Ícones gerados em `android/.../mipmap-*`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/`, `web/icons/`. Não renomear pacote Dart sem plano explícito.

## Stack

| Camada | Tecnologia |
|---|---|
| App | Flutter 3.x (Dart) |
| Jogos 2D | Flame |
| Estado | Provider + ChangeNotifier |
| Persistência | shared_preferences |
| Backend / Ads | Firebase / AdMob — stubs (`kFirebaseConfigured`, `kAdsConfigured` = false) |
| CI | GitHub Actions — `flutter analyze` + `flutter test` |

## Estrutura

```
lib/
├── main.dart, app.dart
├── bootstrap/games.dart          # registerBundledGames()
├── core/
│   ├── economy/                  # moedas, XP, tier, session_rewards
│   ├── game_sdk/                 # HubGame, prep, runner, widgets
│   ├── storage/                  # PlayerRepository, favorite_games
│   ├── leaderboard/
│   └── theme/                    # hub_theme, game_card_art
├── features/                     # shell, home, leaderboard, profile
└── games/                        # memory ⭐, tap_rush ⭐, 2048, runner, solitaire, snake, domino, sudoku

test/golden/, test/goldens/, test/games/, test/core/, test/helpers/
```

## Dívidas técnicas

- Firebase / AdMob não configurados.
- `GameRunnerScreen` acoplado a ads/economia — extrair `SessionResultHandler`.
- `onRewardEarned` sem uso real.
- Sinks de moedas: só Sudoku + Paciência.
- Tap Rush: paleta ainda pode alinhar ao `HubTheme`.
- Memória: countdown / modo "Memorizar" na prep — opcional.
