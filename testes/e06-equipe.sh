#!/usr/bin/env bash
# Tarefa 6: estados da Equipe (foto preenchida; eixo com nome errado).
source "$(dirname "$0")/lib.sh"
criar assets/equipe/teste.png < assets/marca/png/macroliga-favicon-512.png
trocar equipe.yml '0,/foto: ""/s||foto: "assets/equipe/teste.png"|'
renderizar equipe.qmd
tem equipe.html '<img class="membro__foto" src="assets/equipe/teste\.png" alt="Foto de [^"]+"' "foto aparece acima do nome"
desfazer
trocar equipe.yml 's|- nome: "Mercados externos"|- nome: "Mercados Externos"|'
deve_falhar 'o eixo "Mercados Externos" não existe' "eixo da equipe fora de _variables.yml para o render" equipe.qmd
fim
