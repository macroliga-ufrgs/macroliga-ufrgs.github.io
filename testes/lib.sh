#!/usr/bin/env bash
# testes/lib.sh: funções dos testes do site (maquinaria: não mexa).
# Os testes conferem o HTML já renderizado em $SITE (padrão: _site).
SITE="${SITE:-_site}"
FALHAS=0
NBSP=$'\xc2\xa0'
NO="nº(&nbsp;|&#160;|${NBSP})"

ok()    { echo "  ok    $1"; }
falha() { echo "  FALHA $1"; FALHAS=$((FALHAS + 1)); }
aviso() { echo "  AVISO $1"; }

tem()        { if grep -Eq -- "$2" "$SITE/$1" 2>/dev/null; then ok "$3"; else falha "$3  [$1 não contém: $2]"; fi; }
nao_tem()    { if grep -Eq -- "$2" "$SITE/$1" 2>/dev/null; then falha "$3  [$1 contém: $2]"; else ok "$3"; fi; }
existe()     { if [ -e "$SITE/$1" ]; then ok "$2"; else falha "$2  [não existe: $1]"; fi; }
nao_existe() { if [ -e "$SITE/$1" ]; then falha "$2  [existe: $1]"; else ok "$2"; fi; }
conta() {
  local n
  n=$(grep -Eo -- "$2" "$SITE/$1" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$n" = "$3" ]; then ok "$4"; else falha "$4  [$1: $n ocorrência(s) de $2; esperado $3]"; fi
}
corpo_nao_tem() {
  if sed -n '/<body/,$p' "$SITE/$1" 2>/dev/null | grep -Eq -- "$2"; then
    falha "$3  [$1 contém no corpo: $2]"
  else ok "$3"; fi
}
nenhum_html() { # nenhum_html <padrão> <descrição> [<arquivos-a-ignorar (regex)>]
  local achados
  achados=$(grep -rlE --include='*.html' -- "$1" "$SITE" 2>/dev/null | grep -Ev -- "${3:-^$}" | head -5 | tr '\n' ' ')
  if [ -z "$achados" ]; then ok "$2"; else falha "$2  [$achados]"; fi
}
css() { ls "$SITE"/site_libs/bootstrap/bootstrap-*.min.css 2>/dev/null | head -1; }
tem_css() { if grep -Eq -- "$1" "$(css)"; then ok "$2"; else falha "$2  [CSS não contém: $1]"; fi; }

# Troca de estado (testes e*): guarda cópias e desfaz tudo ao sair.
ALTERADOS=()
CRIADOS=()
trocar() { # trocar <arquivo> <expressão-sed> [<expressão-sed>...]
  local a=$1 e
  shift
  if [ ! -e "$a.bak-teste" ]; then cp "$a" "$a.bak-teste"; ALTERADOS+=("$a"); fi
  for e in "$@"; do sed -i "$e" "$a"; done
}
criar() { # criar <arquivo>  (o conteúdo vem pela entrada padrão)
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  CRIADOS+=("$1")
}
criar_pasta() { mkdir -p "$1"; CRIADOS+=("$1"); }
desfazer() {
  local a
  for a in "${ALTERADOS[@]}"; do mv -f "$a.bak-teste" "$a"; done
  for a in "${CRIADOS[@]}"; do rm -rf "$a"; done
  ALTERADOS=()
  CRIADOS=()
}
trap desfazer EXIT
renderizar() { quarto render "$@" > testes/.render-estado.log 2>&1; }
deve_falhar() { # deve_falhar <trecho-da-mensagem> <descrição> <arquivos...>
  local msg=$1 desc=$2
  shift 2
  if quarto render "$@" > testes/.render-estado.log 2>&1; then
    falha "$desc  [o render não falhou]"
  elif grep -Fq -- "$msg" testes/.render-estado.log; then
    ok "$desc"
  else
    falha "$desc  [mensagem não encontrada: $msg]"
    tail -5 testes/.render-estado.log
  fi
}
fim() {
  echo
  if [ "$FALHAS" -gt 0 ]; then echo "$FALHAS falha(s)."; exit 1; fi
  echo "Tudo certo."
}
