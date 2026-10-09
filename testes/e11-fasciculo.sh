#!/usr/bin/env bash
# Tarefa 11: validação do fascículo.
source "$(dirname "$0")/lib.sh"
F=publicacoes/n01/index.qmd
trocar "$F" 's|^draft: true|draft: false|'
deve_falhar 'o arquivo "fasciculo.pdf" (campo "pdf") não está na pasta publicacoes/n01' "publicado sem PDF para o render" "$F"
desfazer
trocar "$F" 's|^numero: 1|numero:|'
deve_falhar 'o campo "numero" está vazio' "número vazio para o render" "$F"
desfazer
echo "-- questionário com campo da página"
trocar _variables.yml 's|^  url: "[^"]*"|  url: "https://docs.google.com/forms/d/e/TESTE/viewform"|' 's|campo-pagina: "[^"]*"|campo-pagina: "entry.123"|'
quarto render "$F" --profile rascunhos > testes/.render-estado.log 2>&1
SITE=_site-rascunhos tem publicacoes/n01/index.html 'viewform\?usp=pp_url&amp;entry\.123=Pontos%20de%20Macro%20n%C2%BA%C2%A01' "F5 abre o formulário com o título"
SITE=_site-rascunhos tem publicacoes/n01/index.html 'Leu este fascículo\? Conte o que achou em um questionário curto\.' "F5 frase"
fim
