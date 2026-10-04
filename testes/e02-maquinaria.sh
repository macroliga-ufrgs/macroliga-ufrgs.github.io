#!/usr/bin/env bash
# Tarefa 2: estados (GoatCounter preenchido, rascunho, nº + número).
source "$(dirname "$0")/lib.sh"

echo "-- GoatCounter com o código vazio"
trocar _variables.yml 's|goatcounter: "[^"]*"|goatcounter: ""|'
renderizar index.qmd
nao_tem index.html 'goatcounter' "sem GoatCounter com o código vazio"
desfazer

echo "-- página em rascunho e nº"
criar teste-rascunho.qmd <<'EOT'
---
title: "Teste de rascunho"
draft: true
---
Fascículo nº 1 e nº 12.
EOT
renderizar
nao_existe teste-rascunho.html "rascunho não existe no _site (página vazia apagada)"
quarto render --profile rascunhos > testes/.render-estado.log 2>&1
SITE=_site-rascunhos tem teste-rascunho.html "Teste de rascunho" "rascunho aparece no perfil rascunhos"
SITE=_site-rascunhos tem teste-rascunho.html "Fascículo ${NO}1 e ${NO}12" "nº e número unidos por espaço inseparável"
fim
