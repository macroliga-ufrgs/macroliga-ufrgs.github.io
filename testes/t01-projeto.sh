#!/usr/bin/env bash
# Tarefa 1: projeto mínimo, marca e fontes.
source "$(dirname "$0")/lib.sh"
existe index.html "a Início é gerada"
tem index.html '<html[^>]*lang="pt"' "lang pt"
nao_existe CLAUDE.html "CLAUDE.md não vira página"
nao_existe PLANO-SITE.html "PLANO-SITE.md não vira página"
nao_existe docs "docs/ não vai para o site"
nao_existe conteudo "conteudo/ não vai para o site"
nao_existe wireframes "wireframes/ não vão para o site"
nao_existe design "design/ não vai para o site"
# O pedido da Inter pode estar no HTML ou num @import do CSS; o da Libre Baskerville está no HTML.
FONTES=$(cat "$SITE/index.html" "$(css)" 2>/dev/null | grep -oE 'fonts\.googleapis\.com/css2\?[^")'"'"' ]*' | sed 's/&amp;/\&/g' | sort -u)
echo "$FONTES" | grep -qE 'family=Inter:wght@400;700&display=swap' && ok "Inter só com 400 e 700" || falha "Inter: $FONTES"
echo "$FONTES" | grep -qE 'family=Libre\+Baskerville:wght@400\.\.560&display=swap' && ok "Libre Baskerville variável 400–560" || falha "Libre Baskerville: $FONTES"
[ "$(echo "$FONTES" | grep -c .)" = "2" ] && ok "só dois pedidos de fonte" || falha "pedidos de fonte: $FONTES"
echo "$FONTES" | grep -q 'ital' && falha "itálicos carregados" || ok "sem itálicos"
nenhum_html 'bootstrap-dark' "sem CSS de modo escuro"
tem_css '--azul-marinho: ?#083D6B' "token --azul-marinho vem do _brand.yml"
tem_css '--fs-display' "tokens tipográficos no CSS"
tem index.html 'macroliga-favicon-180.png' "favicon da marca"
nenhum_html 'id="quarto-search"|search\.json' "sem caixa de busca (D10)"
nao_existe site_libs/quarto-search "sem biblioteca de busca (D10)"
nao_existe search.json "sem índice de busca (D10)"
fim
