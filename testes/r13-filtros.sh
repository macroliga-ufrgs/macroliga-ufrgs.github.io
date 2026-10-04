#!/usr/bin/env bash
# Tarefa 13: controles de filtro no HTML (sem JavaScript, ficam ocultos e a lista aparece inteira).
SITE=_site-rascunhos
source "$(dirname "$0")/lib.sh"
P=publicacoes/index.html
tem "$P" '<div class="filtros" data-filtros(="")? hidden(="")?>' "controles ocultos sem JS"
conta "$P" '<option value="[a-z-]+">' 10 "6 eixos + 4 tipos nas listas suspensas"
conta "$P" 'name="filtro-eixo"' 7 "botões de eixo: Todos + 6"
conta "$P" 'name="filtro-tipo"' 5 "botões de tipo: Todos + 4"
tem "$P" '<label for="filtro-eixo">Filtrar por eixo</label>' "rótulo do eixo"
tem "$P" 'id="filtros-resultado" role="status"' "resultado anunciado"
tem "$P" 'id="filtros-vazio" hidden(="")?' "estado vazio oculto"
tem "$P" 'Ainda não há textos com esses filtros\. Limpe os filtros para ver todos os textos\.' "texto do estado vazio"
nao_tem "$P" '<li class="item-texto"[^>]*hidden' "nenhum item oculto sem JS"
fim
