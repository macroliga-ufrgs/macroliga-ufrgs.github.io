#!/usr/bin/env bash
# Tarefa 8: Publicações em 18/10 (P1 + P2 em breve; P3 e P4 ocultos).
source "$(dirname "$0")/lib.sh"
existe publicacoes/index.html "página Publicações"
tem publicacoes/index.html '<h1[^>]*>Publicações</h1>' "P1 título"
tem publicacoes/index.html 'Todos têm DOI e podem ser citados\.' "P1 frase"
tem publicacoes/index.html "Fascículo ${NO}1: em breve" "P2 em breve"
tem publicacoes/index.html "O fascículo ${NO}1 está em revisão\. O lançamento será realizado em data a ser definida\." "P2 aviso"
tem publicacoes/index.html 'Impactos setoriais do acordo Mercosul e União Europeia' "P2 lista de títulos"
nao_tem publicacoes/index.html 'class="lista-textos' "P4 oculto sem texto publicado"
nao_tem publicacoes/index.html 'Filtrar por eixo' "P3 oculto sem texto publicado"
tem index.html 'class="nav-link[^"]*" href="\./publicacoes/index\.html"' "Publicações no menu"
tem publicacoes/index.html '<a href="\.\./index\.html" class="navbar-brand' "logo leva à Início também nas subpastas"
# Com JavaScript: só Publicações marcada no menu (o menu.js não pode marcar Início).
ATIVOS=$(bash ferramentas/dom.sh publicacoes/index.html | grep -o '<a class="nav-link[^>]*aria-current="page"[^>]*>' | wc -l | tr -d ' ')
[ "$ATIVOS" = "1" ] && ok "menu marca só a seção atual" || falha "menu com $ATIVOS itens marcados"
fim
