# Design do Hub

Grid **2 colunas**, fundo creme, app bar colapsável. Visual **moderno, premium, casual** — foco na ilustração de cada jogo (pôster reconhecível por `gameId`).

## Layout

| Zona | Regra |
|---|---|
| Fundo grid | `#F5F0E8` (`HubTheme.background`) |
| App bar | `#FAF8FF` (`HubTheme.appBarBackground`) — lavanda suave |
| Header | `MiniPlayAppBar` (menu · logo · chips · ações) |
| Grid | 2 cols, `childAspectRatio: 0.85`, spacing 16, padding 16 · `RepaintBoundary` por card |
| Nav | Bottom nav com indicador pill roxo + labels sempre visíveis |

### Futuro (fora do escopo atual)

Hero Card · categorias (chips) · busca.

## App bar (`MiniPlayAppBar`)

| Linha | Conteúdo |
|---|---|
| 1 | Menu (48×48, margem esq. 12) · logo · MiniPlay |
| 2 | Chips **nível** e **moedas** — valor em destaque, rótulo secundário UPPERCASE |
| 3 | Daily · **Missions** · Remove Ads (colapsa ao rolar) |

### Chips do jogador (`PlayerStatChip`)

- Radius `HubTheme.chipRadius` (22 px), `HubTheme.chipShadow()`
- Hierarquia: ícone + rótulo pequeno → **valor grande** (22 px bold)
- Altura ~10% mais compacta que v2 (padding vertical reduzido)
- Animação de bump ao atualizar nível/moedas

### Botões de ação (`TopActionButton`)

| Botão | Tratamento |
|---|---|
| Daily | Simples; badge vermelho se recompensa disponível |
| Missions | Label `hubActionGoals` → "Missions" / "Missões" |
| Remove Ads | Fundo dourado quente (`#FFF3D6`), borda `#E8B84A`, ícone 28 px, brilho radial interno discreto |

## Card (`GameCard`)

### Forma (v3 — sem alterar tamanho do grid)

- Gradiente diagonal + **fundo exclusivo por jogo** (`_GameCardBackdropPainter`, opacidade máx. **10%**)
- Radius **30 px** · sombra `cardShadow()` (~35% mais leve que v2)
- Padding `cardPadding` = **22 px**

### Hierarquia

1. Ilustração (protagonista, ~60–70% da área útil)
2. Nome do jogo (secundário, 16 px, **uma linha** com `FittedBox` antes de quebrar)
3. Favorito discreto (21 px, glass)

### Fundos por jogo (baixa opacidade + decoração)

| `gameId` | Padrão | Decoração extra |
|---|---|---|
| `memory` | Retângulos arredondados | Brilhos / estrelas |
| `tap_rush` | Círculos | Anéis de pulso |
| `game_2048` / `color_blocks` | Quadrados | — |
| `snake` | Ondas orgânicas | Folhas discretas |
| `infinite_runner` | Linhas horizontais | — |
| `sudoku` | Grade fina | — |
| `cross_sums` | Grade fina | Operadores `+` `−` |
| `minesweeper` | Grade fina | — |
| `solitaire` | Losangos | — |

### Favorito (`FavoriteButton`)

- **21 px** (`HubTheme.favoriteButtonSize`) · efeito **glass** (`BackdropFilter` + borda translúcida)
- Animação scale elástico leve ao favoritar
- Não competir com título nem ilustração

### Microinterações

- Card: `AnimatedScale(0.97)` + ripple · `HubTheme.interactionDuration` (120 ms)
- Entrada: fade + slide
- Favorito: scale elástico leve

**Evitar:** sombras pesadas, emoji como capa, ruído no fundo.

### Ilustração por jogo (`GameCardArt`)

Cada jogo = pôster com composição **única** — elemento principal grande, flat, poucas cores:

| `gameId` | Foco |
|---|---|
| `memory` | 3 cartas sobrepostas, central maior/parcialmente aberta, ?, ♣, ★ |
| `tap_rush` | Círculo central grande, ondas, partículas, brilho radial |
| `game_2048` | Tabuleiro 2×2 (~70%), blocos com profundidade |
| `infinite_runner` | Personagem grande, chão, cacto, obstáculo, poeira, linhas de velocidade |
| `solitaire` | Mesa: Ás, Rei, cartas viradas inclinadas |
| `snake` | Cobra sinuosa expandida, cabeça em destaque, fruta |
| `sudoku` | Grade **4×4** (~70%), números destacados |
| `cross_sums` | Blocos numéricos + operadores, resultado em destaque |
| `color_blocks` | Blocos coloridos em grade |
| `minesweeper` | Grade de células |

## Componentes

| Widget | Arquivo | Uso |
|---|---|---|
| `GameCard` | `features/home/widgets/game_card.dart` | Grid do catálogo |
| `FavoriteButton` | `features/home/widgets/favorite_button.dart` | Estrela 21 px (glass) |
| `GameCardProgressBar` | `core/theme/hub_card_widgets.dart` | Barra 4 px |
| `GameBadge` | `core/theme/hub_card_widgets.dart` | NEW, Popular, … |
| `GameCatalogHero` | `core/theme/game_card_art.dart` | Layout do card |
| `GameCardArt` | `core/theme/game_card_art.dart` | Ilustração vetorial |
| `GameCatalogThumbnail` | `core/theme/game_card_art.dart` | Ranking, AppBar, placar, ajuda **?** |

**Regra:** UI visível usa `gameId` + `HubTheme.themeFor()` — nunca `metadata.icon`.

Parâmetro opcional `GameCard.progress` (0–1) para ligar barra ao melhor score (`LeaderboardRepository`).

## Favoritos

Estrela no card → jogo sobe ao **topo**. API: `PlayerRepository.toggleFavorite`. Toque na estrela **não** abre o jogo.

## Tokens (`hub_theme.dart`)

`appBarBackground`, `chipRadius`, `chipShadow()`, `removeAdsGoldBg`, `cardRadius` (30), `cardPadding` (22), `cardShadow()`, `interactionDuration` (120 ms), `favoriteButtonSize` (21), `navIconSelectedScale` (1.10), demais tokens por jogo.

## Bottom navigation

`NavigationBar` com indicador pill roxo (`removeAdsPurple` 22%), ícone ativo **110%** (`_NavBarIcon` + `AnimatedScale`), leve elevação no item ativo, label **bold** quando selecionado, fundo alinhado à app bar.

## Arquivos principais

`hub_theme.dart`, `hub_card_widgets.dart`, `game_card_art.dart`, `mini_play_app_bar.dart`, `game_card.dart`, `favorite_button.dart`, `home_screen.dart`, `main_shell.dart`, `leaderboard_screen.dart`, `profile_screen.dart`, `settings_panel.dart`.

## Novo jogo no catálogo

1. Entrada em `HubTheme._themes` com `cardColor` + `accentColor` únicos.
2. Case em `GameCardArt` + painter em `game_card_art.dart` — ilustração grande (~65–70%), composição única; backdrop em `_GameCardBackdropPainter` (opacidade ≤ 10%).
3. Registrar em `registerBundledGames()`.
