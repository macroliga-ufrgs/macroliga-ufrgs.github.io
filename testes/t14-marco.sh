#!/usr/bin/env bash
# Tarefa 14: critérios automáticos do site mínimo (spec 6.1).
source "$(dirname "$0")/lib.sh"
for p in index.html sobre.html equipe.html participe.html 404.html publicacoes/index.html eventos/index.html eventos/2026-11-27-lancamento-n01/index.html; do
  existe "$p" "no ar: $p"
done
nao_tem index.html 'Gráficos comentados' "menu sem Gráficos comentados (D1)"
nao_existe graficos "graficos/ ainda não existe"
nenhum_html 'Saiba mais' "sem Saiba mais"
nenhum_html '→' "sem seta colada em link"
nenhum_html ' · ' "sem · entre metadados"
r=$(grep -rln "Pontos de Macro" --include='*.qmd' --include='*.yml' --include='*.lua' --include='*.ejs' --include='*.scss' --include='*.js' . \
  | grep -v -e '^./_variables.yml$' -e '^./_site' -e '^./docs/' -e '^./conteudo/' -e '^./wireframes/' -e '^./design/' -e '^./_freeze/')
[ -z "$r" ] && ok "Pontos de Macro só em _variables.yml" || falha "Pontos de Macro também em: $r"
r=$(git ls-files 'rascunhos/*' '*.pdf' | wc -l | tr -d ' ')
[ "$r" = "0" ] && ok "nem rascunhos/ nem PDF no Git" || falha "$r arquivo(s) de rascunho/PDF no Git"
grep -q '\[a preencher\]' equipe.yml && aviso "equipe.yml ainda tem [a preencher]: a gestão precisa preencher antes de publicar" || ok "equipe.yml preenchido"
fim
