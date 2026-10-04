#!/usr/bin/env bash
# Tarefa 12: os textos em rascunho não existem no site publicado.
source "$(dirname "$0")/lib.sh"
for s in endividamento-familias-financeirizacao impactos-setoriais-mercosul-ue eficacia-politica-monetaria-expectativas-racionais subdesenvolvimento-visao-schumpeteriana risco-cibernetico-sistemico-sistema-financeiro; do
  nao_existe "publicacoes/n01/$s/index.html" "texto $s ausente do _site"
done
nao_existe publicacoes/_modelo-texto "pasta-modelo ausente"
nao_tem publicacoes/index.html 'class="lista-textos' "P4 continua oculto"
nao_tem sitemap.xml 'publicacoes/n01' "fascículo e textos fora do sitemap"
nao_tem listings.json 'publicacoes/n01' "fascículo e textos fora do listings.json"
r=$(git ls-files '*.pdf' | wc -l | tr -d ' ')
[ "$r" = "0" ] && ok "nenhum PDF no Git" || falha "há $r PDF(s) no Git"
fim
