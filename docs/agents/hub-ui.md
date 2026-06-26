# Design do Hub

Grid **2 colunas**, fundo creme, header minimalista.

## Layout

| Zona | Regra |
|---|---|
| Fundo | `#F5F0E8` (`HubTheme.background`) |
| Header | Drawer · pill nível · pill moedas · ícone remover ads |
| Grid | 2 cols, `childAspectRatio: 0.92`, spacing 14, padding 16; favoritos no topo |
| Nav | Bottom nav (Jogos / Ranking / Perfil) + drawer |

## Favoritos

Estrela no card → jogo sobe ao **topo** na ordem marcada. Demais: `GameRegistry.enabledInCatalogOrder`.

- Persistência: `PlayerProfile.favoriteGameIds`
- API: `PlayerRepository.toggleFavorite`, `sortGamesByFavorites()`
- Toque na estrela **não** abre o jogo
- Independente da badge "NOVO!"

## Card (`GameCard`)

1. Cantos 22 px, borda branca 4 px, `cardColor` por jogo.
2. Título CAIXA ALTA, bold, branco; vinheta ~64 px.
3. Linha decorativa (`accentColor`, largura `hubUnderlineWidth`).
4. Ilustração **vetorial** full-bleed (`GameCardArt` / `GameCatalogHero`) — não PNG pequeno em `contain`.
5. Badge "NOVO!" — últimos `HubCatalogConfig.featuredNewGameCount` (3) jogos habilitados.
6. Estrela favorito (`HubTheme.coinGold` quando ativo).
7. `AnimatedScale(0.96)` no toque.

**Evitar:** PNG com checkerboard falso, emoji como capa, hex solto na pintura.

## Widgets compartilhados (`game_card_art.dart`)

| Widget | Uso |
|---|---|
| `GameCatalogHero` | Catálogo + prep |
| `GameCatalogThumbnail` | Ranking, AppBar, placar, ajuda **?** |

**Regra:** UI visível usa `gameId` + `HubTheme.themeFor()` — nunca `metadata.icon`.

## Tokens (`hub_theme.dart`)

`background`, `textPrimary`/`textSecondary`, `featuredBadge`, `coinGold`, `coinIcon`, `levelIcon`, `levelPillBg`, `cardColor`/`accentColor` por jogo, `blendColor`/`accentSoft`.

## Header

- Nível: anel XP → toque abre Perfil.
- Moedas: `PlayerRepository.profile.coins`.
- Remover ads: stub (não bloquear navegação).
- `DailyRewardBanner` compacto abaixo do header.

## Arquivos principais

`hub_theme.dart`, `game_card_art.dart`, `hub_header.dart`, `game_card.dart`, `daily_reward_banner.dart`, `home_screen.dart`, `leaderboard_screen.dart`, `profile_screen.dart`.
