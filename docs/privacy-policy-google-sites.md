# Publicar política de privacidade no Google Sites

Guia visual passo a passo para o MiniPlay.

**Contato configurado:** `djmarina@gmail.com` (já preenchido em `privacy-policy-google-sites.txt`).

---

## Passo 1 — Abrir o Google Sites

1. Acesse [sites.google.com](https://sites.google.com)
2. Entre com a **mesma conta Google** da Play Console (facilita)
3. Clique em **Blank** (Em branco) ou **+ Criar**

---

## Passo 2 — Nome e título do site

1. No topo, clique em **Untitled site** → renomeie para: `MiniPlay Privacidade`
2. Na primeira caixa de texto grande, apague o placeholder e escreva:

```
Política de Privacidade — MiniPlay
```

3. Selecione esse título → menu de estilo → **Heading** (Título)

---

## Passo 3 — Colar o conteúdo

1. Clique abaixo do título → **Insert** (Inserir) → **Text box** (Caixa de texto)  
   — ou simplesmente clique na área e comece a digitar
2. Abra o arquivo [`privacy-policy-google-sites.txt`](privacy-policy-google-sites.txt) deste repositório
3. **Ctrl+A → Ctrl+C** no arquivo de texto
4. **Ctrl+V** na caixa do Google Sites

O Google Sites aceita colar texto com quebras de linha; títulos com linhas em branco antes/depois ficam legíveis.

**Dica:** se a formatação ficar estranha, cole **seção por seção** (cada bloco entre linhas `===` no arquivo .txt).

---

## Passo 4 — Ajustar links

Dois links devem ficar clicáveis:

- `https://policies.google.com/privacy`
- `https://policies.google.com/technologies/ads`

Selecione cada URL → ícone de **link** (corrente) → confirme.

---

## Passo 5 — Aparência (opcional)

1. Ícone direito → **Themes** (Temas)
2. Escolha um tema simples (ex.: **Simple** / **Diplomat**)
3. Cores sugeridas MiniPlay: fundo claro, destaque rosa `#E84393` se quiser personalizar

Não é obrigatório — a Play Console só exige conteúdo legível.

---

## Passo 6 — Publicar na web

1. Canto superior direito → **Publish** (Publicar)
2. **Web address:** escolha algo curto, ex.:
   - `miniplay-privacidade`  
   URL final: `https://sites.google.com/view/miniplay-privacidade`
3. Em **Who can view my site** → **Anyone on the web** (Qualquer pessoa na Web)
4. Clique **Publish** de novo

---

## Passo 7 — Testar a URL

1. Abra a URL em **aba anônima** do navegador
2. Confirme:
   - [ ] Página abre sem pedir login
   - [ ] E-mail de contato está correto
   - [ ] Data e nome MiniPlay aparecem

---

## Passo 8 — Colar na Play Console

1. Play Console → seu app MiniPlay
2. **Política do app** → **Política de privacidade**
3. Cole a URL, ex.:
   ```
   https://sites.google.com/view/miniplay-privacidade
   ```
4. Salvar

---

## Problemas comuns

| Problema | Solução |
|---|---|
| Play Console rejeita URL | Site precisa estar **Public on the web**, não restrito |
| Página pede login | Republicar com "Anyone on the web" |
| URL muito longa | Em Publish, edite o slug para `miniplay-privacidade` |
| Quero mudar e-mail depois | Edite o site → **Publish** → **Published settings** → republicar |

---

## Atualizar a política no futuro

1. Edite o site no Google Sites
2. **Publish** → **Publish changes** (mesma URL)
3. Não precisa alterar na Play Console se a URL não mudou

---

## Texto para colar

Ver: [`privacy-policy-google-sites.txt`](privacy-policy-google-sites.txt)
