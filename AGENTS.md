# AGENTS.md — Minigames Hub

> Guia para agentes de IA (Cursor, etc.) que trabalham neste repositório.
> **Leia este arquivo antes de implementar qualquer feature.**

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

Hub de **minijogos casuais** para mobile. Android primeiro, iOS depois.
Sessões curtas (1–5 min), moeda virtual, rankings, recompensa diária, ads.

Documento mestre de produto e roadmap: [`PLANO.md`](PLANO.md).

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
│   ├── firebase/             # bootstrap stub
│   ├── ads/                  # AdMob stub (Fase 1+)
│   ├── game_sdk/             # HubGame, registry, prep, runner, widgets
│   │   ├── game_prep.dart
│   │   ├── game_prep_screen.dart
│   │   ├── game_session_config.dart
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
    ├── memory/               # Flame — pares
    │   ├── memory_config.dart
    │   ├── memory_game.dart
    │   └── components/       # memory_card.dart
    └── tap_rush/             # ⭐ Referência Flame (copiar estrutura)
        ├── tap_rush_game.dart
        ├── tap_rush_config.dart
        └── components/

test/
├── golden/                   # golden tests (Home mobile + tablet)
├── goldens/                  # PNGs de referência — commitar no git
├── helpers/                  # test_app.dart, mock_game.dart, load_test_fonts.dart
├── games/                    # testes de scoring/config
└── core/                     # registry, player/leaderboard repos, game_runner
```

---

## Jogo referência: Tap Rush

**Copie `lib/games/tap_rush/` como template** ao criar jogos Flame novos.

| Arquivo | Responsabilidade |
|---|---|
| `*_game.dart` | Só `HubGame` + `GameWidget` |
| `*_config.dart` | Duração, cores, scoring (testável sem Flame) |
| `components/` | Componentes reutilizáveis (alvo, HUD, FX) |
| `*_flame_game.dart` | Loop `update`/`render`, fases, callbacks (pode ficar no mesmo `*_game.dart` que Tap Rush) |

**Padrões obrigatórios (Tap Rush):**

1. **Fases** — countdown → playing → finished (nunca iniciar no `onGameResize` sem flag `_sessionStarted`).
2. **Timer no `update(dt)`** — não usar `Timer.periodic` para gameplay (HUD fica suave).
3. **Dificuldade progressiva** — funções puras em `*_config.dart` (`progress → radius/lifetime`).
4. **Combo / feedback** — labels flutuantes + flash visual em erro.
5. **Score via callback** — `onScoreUpdate(total)`; **não** forçar rebuild do `GameWidget`.
6. **GameResult** — incluir `metadata` útil (hits, misses, maxCombo).
7. **Testes** — scoring e curva de dificuldade em `test/games/`.
8. **UI compartilhada** — AppBar e placar final em `core/game_sdk/widgets/` (`GameSessionAppBar`, `GameResultDialog`); não duplicar por jogo.
9. **Tela de preparação** — opções de dificuldade + ajuda via `GamePrepDefinition` (ver seção abaixo).

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
| **Header** | Menu (drawer) · pill de moedas · botão "REMOVER ADS" |
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
| `GameCardArt` | Ilustração vetorial full-bleed; `compact: true` omite bolhas/sparkles (listas) |
| `GameCatalogHero` | Banner do catálogo e da prep (título + linha + arte) |
| `GameCatalogThumbnail` | Miniatura quadrada (~52px) — **ranking**, estados vazios |

**Regra:** face visual do jogo no hub = `gameId` + `HubTheme.themeFor()` → **nunca** `metadata.icon` em UI (emoji fica só para fallback genérico / uso interno).

Ao adicionar jogo: implementar painter em `GameCardArt`; catálogo, prep e ranking passam a herdar automaticamente via `GameCatalogHero` / `GameCatalogThumbnail`.

### Tokens de cor (`hub_theme.dart`)

| Token | Uso |
|---|---|
| `background` | Fundo creme do hub |
| `textPrimary` / `textSecondary` | Títulos e corpo (header, ranking, perfil, prep, ajuda) |
| `featuredBadge` | Badge "NOVO!" nos cards |
| `cardColor` + `accentColor` | Por jogo em `HubTheme._themes` |
| `blendColor` / `accentSoft` | Derivados em `HubGameTheme` — detalhes da arte vetorial |
| `hubUnderlineWidth(titleLead)` | Largura da barra decorativa (proporcional à 1ª palavra do título) |

**Não** usar `Color(0xFF2D3436)` etc. solto — sempre `HubTheme.textPrimary` / `textSecondary`.

### Header (`HubHeader`)

- Moedas vêm de `PlayerRepository.profile.coins` (Provider).
- Botão ads: stub até IAP Fase 2; nunca bloquear navegação.
- Recompensa diária: banner compacto abaixo do header (`DailyRewardBanner`), não `MaterialBanner` full-width.

### Ao adicionar jogo novo

1. Registrar em `registerBundledGames()` (`lib/bootstrap/games.dart`).
2. Adicionar entrada em `HubTheme._themes` com `cardColor` + `accentColor`.
3. Implementar arte em `core/theme/game_card_art.dart` (CustomPaint) — ver jogos existentes.
4. Escolher emoji em `metadata.icon` apenas para fallback — UI usa `GameCardArt` por `gameId`.

### Arquivos do hub

```
lib/core/theme/game_card_art.dart
lib/core/theme/hub_theme.dart
lib/features/home/widgets/hub_header.dart
lib/features/home/widgets/game_card.dart
lib/features/home/widgets/daily_reward_banner.dart
lib/features/home/home_screen.dart
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

Grid adapta ao nº de pares (4 → 4×2, 6 → 4×3, 8 → 4×4).

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
| `onScoreUpdate(int)` | Durante a partida |
| `onGameOver(GameResult)` | Fim da partida (score, moedas, xp) |
| `onRewardEarned(type, amount)` | Recompensa mid-game (ex.: ad) |
| `onExit()` | Jogador desiste |

**Importante:** o `GameRunnerScreen` instancia o jogo **uma única vez**. Atualizar placar usa `ValueNotifier` — **nunca** `setState` no widget pai que recria o `GameWidget`, senão Flame reseta (timer volta a 15 s, memória embaralha de novo).

Registrar em `registerBundledGames()` (`lib/bootstrap/games.dart`).

---

## Economia do jogador (`PlayerRepository`)

| Método | Uso |
|---|---|
| `recordGameSession(coins, xp)` | Fim de partida — incrementa moedas, XP **e** `gamesPlayed` |
| `addBonusCoins(amount)` | Anúncio rewarded, bônus mid-game — **não** conta partida |
| `claimDailyReward()` | Banner de recompensa diária |

`GameRunnerScreen` usa `recordGameSession` no `onGameOver` e `addBonusCoins` no fluxo “Dobrar moedas”.

Persistência defensiva: JSON inválido em `load()` cai para perfil default (não derruba o app).

---

## Testes

`GameRegistry.instance.resetForTesting()` em `setUp`/`tearDown` — evita vazamento entre arquivos.
`test/helpers/test_app.dart` centraliza providers + `registerBundledGames()`.

---

## Convenções de código

1. **Escopo mínimo** — só o necessário para a tarefa/fase atual.
2. **Seguir padrões existentes** — nomes, pastas, imports relativos a `lib/`.
3. **Stub first** — Firebase e AdMob funcionam em modo offline até o usuário configurar (`kFirebaseConfigured`, `kAdsConfigured`).
4. **Persistência local no MVP** — ranking e perfil em `shared_preferences`; migrar para Firestore na Fase 2+.
5. **Testes** — unit/widget/golden; rodar `flutter test` antes de encerrar tarefa. Após mudar UI do hub: `--update-goldens`.
6. **Idioma UI** — PT-BR para strings visíveis ao usuário.
7. **Commits** — só quando o usuário pedir; mensagens em português, foco no *porquê*.

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
- [x] Testes: **24** passando (widget + unit + golden + repos + runner)
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
- [x] `GameResultDialog`: stats da Memória + scroll em telas baixas
- [x] Testes: `leaderboard_repository_test`, `game_runner_screen_test`, repos expandidos
- [x] Removidos PNGs órfãos em `assets/games/` (arte = CustomPaint)
- [x] Identidade visual unificada: `GameCatalogThumbnail` no ranking + tokens `HubTheme` (`textPrimary`, `textSecondary`, `featuredBadge`)
- [x] Arte vetorial deriva cores de `HubGameTheme` (`blendColor`, `accentSoft`); goldens da Home atualizados

### Fase 2 — Lançamento Android ⏳

Ver `PLANO.md`.

### Fase 3 — iOS ⏳

Ver `PLANO.md`.

### Fase 4 — Crescimento ⏳

Ver `PLANO.md`.

---

## Dívidas técnicas conhecidas

- Firebase não configurado — auth/ranking na nuvem pendente.
- AdMob não configurado — IDs de teste prontos para quando ativar.
- Memória: polir flip animado e FX (Tap Rush já é referência); fase countdown opcional.
- `GameRunnerScreen` ainda acopla ads/economia — extrair `SessionResultHandler` na Fase 2.
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
| Pós-review | `GameCardArt(compact: true)` para listas | Thumbnail legível sem duplicar painters |
