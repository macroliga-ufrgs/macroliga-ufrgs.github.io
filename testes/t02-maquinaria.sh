#!/usr/bin/env bash
# Tarefa 2: maquinaria comum (Open Graph, menu, pular para o conteúdo, rascunhos).
source "$(dirname "$0")/lib.sh"
tem index.html '<a class="pular" href="#quarto-document-content">Pular para o conteúdo</a>' "link Pular para o conteúdo"
tem index.html '<main id="quarto-document-content"' "alvo do link de pular é o <main>"
sed -n '/<body/,/<header/p' "$SITE/index.html" | grep -q 'class="pular"' && ok "link de pular é o primeiro item da página" || falha "link de pular depois do cabeçalho"
tem index.html 'site_libs/quarto-contrib/macroliga-menu-1\.0/menu\.js' "menu.js anexado"
existe site_libs/quarto-contrib/macroliga-menu-1.0/menu.js "menu.js copiado para site_libs"
tem index.html '<meta property="og:title"' "og:title"
tem index.html '<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/assets/marca/png/macroliga-og\.png"' "og:image padrão é o selo"
tem index.html '<meta property="og:description" content="[^"]+' "og:description preenchida"
# A imagem de compartilhamento existe em toda página (LinkedIn e Instagram não mostram SVG).
OG='<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/assets/marca/png/macroliga-og\.png"'
for p in sobre.html equipe.html participe.html publicacoes/index.html eventos/index.html eventos/2026-11-27-lancamento-n01/index.html; do
  tem "$p" "$OG" "og:image do selo em $p"
done
nenhum_html '<meta property="og:image" content="[^"]*\.svg"' "nenhum og:image em SVG"
tem_css '\.navbar-toggler:focus-visible' "botão do menu com foco visível"
tem index.html 'https://macroliga\.goatcounter\.com/count' "GoatCounter com o código de _variables.yml"
tem index.html 'location\.hostname' "o script não conta visitas em localhost"
nenhum_html '(href|src)="/[^/]' "nenhum link começa com / (exceto a 404)" '/404\.html$'
fim
