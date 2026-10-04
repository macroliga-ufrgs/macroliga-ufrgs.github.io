#!/usr/bin/env bash
# Tarefa 9: estados e validação dos eventos.
source "$(dirname "$0")/lib.sh"
L=eventos/2026-11-27-lancamento-n01/index.qmd
P=eventos/2026-11-27-lancamento-n01/index.html

echo "-- inscrição por link"
trocar "$L" 's|^inscricao: ""|inscricao: "https://forms.gle/teste"|'
renderizar "$L" eventos/index.qmd index.qmd
tem "$P" 'href="https://forms\.gle/teste">Fazer inscrição' "EVP3 botão"
tem eventos/index.html 'href="https://forms\.gle/teste">Fazer inscrição' "EV2 botão"
tem index.html 'href="https://forms\.gle/teste">Fazer inscrição' "I4 botão"
desfazer

echo "-- entrada livre"
trocar "$L" 's|^inscricao: ""|inscricao: "livre"|'
renderizar "$L" eventos/index.qmd
tem "$P" 'Entrada livre, sem inscrição\.' "EVP3 livre"
tem eventos/index.html 'Entrada livre, sem inscrição\.' "EV2 livre"
desfazer

echo "-- realizado sem capa e sem fotos (Foco de revisão 5)"
trocar "$L" 's|^situacao: "proximo"|situacao: "realizado"|'
renderizar "$L" eventos/index.qmd index.qmd
tem eventos/index.html 'id="ev2-vazio"' "EV2 vazio visível"
nao_tem eventos/index.html 'id="ev2-vazio"[^>]*hidden' "EV2 vazio não oculto"
tem eventos/index.html "Lançamento do fascículo ${NO}1" "EV3 mostra o evento"
nao_tem eventos/index.html '<img[^>]*src=""' "EV3 sem imagem quebrada"
nao_tem eventos/index.html 'Ver as fotos' "EV3 sem Ver as fotos"
nao_tem "$P" '<img class="evento__capa' "EVP3 sem capa"
tem index.html 'Nenhum evento agendado\.' "I4 vazio"
desfazer

echo "-- realizado com capa e fotos"
criar eventos/2026-11-27-lancamento-n01/capa.jpg < design/img/capa-modelo.png
trocar "$L" 's|^situacao: "proximo"|situacao: "realizado"|' 's|^capa: ""|capa: "capa.jpg"|' \
  's|^capa-alt: ""|capa-alt: "Público no lançamento"|' 's|^fotos: ""|fotos: "https://photos.app.goo.gl/teste"|'
renderizar "$L" eventos/index.qmd
tem "$P" '<img class="evento__capa preview-image" src="capa\.jpg" alt="Público no lançamento"' "EVP3 capa"
tem "$P" 'href="https://photos\.app\.goo\.gl/teste">Ver as fotos' "EVP3 fotos"
tem eventos/index.html 'Ver as fotos' "EV3 fotos"
tem eventos/index.html 'capa\.jpg' "EV3 capa"
desfazer

echo "-- validação"
trocar "$L" 's|^situacao: "proximo"|situacao: "talvez"|'
deve_falhar 'a situação "talvez" não existe' "situação inválida para o render" "$L"
desfazer
trocar "$L" 's|^local: .*|local: ""|'
deve_falhar 'o campo "local" está vazio' "local vazio para o render" "$L"
desfazer
trocar "$L" 's|^capa: ""|capa: "capa.jpg"|'
deve_falhar 'a capa precisa de uma descrição no campo "capa-alt"' "capa sem alt para o render" "$L"
fim
