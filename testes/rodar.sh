#!/usr/bin/env bash
# Roda os testes do site. Uso: bash testes/rodar.sh       (todos)
#                              bash testes/rodar.sh 04    (só os que têm "04" no nome)
# Ordem: testes de estado (e*), que mexem no YAML e renderizam o que precisam;
# depois o render limpo dos dois perfis; depois os testes t* (_site) e r* (_site-rascunhos).
cd "$(dirname "$0")/.." || exit 1
FILTRO="${1:-}"
STATUS=0
roda() {
  local t
  for t in "$@"; do
    [ -e "$t" ] || continue
    case "$(basename "$t")" in *"$FILTRO"*) ;; *) continue ;; esac
    echo "== $t"
    bash "$t" || STATUS=1
  done
}
roda testes/e*.sh
echo "== quarto render"
if ! quarto render > testes/.render.log 2>&1; then tail -40 testes/.render.log; echo "quarto render falhou."; exit 1; fi
grep -E "WARN" testes/.render.log | sort -u | sed 's/^/  aviso do Quarto: /'
echo "== quarto render --profile rascunhos"
if ! quarto render --profile rascunhos > testes/.render-rascunhos.log 2>&1; then
  tail -40 testes/.render-rascunhos.log; echo "quarto render --profile rascunhos falhou."; exit 1
fi
roda testes/t*.sh testes/r*.sh
exit $STATUS
