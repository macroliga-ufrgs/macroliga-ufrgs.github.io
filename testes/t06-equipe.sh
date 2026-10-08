#!/usr/bin/env bash
# Tarefa 6: Equipe (conselho, membros e fundadores).
source "$(dirname "$0")/lib.sh"
existe equipe.html "página Equipe"
tem equipe.html '<h1[^>]*>Equipe</h1>' "EQ1 título"
tem equipe.html 'Cerca de 15 estudantes de graduação da UFRGS' "EQ1 frase"
tem equipe.html '<h2 id="t-conselho"[^>]*>Conselho Executivo</h2>' "EQ2 seção do conselho"
tem equipe.html '<h2 id="t-membros"[^>]*>Membros</h2>' "EQ3 seção dos membros"
tem equipe.html '<h2 id="t-fundadores"[^>]*>Membros fundadores</h2>' "EQ4 seção dos fundadores"
# Ordem: conselho, membros, fundadores.
ordem=$(grep -Eo 'id="t-(conselho|membros|fundadores)"' "$SITE/equipe.html" | tr '\n' ' ')
[ "$ordem" = 'id="t-conselho" id="t-membros" id="t-fundadores" ' ] && ok "ordem das seções" || falha "ordem das seções  [$ordem]"
conta equipe.html '<span class="membro__cargo">Presidente</span>' 1 "EQ2 um presidente"
tem equipe.html '<span class="membro__cargo">Conselheira</span>' "EQ2 cargo no feminino"
tem equipe.html '<span class="membro__cargo">Conselheiro</span>' "EQ2 cargo no masculino"
sed -n '/id="t-fundadores"/,/<\/section>/p' "$SITE/equipe.html" | grep -o 'class="membro"' | wc -l | grep -qx 5 \
  && ok "EQ4 cinco fundadores" || falha "EQ4 cinco fundadores"
nao_tem equipe.html 'Diretorias|Eixos temáticos' "sem diretorias nem eixos"
nao_tem equipe.html 'class="membro__foto"' "sem fotos enquanto o campo foto está vazio"
tem equipe.html 'Ver como participar' "EQ5 botão"
tem equipe.html 'Site feito por membros da liga' "rodapé novo"
nao_tem equipe.html 'equipe de Comunicação' "rodapé sem a diretoria de Comunicação"
sed -n '/<main/,/<\/main>/p' "$SITE/equipe.html" | grep -q 'Leonardo Xavier' && falha "coordenação no conteúdo da Equipe" || ok "coordenação não aparece no conteúdo da Equipe (só G2 e S5)"
fim
