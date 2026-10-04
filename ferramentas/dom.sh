#!/usr/bin/env bash
# Imprime o HTML de uma página depois de o JavaScript rodar (Chrome sem janela).
# Uso: bash ferramentas/dom.sh [-s pasta] "caminho?consulta"
set -euo pipefail
PASTA=_site
while getopts "s:" op; do case $op in s) PASTA=$OPTARG ;; *) exit 2 ;; esac; done
shift $((OPTIND - 1))
CHROME="${CHROME:-/c/Program Files/Google/Chrome/Application/chrome.exe}"
PORTA=8771
python -m http.server "$PORTA" --bind 127.0.0.1 -d "$PASTA" >/dev/null 2>&1 &
SERVIDOR=$!
trap 'kill $SERVIDOR 2>/dev/null || true' EXIT
for _ in $(seq 1 300); do curl -s -o /dev/null "http://127.0.0.1:$PORTA/" && break; done
"$CHROME" --headless=new --disable-gpu --virtual-time-budget=3000 --dump-dom "http://127.0.0.1:$PORTA/$1" 2>/dev/null
