#!/usr/bin/env bash
# Tarefa 3: tema (base, navbar, rodapé, componentes da prancha).
source "$(dirname "$0")/lib.sh"
tem_css '\.botao\{' "componente botão"
tem_css '\.fasciculo\{' "componente fascículo"
tem_css '\.item-texto\{' "componente item de texto"
tem_css '\.abertura\{' "componente abertura"
tem_css 'prefers-reduced-motion' "animação desligada com reduzir movimento"
tem_css '\[hidden\]\{display:none ?!important\}' "[hidden] vence display:grid"
tem_css '#title-block-header\{display:none' "título padrão do Quarto oculto"
tem index.html '<img[^>]*(navbar-logo[^>]*alt="MacroLiga UFRGS, página inicial"|alt="MacroLiga UFRGS, página inicial"[^>]*navbar-logo)' "logo com alt"
tem index.html 'class="rodape__logo' "logo no rodapé"
tem index.html 'coordenado pelo prof\. Leonardo Xavier da Silva' "coordenação no rodapé (de _variables.yml)"
tem index.html 'href="mailto:macroliga\.ufrgs@gmail\.com"' "e-mail no rodapé"
tem index.html 'href="https://www\.instagram\.com/macroliga\.ufrgs/"' "Instagram no rodapé"
tem index.html 'creativecommons\.org/licenses/by-nc/4\.0/deed\.pt-br' "licença CC BY-NC 4.0"
tem index.html 'Escrever para a liga' "botão Escrever para a liga"
# vermelho só nos usos previstos
n=$(grep -v '^\s*//' estilos/macroliga.scss | grep -c 'var(--vermelho)')
[ "$n" -le 2 ] && ok "var(--vermelho) usado no máximo 2 vezes no SCSS ($n)" || falha "var(--vermelho) usado $n vezes"
n=$(grep -v '^\s*//' estilos/macroliga.scss | grep -c 'tabular-nums')
[ "$n" -eq 1 ] && ok "tabular-nums numa única regra" || falha "tabular-nums em $n regras"
fim
