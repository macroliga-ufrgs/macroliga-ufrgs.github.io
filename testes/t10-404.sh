#!/usr/bin/env bash
# Tarefa 10: 404. O Quarto escreve os links da 404 a partir do caminho do site-url,
# para que funcionem quando ela é servida de um endereço profundo.
source "$(dirname "$0")/lib.sh"
existe 404.html "404 gerada"
tem 404.html '<h1[^>]*>Página não encontrada</h1>' "E1 título"
tem 404.html 'Não encontramos esta página\. O endereço pode ter mudado\.' "E1 texto"
tem 404.html 'href="/(\./)?index\.html"[^>]*>Voltar ao início' "Voltar ao início com caminho do site"
tem 404.html 'href="/(\./)?publicacoes/index\.html"[^>]*>Ver as publicações' "Ver as publicações com caminho do site"
tem 404.html 'href="/site_libs/' "CSS com caminho do site"
fim
