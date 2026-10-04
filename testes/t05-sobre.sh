#!/usr/bin/env bash
# Tarefa 5: Sobre.
source "$(dirname "$0")/lib.sh"
existe sobre.html "página Sobre"
tem sobre.html '<h1[^>]*>Sobre a liga</h1>' "S1 título"
tem sobre.html 'integração entre a teoria e prática científica' "S1 missão"
tem sobre.html 'macroliga-selo-cor\.svg' "selo"
tem sobre.html 'id="como-funcionamos"' "S2 âncora"
conta sobre.html 'class="etapa( |")' 4 "S2 quatro etapas"
tem sobre.html 'Cada fascículo é lançado em um evento presencial na FCE' "S2 texto longo"
conta sobre.html 'href="publicacoes/index\.html\?eixo=' 6 "S3 seis eixos com link filtrado"
tem sobre.html 'href="publicacoes/index\.html\?eixo=atividade-economica-mercado-de-trabalho-e-credito"' "slug sem acento nem vírgula"
tem sobre.html 'class="[^"]*pluralidade[^"]*fundo-azul|class="[^"]*fundo-azul[^"]*pluralidade' "S4 em bloco azul"
tem sobre.html 'A coordenação é do prof\. Leonardo Xavier da Silva' "S5 coordenação de _variables.yml"
tem sobre.html 'Ver a equipe' "S5 botão equipe"
tem index.html 'class="nav-link[^"]*" href="\./sobre\.html"' "Sobre no menu"
fim
