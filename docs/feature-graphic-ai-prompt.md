# Prompt — Feature Graphic MiniPlay (1024×500)

Use o bloco abaixo em ferramentas como **Midjourney**, **DALL·E**, **Ideogram**, **Leonardo**, **Firefly** ou **ChatGPT (DALL·E)**.

**Após gerar:** redimensione/corte para **1024 × 500 px** exatos se a IA entregar outro tamanho.

---

## Prompt principal (inglês — melhor resultado na maioria das IAs)

```
Play Store feature graphic banner, exact aspect ratio 1024:500 (wide horizontal), flat modern mobile game marketing art.

Brand: "MiniPlay" — a casual minigames hub app for Android. One app with many short arcade and puzzle games.

Layout:
- Left third: app icon (rounded square, pink-to-coral vertical gradient #E84393 to #FF6B6B, white minimalist gamepad silhouette centered) + bold wordmark "MiniPlay" in vibrant pink #E84393
- Tagline below in dark gray: "Minijogos casuais num só lugar" (Portuguese, must be readable)
- Secondary line smaller: "Ranking · moedas · missões · offline"

- Right two-thirds: playful grid of 6 colorful rounded game tiles suggesting different minigames (memory pairs, tap targets, 2048 blocks, endless runner, snake, sudoku) — each tile a different bold color (purple, pink, teal, orange, green, indigo), minimal icons inside tiles, no photorealism

Background: warm cream #F5F0E8, subtle soft pink circular bokeh accents, thin pink accent strip along top edge.

Style: premium casual mobile game store banner, Material Design inspired, clean vector-like illustration, high contrast, no clutter, no screenshots of UI, no people, no 3D characters, no watermark.

Typography: bold rounded sans-serif for title, crisp and legible at small preview size.

Mood: fun, approachable, polished indie game hub — NOT childish toddler aesthetic, target teens and adults 13+.

Output: single cohesive banner, professional Google Play feature graphic quality.
```

---

## Prompt alternativo (português — Ideogram / alguns modelos locais)

```
Banner horizontal 1024x500 para Google Play Store, gráfico de recursos de app mobile.

App "MiniPlay": hub de minijogos casuais — vários jogos rápidos num só aplicativo (puzzle, arcade, cartas, lógica).

Composição:
- Esquerda: ícone quadrado arredondado com gradiente rosa (#E84393) para coral (#FF6B6B) e controle de videogame branco minimalista; ao lado ou abaixo o nome "MiniPlay" em rosa forte, grande e legível
- Subtítulo em português: "Minijogos casuais num só lugar"
- Linha menor: "Ranking · moedas · missões · offline"
- Direita: grade 2x3 de cartões coloridos arredondados representando minijogos variados (memória, reflexo, 2048, corrida, cobra, sudoku) — ícones simples, cores vibrantes distintas, estilo flat design

Fundo creme claro #F5F0E8, detalhes decorativos suaves em rosa, faixa rosa fina no topo.

Estilo: ilustração vetorial limpa, moderna, profissional, banner de loja de jogos casuais premium. Sem fotos, sem pessoas, sem personagens 3D, sem interface real de celular, sem texto ilegível, sem marca d'água.

Público: jogadores casuais 13+, visual divertido mas polido.
```

---

## Negative prompt (cole se a ferramenta tiver campo separado)

```
blurry text, misspelled text, wrong language, English tagline, photorealistic, 3D render, anime characters, children cartoon, cluttered, dark background, neon cyberpunk, casino, gambling, stock photo, phone mockup with UI screenshot, low resolution, jpeg artifacts, watermark, logo of other brands, "8 games", numbered game count
```

---

## Referências visuais para anexar (se a IA aceitar imagem)

Anexe junto ao prompt:

1. `assets/branding/miniplay_icon_512.png` — ícone oficial (cor e gamepad)
2. Opcional: screenshot da Home do app (só como referência de paleta dos cards)

Instrução extra ao anexar:

```
Use the attached icon colors and gamepad shape exactly. Match cream background #F5F0E8 and pink accent #E84393.
```

---

## Paleta (copiar/colar)

| Uso | Hex |
|---|---|
| Fundo | `#F5F0E8` |
| Rosa principal | `#E84393` |
| Gradiente ícone (topo → base) | `#E84393` → `#FF6B6B` |
| Texto principal | `#2D3436` |
| Texto secundário | `#636E72` |
| Cards jogos (exemplos) | `#5B4BB7`, `#00B894`, `#FF9F43`, `#16A085`, `#4834D4` |

---

## Checklist pós-geração

- [ ] Proporção **1024 × 500 px** (ou recortar sem perder textos)
- [ ] "MiniPlay" legível em miniatura (como aparece na Play Store)
- [ ] Tagline em **português** correta
- [ ] **Não** fixar número de jogos ("8 jogos", etc.)
- [ ] PNG, sem transparência (Play prefere JPG ou PNG opaco)
- [ ] Arquivo ≤ 1 MB

Salvar como: `assets/branding/miniplay_feature_graphic_1024x500.png`

---

## Dica por ferramenta

| Ferramenta | Config sugerida |
|---|---|
| **Midjourney** | `--ar 1024:500` ou `--ar 2:1` + upscale; depois crop 1024×500 |
| **Ideogram** | Aspect ratio **2:1**, preset *Design* ou *Poster* |
| **DALL·E / ChatGPT** | "Wide horizontal banner, 2:1 aspect ratio" + pedir PNG |
| **Canva AI** | Template "Google Play Feature Graphic" 1024×500 + prompt acima |

Se o texto sair errado na IA (comum), gere **sem texto** e adicione "MiniPlay" + tagline no Canva/Figma por cima do ícone oficial.

### Prompt sem texto (fallback)

```
Wide 2:1 banner, MiniPlay casual minigames hub, cream background #F5F0E8, pink gradient rounded app icon with white gamepad left side, colorful 2x3 grid of rounded game tiles right side, flat vector illustration, no text, no letters, no watermark, Play Store feature graphic style
```

Depois sobreponha textos no Canva com fonte **Nunito Bold** ou **Poppins Bold**.
