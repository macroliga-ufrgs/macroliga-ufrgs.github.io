#!/usr/bin/env bash
# Validação das páginas de redirecionamento (endereços curtos da página final).
source "$(dirname "$0")/lib.sh"
F=n01/opine/index.qmd
trocar "$F" 's|^canal: impresso|canal: papel|'
deve_falhar 'o canal "papel" não existe. Use "impresso" ou "PDF".' "canal inválido para o render" "$F"
desfazer
trocar "$F" '/^canal:/d' '/^numero:/d'
deve_falhar 'preencha "destino" ou o par "numero" e "canal"' "sem destino nem canal para o render" "$F"
desfazer
fim
