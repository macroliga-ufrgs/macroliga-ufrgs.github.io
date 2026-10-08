#!/usr/bin/env bash
# Tarefa 6: estados da Equipe (membros vazio ou preenchido; foto; gênero inválido; dois presidentes; formato antigo).
source "$(dirname "$0")/lib.sh"
trocar equipe.yml '/^membros:/,/^fundadores:/{/^  - /d}' 's|^membros:.*|membros: []|'
renderizar equipe.qmd
nao_tem equipe.html 'id="t-membros"' "membros vazio: a seção Membros não aparece"
desfazer
trocar equipe.yml 's|^membros:.*|membros:\n  - { nome: "Pessoa de Teste", foto: "" }|'
renderizar equipe.qmd
ordem=$(grep -Eo 'id="t-(conselho|membros|fundadores)"' "$SITE/equipe.html" | tr '\n' ' ')
[ "$ordem" = 'id="t-conselho" id="t-membros" id="t-fundadores" ' ] && ok "membros preenchido: seção entre conselho e fundadores" || falha "ordem das seções com membros  [$ordem]"
tem equipe.html '<span class="membro__nome">Pessoa de Teste</span>' "membro aparece pelo nome"
desfazer
criar assets/equipe/teste.png < assets/marca/png/macroliga-favicon-512.png
trocar equipe.yml '0,/foto: ""/s||foto: "assets/equipe/teste.png"|'
renderizar equipe.qmd
tem equipe.html '<img class="membro__foto" src="assets/equipe/teste\.png" alt="Foto de [^"]+"' "foto aparece acima do nome"
desfazer
trocar equipe.yml '0,/genero: "masculino", /s||genero: "Feminino!", |'
deve_falhar 'o gênero "Feminino!" não é válido' "gênero fora da lista para o render" equipe.qmd
desfazer
trocar equipe.yml 's|presidente: false|presidente: true|'
deve_falhar 'mais de uma pessoa com presidente: true' "dois presidentes param o render" equipe.qmd
desfazer
trocar equipe.yml '1i diretorias: []'
deve_falhar 'equipe.yml está no formato antigo' "formato antigo (diretorias) para o render" equipe.qmd
fim
