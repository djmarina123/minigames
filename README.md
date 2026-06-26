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

## Configurar Firebase

Guia completo: [`docs/firebase-setup.md`](docs/firebase-setup.md)

Resumo:

1. Crie o projeto **MiniPlay** no [Firebase Console](https://console.firebase.google.com/)
2. Ative **Auth anônimo** e **Crashlytics**
3. `npm install -g firebase-tools && firebase login`
4. `./scripts/configure-firebase.sh`
5. Em `lib/core/firebase/firebase_config.dart`, altere `kFirebaseConfigured` para `true`

## Publicar na Play Store

- Listagem ASO (textos, screenshots, palavras-chave): [`docs/play-store-listing.md`](docs/play-store-listing.md)
- Beta fechado passo a passo: [`docs/play-store-closed-beta.md`](docs/play-store-closed-beta.md)

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

