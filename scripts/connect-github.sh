#!/usr/bin/env bash
# Conecta o repositório local ao GitHub e faz o primeiro push.
# Uso: ./scripts/connect-github.sh git@github.com:USUARIO/minigames.git

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: $0 <url-do-repositorio>"
  echo "Exemplo SSH:  $0 git@github.com:marinajungblut/minigames.git"
  echo "Exemplo HTTPS: $0 https://github.com/marinajungblut/minigames.git"
  exit 1
fi

REPO_URL="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -d .git ]; then
  git init -b main
fi

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

git add -A
if git diff --cached --quiet; then
  echo "Nada novo para commitar."
else
  git commit -m "$(cat <<'EOF'
Inicializa hub de minigames (Fase 0).

Projeto Flutter com Game SDK, jogo demo, Firebase stub e CI.
EOF
)"
fi

git push -u origin main
echo "Repositório conectado e push concluído: $REPO_URL"
