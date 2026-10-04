#!/usr/bin/env bash
# Tarefa 7: seleção aberta e seleção aberta sem formulário.
source "$(dirname "$0")/lib.sh"
trocar participe.qmd 's|aberta: false|aberta: true|' 's|prazo: ""|prazo: "30 de outubro de 2026"|' \
  's|formulario: ""|formulario: "https://forms.gle/teste"|'
renderizar participe.qmd
tem participe.html 'Inscrições abertas até 30 de outubro de 2026\.' "PA2 seleção aberta"
tem participe.html 'id="pa-inscricao-topo"[^>]*>' "bloco de inscrição no topo"
tem participe.html 'href="https://forms\.gle/teste">Fazer inscrição no processo seletivo' "botão com o formulário"
nao_tem participe.html 'Não há processo seletivo aberto agora' "sem o aviso de fechada"
desfazer
trocar participe.qmd 's|aberta: false|aberta: true|'
deve_falhar 'falta o link do formulário' "seleção aberta sem formulário para o render" participe.qmd
fim
