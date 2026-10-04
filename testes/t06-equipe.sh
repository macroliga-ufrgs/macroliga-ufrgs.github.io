#!/usr/bin/env bash
# Tarefa 6: Equipe.
source "$(dirname "$0")/lib.sh"
existe equipe.html "página Equipe"
tem equipe.html '<h1[^>]*>Equipe</h1>' "EQ1 título"
tem equipe.html 'Cerca de 15 estudantes de graduação da UFRGS' "EQ1 frase"
for d in "Presidência" "Vice-Presidência e Tesouraria" "Comunicação \(Marketing e Design\)" "Outreach"; do
  tem equipe.html "<h3>$d</h3>" "EQ2 diretoria $d"
done
conta equipe.html 'class="equipe-grupo equipe-eixo"' 6 "EQ3 seis eixos"
conta equipe.html 'href="publicacoes/index\.html\?eixo=' 6 "EQ3 links filtrados"
nao_tem equipe.html 'class="membro__foto"' "sem fotos enquanto o campo foto está vazio"
tem equipe.html 'Ver como participar' "EQ4 botão"
sed -n '/<main/,/<\/main>/p' "$SITE/equipe.html" | grep -q 'Leonardo Xavier' && falha "coordenação no conteúdo da Equipe" || ok "coordenação não aparece no conteúdo da Equipe (só G2 e S5)"
fim
