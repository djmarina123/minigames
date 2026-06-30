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
12. **Card do catálogo** (`game_card_art.dart`): ilustração grande (~65–70% da área), composição única por jogo; decoração de fundo só no backdrop (≤ 10% opacidade) — ver [`hub-ui.md`](hub-ui.md).

### HUD (~48–56 px abaixo da AppBar)

12. Tabuleiro **depois** da faixa HUD — nunca sobrepor stats ao grid.
13. **Placar total** só na `GameSessionAppBar` (`onScoreUpdate`) — o HUD **não** repete `hudPoints` com o mesmo valor.
14. HUD = stats que ajudam a jogar (progresso, jogadas, combo, erros…) — **sem cronômetro** (ver tabela).
15. **Barra de progresso** = avanço do puzzle ou rampa de velocidade — **sempre enchendo** (`ratio` sobe).
16. Pintar em `render()` com `TextPainter`; cores no config; **legendas do HUD traduzidas** (não literal PT).
17. Layout seguro em **390 px**: esquerda = `pos.dx`, direita = `pos.dx - width`, centro = `pos.dx - width/2`; margem 16 px; textos curtos.

#### Placar AppBar vs. HUD (por tipo de jogo)

| Tipo | AppBar (placar) | Colunas típicas do HUD | Barra do HUD |
|---|---|---|---|
| Puzzle (Paciência, Campo Minado, Sudoku, Cross Sums) | `*ProgressScore` ao vivo | Progresso · Jogadas | `*CompletionRatio()` |
| Paciência | move score ao vivo | Fundação (+ jogadas) | `solitaireCompletionRatio` |
| Memória | score composto ao vivo | Pares · Jogadas | `memoryCompletionRatio` |
| Arcade (Cobra, Corrida) | pontos ao vivo | métricas de jogo — **sem** repetir placar | velocidade **enchendo** |
| Tap Rush | pontos ao vivo | combo + timer regressivo (mecânica do jogo) | barra regressiva |
| Blocos Coloridos | score ao vivo | Linhas · Jogadas · Combo | — |
| 2048 | merge score ao vivo | Jogadas · Objetivo · Máx. (peça) | — |

**Sem bônus por tempo** e **sem cronômetro no HUD** — duração da partida fica só em `GameResult.duration` (resultado/ranking). Pontuação vem de acertos, vitória, perfeição e penalidades.

Helpers de progresso em `*_config.dart`: `memoryCompletionRatio`, `solitaireCompletionRatio`, `minesweeperCompletionRatio`, `sudokuCompletionRatio`, `crossSumsCompletionRatio`.

Countdown 3-2-1 no início (Tap Rush, Cobra, Corrida) é só preparação — não confundir com limite de partida.

### Feedback

18. Acerto: label `+pts` e/ou burst.
19. Erro: shake/flash ou label `−N` quando há penalidade.
20. Transições animadas no `update(dt)`.
21. Bloquear input durante animações críticas.

### Label vs placar (devem bater)

22. `+N`/`−N` = **`newScore − previousScore`**, não constante bruta quando placar é composto.
23. Penalidades atualizam placar e FX na mesma ação.
24. Helpers `*ScoreDelta(...)` em config + testes.
25. Bônus de vitória/perfeição entram no placar final; penalidades no HUD com `hudPenaltyPerMove` quando aplicável.

| Jogo | Delta |
|---|---|
| Memória | `memoryProgressScoreDelta` |
| Corrida | `infiniteRunnerObstaclePassDelta` |
| Tap Rush / 2048 / Cobra / Paciência | incremento direto |
| Sudoku / Cross Sums | `result.scoreDelta` |

### Prep e testes

27. `GamePrepDefinition` + `GameHelpContent` — textos em ARB + `HubL10n` (ver [`i18n.md`](i18n.md)); prep localiza labels na tela.
28. Scoring puro em config; `*PerformanceTier()` via `tierFromRatio()`.
29. Testes em `test/games/`; helpers de HUD com texto → `L10nScope.installForTest()` no `setUpAll`.
30. `GameSessionAppBar` / `GameResultDialog` com `GameCatalogThumbnail` + `localizedMetadata()`.
31. `metadata['won']` só em jogos com vitória/derrota (Paciência, Sudoku, Cobra, Campo Minado, Cross Sums).
32. Dicas pagas: `GameSessionHudAction(coinCost: …)` + `EconomyConfig`.

## Anti-padrões

- Fundo genérico sem relação ao card do catálogo.
- Score só na AppBar; HUD com stats de jogo (nunca duplicar placar em `hudPoints`).
- Label flutuante com constante bruta (`+150`, `+30`) quando placar é composto.
- Penalidade silenciosa; HUD cortado; estado visual que teleporta.
- Cores no `render()`; regras só no código ou só no help.
- `coinsEarned`/`xpEarned` derivados do score de ranking.
- Barra do HUD **drenando** em puzzle ou endless (parece que a partida acaba no zero).
- Coluna `hudPoints` no HUD repetindo o mesmo valor da AppBar — placar total só na AppBar.
- Bônus por tempo no scoring ou cronômetro no HUD — duração só em `GameResult.duration`.

## Ao adicionar jogo

1. `registerBundledGames()` + `HubTheme._themes` + painter em `game_card_art.dart` (ilustração grande, identidade por jogo — [`hub-ui.md`](hub-ui.md)).
2. Espelhar cores em `*_config.dart`.
3. Chaves ARB + mapeamento em `HubL10n` ([`i18n.md`](i18n.md)).
4. Cumprir checklist acima + [`game-sdk.md`](game-sdk.md) (callbacks, tier).
5. `test/games/<jogo>_config_test.dart`.

Regras de pontuação detalhadas ficam em `*_config.dart` e no modal **?** da prep — não duplicar no ranking.
