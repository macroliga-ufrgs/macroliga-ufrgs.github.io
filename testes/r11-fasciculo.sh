#!/usr/bin/env bash
# Tarefa 11: o fascículo completo no perfil rascunhos (F1–F6).
SITE=_site-rascunhos
source "$(dirname "$0")/lib.sh"
P=publicacoes/n01/index.html
existe "$P" "fascículo nº 1 no perfil rascunhos"
tem "$P" "<title>Pontos de Macro ${NO}1 – MacroLiga UFRGS</title>" "<title> montado com o nome da publicação"
tem "$P" "href=\"(\.\./index|\.\./\.\./publicacoes/index)\.html\">Publicações</a> / Fascículo ${NO}1" "F1 trilha"
tem "$P" "<h1 class=\"fasciculo-pagina__titulo\">Pontos de Macro ${NO}1</h1>" "F2 título"
tem "$P" '<img class="fasciculo__capa" src="capa\.png" alt="Capa do fascículo' "F2 capa com alt"
tem "$P" 'Publicado em: 27 de novembro de 2026' "F2 data"
tem "$P" 'O PDF fica disponível no lançamento do fascículo\.' "F2 sem PDF"
tem "$P" '<h2 id="t-sumario">Sumário</h2>' "F3 título"
tem "$P" "Ver o evento de lançamento" "F4 link para o evento"
tem "$P" 'Os textos publicados não representam a posição da MacroLiga UFRGS' "F6"
tem "$P" '<meta property="og:title" content="Pontos de Macro nº 1">' "og:title do fascículo"
tem "$P" '<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/publicacoes/n01/capa\.png"' "og:image é a capa"
tem publicacoes/index.html 'id="listing-lista-em-breve"[^>]*hidden' "P2: em breve oculto quando o nº 1 está visível"
tem publicacoes/index.html '<img class="fasciculo__capa" src="[^"]*n01/capa\.png"' "P2 com a capa"
# Com a capa na página, Início e Publicações continuam compartilhando o selo (spec 4.5).
for p in index.html publicacoes/index.html; do
  tem "$p" '<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/assets/marca/png/macroliga-og\.png"' "og:image de $p é o selo"
done
fim
