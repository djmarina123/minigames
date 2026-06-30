# Design do Hub

Grid **2 colunas**, fundo creme, app bar colapsável. Visual **moderno, premium, casual** — foco na ilustração de cada jogo.

## Layout

| Zona | Regra |
|---|---|
| Fundo grid | `#F5F0E8` (`HubTheme.background`) |
| App bar | `#FAF8FF` (`HubTheme.appBarBackground`) — lavanda suave |
| Header | `MiniPlayAppBar` (menu · logo · chips · ações) |
| Grid | 2 cols, `childAspectRatio: 0.85`, spacing 16, padding 16 |
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
- Animação de bump ao atualizar nível/moedas

### Botões de ação (`TopActionButton`)

| Botão | Tratamento |
|---|---|
| Daily | Simples; badge vermelho se recompensa disponível |
| Missions | Label `hubActionGoals` → "Missions" / "Missões" |
| Remove Ads | Fundo `removeAdsGoldBg`, borda dourada, ícone 28 px, brilho suave |

## Card (`GameCard`)

### Forma (v2 — sem alterar tamanho do grid)

- Gradiente diagonal + **fundo exclusivo por jogo** (`_GameCardBackdropPainter`)
- Radius 24 px · sombra `cardShadow()` (~40% mais leve que v1)
- Padding `cardPadding` = 20 px

### Hierarquia

1. Ilustração (protagonista)
2. Nome do jogo (secundário, 16 px)
3. Favorito discreto (26 px, fundo 12% opacidade)

### Fundos por jogo (baixa opacidade)

| `gameId` | Padrão |
|---|---|
| `memory` | Retângulos arredondados |
| `tap_rush` | Círculos |
| `game_2048` / `color_blocks` | Quadrados |
| `snake` | Ondas orgânicas |
| `infinite_runner` | Linhas horizontais |
| `sudoku` / `cross_sums` / `minesweeper` | Grade fina |
| `solitaire` | Losangos |

### Favorito (`FavoriteButton`)

- 26 px · translúcido · animação scale + fade ao favoritar
- Não competir com título nem ilustração

### Microinterações

- Card: `AnimatedScale(0.98)` + ripple
- Entrada: fade + slide
- Favorito: scale elástico leve

**Evitar:** sombras pesadas, emoji como capa, ruído no fundo.

### Ilustração por jogo (`GameCardArt`)

Cada jogo = pôster reconhecível — elemento principal **grande**, sem sparkles no painter:

| `gameId` | Foco |
|---|---|
| `memory` | Cartas grandes sobrepostas |
| `tap_rush` | Círculos concêntricos + toque |
| `game_2048` | Blocos 2×2 grandes |
| `infinite_runner` | Corredor + chão + obstáculos |
| `solitaire` | Cartas inclinadas |
| `snake` | Cobra expandida |
| `sudoku` | Grade 3×3 protagonista |
| `cross_sums` | Números grandes em grade |
| `color_blocks` | Blocos coloridos |
| `minesweeper` | Grade de células |

## Componentes

| Widget | Arquivo | Uso |
|---|---|---|
| `GameCard` | `features/home/widgets/game_card.dart` | Grid do catálogo |
| `FavoriteButton` | `features/home/widgets/favorite_button.dart` | Estrela 26 px (discreta) |
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

`appBarBackground` (`#FAF8FF`), `chipRadius`, `chipShadow()`, `removeAdsGoldBg`, `cardShadow()` (elevação mínima), `cardPadding`, demais tokens por jogo.

## Bottom navigation

`NavigationBar` com indicador pill roxo (`removeAdsPurple` 22%), ícone/label **bold** no item ativo, fundo alinhado à app bar.

## Arquivos principais

`hub_theme.dart`, `hub_card_widgets.dart`, `game_card_art.dart`, `mini_play_app_bar.dart`, `game_card.dart`, `favorite_button.dart`, `home_screen.dart`, `leaderboard_screen.dart`, `profile_screen.dart`, `settings_panel.dart`.

## Novo jogo no catálogo

1. Entrada em `HubTheme._themes` com `cardColor` + `accentColor` únicos.
2. Case em `GameCardArt` + painter em `game_card_art.dart` — ilustração grande, sem ruído de fundo.
3. Registrar em `registerBundledGames()`.
