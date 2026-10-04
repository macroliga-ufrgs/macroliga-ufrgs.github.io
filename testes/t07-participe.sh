#!/usr/bin/env bash
# Tarefa 7: Participe com a seleção fechada.
source "$(dirname "$0")/lib.sh"
existe participe.html "página Participe"
tem participe.html '<h1[^>]*>Participe</h1>' "PA1 título"
tem participe.html 'pertencentes a qualquer curso' "PA1 texto"
tem participe.html 'Não há processo seletivo aberto agora\.' "PA2 seleção fechada"
nao_tem participe.html 'Fazer inscrição no processo seletivo' "sem botão de inscrição com a seleção fechada"
tem participe.html 'O que se espera do membro' "PA3"
tem participe.html 'href="modelos/modelo-macroliga\.docx"[^>]*>Baixar modelo em Word' "PA4 Word"
tem participe.html 'href="modelos/modelo-macroliga\.zip"[^>]*>Baixar modelo em LaTeX' "PA4 LaTeX"
existe modelos/modelo-macroliga.docx "modelo Word copiado para o site"
existe modelos/modelo-macroliga.zip "modelo LaTeX copiado para o site"
tem participe.html 'Escrever para a liga' "PA5"
fim
