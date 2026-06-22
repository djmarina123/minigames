# Minigames Hub

Hub de jogos casuais para mobile (Android primeiro, iOS depois).

## Fase 0 — concluída

- Projeto Flutter com estrutura `lib/core`, `lib/features`, `lib/games`
- **Game SDK** (`lib/core/game_sdk/`) — contrato comum para todos os jogos
- **Firebase** preparado em modo stub (`kFirebaseConfigured = false`)
- **CI** — análise estática + testes no GitHub Actions
- Jogo demo **Demo Tap** para validar o fluxo hub → jogo → resultado

## Pré-requisitos

1. **Flutter** instalado ([guia oficial](https://docs.flutter.dev/get-started/install))
2. Para rodar no celular/emulador Android: **Android Studio** + SDK

O Flutter já foi instalado nesta máquina em `~/flutter`. Adicione ao seu `~/.bashrc`:

```bash
export PATH="$HOME/flutter/bin:$PATH"
```

Depois: `source ~/.bashrc` e confira com `flutter doctor`.

## Rodar o app

```bash
cd /home/marina/projetos/minigames
flutter pub get
flutter run
```

Sem Android SDK, você pode testar no **Chrome**:

```bash
flutter run -d chrome
```

## Testes

```bash
flutter test
flutter analyze
```

## Configurar Firebase (próximo passo seu)

1. Crie um projeto em [Firebase Console](https://console.firebase.google.com/)
2. Instale o FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
```

3. Na pasta do projeto:

```bash
flutterfire configure
```

4. Em `lib/core/firebase/firebase_options.dart`, altere `kFirebaseConfigured` para `true`
5. Baixe `google-services.json` (Android) e adicione plugins Gradle conforme [documentação FlutterFire](https://firebase.flutter.dev/docs/overview)

## Estrutura

```
lib/
├── main.dart              # bootstrap
├── app.dart               # MaterialApp
├── core/
│   ├── firebase/          # Auth, Analytics, Crashlytics
│   ├── game_sdk/          # contrato HubGame + registry + runner
│   └── theme/
├── features/
│   └── home/              # catálogo
└── games/
    └── demo/              # jogo de exemplo
```

## GitHub

Repositório remoto: **https://github.com/djmarina123/minigames**

### Autenticação (faça uma vez)

A chave SSH desta máquina ainda **não está** no GitHub. Adicione:

1. Copie a chave pública:

```bash
cat ~/.ssh/id_rsa.pub
```

2. No GitHub: **Settings → SSH and GPG keys → New SSH key** → cole e salve.

3. Teste e envie o código:

```bash
ssh -T git@github.com
cd /home/marina/projetos/minigames
git push -u origin main
```

**Alternativa (HTTPS + token):** crie um [Personal Access Token](https://github.com/settings/tokens) e use como senha no push.

### CI

O workflow `.github/workflows/ci.yml` roda `flutter analyze` e `flutter test` em cada push/PR para `main`.


Ver [PLANO.md](PLANO.md) — casca completa, 2 jogos Flame, moedas, ranking e AdMob.
