# AGENTS.md — MiniPlay

> Guia para agentes de IA (Cursor, etc.) que trabalham neste repositório.
> **Leia este arquivo antes de implementar qualquer feature.**

**Nome do app (lojas/UI):** MiniPlay · **Pacote Dart:** `minigames_hub` (repo `minigames`) · **Application ID:** `com.miniplay.games`

---

## Manutenção deste arquivo

**Obrigatório:** ao **concluir cada fase** do roadmap (`PLANO.md`), o agente deve:

1. Revisar o que foi implementado vs. o que estava planejado.
2. Atualizar a seção **Estado das fases** abaixo (marcar itens, registrar decisões).
3. Atualizar **Estrutura do projeto**, **Convenções** ou **Como rodar** se algo mudou.
4. Registrar **dívidas técnicas** ou **próximos passos** deixados para a fase seguinte.

Não encerrar uma fase sem atualizar este `AGENTS.md`.

---

## Visão do produto

**MiniPlay** — hub de **minijogos casuais** para mobile. Android primeiro, iOS depois.
Sessões curtas (1–5 min), moeda virtual, rankings, recompensa diária, ads.

Documento mestre de produto e roadmap: [`PLANO.md`](PLANO.md).

### Identidade (Fase 2 — início)

| Item | Valor |
|---|---|
| Nome exibido | MiniPlay |
| Android `applicationId` / namespace | `com.miniplay.games` |
| iOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.miniplay.games` |
| Ícone fonte | `assets/branding/miniplay_icon_512.png` |
| Web manifest | `background_color` creme `#F5F0E8`, `theme_color` rosa `#E84393` |

Ícones gerados em `android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/` e `web/icons/`. O nome do pacote Dart (`minigames_hub`) permanece até migração futura — não renomear sem plano explícito.

---

## Stack

| Camada | Tecnologia |
|---|---|
| App | Flutter 3.x (Dart) |
| Jogos 2D | Flame |
| Estado (MVP) | Provider + ChangeNotifier |
| Persistência local (MVP) | shared_preferences |
| Backend (futuro) | Firebase — stub (`kFirebaseConfigured = false`) |
| Ads (futuro) | AdMob — stub (`kAdsConfigured = false`) |
| CI | GitHub Actions — `flutter analyze` + `flutter test` |

Repositório GitHub pessoal: `git@github.com:djmarina123/minigames.git`
Chave SSH dedicada (`~/.ssh/id_ed25519_github`) — **não usar a chave do Senado**.

---

## Estrutura do projeto

```
lib/
├── main.dart                 # bootstrap, providers
├── bootstrap/
│   └── games.dart            # registerBundledGames()
├── app.dart                  # MaterialApp
├── core/
│   ├── economy/              # moedas, XP, nível, recompensa de sessão (testável)
│   │   ├── economy_config.dart
│   │   ├── economy_copy.dart
│   │   ├── economy_help_dialog.dart
│   │   ├── level_curve.dart
│   │   ├── performance_tier.dart
│   │   └── session_rewards.dart
│   ├── firebase/             # bootstrap stub
│   ├── ads/                  # AdMob stub (Fase 1+)
│   ├── game_sdk/             # HubGame, registry, prep, runner, widgets
│   │   ├── game_prep.dart
│   │   ├── game_prep_screen.dart
│   │   ├── game_session_config.dart
│   │   ├── game_session_hud_actions.dart  # barra de botões (dica paga, undo…)
│   │   └── widgets/          # GameSessionAppBar, GameResultDialog, game_help_dialog
│   ├── models/               # PlayerProfile, LeaderboardEntry
│   ├── storage/              # PlayerRepository (shared_preferences)
│   ├── leaderboard/          # LeaderboardRepository (ChangeNotifier)
│   └── theme/                # app_theme, game_ui, hub_theme, game_card_art
├── features/
│   ├── shell/                # bottom nav + drawer
│   ├── home/                 # grid + hub_header + game_card
│   ├── leaderboard/          # ranking estilizado (melhor score por jogo)
│   └── profile/              # stats com HubTheme.background
└── games/
    ├── demo/                 # Demo Tap (legado — fora do catálogo público)
    ├── memory/               # ⭐ Referência visual + HUD + scoring
    ├── tap_rush/             # ⭐ Referência gameplay arcade
    ├── game_2048/
    ├── infinite_runner/
    ├── solitaire/            # dica paga via GameSessionHudActionBar
    ├── snake/
    ├── domino/
    └── sudoku/               # dica paga via GameSessionHudActionBar

assets/
└── branding/
    └── miniplay_icon_512.png   # fonte do ícone (Android/iOS/web)

test/
├── golden/                   # golden tests (Home mobile + tablet)
├── goldens/                  # PNGs de referência — commitar no git
├── helpers/                  # test_app.dart, mock_game.dart, load_test_fonts.dart
├── games/                    # testes de scoring/config + performanceTier
└── core/                     # registry, repos, economy, game_runner
```

---

## Jogos referência

Todo jogo Flame novo deve atingir o **mesmo nível de polish** de **Tap Rush** (gameplay) + **Memória** (visual/HUD/scoring). Copie a **estrutura de pastas** de um dos dois e cumpra o checklist abaixo antes de considerar o jogo pronto.

| Referência | Copiar principalmente |
|---|---|
| `lib/games/tap_rush/` | Fases, loop `update`/`render`, combo, dificuldade progressiva, FX arcade |
| `lib/games/memory/` | Paleta do hub in-game, HUD com stats de scoring, animações, `*_fx.dart` |

### Estrutura de arquivos (obrigatória)

| Arquivo | Responsabilidade |
|---|---|
| `*_game.dart` | `HubGame` + `GameWidget` + `FlameGame` (loop, render, callbacks) |
| `*_config.dart` | Cores, duração, scoring, timings de animação — **testável sem Flame** |
| `components/` | Entidades Flame + FX (`*_card.dart`, `*_fx.dart`, alvos, HUD pieces) |
| `test/games/*_config_test.dart` | Funções puras de pontuação, progresso, previews do HUD |

### Checklist de qualidade — jogos Flame

**Antes de abrir PR ou encerrar tarefa, marque mentalmente cada item:**

#### Arquitetura e loop

1. **Fases** — `countdown → playing → finished` (ou equivalente claro). Nunca iniciar gameplay no `onGameResize` sem flag (`_sessionStarted` / `_gridBuilt`).
2. **Estado síncrono antes do layout** — dados usados em `onGameResize`/`_buildGrid` no **construtor**, não só em `onLoad()` async (`LateInitializationError` se violar).
3. **Timer no `update(dt)`** — tempo, animações e decaimento no loop Flame; **não** `Timer.periodic` para gameplay.
4. **Score via callback** — `onScoreUpdate(int)` durante a partida; **nunca** `setState` no pai que recria o `GameWidget`.
5. **`GameResult.metadata`** — stats úteis para o placar final (`moves`, `hits`, `timeBonus`, etc.) **e** `performanceTier` (`bronze` / `silver` / `gold`) para a economia global.
6. **`_sessionActive`** — guardas após `await` / `onRemove` para não chamar callbacks pós-dispose.
7. **Recompensa de sessão** — jogos **não** calculam `coinsEarned`/`xpEarned` a partir do score de ranking; o runner chama `resolveSessionReward()` em `core/economy/`.

#### Visual in-game (identidade MiniPlay)

8. **Paleta em `*_config.dart`** — derivar de `HubTheme._themes[gameId]` (`cardColor`, `accentColor`, `blendColor`, `accentSoft`). Mesmas cores do card do catálogo, **não** hex genérico solto (`#16213E`, etc.).
9. **Fundo** — gradiente (`bgTop` → `bgBottom`) + detalhe decorativo leve (bolhas, como `_MemoryArt` / Tap Rush).
10. **Elementos jogáveis** — borda branca + sombra onde fizer sentido (cartas, tiles, alvos); cantos arredondados proporcionais ao tamanho.
11. **Usar o viewport** — evitar elemento principal minúsculo no centro com faixas vazias; calcular tamanho pelo espaço disponível **menos** área do HUD.

#### HUD in-game (obrigatório)

12. **Barra compacta** abaixo da `GameSessionAppBar` (~48–56 px reservados no topo do canvas Flame). O tabuleiro começa **depois** dessa faixa (`_hudHeight` + margem) — nunca sobrepor stats ao grid.
13. **Mostrar o que afeta o score** — se a regra usa tempo, jogadas, combo ou progresso, o jogador **vê** isso ao vivo (não só no modal **?** nem só no placar final).
14. **Preview de bônus** — se houver bônus decrescente (ex.: tempo), exibir valor ou barra restante (padrão Memória: `+160 tempo` + barra).
15. **Pintar HUD em `render()`** — após `super.render()`, texto via `TextPainter`; cores `hudText` / `hudMuted` definidas no config.
16. **Layout seguro (sem texto cortado)** — ao usar `TextPainter` no HUD:
    - **Esquerda:** `pos.dx` = borda esquerda do texto (`paint` em `pos.dx`, não `pos.dx - width`).
    - **Direita:** `pos.dx` = borda direita (`paint` em `pos.dx - width`).
    - **Centro:** `pos.dx - width / 2`.
    - Margem horizontal mínima **16 px** da borda do canvas; em 3 colunas, dividir `(size.x - 2×margem) / 3` e passar `maxWidth` + `ellipsis` em cada coluna.
    - Validar em viewport **390 px** de largura (mobile) — nenhum label pode sair da tela.
    - Preferir textos curtos no HUD (`Deslize p/ jogar` em vez de frases longas).

#### Feedback e animação (obrigatório)

17. **Acerto** — FX positivo mínimo: label flutuante (`+pts`) e/ou burst/partículas no ponto de interação.
18. **Erro** — FX negativo mínimo: shake, flash de tela suave ou label com **penalidade** (`−10`, `−15`) quando a regra reduz pontos; feedback emocional (“Errou!”, “Tente de novo”) pode coexistir, mas não substituir o delta.
19. **Transições** — evitar mudanças instantâneas de estado visual; animar no `update(dt)` dos componentes (flip, scale, fade).
20. **Bloqueio de input** durante animações críticas (`_lockInput`, `isFlipSettled`, etc.).

#### Label flutuante vs placar (obrigatório)

O jogador compara o `+N` flutuante com o que subiu na AppBar. **Devem bater.**

21. **Delta real, não constante bruta** — o texto `+N` / `−N` deve refletir **`newScore − previousScore`** (variação líquida visível no placar), **não** a constante da regra (`pointsPerPair`, `pointsPerObstacle`, etc.) quando o placar usa fórmula composta ou penalidades acumuladas.
22. **Penalidades na hora** — se erro/jogada reduz pontos, chamar `onScoreUpdate` na mesma ação e mostrar o delta negativo (ou `−N` quando o placar ainda está em 0 mas a regra já cobrou). Não acumular penalidade silenciosa até o próximo acerto.
23. **Helpers testáveis** — expor `*ProgressScoreDelta(...)` / `*ObstaclePassDelta(...)` em `*_config.dart` e cobrir em `test/games/` o cenário em que label ≠ constante bruta.
24. **Bônus só no final ≠ bug** — bônus de tempo, vitória ou perfeição aplicados só em `*FinalScore` / `onGameOver` podem fazer o modal final > placar ao vivo; o HUD deve fazer **preview** (`+160 tempo`, `+10/s`, `−10/jogada`).

| Jogo | Padrão correto |
|---|---|
| Memória | `memoryProgressScoreDelta` — 1º par na 6ª jogada → `+90`, não `+150` |
| Corrida | `infiniteRunnerObstaclePassDelta` — obstáculo + tempo desde último placar |
| Tap Rush / 2048 / Cobra / Paciência | incremento direto — label = valor somado ao placar |
| Sudoku / Dominó | `result.scoreDelta` do movimento, nunca constante hardcoded no FX |

#### Prep, scoring e testes

25. **`GamePrepDefinition`** — opções de dificuldade + `GameHelpContent` (como jogar + pontuação em PT-BR).
26. **Scoring em funções puras** — `progressScore`, `finalScore`, previews do HUD em `*_config.dart`; `*PerformanceTier()` para economia.
27. **Testes unitários** — cobrir scoring, penalidades, bônus, deltas de label e helpers de formatação em `test/games/`.
28. **UI compartilhada** — `GameSessionAppBar` e `GameResultDialog` usam `GameCatalogThumbnail` (mesma arte do catálogo); estender `_GameResultStats` se o jogo tiver stats novas.
29. **Dicas pagas** — usar `GameSessionHudAction(coinCost: …)` + `callbacks.trySpendCoins`; custos em `EconomyConfig`, não hardcoded no `render()`.

### Padrões por referência

**Tap Rush** (`tap_rush_config.dart`, `tap_rush_game.dart`):

- Countdown 3 s antes de `playing`.
- Dificuldade progressiva via funções puras (`progress → radius/lifetime`).
- Combo com multiplicador + `FloatingLabel` + `HitBurst`.
- Barra de tempo no HUD; flash vermelho em miss.

**Memória** (`memory_config.dart`, `memory_game.dart`, `components/`):

- Paleta alinhada ao hub (`cardColor` `#5B4BB7`, `accentColor` `#FF7675`).
- HUD: pares `N/total`, timer `m:ss`, jogadas + `−10/jogada`, preview de bônus tempo + barra (`memoryTimeBonusRemaining`).
- Label no acerto: `memoryProgressScoreDelta` (líquido); no erro: `−10` quando a jogada custa pontos.
- Cartas: flip animado, shake em erro, pulse em par, verso com padrão + borda branca.
- `MemoryMatchBurst` + `MemoryFloatingLabel` em `memory_fx.dart`.
- `memoryProgressScore` / `memoryProgressScoreDelta` / `memoryFinalScore` / `memoryTimeBonusRemaining` testados sem Flame.

**Corrida Infinita** (`infinite_runner_config.dart`, `infinite_runner_game.dart`):

- Placar ao vivo = tempo (`+10/s`) + obstáculos (`+30` cada).
- Label ao passar obstáculo: `infiniteRunnerObstaclePassDelta` (inclui tempo desde último placar), não `+30` fixo.
- HUD: distância, velocidade, obstáculos + footnote `+10/s`.

### Anti-padrões (não entregar assim)

- Fundo cinza/azul genérico sem relação com o card do catálogo.
- Placar só na AppBar — jogador não entende **por que** o score muda.
- **Label flutuante com constante bruta** (`+150`, `+30`) enquanto o placar usa fórmula líquida ou multi-componente — usar delta real (`newScore − previousScore` ou `result.scoreDelta`).
- **Penalidade silenciosa** — jogadas/erros que custam pontos sem atualizar placar nem FX até o próximo acerto.
- **HUD com texto cortado** — `TextPainter` tratando borda esquerda como direita (`pos.dx - width` para coluna esquerda); sempre testar em 390 px.
- Estado visual que “teleporta” (carta vira sem animação, alvo some seco).
- Cores hardcoded espalhadas no `render()` — centralizar no config.
- Regras de pontuação só no código ou só no help — duplicar: funções testáveis + texto na prep.
- **`coinsEarned` / `xpEarned` derivados do score de ranking** — score é para leaderboard; economia usa `performanceTier` + `session_rewards.dart`.

---

## Tela de preparação (Game Prep)

Fluxo ao tocar em um jogo no catálogo:

```
Home → GamePrepScreen (se game.prep != null) → GameRunnerScreen
     → GameRunnerScreen direto (se game.prep == null)
```

### Arquivos

| Arquivo | Responsabilidade |
|---|---|
| `game_prep.dart` | Modelos: `GamePrepDefinition`, `GamePrepOptionGroup`, `GameHelpContent` |
| `game_session_config.dart` | Valores escolhidos (`Map` tipado via `.value(key, fallback)`) |
| `game_prep_screen.dart` | UI: `GameCatalogHero`, painéis de opção, botão JOGAR |
| `widgets/game_help_dialog.dart` | Modal bottom sheet: como jogar + pontuação |

### Contrato `HubGame`

```dart
abstract class HubGame {
  GameMetadata get metadata;
  GamePrepDefinition? get prep => null;  // null = sem tela intermediária
  Widget buildGame(context, callbacks, {GameSessionConfig config});
}
```

### Quando usar opções

| Jogo | `optionKey` | Escolhas |
|---|---|---|
| Memória | `MemoryConfig.optionKeyPairCount` | 8 / 12 / 16 cartas (4 / 6 / 8 pares) |
| Tap Rush | `TapRushConfig.optionKeyDurationSec` | 15 / 30 / 60 s |

Regras de pontuação ficam em `GameHelpContent.scoring` (modal **?**) — **não** repetir no ranking.

### Ao adicionar jogo novo com prep

1. Definir constantes de opção em `*_config.dart`.
2. Sobrescrever `prep` no `HubGame` com textos PT-BR.
3. Ler `config.value(optionKey, default)` em `buildGame`.
4. Manter defaults iguais ao valor `defaultIndex` do grupo.

### UI da prep (`GamePrepScreen`)

- **Hero:** `GameCatalogHero` — mesma arte vetorial do catálogo (`GameCardArt`), nunca emoji solto.
- **Opções:** painel branco + tiles em `Row` (largura igual); selecionado = cor do jogo + ✓.
- **Ajuda:** ícone **?** no topo → `showGameHelpDialog` (como jogar + pontuação).
- **JOGAR:** botão fixo no rodapé; navega com `pushReplacement` para `GameRunnerScreen`.

**Importante:** jogos que usam `implements HubGame` devem sobrescrever `prep` explicitamente (default `=> null` só vale com `extends`).

---

## Design do Hub (catálogo de jogos)

Referência: apps de minijogos casuais com **grid colorido 2 colunas**, fundo creme, header minimalista.

### Layout

| Zona | Regra |
|---|---|
| **Fundo** | Creme `#F5F0E8` (`HubTheme.background`) |
| **Header** | Menu (drawer) · pill de **nível** (anel de progresso, toque → Perfil) · pill de **moedas** · ícone remover ads |
| **Grid** | 2 colunas, `childAspectRatio: 0.92`, spacing 14px, padding 16px |
| **Nav secundária** | Bottom nav (Jogos / Ranking / Perfil) + drawer pelo menu |

### Card de jogo (`GameCard`)

Todo jogo no catálogo **deve** seguir:

1. **Container** — cantos `22px`, borda branca **4px**, cor de fundo única por jogo.
2. **Título** — canto superior esquerdo, **CAIXA ALTA**, bold, branco; vinheta leve no topo (~64px).
3. **Linha decorativa** — barra curta colorida abaixo do título (cor `accentColor`, largura proporcional à 1ª palavra).
4. **Ilustração** — vetorial em `core/theme/game_card_art.dart` (`CustomPaint` + `GameCatalogHero`), **full-bleed** no card (Stack `fit: expand`). Arte centralizada com bolhas decorativas no fundo — **não** colocar PNG pequeno em `BoxFit.contain` (fica “caixa colada” com espaço vazio).
5. **Badge "NOVO!"** — `HubTheme.featuredBadge`, canto superior direito, só se `metadata.featured == true`.
6. **Feedback** — `AnimatedScale(0.96)` no toque; card inteiro é clicável.
7. **Cores por jogo** — registrar em `HubTheme._themes` em `core/theme/hub_theme.dart` (não hardcodar no card).

**Ilustração — o que NÃO fazer (aprendizado):**

- PNG gerado por IA com **checkerboard de transparência falso** embutido → aparece xadrez cinza/branco no app.
- PNG com `BoxFit.contain` em área branca → arte pequena, faixa colorida vazia em cima.
- Emojis pequenos no canto → parece placeholder, não capa de jogo.

**Preferir:** `CustomPaint` por jogo (`_TapRushArt`, `_MemoryArt`) ou PNG **sem alpha** com fundo igual ao `cardColor` (export sólido, não checkerboard). Cores internas da arte derivam de `HubGameTheme` (`cardColor`, `accentColor`, `blendColor`, `accentSoft`) — não hardcodar hex na pintura.

### Identidade visual compartilhada (`game_card_art.dart`)

| Widget | Uso |
|---|---|
| `GameCardArt` | Ilustração vetorial full-bleed; `compact: true` simplifica (só uso interno legado) |
| `GameCatalogHero` | Banner do catálogo e da prep (título + linha + arte) |
| `GameCatalogThumbnail` | Recorte escalado do [GameCatalogHero] (~38–80px) — **ranking**, `GameSessionAppBar`, `GameResultDialog`, ajuda **?** |

**Regra:** face visual do jogo no hub = `gameId` + `HubTheme.themeFor()` → **nunca** `metadata.icon` em UI (emoji fica só para fallback genérico / uso interno). Miniaturas usam o **mesmo widget** do card da Home (`GameCatalogHero` via `FittedBox`), não uma arte separada.

Ao adicionar jogo: implementar painter em `GameCardArt`; catálogo, prep, ranking, sessão de jogo, placar final e ajuda passam a heredar automaticamente via `GameCatalogHero` / `GameCatalogThumbnail`.

### Tokens de cor (`hub_theme.dart`)

| Token | Uso |
|---|---|
| `background` | Fundo creme do hub |
| `textPrimary` / `textSecondary` | Títulos e corpo (header, ranking, perfil, prep, ajuda) |
| `featuredBadge` | Badge "NOVO!" nos cards |
| `coinGold` | Moedas — pill, dicas, barra de XP no perfil |
| `coinIcon` | Ícone padrão de moeda (`Icons.monetization_on_rounded`) — **único** em todo o hub |
| `levelIcon` | Ícone de XP/nível (`Icons.star_rounded`) |
| `levelPillBg` | Fundo do pill de nível no header |
| `cardColor` + `accentColor` | Por jogo em `HubTheme._themes` |
| `blendColor` / `accentSoft` | Derivados em `HubGameTheme` — detalhes da arte vetorial |
| `hubUnderlineWidth(titleLead)` | Largura da barra decorativa (proporcional à 1ª palavra do título) |

**Não** usar `Color(0xFF2D3436)` etc. solto — sempre `HubTheme.textPrimary` / `textSecondary`.

### Header (`HubHeader`)

- **Nível:** anel circular com progresso de XP + número; toque navega para aba Perfil (`onProfileTap` no `MainShell`).
- **Moedas:** `PlayerRepository.profile.coins` (Provider); ícone `HubTheme.coinIcon`.
- **Remover ads:** ícone compacto (tooltip); stub até IAP Fase 2 — nunca bloquear navegação.
- Recompensa diária: banner compacto abaixo do header (`DailyRewardBanner`) com valor previsto (`dailyRewardAmount`); não `MaterialBanner` full-width.

### Ao adicionar jogo novo

1. Registrar em `registerBundledGames()` (`lib/bootstrap/games.dart`).
2. Adicionar entrada em `HubTheme._themes` com `cardColor` + `accentColor`.
3. Implementar arte em `core/theme/game_card_art.dart` (CustomPaint) — ver jogos existentes.
4. Escolher emoji em `metadata.icon` apenas para fallback — **toda** UI visível usa `GameCardArt` por `gameId` (incl. AppBar e placar final).
5. **Espelhar cores do passo 2** em `*_config.dart` do jogo (`bgTop`, `bgBottom`, `accentColor`, etc.).
6. Cumprir o **Checklist de qualidade — jogos Flame** (seção acima) antes de considerar pronto.
7. Adicionar `test/games/<jogo>_config_test.dart` com scoring e helpers do HUD.

### Arquivos do hub

```
lib/core/economy/
lib/core/theme/game_card_art.dart
lib/core/theme/hub_theme.dart
lib/features/home/widgets/hub_header.dart
lib/features/home/widgets/game_card.dart
lib/features/home/widgets/daily_reward_banner.dart
lib/features/home/home_screen.dart
lib/features/profile/profile_screen.dart
lib/features/leaderboard/leaderboard_screen.dart
```

---

## Ranking local

Melhor score **por jogo** (`LeaderboardRepository.allBest`), persistido em `shared_preferences`.

### Comportamento

- `GameRunnerScreen` chama `submitScore` ao fim da partida.
- `LeaderboardRepository` é `ChangeNotifier` — `submitScore` chama `refresh()` e notifica ouvintes.
- Aba Ranking usa `context.watch<LeaderboardRepository>()` + reload ao ativar aba (`isActive`).
- Lista ordenada **por título do jogo** (não ranking global cross-game); sem medalhas 🥇🥈🥉 enganosas.
- Pull-to-refresh disponível.
- Regras de pontuação **não** aparecem na lista — só no modal **?** da prep.
- Cada linha usa `GameCatalogThumbnail` (mesma arte do catálogo) + `HubTheme.themeFor()` — alinhado visualmente à Home.
- Estado vazio: `GameCatalogThumbnail` com tema hub (`removeAdsPurple` + `coinGold`), não ícone Material.

### Pontuação — Memória (`memory_config.dart`)

| Componente | Valor |
|---|---|
| Base | 150 pts / par |
| Penalidade | −10 pts / jogada |
| Bônus tempo | até 200 pts (decai 4 pts/s) |
| Partida perfeita | +100 pts (mínimo de jogadas) |

Grid adapta ao nº de pares (4 → 4×2, 6 → 4×3, 8 → 4×4). HUD exibe pares, timer, jogadas e preview do bônus tempo (`memoryTimeBonusRemaining`). Label flutuante no acerto usa delta líquido (`memoryProgressScoreDelta`), não `+150` fixo.

### Pontuação — Corrida Infinita (`infinite_runner_config.dart`)

| Componente | Valor |
|---|---|
| Tempo | +10 pts/s (contínuo no placar ao vivo) |
| Obstáculo | +30 pts cada (ultrapassado) |

Label ao passar obstáculo = delta real desde último placar (`infiniteRunnerObstaclePassDelta`), pois tempo e obstáculo somam juntos.

### Pontuação — Tap Rush (`tap_rush_config.dart`)

| Componente | Valor |
|---|---|
| Base | 10 pts / acerto × combo (até ×5) |
| Dificuldade | alvo menor e lifetime menor conforme `progress` |
| HUD | barra de tempo restante + combo |

---

## Golden tests (revisão visual por agentes)

Agentes **não veem** o Chrome do usuário em tempo real. Para revisar layout/cores da Home sem print manual:

| Arquivo | Conteúdo |
|---|---|
| `test/golden/home_screen_golden_test.dart` | Captura `MainShell` (aba Jogos) |
| `test/goldens/home_mobile.png` | Viewport **390×844** (mobile) |
| `test/goldens/home_tablet.png` | Viewport **768×1024** (tablet) |
| `test/helpers/test_app.dart` | Providers + registry para testes |
| `test/helpers/load_test_fonts.dart` | Roboto + Material Icons (evita texto em blocos) |

**Fluxo do agente:**

1. Rodar `flutter test test/golden/` (ou `flutter test` completo).
2. Ler os PNGs em `test/goldens/` com a ferramenta de leitura de imagem.
3. Se a UI mudou de propósito: `flutter test test/golden/ --update-goldens` e commitar os PNGs.

**Limitações:**

- Renderer de **teste** Flutter, não Chrome pixel a pixel — suficiente para layout, cores e cards.
- Emojis no `_MemoryArt` podem variar entre Linux/macOS; CI roda Ubuntu — gerar goldens no Linux ou no CI.
- Fontes carregadas de `$FLUTTER_ROOT/bin/cache/artifacts/material_fonts` (ou `~/flutter/...`).

**Quando adicionar golden:** após mudanças visuais na Home, shell ou cards. Não é obrigatório por jogo individual (só catálogo por enquanto).

---

Todo jogo implementa `HubGame`:

- `GameMetadata metadata` — id, título, categoria, ícone
- `GamePrepDefinition? prep` — tela intermediária (opções + ajuda); `null` se não aplicável
- `Widget buildGame(BuildContext, GameSessionCallbacks, {GameSessionConfig config})` — UI do jogo

Callbacks que o jogo **deve** usar:

| Callback | Quando |
|---|---|
| `onScoreUpdate(int)` | Durante a partida (score de **ranking**) |
| `onGameOver(GameResult)` | Fim da partida — incluir `metadata['performanceTier']` |
| `onRewardEarned(type, amount)` | Recompensa mid-game (ex.: ad) — reservado |
| `onExit()` | Jogador desiste |
| `trySpendCoins(amount)` | Gasto mid-game (dicas Sudoku/Paciência) — retorna `false` se saldo insuficiente |
| `currentCoins()` | Saldo atual para habilitar botões pagos no HUD |

**Importante:** o `GameRunnerScreen` resolve moedas/XP via `resolveSessionReward()` **antes** de `recordGameSession`. O jogo **uma única vez** — placar usa `ValueNotifier`; **nunca** `setState` no pai que recria o `GameWidget`.

Registrar em `registerBundledGames()` (`lib/bootstrap/games.dart`).

---

## Economia do jogador

### Separação score vs. recompensa

| Sistema | Fonte | Uso |
|---|---|---|
| **Score** | Regras do jogo em `*_config.dart` | Ranking local (`LeaderboardRepository`) |
| **Moedas / XP** | `core/economy/session_rewards.dart` | Perfil, dicas, level up |

Cada jogo define `*PerformanceTier()` em `*_config.dart` e grava `performanceTier` no `GameResult.metadata`. O `GameRunnerScreen` combina tier + recorde + primeira partida do dia.

### Régua de desempenho (tier) — regra única

**Problema que ela resolve:** moeda/XP são pagos **por faixa** (bronze/prata/ouro), não pelo score bruto — então o score de cada jogo pode ter a escala que quiser. Mas se cada jogo decidir "o que é ouro" com números mágicos próprios, "ouro" custa esforços muito diferentes (ex.: vencer no Dominó vs. zerar o Sudoku sem erro) e o jogador farma o jogo de ouro mais barato.

**Regra:** todo jogo converte a partida num **desempenho normalizado `[0,1]`** (`*PerformanceRatio(...)`, `1.0` = partida excelente/ótima) e delega a faixa a `tierFromRatio()` em `core/economy/performance_tier.dart`. Cortes **iguais para todos**:

| Faixa | Desempenho | Calibração-alvo |
|---|---|---|
| Ouro | `>= 0.85` (`TierRubric.goldRatio`) | ~top 10–15% das partidas |
| Prata | `>= 0.55` (`TierRubric.silverRatio`) | ~os 30% seguintes |
| Bronze | resto | baseline (jogou/terminou) |

Assim "ouro" significa o **mesmo nível de excelência** em todos os jogos; calibrar é só mexer no alvo de cada jogo (ratio `1.0`), nunca nos cortes.

| Jogo | Como o ratio é computado (alvo `1.0`) |
|---|---|
| Memória | eficiência de jogadas (perfeito = `1.0`; cai até `pares × 2.5` jogadas) |
| Tap Rush | `score / tapRushGoldScore` (470) |
| 2048 | escala **log2** da maior peça (`64` → `0`, `1024` → `1.0`) |
| Cobra | vencer = `1.0`; senão `comprimento / 21` |
| Corrida | melhor entre `dist/235` e `obstáculos/17` |
| Sudoku | derrota = `0`; vitória parte de `0.65`, impecável (0 erro/dica) = `0.85`; erro `−0.05`, dica `−0.07` |
| Paciência | vencer = `1.0`; derrota gradua por fundações (`/47`, teto `0.84`) |
| Dominó | vitória `>= 0.85` (margem reforça); derrota gradua por pips na mão (teto `0.84`) |

**Ao adicionar jogo novo:** exponha `*PerformanceRatio(...)` (testável, sem Flame), faça `*PerformanceTier(...) => tierFromRatio(ratio)`, e calibre o alvo `1.0` para uma partida realmente excelente daquele jogo. Jogos de vitória/derrota: vencer não é automaticamente ouro nem derrota é automaticamente bronze — gradue por margem/qualidade/progresso. Cubra os limiares em `test/games/<jogo>_config_test.dart`.

### `PlayerRepository`

| Método / getter | Uso |
|---|---|
| `recordGameSession(coins, xp)` | Fim de partida — moedas, XP, `gamesPlayed`, bônus de level up |
| `addBonusCoins(amount)` | Anúncio “dobrar moedas” — **não** conta partida |
| `trySpendCoins(amount)` | Dicas pagas mid-game — **não** conta partida |
| `claimDailyReward()` | Banner de recompensa diária |
| `isFirstGameToday` | Bônus de XP na primeira partida do dia civil |
| `dailyRewardAmount` / `nextDailyStreak` | Preview no banner |

Saldo inicial: **`EconomyConfig.startingCoins` (50)** — perfis sem partidas com menos moedas recebem no `load()`.

### Constantes (`EconomyConfig`)

| Item | Valor |
|---|---|
| Moedas por partida | 8 base + bônus tier (+4 prata, +8 ouro) + 10 recorde — **cap 20** |
| XP por partida | 20 base + bônus tier (+5/+10) + 15 recorde + 10 1ª do dia — **cap 45** |
| Daily | 15 + 3 × streak (cap 30 dias → 105 moedas) |
| Dica Sudoku | 25 moedas (`sudokuHintPaid` — sem penalidade de score) |
| Dica Paciência | 20 moedas (destaca jogada válida) |
| Level up | +`(10 + nível)` moedas por nível ganho |

Curva de nível: `level_curve.dart` — quadrática (`nível 2` = 100 XP total).

### UI da economia

| Onde | O quê |
|---|---|
| Header | Pill de nível (anel) + pill de moedas |
| Perfil | Hero com barra XP, card “Moedas e XP”, tile XP total, **?** → `showEconomyHelpDialog` |
| Placar final | Colunas moedas + “XP nível”; banner “Nível up!” com moedas bônus |
| HUD dica | `GameSessionHudAction.coinCost` — ícone + número em dourado |

Textos PT-BR centralizados em `economy_copy.dart`.

Persistência defensiva: JSON inválido em `load()` cai para perfil default (não derruba o app).

---

## Testes

`GameRegistry.instance.resetForTesting()` em `setUp`/`tearDown` — evita vazamento entre arquivos.
`test/helpers/test_app.dart` centraliza providers + `registerBundledGames()`.

**Jogos Flame:** todo jogo com scoring não-trivial deve ter `test/games/<jogo>_config_test.dart` (scoring, tiers, helpers do HUD). Economia global: `test/core/session_rewards_test.dart`, `level_curve_test.dart`, `economy_copy_test.dart`. Goldens ficam no hub (`test/golden/`).

## Convenções de código

1. **Escopo mínimo** — só o necessário para a tarefa/fase atual.
2. **Seguir padrões existentes** — nomes, pastas, imports relativos a `lib/`.
3. **Stub first** — Firebase e AdMob funcionam em modo offline até o usuário configurar (`kFirebaseConfigured`, `kAdsConfigured`).
4. **Persistência local no MVP** — ranking e perfil em `shared_preferences`; migrar para Firestore na Fase 2+.
5. **Testes** — unit/widget/golden; rodar `flutter test` antes de encerrar tarefa. Jogo Flame novo: incluir `test/games/*_config_test.dart`. Após mudar UI do hub: `--update-goldens`.
6. **Idioma UI** — PT-BR para strings visíveis ao usuário.
7. **Commits** — só quando o usuário pedir; mensagens em português, foco no *porquê*. Quando o usuário pedir commit, **fazer também `git push`** (o pedido de commit já autoriza o push).

---

## Como rodar

```bash
# Dev rápido (browser)
flutter run -d chrome

# Android (emulador ou celular)
flutter run -d emulator-5554

# Testes e análise (CI faz o mesmo)
flutter analyze && flutter test

# Golden tests da Home (mobile + tablet) — gera PNGs em test/goldens/
flutter test test/golden/ --update-goldens   # após mudar UI
flutter test test/golden/                     # só comparar (ou incluído no flutter test)
```

Variáveis no `~/.bashrc`: `PATH` (Flutter), `ANDROID_HOME`, `JAVA_HOME`.

Emulador recomendado: **Pixel 6a**, API 34, x86_64, **sem** imagem 16KB.

---

## Estado das fases

### Fase 0 — Fundação ✅ (concluída)

- [x] Projeto Flutter + estrutura `core/`, `features/`, `games/`
- [x] Game SDK (`HubGame`, registry, runner)
- [x] Firebase stub
- [x] CI GitHub Actions
- [x] Demo Tap + testes
- [x] Android Studio + emulador configurados

### Fase 1 — MVP Android ✅ (concluída — exceto Play Store)

- [x] Casca: bottom nav (Home, Ranking, Perfil)
- [x] Perfil básico (moedas, XP, nível, partidas, sequência diária)
- [x] Recompensa diária (banner + resgate)
- [x] Ranking local (melhor score por jogo via `shared_preferences`)
- [x] 2 jogos Flame: **Jogo da Memória** + **Tap Rush** (Demo Tap fora do catálogo público)
- [x] Hub visual: grid colorido, `HubTheme`, cards com arte vetorial (`game_card_art.dart`)
- [x] Golden tests da Home (mobile + tablet) — `test/goldens/*.png`
- [x] AdMob stub (`kAdsConfigured = false`; ID de teste no AndroidManifest)
- [x] Game Runner integrado com economia (moedas/XP ao terminar + opção “dobrar moedas”)
- [x] Testes: widget + unit + golden + repos + runner (ver CI; `memory_config_test` expandido pós-polish)
- [x] Tela de prep (dificuldade + ajuda) — Memória (cartas) e Tap Rush (tempo)
- [x] Ranking estilizado + refresh ao abrir aba
- [x] Regras de pontuação da Memória em `memory_config.dart`
- [ ] Beta fechado Play Store — **ação manual do usuário**

**Decisões Fase 1:** Provider + `shared_preferences` para perfil/ranking local; Flame para jogos; ads/Firebase permanecem stub até credenciais reais. Pós-F1: prep screen, `GameCatalogHero` compartilhado, ranking reativo. Pós-review: bootstrap em `lib/bootstrap/`, economia separada (`recordGameSession` vs `addBonusCoins`), Perfil alinhado ao hub, Memory com `components/`, persistência defensiva.

### Pós-F1 — Hardening ✅ (review de código)

- [x] `recordGameSession` / `addBonusCoins` — “dobrar moedas” não infla `gamesPlayed`
- [x] try/catch em `PlayerRepository.load` e `LeaderboardRepository.getEntries`
- [x] Botão “Dobrar moedas” com loading/disabled durante anúncio
- [x] Ranking sem medalhas cross-game; ordenação por título
- [x] `LeaderboardRepository` reativo (`ChangeNotifier`)
- [x] `registerBundledGames()` em `lib/bootstrap/games.dart`
- [x] `GameRegistry.resetForTesting()`
- [x] Perfil com `HubTheme.background` (sem Scaffold aninhado)
- [x] Memory: `components/memory_card.dart` + guarda `_sessionActive` pós-dispose
- [x] Memory: `_symbols` no construtor — evita crash `LateInitializationError` se `onGameResize` roda antes de `onLoad`
- [x] `GameResultDialog`: stats da Memória + scroll em telas baixas
- [x] Testes: `leaderboard_repository_test`, `game_runner_screen_test`, repos expandidos
- [x] Removidos PNGs órfãos em `assets/games/` (arte = CustomPaint)
- [x] Identidade visual unificada: `GameCatalogThumbnail` no ranking + tokens `HubTheme` (`textPrimary`, `textSecondary`, `featuredBadge`)
- [x] Arte vetorial deriva cores de `HubGameTheme` (`blendColor`, `accentSoft`); goldens da Home atualizados
- [x] Memória — polish completo: identidade hub in-game, flip/FX, HUD (pares/tempo/jogadas/bônus)

### Fase 2 — Lançamento Android ⏳

Ver `PLANO.md`.

- [x] Rebrand **MiniPlay**: nome na UI, `applicationId`/`bundleId` `com.miniplay.games`, ícones Android/iOS/web
- [x] Catálogo expandido: **2048**, **Runner**, **Paciência**, **Snake**, **Dominó**, **Sudoku** (8 jogos públicos)
- [x] Economia centralizada (`core/economy/`) — moedas/XP desacoplados do score; nível no header; dicas pagas; moedas iniciais
- [ ] Conquistas, missões diárias
- [ ] Mais sinks de moedas (continue Runner/Snake, cosméticos)
- [ ] IAP (remover ads + moedas), FCM, Remote Config
- [ ] ASO completo e lançamento público Play Store

### Fase 3 — iOS ⏳

Ver `PLANO.md`.

### Fase 4 — Crescimento ⏳

Ver `PLANO.md`.

---

## Dívidas técnicas conhecidas

- Firebase não configurado — auth/ranking na nuvem pendente.
- AdMob não configurado — IDs de teste prontos para quando ativar.
- Memória: countdown / modo “Memorizar” na prep — opcional; restante do polish concluído.
- Tap Rush ainda pode receber alinhamento de paleta ao hub (`HubTheme`).
- `GameRunnerScreen` ainda acopla ads/economia — extrair `SessionResultHandler` na Fase 2.
- `onRewardEarned` nos callbacks ainda sem uso real.
- Sinks de moedas: só Sudoku + Paciência; faltam continue (Runner/Snake), Memória, cosméticos.
- Header mobile 390px: botão ads só ícone — texto “REMOVER ADS” removido por espaço; restaurar em tablet se desejado.
- Emulador ainda pode usar imagem API 37 16KB — trocar para API 34 se travar.
- KVM: usuário pode precisar de `sudo usermod -aG kvm $USER` + relogin.

---

## Decisões de arquitetura (registro)

| Data | Decisão | Motivo |
|---|---|---|
| Fase 0 | Game SDK com interface `HubGame` | Hub trata todos os jogos uniformemente |
| Fase 0 | Firebase/AdMob em stub | Dev local sem credenciais |
| Fase 1 | Provider + shared_preferences | Simples, sem backend, ideal para MVP |
| Fase 1 | Ranking local por jogo | Firestore na Fase 2 |
| Fase 1 | AdMob com stub + ID teste no manifest | Ativar `kAdsConfigured` quando tiver conta |
| Fase 1 | GameRunner cacheia GameWidget + ValueNotifier no placar | Evita reset do Flame a cada ponto |
| Pós-F1 | Hub grid 2 colunas + HubTheme | Referência visual de app casual; Tap Rush = ref. gameplay |
| Pós-F1 | Arte de card em CustomPaint (não PNG IA) | PNG com checkerboard/`contain` quebrava layout |
| Pós-F1 | Golden tests Home (390×844, 768×1024) | Agentes revisam UI lendo `test/goldens/*.png` |
| Pós-F1 | `GamePrepScreen` + `GameSessionConfig` | Dificuldade/tempo antes da partida; ajuda no modal ? |
| Pós-F1 | `GameCatalogHero` em `core/theme/game_card_art.dart` | Mesma arte no catálogo e na prep |
| Pós-F1 | Ranking reload na aba (`isActive`) | IndexedStack não remonta filhos ao voltar do jogo |
| Pós-F1 | Scoring Memória em `memory_config.dart` | Testável sem Flame; prep explica regras |
| Pós-review | `recordGameSession` vs `addBonusCoins` | Rewarded ad não conta como segunda partida |
| Pós-review | Persistência defensiva (try/catch JSON) | App sobrevive a prefs corrompidos |
| Pós-review | `lib/bootstrap/games.dart` | Registro de jogos fora da feature Home |
| Pós-review | `LeaderboardRepository` reativo | Ranking atualiza via `watch` + `refresh` |
| Pós-review | Ranking por jogo sem medalhas globais | UX alinhada ao subtítulo “melhor por jogo” |
| Pós-review | `AppTheme` usa `HubTheme.background` | Uma fonte para cor creme do hub |
| Pós-review | `GameCatalogThumbnail` + tokens de texto no hub | Ranking e Home com mesma arte; sem hex solto na UI |
| Pós-review | `GameCatalogThumbnail` = `GameCatalogHero` escalado | Mesmo card da Home em AppBar, ranking, placar e ajuda; sem arte duplicada |
| Fase 2 | App **MiniPlay**, ID `com.miniplay.games` | Nome comercial e ASO; pacote Dart `minigames_hub` intacto |
| Fase 2 | Memória: estado do grid no construtor | `onGameResize` pode preceder `onLoad` no Flame |
| Pós-polish | Barra de qualidade Flame = Tap Rush + Memória | Novos jogos com identidade hub, HUD, FX e scoring testável |
| Pós-polish | Paleta in-game em `*_config.dart` espelha `HubTheme` | Catálogo e partida visualmente coerentes |
| Pós-polish | `GameSessionAppBar` + `GameResultDialog` com `GameCatalogThumbnail` | Mesma arte vetorial do catálogo; sem emoji solto na sessão de jogo |
| Pós-polish | HUD in-game obrigatório | Jogador vê regras de score ao vivo; AppBar não basta |
| Pós-polish | FX mínimo acerto/erro + animações no `update(dt)` | Evita sensação de protótipo |
| Pós-polish | Label flutuante = delta do placar | Evita `+150`/`+30` fixo com placar líquido/multi-componente; helpers em `*_config.dart` |
| Fase 2 econ. | `core/economy/` — score ≠ moedas/XP | Ranking e progressão com regras distintas |
| Fase 2 econ. | `performanceTier` por jogo em `*_config.dart` | Recompensa testável e consistente entre jogos |
| Fase 2 econ. | `HubTheme.coinIcon` / `levelIcon` | Ícones únicos de moeda e XP em todo o hub |
| Fase 2 econ. | Dicas pagas via `trySpendCoins` + `coinCost` no HUD | Primeiro sink de moedas com custo visível no botão |
| Fase 2 econ. | `showEconomyHelpDialog` no Perfil | Jogador entende loop moedas → XP → nível |
