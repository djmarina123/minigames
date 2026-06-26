# AGENTS.md — MiniPlay

> Índice para agentes de IA. Detalhes em [`docs/agents/`](docs/agents/).

**MiniPlay** · pacote `minigames_hub` · ID `com.miniplay.games` · roadmap [`PLANO.md`](PLANO.md)

---

## Leitura por tarefa

| Tarefa | Arquivo |
|---|---|
| Commit, CI, convenções, comandos | [`docs/agents/workflow.md`](docs/agents/workflow.md) |
| Stack, estrutura, dívidas | [`docs/agents/project.md`](docs/agents/project.md) |
| **Novo jogo Flame** ou polish in-game | [`docs/agents/games-flame.md`](docs/agents/games-flame.md) |
| Catálogo, cards, tema, favoritos | [`docs/agents/hub-ui.md`](docs/agents/hub-ui.md) |
| HubGame, prep, callbacks, economia, ranking | [`docs/agents/game-sdk.md`](docs/agents/game-sdk.md) |
| Testes e goldens | [`docs/agents/testing.md`](docs/agents/testing.md) |

---

## Regras sempre aplicáveis

### "Pronto" = commit + push + CI verde

Ver [`workflow.md`](docs/agents/workflow.md). Fora do "pronto", não commitar/push sem pedido explícito.

### Jogo Flame novo (resumo)

Copiar estrutura de **Tap Rush** + **Memória**. Checklist completo em [`games-flame.md`](docs/agents/games-flame.md). Registrar em `registerBundledGames()`, tema em `HubTheme`, arte em `game_card_art.dart`, scoring testável em `*_config.dart`.

### Princípios críticos

- Score (ranking) ≠ moedas/XP (`core/economy/`).
- Label flutuante = delta real do placar.
- UI visível: `GameCatalogHero`/`Thumbnail` — não emoji.
- Paleta in-game espelha `HubTheme._themes[gameId]`.
- Nunca `setState` no pai que recria `GameWidget`.

### Testes antes de encerrar

`flutter analyze && flutter test` — ver [`testing.md`](docs/agents/testing.md).
