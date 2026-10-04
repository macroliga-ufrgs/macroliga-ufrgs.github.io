#!/usr/bin/env bash
# Tarefa 8: nenhum fascículo publicado e em-breve.yml vazio.
source "$(dirname "$0")/lib.sh"
cp publicacoes/em-breve.yml publicacoes/em-breve.yml.bak-teste && ALTERADOS+=("publicacoes/em-breve.yml")
printf '[]\n' > publicacoes/em-breve.yml
renderizar index.qmd publicacoes/index.qmd
tem index.html '<a class="botao" href="(\./)?publicacoes/index\.html">Ver as publicações</a>' "I1 vira Ver as publicações"
tem index.html 'id="fasciculo"[^>]*hidden' "I2 inteiro oculto"
nao_tem publicacoes/index.html 'em breve' "P2 sem em breve"
fim
