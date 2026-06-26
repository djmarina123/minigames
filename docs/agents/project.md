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
| i18n | `flutter_localizations` + `intl` · ARB em `lib/l10n/` · `LocaleRepository` |
| Backend / Ads | Firebase (Auth, Analytics, Crashlytics) · AdMob stub (`kAdsConfigured` = false). Setup Firebase: [`docs/firebase-setup.md`](../../docs/firebase-setup.md) |
| CI | GitHub Actions — `flutter analyze` + `flutter test` |

## Estrutura

```
lib/
├── main.dart, app.dart
├── bootstrap/games.dart          # registerBundledGames()
├── core/
│   ├── economy/                  # moedas, XP, tier, session_rewards
│   ├── game_sdk/                 # HubGame, prep, runner, widgets
│   ├── locale/                   # LocaleRepository, AppLocales
│   ├── l10n/                     # HubL10n, L10nScope
│   ├── storage/                  # PlayerRepository, favorite_games
│   ├── leaderboard/
│   └── theme/                    # hub_theme, game_card_art
├── features/                     # shell, home, leaderboard, profile
├── l10n/                         # app_pt/en/es.arb → app_localizations.dart
└── games/                        # memory ⭐, tap_rush ⭐, 2048, runner, solitaire, snake, domino, sudoku

test/golden/, test/goldens/, test/games/, test/core/, test/helpers/
```

Detalhes de i18n: [`i18n.md`](i18n.md).

## Dívidas técnicas

- AdMob não configurado (`kAdsConfigured` = false).
- `GameRunnerScreen` acoplado a ads/economia — extrair `SessionResultHandler`.
- `onRewardEarned` sem uso real.
- Sinks de moedas: só Sudoku + Paciência.
- Tap Rush: paleta ainda pode alinhar ao `HubTheme`.
- Memória: countdown / modo "Memorizar" na prep — opcional.
