#!/usr/bin/env bash
# Tarefa 13: filtros com JavaScript (DOM depois de o script rodar).
source "$(dirname "$0")/lib.sh"
dom() { bash ferramentas/dom.sh -s _site-rascunhos "publicacoes/index.html$1"; }
visiveis() { grep -o '<li class="item-texto"[^>]*>' | grep -vc 'hidden'; }
confere() { # confere <consulta> <esperado> <descrição>
  local n; n=$(dom "$1" | visiveis)
  [ "$n" = "$2" ] && ok "$3 ($n)" || falha "$3: $n visíveis, esperado $2"
}
confere "" 4 "sem filtro: todos"
confere "?eixo=setor-externo-e-cambio" 1 "eixo sozinho"
confere "?eixo=atividade-economica-mercado-de-trabalho-e-credito" 2 "eixo com dois textos"
confere "?tipo=analise-de-conjuntura" 2 "tipo sozinho"
confere "?eixo=atividade-economica-mercado-de-trabalho-e-credito&tipo=analise-de-conjuntura" 1 "eixo E tipo"
confere "?eixo=mercados-externos" 0 "sem resultado"
dom "?eixo=mercados-externos" | grep -q 'id="filtros-vazio" hidden' && falha "estado vazio deveria aparecer" || ok "estado vazio aparece"
confere "?eixo=inexistente&tipo=xyz" 4 "filtro inválido no endereço: lista inteira"
dom "?eixo=inexistente" | grep -q 'id="filtros-vazio" hidden' && ok "filtro inválido não mostra estado vazio" || falha "filtro inválido mostrou estado vazio"
dom "" | grep -qE 'data-filtros(="")? hidden' && falha "controles deveriam aparecer com JS" || ok "controles aparecem com JS"
dom "?eixo=setor-externo-e-cambio" | grep -Eq '1 texto encontrado\.' && ok "resultado anunciado no singular" || falha "anúncio do resultado"
dom "?eixo=mercados-externos" | grep -qE '<ul class="lista-textos lista-textos--filtravel" hidden' && ok "lista vazia oculta (sem linha de eixo solta)" || falha "lista vazia continua visível"
fim
