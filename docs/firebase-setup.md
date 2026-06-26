# Configurar Firebase — MiniPlay

O app já inclui **Auth anônimo**, **Analytics** e **Crashlytics** em `lib/core/firebase/firebase_bootstrap.dart`. Até concluir este guia, o Firebase fica desligado (`kFirebaseConfigured = false`) e o app roda só com persistência local.

| Item | Valor |
|---|---|
| Pacote Android | `com.miniplay.games` |
| Bundle iOS | `com.miniplay.games` |
| Flag de ativação | `lib/core/firebase/firebase_config.dart` |

---

## Passo 1 — Criar projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/).
2. **Adicionar projeto** → nome sugerido: **MiniPlay**.
3. Google Analytics: **ativar** (recomendado; alinha com o código atual).
4. Escolha ou crie uma conta do Analytics e conclua a criação.

---

## Passo 2 — Habilitar serviços no Console

### Authentication (obrigatório)

1. **Build → Authentication → Começar**.
2. Aba **Sign-in method** → **Anônimo** → **Ativar** → Salvar.

O bootstrap faz `signInAnonymously()` na inicialização.

### Crashlytics (obrigatório para relatórios de crash)

1. **Build → Crashlytics → Começar**.
2. Siga o assistente (Android primeiro; iOS quando tiver Mac/Xcode).

Analytics já vem habilitado com o projeto.

### Serviços futuros (opcional, não usados ainda)

- Firestore, Remote Config, Cloud Messaging — previstos no [`PLANO.md`](../PLANO.md), mas ainda não integrados no código.

---

## Passo 3 — Instalar CLIs e autenticar

### Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

Use a mesma conta Google do Firebase Console.

### FlutterFire CLI

Incluído no script do projeto; para instalar manualmente:

```bash
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Adicione o `export PATH` ao `~/.bashrc` ou `~/.zshrc` para persistir.

---

## Passo 4 — Gerar arquivos do projeto (automático)

Na raiz do repositório:

```bash
chmod +x scripts/configure-firebase.sh
./scripts/configure-firebase.sh
```

O script:

- Detecta `applicationId` / bundle `com.miniplay.games`
- Cria apps Android e iOS no Firebase (se ainda não existirem)
- Gera `lib/core/firebase/firebase_options.dart`
- Baixa `android/app/google-services.json`
- Baixa `ios/Runner/GoogleService-Info.plist`
- Aplica plugins Gradle (`google-services`, Crashlytics)
- Cria `firebase.json`

Quando pedir o projeto, escolha o **MiniPlay** criado no passo 1.

### Alternativa manual (equivalente)

```bash
flutterfire configure \
  --out=lib/core/firebase/firebase_options.dart \
  --android-package-name=com.miniplay.games \
  --ios-bundle-id=com.miniplay.games \
  --platforms=android,ios
```

---

## Passo 5 — Ativar no código

Edite `lib/core/firebase/firebase_config.dart`:

```dart
const bool kFirebaseConfigured = true;
```

**Não** altere `firebase_options.dart` manualmente — regenere com o script se precisar.

---

## Passo 6 — Validar localmente

```bash
flutter pub get
flutter analyze && flutter test
```

### Android

```bash
flutter run -d <seu-emulador-ou-device>
```

No Console → **Analytics → DebugView**, ative o modo debug no device:

```bash
adb shell setprop debug.firebase.analytics.app com.miniplay.games
```

### iOS (requer Mac)

```bash
cd ios && pod install && cd ..
flutter run -d <iphone-ou-simulador>
```

No Xcode, confirme que `GoogleService-Info.plist` está em **Runner** (o FlutterFire coloca em `ios/Runner/`).

---

## Passo 7 — Confirmar Crashlytics

1. Rode o app em **modo release** ou profile (Crashlytics ignora muitos erros em debug).
2. Force um crash de teste **temporário** (remova depois):

```dart
// Só para validar — apagar após ver o evento no Console
FirebaseBootstrap.crashlytics?.crash();
```

3. Aguarde alguns minutos em **Crashlytics** no Console.

---

## Passo 8 — Commitar arquivos gerados

Após configurar, versione (não contêm segredos críticos — as chaves são restritas por package/bundle):

- `lib/core/firebase/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase.json`
- Alteração em `lib/core/firebase/firebase_config.dart` (`kFirebaseConfigured = true`)

---

## CI (GitHub Actions)

O CI atual roda com `kFirebaseConfigured = false`, então **não precisa** de credenciais Firebase.

Quando quiser Firebase no CI (testes de integração ou builds release assinados):

1. Mantenha os arquivos acima no repositório.
2. Para deploy automatizado, use [Firebase App Distribution](https://firebase.google.com/docs/app-distribution) ou Fastlane com service account — fora do escopo deste guia.

---

## Solução de problemas

| Problema | Ação |
|---|---|
| `flutterfire: command not found` | `export PATH="$PATH:$HOME/.pub-cache/bin"` |
| `Firebase não configurado` em runtime | `kFirebaseConfigured = true` em `firebase_config.dart` |
| Build Android: `google-services.json` missing | Rode `./scripts/configure-firebase.sh` |
| Auth: `operation-not-allowed` | Ative **Anônimo** no Console (passo 2) |
| Crashlytics sem dados | Teste em release/profile; aguarde ~15 min |
| Regenerar config | `./scripts/configure-firebase.sh` (sobrescreve `firebase_options.dart`) |

---

## Referências

- [FlutterFire overview](https://firebase.flutter.dev/docs/overview)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- Código: `lib/core/firebase/firebase_bootstrap.dart`
