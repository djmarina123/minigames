# MiniPlay

Hub de minijogos casuais para mobile (Android primeiro, iOS depois).

Roadmap: [`PLANO.md`](PLANO.md) · guia para agentes: [`AGENTS.md`](AGENTS.md) · [`docs/agents/`](docs/agents/)

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

Ver [`docs/agents/project.md`](docs/agents/project.md).

## GitHub

Repositório remoto: **https://github.com/djmarina123/minigames**

### Chaves SSH separadas (Senado vs GitHub)

Este projeto usa uma **chave SSH própria** para o GitHub. A chave `id_rsa` existente continua sendo usada nos repositórios do Senado — não mexa nela.

Configuração em `~/.ssh/config`:

- `github.com` → `~/.ssh/id_ed25519_github` (pessoal)
- demais hosts → chave padrão do Senado (`id_rsa`)

### Cadastrar a chave no GitHub (uma vez)

```bash
cat ~/.ssh/id_ed25519_github.pub
```

Copie a saída e adicione em [github.com/settings/keys](https://github.com/settings/keys) → **New SSH key**.

### Enviar o código

```bash
ssh -T git@github.com
# Esperado: "Hi djmarina123! You've successfully authenticated..."

cd /home/marina/projetos/minigames
git push -u origin main
```

Identidade Git **só neste repositório** (não altera projetos do Senado):

- `user.name` = `djmarina123`
- `user.email` = `djmarina123@users.noreply.github.com`

### CI

O workflow `.github/workflows/ci.yml` roda `flutter analyze` e `flutter test` em cada push/PR para `main`.

