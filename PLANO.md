# Plano — Hub de Jogos Casuais (Mobile)

> Documento vivo de planejamento. Objetivo: construir um **hub de minijogos casuais** para mobile, lançando primeiro no **Android** e depois no **iPhone (iOS)**.

---

## 1. Visão do Produto

Um único app que funciona como **portal** para vários minijogos casuais (puzzle, arcade, cartas, palavras, etc.). O usuário abre o app, escolhe um jogo, joga sessões curtas (1–5 min), acumula moedas/XP, compete em rankings e volta no dia seguinte por causa de recompensas diárias.

**Pilares:**
- **Sessões curtas** — jogos rápidos, ideais para tempo ocioso.
- **Coleção** — vários jogos num só lugar, atualizável remotamente.
- **Progressão & competição** — moedas, conquistas, rankings, eventos.
- **Retenção** — recompensa diária, missões, notificações.
- **Monetização leve** — anúncios recompensados + compras opcionais.

**Público-alvo:** jogadores casuais, todas as idades, que querem diversão rápida sem curva de aprendizado.

---

## 2. Decisões de Tecnologia (recomendação)

A escolha-chave de um hub é separar a **casca do app** (navegação, perfil, loja, rankings) dos **jogos** em si.

### Stack recomendada

| Camada | Tecnologia | Por quê |
|---|---|---|
| **App / Casca** | **Flutter (Dart)** | Um único código para Android e iOS, UI rica e fluida, ótimo time-to-market. Atende ao requisito "Android primeiro, iOS depois" sem reescrever. |
| **Motor de jogos 2D** | **Flame** (engine 2D para Flutter) | Roda dentro do mesmo app Flutter. Ideal para casuais 2D (puzzle, arcade, cartas). |
| **Jogos com atualização remota (opcional)** | **HTML5/JS em WebView** | Permite publicar/atualizar jogos sem nova versão na loja. Bom para iterar rápido e testar jogos novos. |
| **Backend** | **Firebase** (Auth, Firestore, Cloud Functions, Remote Config, Analytics, Cloud Messaging) | Pronto para uso, escala sozinho, cobre auth, ranking, config remota, push e métricas. Acelera muito o MVP. |
| **Anúncios** | **Google AdMob** | Padrão de mercado; suporta rewarded, interstitial e banner. |
| **Compras no app** | **in_app_purchase** (plugin oficial Flutter) | Play Billing + StoreKit num só plugin. |
| **Crash/erros** | **Firebase Crashlytics** | Monitoramento de estabilidade. |
| **CI/CD** | **GitHub Actions** + **Fastlane** | Build/assinatura/publicação automatizadas nas lojas. |

### Por que Flutter + Flame (e não as alternativas)?

- **Unity**: excelente para jogos, mas binário pesado e UI de "app" (menus, loja, perfil) é trabalhosa. Overkill para casuais 2D simples.
- **React Native**: ótimo para a casca, mas precisa de engine externa para jogos; integração mais frágil.
- **Nativo (Kotlin + Swift)**: dobra o esforço entre plataformas — vai contra o objetivo de lançar rápido nas duas.

> **Arquitetura híbrida ideal:** casca + jogos "core" em Flutter/Flame (performance nativa) **e** slot para jogos HTML5 via WebView (atualização sem passar pela loja). Começamos só com Flutter/Flame no MVP e adicionamos o WebView quando precisarmos iterar mais rápido.

### Alternativa "open-source first"
Se houver preferência por não depender do Google: trocar **Firebase → Supabase** (Postgres + Auth + Edge Functions) e manter AdMob para anúncios.

---

## 3. Arquitetura

```
┌──────────────────────────────────────────────┐
│                  APP (Flutter)                │
│                                               │
│  ┌──────────┐  ┌──────────┐  ┌─────────────┐  │
│  │  Home /  │  │  Perfil  │  │  Loja /     │  │
│  │  Catálogo│  │  & XP    │  │  Moedas     │  │
│  └────┬─────┘  └──────────┘  └─────────────┘  │
│       │                                       │
│  ┌────▼──────────────────────────────────┐   │
│  │        Game Runner (sandbox)           │   │
│  │  ┌──────────────┐   ┌───────────────┐  │   │
│  │  │ Jogos Flame  │   │ Jogos HTML5   │  │   │
│  │  │ (nativos 2D) │   │ (WebView)     │  │   │
│  │  └──────────────┘   └───────────────┘  │   │
│  └────────────────────────────────────────┘  │
│                                               │
│  Serviços: Auth · Ranking · RemoteConfig ·    │
│            Ads · IAP · Analytics · Push       │
└───────────────────────┬──────────────────────┘
                        │
              ┌─────────▼──────────┐
              │     Firebase       │
              │ Auth · Firestore · │
              │ Functions · Remote │
              │ Config · FCM ·     │
              │ Analytics          │
              └────────────────────┘
```

**Princípio central — "Game SDK" interno:** cada jogo implementa uma interface comum (`onStart`, `onScore`, `onGameOver`, `onRewardEarned`). Assim o hub trata todos os jogos de forma uniforme: ranking, moedas e analytics funcionam para qualquer jogo novo sem retrabalho.

### Catálogo dirigido por dados (data-driven)
A lista de jogos vem do **Remote Config/Firestore** (não fixa no código): permite ativar/desativar jogos, ordenar, destacar e fazer eventos sazonais sem atualizar o app.

---

## 4. Funcionalidades Propostas

### Núcleo do Hub (essenciais)
- **Catálogo de jogos** — grade com capas, categorias, "novos" e "em destaque".
- **Game Runner** — abre/fecha jogos de forma uniforme, com tela de loading e resultado.
- **Perfil do jogador** — avatar, nível, XP, estatísticas.
- **Moeda virtual** — ganha jogando/anúncios; gasta em cosméticos/continues.
- **Recompensa diária** — login streak com prêmios crescentes.
- **Conquistas (achievements)** — metas por jogo e gerais.
- **Rankings (leaderboards)** — global, semanal e entre amigos.
- **Configurações** — som, vibração, idioma, privacidade.

### Retenção & Engajamento
- **Missões diárias/semanais** ("jogue 3 partidas", "faça 500 pontos").
- **Notificações push** — vida cheia, recompensa pronta, novo jogo.
- **Eventos sazonais** — temas de Natal, Halloween, torneios por tempo limitado.
- **Sistema de níveis/XP global** com recompensas por nível.

### Social (fase posterior)
- **Login social** (Google/Apple).
- **Lista de amigos** e comparação de pontuações.
- **Compartilhar resultado** (placar/print) em redes sociais.
- **Desafios** entre amigos (bata minha pontuação).

### Monetização
- **Anúncios recompensados** — dobrar moedas, continuar partida, vida extra.
- **Intersticiais** — entre partidas (com limite de frequência).
- **Remover anúncios** (compra única).
- **Pacotes de moedas** e **passe de temporada** (battle pass leve).

### Acessibilidade & Qualidade
- Modo daltônico, textos escaláveis, suporte a 1 mão.
- **Internacionalização** — PT-BR no lançamento, EN/ES em seguida.
- Modo offline para jogos que não exigem rede.

---

## 5. Plano de Jogos

### Princípios de seleção

Cada jogo do hub deve passar por estes critérios antes de entrar no catálogo:

| Critério | Pergunta |
|---|---|
| **Sessão** | Dá para jogar uma partida em 1–5 min? |
| **Curva** | Entende em 5 segundos sem tutorial longo? |
| **Replay** | Quer jogar de novo imediatamente? |
| **Escopo** | Dá para polir em 1–2 semanas (vibecoding)? |
| **Variedade** | É diferente dos jogos que já existem no hub? |
| **Offline** | Funciona sem internet? (obrigatório no MVP) |

**Mix ideal do catálogo:** 1 puzzle · 1 arcade/reflexo · 1 palavras/cartas · 1 “zen” (sessão longa opcional).

---

### Estado atual (pós-Fase 1)

| Jogo | ID | Engine | Status | Notas |
|---|---|---|---|---|
| Jogo da Memória | `memory` | Flame | ✅ MVP | 4 pares, grid 4×2; polir animações Fase 2 |
| Tap Rush | `tap_rush` | Flame | ✅ MVP | 15 s, alvos aleatórios |
| Demo Tap | `demo_tap` | Flutter | 🗑️ Remover | Substituído pelos Flame; manter só em dev se útil |

---

### Roadmap de jogos por fase

#### Fase 2 — completar variedade (3 jogos novos)

Prioridade: **polir os 2 existentes** + **1 jogo novo** antes de abrir Play Store.

| # | Jogo | Categoria | Sessão | Por quê |
|---|---|---|---|---|
| 1 | **2048** (ou variantes) | Puzzle | 3–8 min | Viciante, lógica simples, ranking claro |
| 2 | **Runner infinito** (obstáculos, 1 toque) | Arcade | 30 s–2 min | Complementa Tap Rush com skill diferente |
| 3 | **Paciência (Solitaire)** | Cartas | 5–15 min | Público amplo, retenção alta |

**Polimento dos existentes (Fase 2):**
- Memória: flip animado, som ao acertar/errar, grid responsivo
- Tap Rush: ✅ combo, alvo com timeout, dificuldade progressiva, FX — **padrão de referência**

#### Fase 3 — retenção e iOS

| # | Jogo | Categoria | Por quê |
|---|---|---|---|
| 4 | **Caça-palavras** | Palavras | Missões diárias (“ache 5 palavras”) |
| 5 | **Match-3 simplificado** | Puzzle | Eventos sazonais, moedas |

#### Fase 4 — expansão

| # | Jogo | Tipo | Por quê |
|---|---|---|---|
| 6+ | Slots via **HTML5/WebView** | WebView | Iterar sem passar pela loja |
| — | Torneios semanais por jogo | Meta | Reusar ranking existente |

---

### Template de implementação (todo jogo novo)

```
lib/games/<id>/
  <id>_game.dart      # implements HubGame
  <id>_flame.dart     # FlameGame (ou widgets Flutter se puzzle puro)
```

**Checklist antes de merge:**

- [ ] Implementa `HubGame` + registrado em `registerBundledGames()`
- [ ] `onScoreUpdate` / `onGameOver` corretos
- [ ] Partida tem **início e fim claros** (evitar jogos “infinitos” sem objetivo)
- [ ] Testado em **Chrome** e **Android**
- [ ] Game Runner **não recria** o jogo ao atualizar placar (ver `AGENTS.md`)
- [ ] Metadados: título, descrição, categoria, ícone emoji
- [ ] Moedas/XP balanceados (partida curta ≈ 5–20 moedas)

---

### Balanceamento econômico (referência)

| Tipo de partida | Moedas | XP |
|---|---|---|
| Curta (< 1 min) | 5–15 | 10–30 |
| Média (1–5 min) | 15–40 | 30–100 |
| Longa (> 5 min) | 40–80 | 100–200 |

Recompensa diária permanece independente (10 + bônus de sequência).

---

### Jogos descartados por enquanto

- **Flappy clone puro** — difícil de diferenciar; runner com obstáculos é melhor
- **Quiz online** — exige backend cedo demais
- **Multijogador realtime** — escopo Fase 4+

---

### Critério legado (referência)

Variety pack original: puzzle de blocos, arcade infinito, memória, palavras, cartas — **memória e arcade já cobertos**; próximos: **2048, runner, solitaire**.

---

## 6. Modelo de Dados (Firestore — esboço)

```
users/{uid}
  ├─ displayName, avatarId, level, xp, coins
  ├─ createdAt, lastLogin, loginStreak
  └─ settings { sound, music, vibration, lang }

users/{uid}/stats/{gameId}
  ├─ highScore, gamesPlayed, totalScore, lastPlayed

users/{uid}/achievements/{achId}
  └─ unlockedAt, progress

leaderboards/{gameId}/scores/{uid}
  ├─ score, displayName, avatarId, period (weekly/all-time), updatedAt

games/{gameId}            (catálogo data-driven)
  ├─ title, category, coverUrl, type (flame|webview)
  ├─ enabled, featured, order, minAppVersion

config/global             (via Remote Config também)
  ├─ adFrequency, dailyRewards[], eventActive
```

> Rankings e gasto de moedas devem ser validados em **Cloud Functions** para evitar trapaça (nunca confiar só no cliente).

---

## 7. Roadmap em Fases

### Fase 0 — Fundação (1–2 semanas) ✅
- [x] Setup do projeto Flutter + estrutura de pastas + CI básico.
- [x] Integração Firebase (Auth anônimo, Analytics, Crashlytics) — stub, aguarda `flutterfire configure`.
- [x] Definir o **Game SDK** interno (interface comum de jogo).
- [x] Jogo demo **Demo Tap** para validar fluxo hub → jogo → resultado.

### Fase 1 — MVP Android (4–6 semanas) ✅
- [x] Casca: Home/Catálogo + Game Runner + Perfil básico + bottom nav + Ranking.
- [x] **2 jogos** em Flame (Memória + Tap Rush).
- [x] Moedas + recompensa diária + ranking local.
- [x] AdMob stub (rewarded + interstitial) — aguarda `kAdsConfigured = true`.
- [ ] **Beta fechado** na Play Store (faixa interna/fechada) — manual.

### Fase 2 — Lançamento Android (3–4 semanas)
- +2/3 jogos, conquistas, missões diárias.
- Compras no app (remover ads + pacote de moedas).
- Push (FCM), Remote Config para catálogo data-driven.
- Polimento, ASO (ícone, screenshots, descrição) e **lançamento público**.

### Fase 3 — iOS (3–4 semanas)
- Build iOS (o código Flutter já é compartilhado).
- Login com Apple (obrigatório se houver login social).
- Adequação às diretrizes da App Store, StoreKit/IAP, App Tracking Transparency.
- Beta TestFlight → lançamento.

### Fase 4 — Crescimento (contínuo)
- Social (amigos, desafios, compartilhamento).
- Eventos sazonais, passe de temporada.
- Jogos via WebView/HTML5 para iteração rápida.
- Otimização de retenção e monetização guiada por métricas.

---

## 8. Métricas de Sucesso (KPIs)

- **Retenção** D1 / D7 / D30.
- **DAU/MAU** e razão de "stickiness".
- **Duração de sessão** e **sessões por usuário/dia**.
- **ARPDAU** (receita média por usuário ativo/dia).
- **Taxa de conclusão de anúncio recompensado**.
- **Conversão** para compra (remover ads / pacotes).

---

## 9. Riscos & Cuidados

- **Aprovação na App Store** (iOS é mais rígido): privacidade, ATT, login com Apple.
- **Anti-trapaça** em rankings — validar no servidor.
- **Privacidade infantil** — se mirar crianças, atenção a COPPA/GDPR-K e políticas de ads para público familiar.
- **Tamanho do app** — manter enxuto; baixar assets pesados sob demanda.
- **Diversidade de aparelhos Android** — testar em telas/versões variadas.

---

## 10. Próximos Passos Imediatos

1. **Validar a stack** (Flutter + Flame + Firebase) e o catálogo inicial de jogos.
2. Criar o repositório e a estrutura base do projeto Flutter.
3. Definir a interface do **Game SDK** interno.
4. Prototipar o **primeiro jogo** + a Home do hub para validar a experiência ponta a ponta.

> Quando aprovarmos a stack, posso já criar o scaffold do projeto Flutter com a estrutura de pastas, o Game SDK e um jogo de exemplo.
