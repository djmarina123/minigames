# Beta fechado na Play Store — MiniPlay

Guia passo a passo para publicar o MiniPlay na faixa de **teste fechado** da Google Play.

| Item | Valor |
|---|---|
| App | MiniPlay |
| Application ID | `com.miniplay.games` |
| Versão atual | `1.0.0+1` (`pubspec.yaml`) |
| Listagem ASO | [`play-store-listing.md`](play-store-listing.md) |

---

## Pré-requisitos

### Conta e ferramentas

- [ ] Conta [Google Play Console](https://play.google.com/console) (taxa única ~US$ 25)
- [ ] Flutter instalado e `flutter doctor` sem erros críticos para Android
- [ ] Android SDK + JDK 17
- [ ] Repositório com commits locais enviados (`git push`) quando houver rede

### Antes de começar no projeto

```bash
cd /home/marina/projetos/minigames
flutter pub get
flutter analyze && flutter test
```

Confirme que CI local passa antes de gerar o AAB.

---

## Passo 1 — Assinatura release (importante)

O `android/app/build.gradle.kts` usa **debug signing** no release — serve para testes locais, mas a Play Store exige assinatura de upload válida.

### Opção A — Play App Signing (recomendado)

1. Gere um keystore de upload (uma vez):

```bash
keytool -genkey -v \
  -keystore ~/miniplay-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias miniplay
```

Guarde a senha em local seguro (gerenciador de senhas). **Nunca commite o `.jks`.**

2. Crie `android/key.properties` (já deve estar no `.gitignore`):

```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=miniplay
storeFile=/home/marina/miniplay-upload-keystore.jks
```

3. Configure signing release no Gradle — ver [documentação Flutter](https://docs.flutter.dev/deployment/android#signing-the-app).

4. Na Play Console, ative **Play App Signing** — o Google guarda a chave de assinatura final.

### Opção B — Primeiro upload com debug (só teste interno rápido)

Alguns desenvolvedores fazem o primeiro upload na faixa **Teste interno** com debug key para validar o fluxo. Para beta fechado público ou produção, use a Opção A.

---

## Passo 2 — Gerar o Android App Bundle (AAB)

```bash
cd /home/marina/projetos/minigames
flutter build appbundle --release
```

Saída:

```
build/app/outputs/bundle/release/app-release.aab
```

**Verifique o tamanho** (~30–80 MB é normal com Flame + Firebase).

### Testar release localmente (opcional)

```bash
flutter build apk --release
flutter install --release
```

Ou instale o AAB via [bundletool](https://developer.android.com/tools/bundletool) em emulador/device.

---

## Passo 3 — Criar o app na Play Console

1. Acesse [Play Console](https://play.google.com/console) → **Criar app**
2. Preencha:
   - **Nome:** MiniPlay
   - **Idioma padrão:** Português (Brasil)
   - **App ou jogo:** Jogo
   - **Gratuito ou pago:** Gratuito
3. Aceite as declarações (políticas, exportação EUA, etc.)

---

## Passo 4 — Configurar a listagem da loja

Menu **Presença na loja → Principal listing**:

| Campo | Onde copiar |
|---|---|
| Nome do app | [`play-store-listing.md`](play-store-listing.md) |
| Descrição curta | idem |
| Descrição completa | idem |
| Ícone 512×512 | `assets/branding/miniplay_icon_512.png` |
| Feature graphic | criar 1024×500 (ver listagem) |
| Screenshots | capturar do emulador/device |

Marque **Visibilidade** como não listado publicamente enquanto estiver só em teste.

---

## Passo 5 — Política de privacidade e classificação

### Política de privacidade

1. Publique uma URL pública (GitHub Pages, site, etc.)
2. Em **Política do app → Política de privacidade**, cole a URL
3. Veja pontos mínimos em [`play-store-listing.md`](play-store-listing.md#política-de-privacidade)

### Classificação de conteúdo

1. **Política do app → Classificação do app** → iniciar questionário
2. Responda conforme tabela na listagem ASO
3. Salve e aplique a classificação

### Público-alvo

- Se **não** mirar crianças como público principal: marque 13+ ou “não direcionado a crianças”
- Se incluir crianças: exige conformidade Família do Google Play (ads certificadas, etc.)

---

## Passo 6 — Declarações técnicas

Em **Política do app → Segurança dos dados** (Data safety):

| Dado | Coleta | Compartilhado | Finalidade |
|---|---|---|---|
| IDs de diagnóstico (Crashlytics) | Sim | Não | Estabilidade |
| Interações com app (Analytics) | Sim | Não | Analytics |
| ID de instalação / Auth anônimo | Sim | Não | Funcionalidade |
| Compras (futuro IAP) | Sim | Google | Compras no app |
| ID de publicidade (futuro AdMob) | Sim | Parceiros ads | Anúncios |

Seja honesto com o que `kFirebaseConfigured`, `kAdsConfigured` e `kIapConfigured` tiverem **ativos na build enviada**.

---

## Passo 7 — Faixa de teste fechado

### Criar a faixa

1. **Testar e lançar → Teste → Teste fechado**
2. **Criar faixa** (ex.: `closed-beta-v1`)
3. Opcional: configure países (Brasil) e limite de testadores

### Diferença entre faixas

| Faixa | Testadores | Uso |
|---|---|---|
| **Teste interno** | Até 100, deploy rápido (~minutos) | Smoke test da pipeline |
| **Teste fechado** | Lista de e-mails ou Google Groups | Beta com feedback estruturado |
| **Teste aberto** | Qualquer um opt-in | Pré-lançamento amplo |
| **Produção** | Público geral | Lançamento |

**Recomendação:** Teste interno primeiro (1 upload) → depois teste fechado.

### Upload do AAB

1. **Testar e lançar → Teste fechado → Criar nova versão**
2. **Upload** → selecione `app-release.aab`
3. **Nome da versão:** `1.0.0 (1)`
4. **Notas da versão:** copie de [`play-store-listing.md`](play-store-listing.md#o-que-há-de-novo-notas-da-versão-100)
5. **Revisar e lançar** a versão de teste

A revisão do Google pode levar de **algumas horas a 2–3 dias** na primeira submissão.

---

## Passo 8 — Convidar testadores

### Por lista de e-mails

1. **Testadores → Criar lista** (ex.: `beta-miniplay-v1`)
2. Adicione e-mails Gmail dos testadores (incluindo o seu)
3. Associe a lista à faixa de teste fechado
4. Copie o **link de opt-in** e envie aos testadores

### Fluxo do testador

1. Abrir link de opt-in no celular (conta Google igual ao e-mail convidado)
2. Aceitar participar do teste
3. Instalar pela Play Store (link “Baixar no Google Play” ou busca por MiniPlay — pode aparecer só para testadores)

---

## Passo 9 — Validar no device (checklist pós-instalação)

### App básico

- [ ] App abre sem crash
- [ ] Catálogo mostra 8 jogos
- [ ] Abrir e concluir partida em 2–3 jogos diferentes
- [ ] Placar final: moedas, XP, ranking
- [ ] Recompensa diária resgata
- [ ] Missões avançam após partidas
- [ ] Conquista desbloqueia (ex.: primeira partida)
- [ ] Favorito funciona
- [ ] Perfil: loja, conquistas, stats

### Firebase (com `kFirebaseConfigured = true`)

```bash
adb shell setprop debug.firebase.analytics.app com.miniplay.games
```

- [ ] **Analytics → DebugView** mostra eventos ao usar o app
- [ ] Auth anônimo ativo (Console → Authentication)
- [ ] Crashlytics: force crash de teste em release/profile (remover depois)

### Monetização (quando flags ativas)

- [ ] `kAdsConfigured = true` — rewarded “dobrar moedas” e interstitial
- [ ] `kIapConfigured = true` — produtos criados no Play Console batem com `IapConfig`

---

## Passo 10 — Coletar feedback e iterar

1. Crie canal simples: e-mail de suporte ou formulário Google Forms
2. Peça aos testadores:
   - Device + versão Android
   - Jogo testado
   - Passos para reproduzir bugs
   - Screenshots se possível
3. Monitore **Crashlytics** e **Pré-lançamento** (vitals) na Play Console
4. Para nova build: incremente versão em `pubspec.yaml`:

```yaml
version: 1.0.1+2   # nome+code — code deve subir a cada upload
```

5. Gere novo AAB → nova versão na mesma faixa → notas da versão descrevendo correções

---

## Problemas comuns

| Problema | Solução |
|---|---|
| Upload rejeitado — assinatura | Configure keystore de upload (Passo 1) |
| “App bundle não assinado” | `flutter build appbundle --release` com signing configurado |
| Testador não vê o app | Mesmo e-mail Google no convite e no device; aceitar opt-in |
| Firebase não conecta | `google-services.json` presente; Auth anônimo ativo |
| Revisão demorada | Normal na 1ª submissão; teste interno é mais rápido |
| `version code already used` | Incremente o número após `+` em `pubspec.yaml` |
| Política de privacidade obrigatória | Publique URL antes de enviar para revisão |

---

## Ordem resumida (checklist)

```
[ ] 1. Keystore + signing release
[ ] 2. flutter analyze && flutter test
[ ] 3. flutter build appbundle --release
[ ] 4. Criar app na Play Console
[ ] 5. Listagem (textos + ícone + screenshots)
[ ] 6. Política de privacidade (URL)
[ ] 7. Classificação de conteúdo + Data safety
[ ] 8. Upload AAB → teste interno (smoke)
[ ] 9. Upload AAB → teste fechado
[ ] 10. Convidar testadores + link opt-in
[ ] 11. Validar Firebase + gameplay no device
[ ] 12. Iterar com feedback → 1.0.1+2...
```

---

## Depois do beta fechado

1. Corrigir bugs críticos reportados
2. Ativar AdMob/IAP com IDs reais
3. Completar ASO (6–8 screenshots polidos)
4. Promover para **teste aberto** ou **produção**
5. Monitorar retenção D1/D7 via Firebase Analytics

---

## Referências

- [Flutter — Deploy Android](https://docs.flutter.dev/deployment/android)
- [Play Console — Teste fechado](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Firebase setup](firebase-setup.md)
- [Listagem ASO](play-store-listing.md)
