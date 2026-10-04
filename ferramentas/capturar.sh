#!/usr/bin/env bash
# Screenshots de página inteira, com o Chrome instalado (via Playwright, sem instalar nada no site).
# Uso: bash ferramentas/capturar.sh [-s pasta] [-l "390 1280"] nome=caminho [nome=caminho ...]
#   -s  pasta servida (padrão: _site; para ver rascunhos, _site-rascunhos; para a prancha, .)
#   -l  larguras em px (padrão: "390 1280")
# Saída: capturas/<nome>-<largura>.png (pasta ignorada pelo Git).
set -euo pipefail
PASTA=_site
LARGURAS="390 1280"
while getopts "s:l:" op; do
  case $op in s) PASTA=$OPTARG ;; l) LARGURAS=$OPTARG ;; *) exit 2 ;; esac
done
shift $((OPTIND - 1))
PORTA=8770
mkdir -p capturas
python -m http.server "$PORTA" --bind 127.0.0.1 -d "$PASTA" >/dev/null 2>&1 &
SERVIDOR=$!
trap 'kill $SERVIDOR 2>/dev/null || true' EXIT
for _ in $(seq 1 300); do curl -s -o /dev/null "http://127.0.0.1:$PORTA/" && break; done
for par in "$@"; do
  nome=${par%%=*}
  caminho=${par#*=}
  for largura in $LARGURAS; do
    npx --yes playwright@1.56.0 screenshot --channel chrome --full-page \
      --viewport-size="$largura,900" --wait-for-timeout=2500 \
      "http://127.0.0.1:$PORTA/$caminho" "capturas/$nome-$largura.png" >/dev/null
    echo "capturas/$nome-$largura.png"
  done
done
