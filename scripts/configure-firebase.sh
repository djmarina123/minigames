#!/usr/bin/env bash
# Configura Firebase no MiniPlay via FlutterFire CLI.
# Pré-requisitos: docs/firebase-setup.md (passos 1–3)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Node 20+ e CLIs (nvm / instalação local)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
  nvm use 22 >/dev/null 2>&1 || nvm use 20 >/dev/null 2>&1 || true
fi
export PATH="$HOME/.local/bin:$HOME/.pub-cache/bin:$PATH"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Erro: Flutter não encontrado no PATH." >&2
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "Erro: Firebase CLI não encontrado." >&2
  echo "Instale com (Node 20+):" >&2
  echo "  npm install --prefix ~/.local -g firebase-tools" >&2
  echo "Depois: firebase login" >&2
  exit 1
fi

if ! firebase login:list 2>/dev/null | grep -q '@'; then
  echo "Erro: Firebase não autenticado." >&2
  echo "Rode primeiro: firebase login" >&2
  exit 1
fi

echo "→ Ativando FlutterFire CLI..."
dart pub global activate flutterfire_cli

if ! command -v flutterfire >/dev/null 2>&1; then
  echo "Erro: flutterfire não está no PATH após instalação." >&2
  echo "Adicione ao seu shell: export PATH=\"\$PATH:\$HOME/.pub-cache/bin\"" >&2
  exit 1
fi

PROJECT_ID="${FIREBASE_PROJECT_ID:-miniplay-5ea9f}"

echo "→ Configurando Firebase (projeto: $PROJECT_ID)..."
flutterfire configure \
  --project="$PROJECT_ID" \
  --yes \
  --out=lib/core/firebase/firebase_options.dart \
  --android-package-name=com.miniplay.games \
  --ios-bundle-id=com.miniplay.games \
  --platforms=android,ios

echo ""
echo "✓ Arquivos gerados:"
echo "  - lib/core/firebase/firebase_options.dart"
echo "  - android/app/google-services.json"
echo "  - ios/Runner/GoogleService-Info.plist"
echo "  - firebase.json"
echo ""
echo "Próximo passo manual:"
echo "  1. Abra lib/core/firebase/firebase_config.dart"
echo "  2. Altere kFirebaseConfigured para true"
echo "  3. Siga docs/firebase-setup.md (passos 5–7)"
echo ""
