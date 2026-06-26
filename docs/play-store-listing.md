# Listagem Play Store — MiniPlay

Material ASO (App Store Optimization) para publicação na Google Play.

| Campo | Valor |
|---|---|
| **Nome do app** | MiniPlay |
| **Application ID** | `com.miniplay.games` |
| **Categoria sugerida** | Jogos → Casual |
| **Classificação etária sugerida** | Livre (PEGI 3 / Everyone) |
| **Idioma principal** | Português (Brasil) |
| **Versão inicial** | 1.0.0 (1) |

> A Play Store **não tem campo de palavras-chave** como a App Store. Use os termos da seção [Palavras-chave ASO](#palavras-chave-aso) dentro da descrição longa e no subtítulo visual dos screenshots.

---

## Nome do app (até 30 caracteres)

```
MiniPlay
```

Alternativa com subtítulo na arte promocional (não no nome oficial):

```
MiniPlay — Minijogos Casuais
```

---

## Descrição curta (até 80 caracteres)

```
Minijogos casuais num só app: ranking, moedas, missões e recompensa diária.
```

**Caracteres:** 75

### Variantes (escolha uma)

```
Hub de minijogos offline: memória, 2048, corrida, sudoku e mais. Jogue rápido!
```
(79 caracteres)

```
Minijogos casuais offline com ranking, XP, conquistas e missões diárias.
```
(71 caracteres)

---

## Descrição longa (até 4.000 caracteres)

```
MiniPlay é o seu hub de minijogos casuais — vários jogos num só app, partidas curtas de 1 a 5 minutos e progressão com moedas, XP e ranking.

🎮 CATÁLOGO DE MINIJOGOS
Vários jogos num só lugar — puzzle, arcade, cartas e lógica. Novos títulos entram regularmente. Exemplos do catálogo atual:
• Jogo da Memória — encontre os pares
• Tap Rush — reflexo e combo contra o relógio
• 2048 — puzzle clássico de blocos
• Corrida Infinita — desvie dos obstáculos
• Paciência — cartas no estilo solitaire
• Cobra — clássico arcade
• Dominó — partidas rápidas de dominó
• Sudoku — lógica com dicas opcionais

⭐ PROGRESSÃO E RETENÇÃO
• Ranking local por jogo — bata seu recorde
• Moedas e XP a cada partida
• Recompensa diária com sequência de login
• Missões diárias com prêmios em moedas
• Conquistas para desbloquear
• Favoritos — seus jogos preferidos no topo do catálogo

🏆 FEITO PARA SESSÕES CURTAS
Abra o app, escolha um jogo, jogue uma partida rápida e volte quando quiser. Ideal para fila, intervalo ou tempo ocioso.

📴 JOGA OFFLINE
A maioria dos jogos funciona sem internet. Sincronização na nuvem e recursos online chegam em versões futuras.

🎯 PARA QUEM É
Jogadores casuais de todas as idades que querem variedade sem instalar vários apps.

MiniPlay está em evolução contínua — novos jogos, eventos e recursos sociais estão no roadmap.

Baixe agora e comece sua coleção de minijogos!
```

**Caracteres:** ~1.350 (margem confortável para futuras atualizações)

---

## O que há de novo (notas da versão 1.0.0)

Use na Play Console a cada upload:

```
🎉 Lançamento inicial do MiniPlay!

• Catálogo de minijogos casuais num hub único
• Ranking, moedas, XP e nível
• Recompensa diária e missões do dia
• Conquistas e favoritos no catálogo
• Jogos offline — jogue sem internet

Obrigado por testar! Envie feedback pelo e-mail de suporte.
```

Para betas subsequentes, liste só o que mudou desde a build anterior.

---

## Palavras-chave ASO

Inclua estes termos **naturalmente** na descrição, screenshots e materiais promocionais:

| Grupo | Termos |
|---|---|
| **Hub / coleção** | minijogos, jogos casuais, hub de jogos, vários jogos, arcade |
| **Gêneros** | puzzle, memória, 2048, corrida, cartas, paciência, sudoku, dominó, cobra, snake |
| **Mecânicas** | ranking, recorde, pontuação, combo, offline, partida rápida |
| **Retenção** | recompensa diária, missões, conquistas, moedas, XP, nível |
| **Público** | casual, família, todas as idades, tempo ocioso |

Evite repetir a mesma palavra mais de 3–4 vezes — a Play penaliza keyword stuffing.

---

## Screenshots — roteiro sugerido

Capture em **1080×1920** (phone) ou use emulador Pixel 6. Mínimo **2 screenshots**; recomendado **6–8**.

| # | Tela | Texto overlay sugerido |
|---|---|---|
| 1 | Home (grid de jogos) | *Vários jogos num só app* |
| 2 | Tap Rush em partida | *Reflexo e combo* |
| 3 | Placar final (moedas/XP) | *Ganhe moedas a cada partida* |
| 4 | Missões diárias na Home | *Missões e recompensa diária* |
| 5 | Aba Ranking | *Bata seu recorde* |
| 6 | Perfil (nível + conquistas) | *Suba de nível e desbloqueie conquistas* |
| 7 | 2048 ou Sudoku | *Puzzles clássicos* |
| 8 | Corrida Infinita | *Arcade infinito* |

**Dica:** use fundo `#F5F0E8` e destaque `#E84393` (identidade MiniPlay) nos overlays.

---

## Gráfico de recursos (Feature Graphic)

- **Tamanho:** 1024 × 500 px
- **Conteúdo sugerido:** logo MiniPlay + grid de 4–6 miniaturas de jogos + tagline *Minijogos casuais num só lugar*
- **Arquivo gerado (rascunho):** `assets/branding/miniplay_feature_graphic_1024x500.png`
- **Regenerar rascunho local:** `python3 tools/generate_feature_graphic.py`
- **Prompt para IA externa (melhor qualidade):** [`feature-graphic-ai-prompt.md`](feature-graphic-ai-prompt.md)
- **Fonte do ícone:** `assets/branding/miniplay_icon_512.png`

---

## Ícone da loja

- **Tamanho:** 512 × 512 px
- **Arquivo fonte:** `assets/branding/miniplay_icon_512.png`
- Já gerado em `android/app/src/main/res/mipmap-*`

---

## Classificação de conteúdo (questionário)

Respostas prováveis para MiniPlay v1.0:

| Pergunta | Resposta |
|---|---|
| Violência | Não / cartoon leve (Cobra, Tap Rush) |
| Conteúdo sexual | Não |
| Linguagem imprópria | Não |
| Drogas | Não |
| Jogos de azar | Não |
| Interação entre usuários | Não (v1) |
| Compartilhamento de localização | Não |
| Compras no app | Sim (remover anúncios, moedas) — quando IAP ativo |
| Anúncios | Sim — quando AdMob ativo |

---

## Política de privacidade

A Play Console **exige URL** de política de privacidade (Firebase Analytics; AdMob/IAP quando ativos).

**Arquivos prontos no repositório:**

- Texto: [`docs/privacy-policy.md`](privacy-policy.md)
- HTML (hospedagem): [`docs/privacy-policy.html`](privacy-policy.html)
- Como hospedar: [`docs/privacy-policy-hosting.md`](privacy-policy-hosting.md)

Contato de privacidade: `djmarina@gmail.com`

**Hospedagem recomendada (grátis):** GitHub Pages na pasta `/docs` → URL:

```
https://djmarina123.github.io/minigames/privacy-policy.html
```

---

## E-mail e site (Play Console)

| Campo | Sugestão |
|---|---|
| **E-mail de suporte** | `djmarina@gmail.com` |
| **Site** | URL do repositório GitHub ou landing page (opcional no beta) |
| **Política de privacidade** | URL pública obrigatória |

---

## Checklist antes de publicar a listagem

- [ ] Nome, descrição curta e longa colados na Play Console
- [ ] Ícone 512×512 enviado
- [ ] Feature graphic 1024×500 enviado
- [ ] Mínimo 2 screenshots (ideal 6+)
- [ ] Classificação de conteúdo concluída
- [ ] Política de privacidade publicada (URL válida)
- [ ] Categoria: Jogos → Casual
- [ ] Países/regiões selecionados (BR primeiro)

---

## Referências

- [Play Console](https://play.google.com/console)
- [Requisitos de metadados](https://support.google.com/googleplay/android-developer/answer/9859455)
- Setup Firebase: [`firebase-setup.md`](firebase-setup.md)
- Beta fechado: [`play-store-closed-beta.md`](play-store-closed-beta.md)
