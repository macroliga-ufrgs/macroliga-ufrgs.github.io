#!/usr/bin/env bash
# Endereços curtos do nº 1 (página final do fascículo), no perfil rascunhos.
SITE=_site-rascunhos
source "$(dirname "$0")/lib.sh"
existe n01/index.html "atalho /n01"
tem n01/index.html 'http-equiv="refresh" content="0; url=\.\./publicacoes/n01/"' "n01 leva ao fascículo (link relativo)"
tem n01/opine/index.html 'http-equiv="refresh" content="0; url=https://docs\.google\.com/forms/[^"]*viewform\?usp=pp_url&amp;entry\.914996542=Pontos%20de%20Macro%20n%C2%BA%201%20%C2%B7%20impresso"' "opine: questionário com a origem impresso"
tem n01/opine/pdf/index.html 'http-equiv="refresh" content="0; url=https://docs\.google\.com/forms/[^"]*viewform\?usp=pp_url&amp;entry\.914996542=Pontos%20de%20Macro%20n%C2%BA%201%20%C2%B7%20PDF"' "opine/pdf: questionário com a origem PDF"
for p in n01/index.html n01/opine/index.html n01/opine/pdf/index.html; do
  tem "$p" '<meta name="robots" content="noindex">' "$p fora dos buscadores"
  tem "$p" '<h1[^>]*>Redirecionando…</h1>' "$p título"
  tem "$p" '>Se nada acontecer, toque aqui\.</a>' "$p link visível"
done
tem n01/index.html 'href="\.\./publicacoes/n01/"[^>]*>Se nada acontecer' "n01: o link visível vai ao mesmo destino"
fim
