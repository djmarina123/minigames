# Workflow do agente

## Encerramento de sessão ("pronto")

Quando o usuário digitar **"pronto"** (ou typo equivalente):

1. Conferir tarefa concluída (testes/análise local se aplicável).
2. **`git commit`** — mensagem em português, foco no *porquê*.
   - **Escopo do commit:** somente arquivos que **este agente** criou ou alterou nesta sessão (via edições no contexto da conversa).
   - **Não** usar `git add .`, `git add -A` nem commitar tudo que aparece em `git status` — outros agentes ou o usuário podem ter mudanças paralelas no working tree.
   - Montar a lista a partir do histórico da sessão (Write/StrReplace/Delete); conferir com `git diff` / `git status` antes de `git add <caminhos…>`.
   - Se um arquivo tocado por este agente também foi alterado por outra sessão, incluir só se as mudanças forem claramente desta tarefa; caso contrário, avisar o usuário em vez de misturar commits.
3. **`git push`** (autorizado pelo "pronto").
4. Acompanhar CI (`.github/workflows/ci.yml` — `flutter analyze` + `flutter test`):
   - `gh run watch --exit-status` no run mais recente do branch, **ou**
   - `gh run list --branch <branch> --limit 1` + `gh run view <id> --log-failed`.
5. Se CI falhar: corrigir, `flutter analyze && flutter test`, commit + push, repetir até verde.
6. Só encerrar quando commit, push **e** CI OK (ou reportar bloqueio).

Fora do "pronto", **não** commitar nem dar push sem pedido explícito.

## Convenções de código

1. **Escopo mínimo** — só o necessário para a tarefa.
2. **Seguir padrões existentes** — nomes, pastas, imports relativos a `lib/`.
3. **Stub first** — Firebase/AdMob offline até configurar (`kFirebaseConfigured`, `kAdsConfigured`).
4. **Persistência MVP** — `shared_preferences` (Firestore quando configurado).
5. **Testes** — rodar `flutter test` antes de encerrar; jogo Flame novo → `test/games/*_config_test.dart`; UI do hub → `--update-goldens`.
6. **UI em PT-BR.**

## Como rodar

```bash
flutter run -d chrome              # dev rápido (browser)
flutter run -d emulator-5554       # Android
flutter analyze && flutter test    # CI local
flutter test test/golden/ --update-goldens   # após mudar UI da Home
```

Emulador recomendado: **Pixel 6a**, API 34, x86_64, **sem** imagem 16KB.
