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
├── main.dart                 # bootstrap, providers, registerBundledGames()
├── app.dart                  # MaterialApp
├── core/
│   ├── firebase/             # bootstrap stub
│   ├── ads/                  # AdMob stub (Fase 1+)
│   ├── game_sdk/             # HubGame, registry, runner
│   ├── models/               # PlayerProfile, LeaderboardEntry
│   ├── storage/              # PlayerRepository (shared_preferences)
│   ├── leaderboard/          # LeaderboardRepository
│   └── theme/                # app_theme, game_ui, hub_theme
├── features/
│   ├── shell/                # bottom nav + drawer
│   ├── home/                 # grid + hub_header + game_card + game_card_art
│   ├── profile/
│   └── leaderboard/
└── games/
    ├── demo/                 # Demo Tap (legado — fora do catálogo público)
    ├── memory/               # Flame — pares
    └── tap_rush/             # ⭐ Referência Flame (copiar estrutura)
        ├── tap_rush_game.dart
        ├── tap_rush_config.dart
        └── components/

test/
├── golden/                   # golden tests (Home mobile + tablet)
├── goldens/                  # PNGs de referência — commitar no git
├── helpers/                  # test_app.dart, load_test_fonts.dart
├── games/                    # testes de scoring/config
└── core/                     # registry, player_repository
```

---

## Jogo referência: Tap Rush

**Copie `lib/games/tap_rush/` como template** ao criar jogos Flame novos.

| Arquivo | Responsabilidade |
|---|---|
| `*_game.dart` | Só `HubGame` + `GameWidget` |
| `*_config.dart` | Duração, cores, scoring (testável sem Flame) |
| `components/` | Componentes reutilizáveis (alvo, HUD, FX) |
| `*_flame_game.dart` | Loop `update`/`render`, fases, callbacks |

**Padrões obrigatórios (Tap Rush):**

1. **Fases** — countdown → playing → finished (nunca iniciar no `onGameResize` sem flag `_sessionStarted`).
2. **Timer no `update(dt)`** — não usar `Timer.periodic` para gameplay (HUD fica suave).
3. **Dificuldade progressiva** — funções puras em `*_config.dart` (`progress → radius/lifetime`).
4. **Combo / feedback** — labels flutuantes + flash visual em erro.
5. **Score via callback** — `onScoreUpdate(total)`; **não** forçar rebuild do `GameWidget`.
6. **GameResult** — incluir `metadata` útil (hits, misses, maxCombo).
7. **Testes** — scoring e curva de dificuldade em `test/games/`.
8. **UI compartilhada** — AppBar e placar final em `core/game_sdk/widgets/` (`GameSessionAppBar`, `GameResultDialog`); não duplicar por jogo.

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
4. **Ilustração** — vetorial em `game_card_art.dart` (`CustomPaint`), **full-bleed** no card (Stack `fit: expand`). Arte centralizada com bolhas decorativas no fundo — **não** colocar PNG pequeno em `BoxFit.contain` (fica “caixa colada” com espaço vazio).
5. **Badge "NOVO!"** — vermelho, canto superior direito, só se `metadata.featured == true`.
6. **Feedback** — `AnimatedScale(0.96)` no toque; card inteiro é clicável.
7. **Cores por jogo** — registrar em `HubTheme._themes` em `core/theme/hub_theme.dart` (não hardcodar no card).

**Ilustração — o que NÃO fazer (aprendizado):**

- PNG gerado por IA com **checkerboard de transparência falso** embutido → aparece xadrez cinza/branco no app.
- PNG com `BoxFit.contain` em área branca → arte pequena, faixa colorida vazia em cima.
- Emojis pequenos no canto → parece placeholder, não capa de jogo.

**Preferir:** `CustomPaint` por jogo (`_TapRushArt`, `_MemoryArt`) ou PNG **sem alpha** com fundo igual ao `cardColor` (export sólido, não checkerboard).

### Header (`HubHeader`)

- Moedas vêm de `PlayerRepository.profile.coins` (Provider).
- Botão ads: stub até IAP Fase 2; nunca bloquear navegação.
- Recompensa diária: banner compacto abaixo do header (`DailyRewardBanner`), não `MaterialBanner` full-width.

### Ao adicionar jogo novo

1. Registrar em `registerBundledGames()`.
2. Adicionar entrada em `HubTheme._themes` com `cardColor` + `accentColor`.
3. Implementar arte em `game_card_art.dart` (CustomPaint) — ver jogos existentes.
4. Escolher emoji forte para fallback genérico.

### Arquivos do hub

```
lib/core/theme/hub_theme.dart
lib/features/home/widgets/hub_header.dart
lib/features/home/widgets/game_card.dart
lib/features/home/widgets/game_card_art.dart
lib/features/home/widgets/daily_reward_banner.dart
lib/features/home/home_screen.dart
```

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
- `Widget buildGame(BuildContext, GameSessionCallbacks)` — UI do jogo

Callbacks que o jogo **deve** usar:

| Callback | Quando |
|---|---|
| `onScoreUpdate(int)` | Durante a partida |
| `onGameOver(GameResult)` | Fim da partida (score, moedas, xp) |
| `onRewardEarned(type, amount)` | Recompensa mid-game (ex.: ad) |
| `onExit()` | Jogador desiste |

**Importante:** o `GameRunnerScreen` instancia o jogo **uma única vez**. Atualizar placar usa `ValueNotifier` — **nunca** `setState` no widget pai que recria o `GameWidget`, senão Flame reseta (timer volta a 15 s, memória embaralha de novo).

Registrar em `registerBundledGames()` (`features/home/home_screen.dart` ou `main.dart`).

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
- [x] Testes: **12** passando (widget + unit + golden)
- [ ] Beta fechado Play Store — **ação manual do usuário**

**Decisões Fase 1:** Provider + `shared_preferences` para perfil/ranking local; Flame para jogos; ads/Firebase permanecem stub até credenciais reais.

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
- Ranking e Perfil ainda sem fundo creme do hub (`HubTheme.background`).
- Memória: polir flip animado e FX (Tap Rush já é referência).
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
