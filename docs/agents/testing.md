# Testes

## Geral

- `GameRegistry.instance.resetForTesting()` em `setUp`/`tearDown`.
- `test/helpers/test_app.dart` — providers + `registerBundledGames()` + `LocaleRepository` (`app_locale: 'pt'`).
- Rodar `flutter analyze && flutter test` antes de encerrar tarefa.

i18n em testes: [`i18n.md`](i18n.md) (`L10nScope.installForTest`, delegates no `MaterialApp`).

## Por área

| Área | Onde |
|---|---|
| Scoring/tier/HUD helpers | `test/games/<jogo>_config_test.dart` — incluir `*CompletionRatio` e labels do HUD |
| Economia | `test/core/session_rewards_test.dart`, `level_curve_test.dart` |
| SDK / placar | `test/core/game_result_dialog_test.dart` |
| Favoritos | `test/core/favorite_games_test.dart`, widget em `test/widget_test.dart` |
| Repos / runner | `test/core/` |

## Golden tests (Home)

Agentes não veem o browser do usuário — use goldens para revisar layout da Home.

| Arquivo | Conteúdo |
|---|---|
| `test/golden/home_screen_golden_test.dart` | Captura `MainShell` |
| `test/goldens/home_mobile.png` | 390×844 |
| `test/goldens/home_tablet.png` | 768×1024 |

Fluxo: `flutter test test/golden/` → ler PNGs → se mudança intencional, `--update-goldens` e commitar.

Limitações: renderer de teste (não pixel-perfect Chrome); emojis podem variar OS — CI roda Ubuntu.

Adicionar golden após mudanças visuais na Home/shell/cards — não obrigatório por jogo individual.
