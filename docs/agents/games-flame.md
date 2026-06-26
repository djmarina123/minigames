# Jogos Flame

Todo jogo novo deve atingir o polish de **Tap Rush** (gameplay) + **Memória** (visual/HUD/scoring).

| Referência | Copiar |
|---|---|
| `lib/games/tap_rush/` | Fases, loop, combo, dificuldade progressiva, FX arcade |
| `lib/games/memory/` | Paleta hub in-game, HUD de scoring, animações, `*_fx.dart` |

## Estrutura obrigatória

| Arquivo | Responsabilidade |
|---|---|
| `*_game.dart` | `HubGame` + `GameWidget` + `FlameGame` |
| `*_config.dart` | Cores, scoring, timings — **testável sem Flame** |
| `components/` | Entidades + FX |
| `test/games/*_config_test.dart` | Scoring, deltas, tiers, HUD helpers |

## Checklist (antes de considerar pronto)

### Arquitetura

1. Fases claras (`countdown → playing → finished`); flag antes de gameplay no `onGameResize`.
2. Estado síncrono no **construtor** (não só `onLoad`) — evita `LateInitializationError`.
3. Timer/animações no `update(dt)` — não `Timer.periodic`.
4. Score via `onScoreUpdate` — nunca `setState` no pai que recria `GameWidget`.
5. `GameResult.metadata`: stats, `won` (vitória/derrota), `performanceTier`.
6. Guarda `_sessionActive` após `await` / `onRemove`.
7. Moedas/XP: runner chama `resolveSessionReward()` — jogo **não** deriva de score.

### Visual

8. Paleta em `*_config.dart` de `HubTheme._themes[gameId]` — sem hex solto.
9. Gradiente de fundo + detalhe decorativo leve.
10. Elementos jogáveis: borda branca, sombra, cantos arredondados.
11. Tamanho pelo viewport menos área do HUD.

### HUD (~48–56 px abaixo da AppBar)

12. Tabuleiro **depois** da faixa HUD — nunca sobrepor stats ao grid.
13. Mostrar ao vivo o que afeta score (tempo, jogadas, combo, progresso).
14. Preview de bônus decrescente (valor ou barra) — strings via `L10nScope.of` (`hudTimeBonus`, etc.).
15. Pintar em `render()` com `TextPainter`; cores no config; **legendas do HUD traduzidas** (não literal PT).
16. Layout seguro em **390 px**: esquerda = `pos.dx`, direita = `pos.dx - width`, centro = `pos.dx - width/2`; margem 16 px; textos curtos.

### Feedback

17. Acerto: label `+pts` e/ou burst.
18. Erro: shake/flash ou label `−N` quando há penalidade.
19. Transições animadas no `update(dt)`.
20. Bloquear input durante animações críticas.

### Label vs placar (devem bater)

21. `+N`/`−N` = **`newScore − previousScore`**, não constante bruta quando placar é composto.
22. Penalidades atualizam placar e FX na mesma ação.
23. Helpers `*ScoreDelta(...)` em config + testes.
24. Bônus só no final: HUD faz preview (`+160 tempo`, `+10/s`, `−10/jogada`).

| Jogo | Delta |
|---|---|
| Memória | `memoryProgressScoreDelta` |
| Corrida | `infiniteRunnerObstaclePassDelta` |
| Tap Rush / 2048 / Cobra / Paciência | incremento direto |
| Sudoku / Dominó | `result.scoreDelta` |

### Prep e testes

25. `GamePrepDefinition` + `GameHelpContent` — textos em ARB + `HubL10n` (ver [`i18n.md`](i18n.md)); prep localiza labels na tela.
26. Scoring puro em config; `*PerformanceTier()` via `tierFromRatio()`.
27. Testes em `test/games/`; helpers de HUD com texto → `L10nScope.installForTest()` no `setUpAll`.
28. `GameSessionAppBar` / `GameResultDialog` com `GameCatalogThumbnail` + `localizedMetadata()`.
29. `metadata['won']` só em jogos com vitória/derrota (Dominó, Paciência, Sudoku, Cobra).
30. Dicas pagas: `GameSessionHudAction(coinCost: …)` + `EconomyConfig`.

## Anti-padrões

- Fundo genérico sem relação ao card do catálogo.
- Score só na AppBar; label com constante bruta (`+150`, `+30`).
- Penalidade silenciosa; HUD cortado; estado visual que teleporta.
- Cores no `render()`; regras só no código ou só no help.
- `coinsEarned`/`xpEarned` derivados do score de ranking.

## Ao adicionar jogo

1. `registerBundledGames()` + `HubTheme._themes` + arte em `game_card_art.dart`.
2. Espelhar cores em `*_config.dart`.
3. Chaves ARB + mapeamento em `HubL10n` ([`i18n.md`](i18n.md)).
4. Cumprir checklist acima + [`game-sdk.md`](game-sdk.md) (callbacks, tier).
5. `test/games/<jogo>_config_test.dart`.

Regras de pontuação detalhadas ficam em `*_config.dart` e no modal **?** da prep — não duplicar no ranking.
