#!/usr/bin/env bash
# Tarefa 12: validação dos textos, caracteres especiais, autor-citacao e estado publicado.
source "$(dirname "$0")/lib.sh"
T=publicacoes/n01/impactos-setoriais-mercosul-ue/index.qmd
trocar "$T" 's|^eixo: .*|eixo: "Setor Externo"|'
deve_falhar 'o eixo "Setor Externo" não existe. Use um destes: Política monetária e inflação; Setor externo e câmbio' "eixo inválido para o render" "$T"
desfazer
trocar "$T" 's|^tipo: .*|tipo: "Ensaio"|'
deve_falhar 'o tipo "Ensaio" não existe' "tipo inválido para o render" "$T"
desfazer
trocar "$T" 's|^revisao: .*|revisao: ""|'
deve_falhar 'o campo "revisao" está vazio' "revisão vazia para o render" "$T"
desfazer
trocar "$T" 's|^draft: true|draft: false|'
deve_falhar 'o arquivo "texto.pdf" (campo "pdf") não está na pasta publicacoes/n01/impactos-setoriais-mercosul-ue' "publicado sem PDF para o render" "$T"
desfazer

echo "-- caracteres especiais e autor-citacao"
trocar "$T" 's|^title: .*|title: "Brasil \& Argentina: o \\"acordo\\" <revisto>"|' 's|^autor-citacao: .*|autor-citacao: "SILVA, Leonardo Xavier da"|'
quarto render "$T" --profile rascunhos > testes/.render-estado.log 2>&1
S=publicacoes/n01/impactos-setoriais-mercosul-ue/index.html
SITE=_site-rascunhos tem "$S" '<h1 class="titulo-longo">Brasil &amp; Argentina: o (&quot;|")acordo(&quot;|") &lt;revisto&gt;</h1>' "título escapado"
SITE=_site-rascunhos tem "$S" 'SILVA, Leonardo Xavier da\. Brasil &amp; Argentina' "autor-citacao substitui a regra"
SITE=_site-rascunhos nao_tem "$S" '<revisto>' "nenhuma tag injetada"
desfazer

echo "-- fascículo e textos publicados (sem draft), com PDFs de teste"
criar_pdf() { printf '%%PDF-1.4 teste\n' > "$1"; CRIADOS+=("$1"); }   # sem pipe: CRIADOS fica no shell principal
for f in publicacoes/n01/index.qmd publicacoes/n01/*/index.qmd; do trocar "$f" '/^draft: true/d'; done
criar_pdf publicacoes/n01/fasciculo.pdf
for d in publicacoes/n01/*/; do criar_pdf "${d}texto.pdf"; done
cp publicacoes/em-breve.yml publicacoes/em-breve.yml.bak-teste && ALTERADOS+=("publicacoes/em-breve.yml")
printf '[]\n' > publicacoes/em-breve.yml
renderizar
tem publicacoes/n01/index.html 'href="fasciculo\.pdf">Baixar PDF' "F2 Baixar PDF"
tem "$S" 'href="texto\.pdf">Baixar PDF' "T3 Baixar PDF"
tem index.html "Ler o fascículo ${NO}1" "I1 publicado"
tem index.html 'Fascículo mais recente' "I2 publicado"
tem publicacoes/index.html 'class="lista-textos lista-textos--filtravel"' "P3/P4 publicados"
tem sitemap.xml 'publicacoes/n01/index.html' "fascículo no sitemap"
fim
