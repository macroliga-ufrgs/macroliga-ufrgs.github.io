#!/usr/bin/env bash
# Tarefa 14: troca do nome da publicação e site sob subcaminho.
source "$(dirname "$0")/lib.sh"

echo "-- trocar o nome da publicação"
trocar _variables.yml 's|nome: "Pontos de Macro"|nome: "Nome Teste"|'
quarto render --profile rascunhos > testes/.render-estado.log 2>&1
SITE=_site-rascunhos nenhum_html 'Pontos de Macro' "nenhuma página com o nome antigo"
SITE=_site-rascunhos tem publicacoes/n01/index.html "Nome Teste ${NO}1" "fascículo com o nome novo"
SITE=_site-rascunhos tem publicacoes/n01/impactos-setoriais-mercosul-ue/index.html '<strong>Nome Teste</strong>' "citação com o nome novo"
desfazer

echo "-- site sob /macroliga"
quarto render --profile subcaminho > testes/.render-estado.log 2>&1
rm -rf capturas/servidor && mkdir -p capturas/servidor && cp -r _site-subcaminho capturas/servidor/macroliga
python -m http.server 8772 --bind 127.0.0.1 -d capturas/servidor >/dev/null 2>&1 &
SERVIDOR=$!
for _ in $(seq 1 300); do curl -s -o /dev/null http://127.0.0.1:8772/ && break; done
if python ferramentas/conferir-links.py http://127.0.0.1:8772/macroliga/index.html > testes/.render-links.log 2>&1; then
  ok "todos os links funcionam sob /macroliga ($(head -1 testes/.render-links.log))"
else
  falha "links quebrados sob /macroliga"; grep ERRO testes/.render-links.log | head -10
fi
curl -s http://127.0.0.1:8772/macroliga/404.html | grep -qE 'href="/macroliga/(./)?index.html"' \
  && ok "404 com links sob /macroliga (funciona aberta de um endereço profundo)" || falha "404 sem o caminho do subcaminho"
curl -s http://127.0.0.1:8772/macroliga/404.html | grep -q 'href="/macroliga/site_libs/' \
  && ok "404 com CSS sob /macroliga" || falha "CSS da 404 fora do subcaminho"
kill $SERVIDOR
rm -rf capturas/servidor
fim
