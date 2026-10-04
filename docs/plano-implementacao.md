# Site da MacroLiga UFRGS em Quarto: plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Objetivo:** construir em Quarto o site da liga descrito na spec, até o marco "site mínimo" (18/10/2026) e, depois, a página Gráficos comentados (até 22/11/2026).

**Arquitetura:** site estático do Quarto publicado no GitHub Pages. O aluno preenche só o cabeçalho YAML de cada item. Filtros Lua (`filtros/`) validam esse YAML e montam as páginas de texto, fascículo, evento e gráfico. Listings do Quarto com templates EJS próprios (`modelos-listing/`) geram as listas. Um SCSS (`estilos/macroliga.scss`) aplica os tokens da prancha sobre o Bootstrap do Quarto, e três scripts pequenos (`assets/js/`) cuidam do menu, dos filtros de Publicações e de "Copiar citação".

**Tecnologias:** Quarto 1.10.18 (Pandoc 3.10, Lua 5.4, Dart Sass), R 4.3.1 (ggplot2 3.5.1, knitr 1.51, ragg, systemfonts) para os gráficos, Git Bash para os testes, Python 3.12 (servidor local e conferência de links) e o Chrome instalado (screenshots com `npx playwright`, só como ferramenta de verificação).

**Spec:** `docs/spec-design.md`, com `docs/design-tokens.md`, `design/prancha.html`, `design/abertura.html`, `design/macroliga.css`, `conteudo/textos-base.md` e os wireframes aprovados em `wireframes/` (screenshots em `wireframes/screenshots/`). Quem executa lê a spec e este plano.

**Skill de design:** a skill `frontend-design` deve estar ativa em todo passo visual.

---

## Restrições globais

Valem para todas as tarefas.

- Custo zero. Nada de `npm install`, `package.json`, React, Tailwind, bundler ou framework JS no site. (`npx playwright` e `npx lighthouse` rodam só na verificação, fora do site.)
- Idioma: português do Brasil no código, nos comentários e no site. `lang: pt`.
- Cores (só estas): `azul-marinho #083D6B`, `vermelho #D51E23`, `offwhite #FAF8F4`, `grafite #1F2933`, `grade #D9D4CA`, `contexto #9AA5B1`.
- O vermelho tem três usos: Porto Alegre no mapa (`.mapa-destaque`), a etapa "Publicação" (`.etapa--publicacao`) e o último dado de cada gráfico (na imagem). Nunca texto, nunca estado de interface, nunca sobre azul.
- `contexto` nunca é cor de texto.
- Fontes: Libre Baskerville (títulos; pesos 400, 450, 500 e 560; o 700 fica fora do site) e Inter (400 e 700), ambas do Google Fonts.
- Tokens com os nomes de `design/macroliga.css` (`--fs-*`, `--peso-*`, `--esp-1` a `--esp-10`, `--raio-0`, `--raio-ponto`, `--linha-grade`, `--linha-eixo`, `--medida: 68ch`, `--largura-max: 75rem`). Desktop a partir de 992 px.
- "nº" e o número nunca se separam: `nº&nbsp;{n}` nos templates e espaço inseparável no texto.
- Algarismos tabulares (`tabular-nums`) só em dados: `.numeros`, `table`, `.dados`, `.item-texto__dados`.
- O ponto é a única forma redonda (`--raio-ponto`); todo o resto tem cantos retos.
- Nome da publicação só em `_variables.yml` (`publicacao.nome`, provisório "Pontos de Macro").
- Nenhum link do site começa com "/" (exceção do Quarto: a 404, que usa o caminho do `site-url`). Nos filtros Lua e nos templates, use caminhos `.qmd` relativos ou "/caminho.qmd" (o Quarto converte em relativo; os testes conferem).
- Microcopy: sentence case; verbos que dizem o que acontece; nada de "Saiba mais"; nada de "→" colado em links; nada de "·" entre metadados.
- Nenhum PDF nem texto do nº 1 vai para o Git antes do lançamento; `rascunhos/` fica ignorada.
- Commits pequenos, em português, no imperativo, terminando com a linha `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Decisões desta etapa (respostas do Miguel, 03/10/2026)

| Ponto em aberto (`docs/design-tokens.md`) | Decisão |
|---|---|
| 1. `grafico_site()` e o freeze | Testado antes do plano: o freeze guarda `grafico.png` e `grafico-celular.png` em `_freeze/.../figure-html/` e o render os copia para `_site/` mesmo sem a pasta `index_files/`. A Tarefa 15 repete o teste no site. Se falhar, a saída aprovada é salvar as imagens na pasta da página e declará-las em `resources:`. |
| 2. Link na lista de Publicações (P4) | O título é o link; não há botão "Ler o texto". Vale também para o sumário do fascículo (F3), que usa o mesmo componente `.item-texto`. |
| 3. Abertura em 360 px | 46 px aceitos (2,7× o corpo). A exceção vale só para 360–375 px. |
| Prancha | Aprovada com dois ajustes já feitos: sem frase sobre Porto Alegre (D-B) e licença CC BY-NC 4.0. O `aria-label` do mapa continua citando Porto Alegre, porque é texto alternativo e não legenda visível. |

## Descobertas técnicas (testadas no Quarto 1.10.18 antes do plano)

Elas explicam escolhas que, sem contexto, pareceriam estranhas.

1. **Rascunhos não aparecem no `quarto preview` padrão.** Com `draft: true`, o render padrão deixa no lugar uma página vazia de 90 bytes (`<html ...></html>`). Por isso existem: (a) o perfil `rascunhos` (`_quarto-rascunhos.yml`, `draft-mode: visible`, saída em `_site-rascunhos/`), usado com `quarto preview --profile rascunhos`; (b) o script pós-render `ferramentas/apagar-rascunhos.lua`, que apaga essas páginas vazias de `_site/`.
2. **Um `error()` num filtro Lua não para o render** (o Quarto registra o erro e segue com código 0). A validação usa `io.stderr:write(...)` + `os.exit(1)`.
3. **Um filtro Lua não consegue criar listings** (a configuração de listing é lida antes dos filtros). As listings ficam no cabeçalho das páginas de listagem e nos `_metadata.yml` das pastas de fascículo e de texto (copiados junto com as pastas-modelo). O filtro Lua só cria a `div` com o `id` da listing.
4. **O Quarto já tira a própria página da listing** em que ela aparece. T10 ("Outros textos") usa `contents: "../*/index.qmd"` sem filtro extra.
5. **Caminhos de template** em `_metadata.yml` são relativos ao documento (`../../modelos-listing/x.ejs` no fascículo; `../../../modelos-listing/x.ejs` no texto). "/" não vale para a raiz do projeto ali.
6. **Saída de template EJS passa pelo Markdown** (aspas viram aspas curvas, recuo vira bloco de código). Todo template fica dentro de um bloco ```` ```{=html} ````. `item.path` só é convertido em link relativo dentro de `href="..."`.
7. **`metadata-files: [_variables.yml]`** põe as variáveis no metadado de toda página: os filtros Lua leem `meta.publicacao.nome`, e os templates leem `item.publicacao.nome`, `item.eixos` e `item.tipos`. `{{< var >}}` continua funcionando.
8. **`_brand.yml` só aceita pesos múltiplos de 100.** Os pesos 450 e 560 da Libre Baskerville não cabem. Por isso: Inter vem pelo `_brand.yml` (`weight: [400, 700]`, `style: normal`), e a Libre Baskerville vem por um `<link>` no `include-in-header` com `wght@400..560` (um arquivo variável). O `_brand.yml` continua dando a família dos títulos.
9. **`brand: light: _brand.yml`** evita que o Quarto gere um segundo CSS de modo escuro (+509 KB).
10. **Open Graph:** o `og:title` e o `og:image` vêm do cabeçalho antes dos filtros. Títulos e descrições calculados usam shortcodes nos `_metadata.yml` (`open-graph: title: "{{< var publicacao.nome >}} nº {{< meta numero >}}"`, `description: "{{< meta sintese >}}"`). Um campo calculado por Lua só entra num shortcode se tiver valor padrão no `_metadata.yml` (ex.: `data-exibida: ""`); sem isso, o Quarto avisa "Unknown meta key".
11. **O filtro Lua não lê `website.site-url`.** Quando precisar, leia o `_quarto.yml` do disco.
12. **Shortcodes funcionam no `page-footer`** e caminhos "/..." no rodapé viram relativos.
13. **Os filtros Lua sabem o perfil** por `os.getenv("QUARTO_PROFILE")` (vale "rascunhos" com `--profile rascunhos`).
14. **Screenshots:** o Chrome headless puro não desce abaixo de ~500 px de largura. `npx playwright@1.56.0 screenshot --channel chrome` usa o Chrome instalado e dá a largura exata, com página inteira.

## Foco de revisão

São os cinco casos que a spec implica sem testar, os mais prováveis de dar problema para quem usa ou mantém o site. Cada um tem teste na tarefa dona do código.

1. **Endereço com filtro inválido** (`publicacoes/?eixo=inexistente`, link antigo ou digitado errado): a lista aparece inteira, os controles ficam em "Todos" e o estado vazio não aparece. Teste em `testes/t13-filtros.sh`.
2. **Item publicado sem o PDF** (no lançamento, alguém apaga `draft: true` e esquece de copiar o PDF): o render para com uma mensagem que diz qual arquivo falta e em que pasta. Teste em `testes/e11-fasciculo.sh` e `testes/e12-textos.sh`.
3. **Caracteres especiais no YAML** (`&`, aspas, `<` no título ou na síntese): a página mostra o texto certo, o HTML não quebra e a citação sai correta. Teste em `testes/e12-textos.sh`.
4. **Nenhum fascículo publicado e `em-breve.yml` vazio** (entre um fascículo e o anúncio do seguinte): a Início não mostra bloco órfão; o botão da abertura vira "Ver as publicações". Teste em `testes/e08-publicacoes.sh`.
5. **Evento realizado sem capa e sem fotos:** EV3 e a página do evento não mostram imagem quebrada nem botão vazio. Teste em `testes/e09-eventos.sh`.

## Verificação visual (vale para toda tarefa com tela)

Depois dos testes, em cada tarefa:

1. Rode `bash ferramentas/capturar.sh nome=caminho ...`, que salva `capturas/<nome>-390.png` e `capturas/<nome>-1280.png`.
2. Abra (Read) as capturas novas, o wireframe aprovado (`wireframes/screenshots/<tela>-390.png` e `-1280.png`; a Início é `inicio-b-*`) e a prancha (`capturas/prancha-*.png` e `capturas/abertura-*.png`, feitas na Tarefa 1).
3. Confira item a item:
   - mesmos blocos e na mesma ordem do wireframe, pelo código do bloco;
   - componentes iguais aos da prancha (tipos, pesos, espaçamentos, linhas de grade e eixo);
   - título da página com 3× ou mais o tamanho do corpo (exceção aprovada: abertura em 360–375 px);
   - azul-marinho em blocos inteiros; vermelho só nos três usos;
   - nada da lista "Evitar" (CLAUDE.md, seção 7): cards iguais com sombra; rótulo em caixa alta espaçada; palavra destacada no título; 01/02/03 fora de sequência; "·" entre metadados; "→" em links; hero com número grande e gradiente; gradiente, glassmorphism ou emoji;
   - sem rolagem horizontal em 390 px; alvos de toque com 44 px ou mais; linhas com até ~75 caracteres;
   - textos iguais aos de `conteudo/textos-base.md`.
4. Corrija o que divergir, renderize de novo, capture de novo e só então faça o commit.

---

## Mapa de arquivos

```
site/
├── _quarto.yml                  projeto, navbar, rodapé, formatos, filtros
├── _quarto-rascunhos.yml        perfil: rascunhos visíveis, saída _site-rascunhos/
├── _quarto-subcaminho.yml       perfil de teste: site sob /macroliga, saída _site-subcaminho/
├── _brand.yml                   cores, fonte Inter, logos
├── _variables.yml               o que muda (nome, contato, questionário, eixos, tipos)
├── index.qmd  sobre.qmd  equipe.qmd  equipe.yml  participe.qmd  404.qmd
├── publicacoes/
│   ├── index.qmd  em-breve.yml
│   ├── _modelo-fasciculo/{index.qmd,_metadata.yml}
│   ├── _modelo-texto/{index.qmd,_metadata.yml}
│   └── n01/{index.qmd,_metadata.yml,capa.png}
│       └── <slug>/{index.qmd,_metadata.yml}   (×4)
├── eventos/
│   ├── index.qmd  _metadata.yml
│   ├── _modelo/index.qmd
│   └── 2026-11-27-lancamento-n01/index.qmd
├── graficos/
│   ├── index.qmd  _metadata.yml
│   └── _modelo/index.qmd
├── modelos/                     modelo-macroliga.docx, modelo-macroliga.zip
├── assets/
│   ├── marca/                   (já existe) + png/macroliga-og.png
│   ├── img/mapa-pontos.svg      gerado por design/gerar-mapa.py
│   ├── graficos/tema_macroliga.R
│   └── js/{menu.js,filtros.js,citacao.js}
├── estilos/macroliga.scss
├── modelos-listing/*.ejs        templates das listings
├── filtros/
│   ├── comum.lua                funções compartilhadas
│   ├── validar.lua              validação do YAML (spec 3.6)
│   ├── montar.lua               escolhe o montador pela chave "pagina"
│   ├── tipografia.lua           "nº" + espaço inseparável
│   ├── contagem.lua             GoatCounter
│   └── paginas/<pagina>.lua     um montador por tipo de página
├── ferramentas/
│   ├── apagar-rascunhos.lua     pós-render
│   ├── capturar.sh  dom.sh  conferir-links.py  og.html
├── testes/                      lib.sh, rodar.sh, t*/r*/e*.sh
├── _freeze/                     (vai para o Git)
└── LEIA-ME.md
```

**A chave `pagina`** diz ao `montar.lua` e ao `validar.lua` que tipo de página é. As páginas fixas a escrevem no cabeçalho (`pagina: inicio`); fascículos e textos a recebem pelo `_metadata.yml` da própria pasta; eventos e gráficos, pelo `_metadata.yml` da pasta-mãe (a página de listagem sobrescreve).

---

### Tarefa 1: Projeto mínimo, marca e ferramentas de verificação

**Arquivos:**
- Criar: `_quarto.yml`, `_brand.yml`, `_variables.yml`, `estilos/macroliga.scss` (só tokens), `index.qmd` (provisório)
- Criar: `testes/lib.sh`, `testes/rodar.sh`, `testes/t01-projeto.sh`, `ferramentas/capturar.sh`, `ferramentas/dom.sh`
- Modificar: `.gitignore`, `docs/design-tokens.md`, `docs/spec-design.md` (linhas de P4 e F3), `conteudo/textos-base.md` (tabela 5.1)

**Interfaces:**
- Produz: `testes/lib.sh` com `tem`, `nao_tem`, `existe`, `nao_existe`, `conta`, `corpo_nao_tem`, `nenhum_html`, `tem_css`, `trocar`, `criar`, `criar_pasta`, `deve_falhar`, `renderizar`, `fim`, e as variáveis `SITE` e `NO` (regex de "nº" + espaço inseparável).
- Produz: `testes/rodar.sh [filtro]`: roda os testes `e*`, depois `quarto render` e `quarto render --profile rascunhos`, depois os testes `t*` (em `_site`) e `r*` (em `_site-rascunhos`).
- Produz: `ferramentas/capturar.sh [-s pasta] [-l "larguras"] nome=caminho...` e `ferramentas/dom.sh [-s pasta] caminho`.
- Produz: variáveis de `_variables.yml` (seção 3.7 da spec), disponíveis como `meta.<chave>` nos filtros e `item.<chave>` nos templates.

- [ ] **Passo 1: Criar o ramo de trabalho**

```bash
git switch -c construcao-site
```

- [ ] **Passo 2: Atualizar o `.gitignore`**

Acrescente ao fim de `.gitignore`:

```gitignore

# Saídas de perfis e verificação
/_site-rascunhos/
/_site-subcaminho/
/capturas/
testes/.render*.log
*.bak-teste
```

- [ ] **Passo 3: Escrever a biblioteca de testes**

`testes/lib.sh`:

```bash
#!/usr/bin/env bash
# testes/lib.sh: funções dos testes do site (maquinaria: não mexa).
# Os testes conferem o HTML já renderizado em $SITE (padrão: _site).
SITE="${SITE:-_site}"
FALHAS=0
NBSP=$'\xc2\xa0'
NO="nº(&nbsp;|&#160;|${NBSP})"

ok()    { echo "  ok    $1"; }
falha() { echo "  FALHA $1"; FALHAS=$((FALHAS + 1)); }
aviso() { echo "  AVISO $1"; }

tem()        { if grep -Eq -- "$2" "$SITE/$1" 2>/dev/null; then ok "$3"; else falha "$3  [$1 não contém: $2]"; fi; }
nao_tem()    { if grep -Eq -- "$2" "$SITE/$1" 2>/dev/null; then falha "$3  [$1 contém: $2]"; else ok "$3"; fi; }
existe()     { if [ -e "$SITE/$1" ]; then ok "$2"; else falha "$2  [não existe: $1]"; fi; }
nao_existe() { if [ -e "$SITE/$1" ]; then falha "$2  [existe: $1]"; else ok "$2"; fi; }
conta() {
  local n
  n=$(grep -Eo -- "$2" "$SITE/$1" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$n" = "$3" ]; then ok "$4"; else falha "$4  [$1: $n ocorrência(s) de $2; esperado $3]"; fi
}
corpo_nao_tem() {
  if sed -n '/<body/,$p' "$SITE/$1" 2>/dev/null | grep -Eq -- "$2"; then
    falha "$3  [$1 contém no corpo: $2]"
  else ok "$3"; fi
}
nenhum_html() { # nenhum_html <padrão> <descrição> [<arquivos-a-ignorar (regex)>]
  local achados
  achados=$(grep -rlE --include='*.html' -- "$1" "$SITE" 2>/dev/null | grep -Ev -- "${3:-^$}" | head -5 | tr '\n' ' ')
  if [ -z "$achados" ]; then ok "$2"; else falha "$2  [$achados]"; fi
}
css() { ls "$SITE"/site_libs/bootstrap/bootstrap-*.min.css 2>/dev/null | head -1; }
tem_css() { if grep -Eq -- "$1" "$(css)"; then ok "$2"; else falha "$2  [CSS não contém: $1]"; fi; }

# Troca de estado (testes e*): guarda cópias e desfaz tudo ao sair.
ALTERADOS=()
CRIADOS=()
trocar() { # trocar <arquivo> <expressão-sed> [<expressão-sed>...]
  local a=$1 e
  shift
  if [ ! -e "$a.bak-teste" ]; then cp "$a" "$a.bak-teste"; ALTERADOS+=("$a"); fi
  for e in "$@"; do sed -i "$e" "$a"; done
}
criar() { # criar <arquivo>  (o conteúdo vem pela entrada padrão)
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  CRIADOS+=("$1")
}
criar_pasta() { mkdir -p "$1"; CRIADOS+=("$1"); }
desfazer() {
  local a
  for a in "${ALTERADOS[@]}"; do mv -f "$a.bak-teste" "$a"; done
  for a in "${CRIADOS[@]}"; do rm -rf "$a"; done
  ALTERADOS=()
  CRIADOS=()
}
trap desfazer EXIT
renderizar() { quarto render "$@" > testes/.render-estado.log 2>&1; }
deve_falhar() { # deve_falhar <trecho-da-mensagem> <descrição> <arquivos...>
  local msg=$1 desc=$2
  shift 2
  if quarto render "$@" > testes/.render-estado.log 2>&1; then
    falha "$desc  [o render não falhou]"
  elif grep -Fq -- "$msg" testes/.render-estado.log; then
    ok "$desc"
  else
    falha "$desc  [mensagem não encontrada: $msg]"
    tail -5 testes/.render-estado.log
  fi
}
fim() {
  echo
  if [ "$FALHAS" -gt 0 ]; then echo "$FALHAS falha(s)."; exit 1; fi
  echo "Tudo certo."
}
```

`testes/rodar.sh`:

```bash
#!/usr/bin/env bash
# Roda os testes do site. Uso: bash testes/rodar.sh       (todos)
#                              bash testes/rodar.sh 04    (só os que têm "04" no nome)
# Ordem: testes de estado (e*), que mexem no YAML e renderizam o que precisam;
# depois o render limpo dos dois perfis; depois os testes t* (_site) e r* (_site-rascunhos).
cd "$(dirname "$0")/.." || exit 1
FILTRO="${1:-}"
STATUS=0
roda() {
  local t
  for t in "$@"; do
    [ -e "$t" ] || continue
    case "$(basename "$t")" in *"$FILTRO"*) ;; *) continue ;; esac
    echo "== $t"
    bash "$t" || STATUS=1
  done
}
roda testes/e*.sh
echo "== quarto render"
if ! quarto render > testes/.render.log 2>&1; then tail -40 testes/.render.log; echo "quarto render falhou."; exit 1; fi
grep -E "WARN" testes/.render.log | sort -u | sed 's/^/  aviso do Quarto: /'
echo "== quarto render --profile rascunhos"
if ! quarto render --profile rascunhos > testes/.render-rascunhos.log 2>&1; then
  tail -40 testes/.render-rascunhos.log; echo "quarto render --profile rascunhos falhou."; exit 1
fi
roda testes/t*.sh testes/r*.sh
exit $STATUS
```

- [ ] **Passo 4: Escrever as ferramentas de captura**

`ferramentas/capturar.sh`:

```bash
#!/usr/bin/env bash
# Screenshots de página inteira, com o Chrome instalado (via Playwright, sem instalar nada no site).
# Uso: bash ferramentas/capturar.sh [-s pasta] [-l "390 1280"] nome=caminho [nome=caminho ...]
#   -s  pasta servida (padrão: _site; para ver rascunhos, _site-rascunhos; para a prancha, .)
#   -l  larguras em px (padrão: "390 1280")
# Saída: capturas/<nome>-<largura>.png (pasta ignorada pelo Git).
set -euo pipefail
PASTA=_site
LARGURAS="390 1280"
while getopts "s:l:" op; do
  case $op in s) PASTA=$OPTARG ;; l) LARGURAS=$OPTARG ;; *) exit 2 ;; esac
done
shift $((OPTIND - 1))
PORTA=8770
mkdir -p capturas
python -m http.server "$PORTA" --bind 127.0.0.1 -d "$PASTA" >/dev/null 2>&1 &
SERVIDOR=$!
trap 'kill $SERVIDOR 2>/dev/null || true' EXIT
for _ in $(seq 1 300); do curl -s -o /dev/null "http://127.0.0.1:$PORTA/" && break; done
for par in "$@"; do
  nome=${par%%=*}
  caminho=${par#*=}
  for largura in $LARGURAS; do
    npx --yes playwright@1.56.0 screenshot --channel chrome --full-page \
      --viewport-size="$largura,900" --wait-for-timeout=2500 \
      "http://127.0.0.1:$PORTA/$caminho" "capturas/$nome-$largura.png" >/dev/null
    echo "capturas/$nome-$largura.png"
  done
done
```

`ferramentas/dom.sh`:

```bash
#!/usr/bin/env bash
# Imprime o HTML de uma página depois de o JavaScript rodar (Chrome sem janela).
# Uso: bash ferramentas/dom.sh [-s pasta] "caminho?consulta"
set -euo pipefail
PASTA=_site
while getopts "s:" op; do case $op in s) PASTA=$OPTARG ;; *) exit 2 ;; esac; done
shift $((OPTIND - 1))
CHROME="${CHROME:-/c/Program Files/Google/Chrome/Application/chrome.exe}"
PORTA=8771
python -m http.server "$PORTA" --bind 127.0.0.1 -d "$PASTA" >/dev/null 2>&1 &
SERVIDOR=$!
trap 'kill $SERVIDOR 2>/dev/null || true' EXIT
for _ in $(seq 1 300); do curl -s -o /dev/null "http://127.0.0.1:$PORTA/" && break; done
"$CHROME" --headless=new --disable-gpu --virtual-time-budget=3000 --dump-dom "http://127.0.0.1:$PORTA/$1" 2>/dev/null
```

- [ ] **Passo 5: Capturar a prancha como referência**

```bash
bash ferramentas/capturar.sh -s . prancha=design/prancha.html abertura=design/abertura.html
```

Esperado: quatro arquivos em `capturas/` (prancha-390, prancha-1280, abertura-390, abertura-1280). Abra-os: o logo branco aparece no cabeçalho azul e o mapa de pontos, na abertura.

- [ ] **Passo 6: Escrever o teste do projeto mínimo (falha primeiro)**

`testes/t01-projeto.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 1: projeto mínimo, marca e fontes.
source "$(dirname "$0")/lib.sh"
existe index.html "a Início é gerada"
tem index.html '<html[^>]*lang="pt"' "lang pt"
nao_existe CLAUDE.html "CLAUDE.md não vira página"
nao_existe PLANO-SITE.html "PLANO-SITE.md não vira página"
nao_existe docs "docs/ não vai para o site"
nao_existe conteudo "conteudo/ não vai para o site"
nao_existe wireframes "wireframes/ não vão para o site"
nao_existe design "design/ não vai para o site"
# O pedido da Inter pode estar no HTML ou num @import do CSS; o da Libre Baskerville está no HTML.
FONTES=$(cat "$SITE/index.html" "$(css)" 2>/dev/null | grep -oE 'fonts\.googleapis\.com/css2\?[^")'"'"' ]*' | sed 's/&amp;/\&/g' | sort -u)
echo "$FONTES" | grep -qE 'family=Inter:wght@400;700&display=swap' && ok "Inter só com 400 e 700" || falha "Inter: $FONTES"
echo "$FONTES" | grep -qE 'family=Libre\+Baskerville:wght@400\.\.560&display=swap' && ok "Libre Baskerville variável 400–560" || falha "Libre Baskerville: $FONTES"
[ "$(echo "$FONTES" | grep -c .)" = "2" ] && ok "só dois pedidos de fonte" || falha "pedidos de fonte: $FONTES"
echo "$FONTES" | grep -q 'ital' && falha "itálicos carregados" || ok "sem itálicos"
nenhum_html 'bootstrap-dark' "sem CSS de modo escuro"
tem_css '--azul-marinho: ?#083D6B' "token --azul-marinho vem do _brand.yml"
tem_css '--fs-display' "tokens tipográficos no CSS"
tem index.html 'macroliga-favicon-512\.png' "favicon da marca"
nenhum_html 'quarto-search|search\.json' "sem busca (D10)"
nao_existe search.json "sem índice de busca (D10)"
fim
```

Rode `bash testes/t01-projeto.sh`. Esperado: FALHA em quase todos os itens, porque ainda não há `_site/`.

- [ ] **Passo 7: Criar `_variables.yml`**

```yaml
# O que muda no site. Edite aqui, e não nos outros arquivos.
publicacao:
  nome: "Pontos de Macro"          # provisório (decisão 1 do CLAUDE.md)
contato:
  email: "macroliga.ufrgs@gmail.com"
  instagram: "@macroliga.ufrgs"
  instagram-url: "https://www.instagram.com/macroliga.ufrgs/"
  linkedin: "MacroLiga UFRGS"
  linkedin-url: "https://www.linkedin.com/company/macroliga-ufrgs/"   # confirmar quando a página abrir
coordenacao: "prof. Leonardo Xavier da Silva"
questionario:
  url: ""              # um único formulário do Google Forms para o site todo
  campo-pagina: ""     # opcional: id do campo (entry.NNN) que recebe o título da página
modelos:
  word: "modelos/modelo-macroliga.docx"
  latex: "modelos/modelo-macroliga.zip"
contagem:
  goatcounter: ""      # código da conta do GoatCounter; vazio = nada é carregado
eixos:
  - "Política monetária e inflação"
  - "Setor externo e câmbio"
  - "Atividade econômica, mercado de trabalho e crédito"
  - "Política fiscal e contas públicas"
  - "Mercados externos"
  - "Conjuntura política"
tipos:
  - "Análise de conjuntura"
  - "Revisão de literatura"
  - "Nota de pesquisa"
  - "Texto de opinião"
```

- [ ] **Passo 8: Criar `_brand.yml`**

```yaml
# Marca da MacroLiga UFRGS (CLAUDE.md, seção 6). Não invente cores nem fontes.
color:
  palette:
    azul-marinho: "#083D6B"
    vermelho: "#D51E23"      # só os três usos de docs/design-tokens.md
    offwhite: "#FAF8F4"
    grafite: "#1F2933"
    grade: "#D9D4CA"
    contexto: "#9AA5B1"      # só séries secundárias de gráficos; nunca texto
  background: offwhite
  foreground: grafite
  primary: azul-marinho
  link: azul-marinho

typography:
  fonts:
    # A Libre Baskerville não entra aqui: o _brand.yml só aceita pesos 100, 200…900,
    # e o site usa 450 e 560. Ela é carregada no _quarto.yml (include-in-header),
    # como fonte variável de 400 a 560.
    - family: Inter
      source: google
      weight: [400, 700]
      style: normal
  base:
    family: Inter
    weight: 400
    line-height: 1.6
  headings:
    family: Libre Baskerville
    weight: 400
    color: azul-marinho
    line-height: 1.12

logo:
  images:
    horizontal-cor:
      path: assets/marca/svg/macroliga-horizontal-cor.svg
      alt: "MacroLiga UFRGS"
    horizontal-branco:
      path: assets/marca/svg/macroliga-horizontal-branco.svg
      alt: "MacroLiga UFRGS"
    simbolo-cor:
      path: assets/marca/svg/macroliga-simbolo-cor.svg
      alt: "Símbolo da MacroLiga UFRGS"
    selo-cor:
      path: assets/marca/svg/macroliga-selo-cor.svg
      alt: "Selo da MacroLiga UFRGS"
  small: simbolo-cor
  medium: horizontal-cor
  large: selo-cor
```

- [ ] **Passo 9: Criar `estilos/macroliga.scss` com os tokens**

```scss
/*-- scss:defaults --*/
// Ajustes do Bootstrap: cantos retos e sem sombras. Cores e fontes vêm do _brand.yml.
// (As variáveis $brand-* não existem nesta camada; use-as só em scss:rules.)
$border-radius: 0;
$border-radius-sm: 0;
$border-radius-lg: 0;
$border-radius-xl: 0;
$border-radius-xxl: 0;
$border-radius-pill: 0;
$enable-shadows: false;
$navbar-padding-y: 0;
$headings-margin-bottom: 0;

/*-- scss:rules --*/
// =============================================================================
// MacroLiga UFRGS: estilos do site. Origem: design/macroliga.css (prancha aprovada).
// Mesmos tokens e nomes; cada componente é uma seção. Mobile primeiro: o desktop
// começa em 992 px, onde o menu do Quarto (Bootstrap) deixa de ser recolhido.
// O vermelho tem três usos (docs/design-tokens.md): .mapa-destaque, .etapa--publicacao
// e o último dado dos gráficos (na imagem). Não use var(--vermelho) em mais nada.
// =============================================================================

// ---- Tokens -----------------------------------------------------------------
:root {
  // Cores da marca, lidas do _brand.yml. Nenhuma outra cor entra no site.
  --azul-marinho: #{$brand-azul-marinho};
  --vermelho: #{$brand-vermelho};
  --offwhite: #{$brand-offwhite};
  --grafite: #{$brand-grafite};
  --grade: #{$brand-grade};
  --contexto: #{$brand-contexto};

  --fonte-titulo: "Libre Baskerville", Georgia, serif;
  --fonte-texto: "Inter", system-ui, sans-serif;

  // Escala tipográfica (celular). O desktop redefine abaixo.
  --fs-display: clamp(2.875rem, 13.4vw, 3.25rem);  // 46–52 px (46 px em 360 px: exceção aprovada)
  --fs-h1: 3.25rem;
  --fs-titulo-longo: 2rem;
  --fs-h2: 1.75rem;
  --fs-h3: 1.3125rem;
  --fs-sintese: 1.3125rem;
  --fs-corpo: 1.0625rem;
  --fs-meta: 0.9375rem;
  --fs-pequeno: 0.875rem;

  // Pesos. A Libre Baskerville é variável: o peso sobe quando o tamanho desce.
  --peso-display: 400;
  --peso-h1: 400;
  --peso-titulo-longo: 450;
  --peso-h2: 500;
  --peso-h3: 560;
  --peso-texto: 400;
  --peso-forte: 700;

  --lh-display: 1.02;
  --lh-titulo: 1.12;
  --lh-texto: 1.6;
  --lh-serifa: 1.65;

  --esp-1: 0.25rem;
  --esp-2: 0.5rem;
  --esp-3: 0.75rem;
  --esp-4: 1rem;
  --esp-5: 1.5rem;
  --esp-6: 2rem;
  --esp-7: 3rem;
  --esp-8: 4rem;
  --esp-9: 6rem;
  --esp-10: 8rem;

  --largura-max: 75rem;
  --margem: var(--esp-4);
  --medida: 68ch;
  --secao: var(--esp-8);

  --raio-0: 0;
  --raio-ponto: 50%;

  --linha-grade: 1px solid var(--grade);
  --linha-eixo: 2px solid var(--grafite);

  --alvo-min: 3rem;
  --cor-foco: var(--azul-marinho);
}

@media (min-width: 992px) {
  :root {
    --fs-display: clamp(4.5rem, 3.4vw + 1.75rem, 5.25rem);
    --fs-h1: 4.5rem;
    --fs-titulo-longo: 2.75rem;
    --fs-h2: 2.25rem;
    --fs-h3: 1.5rem;
    --fs-corpo: 1.125rem;
    --margem: var(--esp-6);
    --secao: var(--esp-9);
  }
}
```

- [ ] **Passo 10: Criar `_quarto.yml` e o `index.qmd` provisório**

`_quarto.yml`:

```yaml
project:
  type: website
  output-dir: _site
  render:
    - "*.qmd"
    - "publicacoes/**/*.qmd"
    - "eventos/**/*.qmd"
    - "graficos/**/*.qmd"

lang: pt
metadata-files:
  - _variables.yml

execute:
  freeze: auto

brand:
  light: _brand.yml

website:
  title: "MacroLiga UFRGS"
  description: "Liga Acadêmica de Macroeconomia da UFRGS: textos curtos sobre a conjuntura brasileira, escritos por estudantes e revisados por professores da FCE."
  site-url: "https://macroliga-ufrgs.github.io"
  favicon: assets/marca/png/macroliga-favicon-512.png
  search: false          # D10: sem busca na 1ª versão
  page-navigation: false
  navbar:
    title: false
    logo: assets/marca/svg/macroliga-horizontal-branco.svg
    logo-alt: "MacroLiga UFRGS, página inicial"
    logo-href: index.qmd
    background: primary
    pinned: true
    collapse-below: lg
    right:
      - text: "Início"
        href: index.qmd

format:
  html:
    theme:
      light: [brand, estilos/macroliga.scss]
    page-layout: custom
    toc: false
    anchor-sections: false
    smooth-scroll: false
    include-in-header:
      text: |
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Libre+Baskerville:wght@400..560&display=swap">
```

`index.qmd` (provisório; a Tarefa 4 o substitui):

```markdown
---
title: "Início"
---

Site em construção.
```

- [ ] **Passo 11: Renderizar e rodar o teste**

```bash
bash testes/rodar.sh 01
```

Esperado: `Tudo certo.` Se `tem_css '--azul-marinho: ?#083D6B'` falhar, confira o nome do token no CSS gerado (`grep -o -- '--azul-marinho:[^;]*' _site/site_libs/bootstrap/bootstrap-*.min.css`): o Dart Sass pode escrever a cor em minúsculas (`#083d6b`). Nesse caso, troque o padrão do teste por `'--azul-marinho: ?#083[dD]6[bB]'`.

- [ ] **Passo 12: Registrar as decisões nos documentos**

Em `docs/design-tokens.md`:
- troque a linha de status por: `- **Status:** prancha aprovada em 03/10/2026, com dois ajustes (sem frase sobre Porto Alegre; licença CC BY-NC 4.0). Plano de implementação em docs/plano-implementacao.md.`
- troque a seção "Pontos em aberto" por:

```markdown
## Pontos resolvidos na etapa do plano (03/10/2026)

1. **`grafico_site()` dentro do Quarto:** testado no Quarto 1.10.18. O freeze guarda as duas imagens em `_freeze/<página>/figure-html/`, e o render as copia para `_site/`. Se um dia falhar, a saída aprovada é salvar as imagens na pasta da página e declará-las em `resources:`.
2. **Link na lista de Publicações (P4) e no sumário (F3):** o título é o link; não há botão "Ler o texto".
3. **Abertura em 360 px:** 46 px aceitos (2,7× o corpo), só em telas de 360–375 px.
4. **Fontes no `_brand.yml`:** ele só aceita pesos múltiplos de 100. A Inter (400 e 700) vem por ele; a Libre Baskerville vem por `<link>` com `wght@400..560`.
```

Em `docs/spec-design.md`, na tabela 2.3, troque a célula de conteúdo de P4 por `Lista de todos os textos: título (é o link para o texto), autor, fascículo, tipo, eixo. Lista, não grade de cards.`; na tabela 2.4, troque a de F3 por `"Sumário": cada texto com título (é o link para o texto), autor, tipo e eixo.`

Em `conteudo/textos-base.md`, tabela 5.1, troque a linha `| Card de texto | Ler o texto |` por `| Lista de textos (Publicações e sumário) | O título é o link; sem botão "Ler o texto" |`.

- [ ] **Passo 13: Verificação visual**

```bash
bash ferramentas/capturar.sh inicio=index.html
```

Nesta tarefa, compare só o básico: fundo off-white, texto em Inter grafite e logo branco sobre a navbar azul. O resto do tema vem na Tarefa 3.

- [ ] **Passo 14: Commit**

```bash
git add .gitignore _quarto.yml _brand.yml _variables.yml estilos/macroliga.scss index.qmd testes ferramentas docs/design-tokens.md docs/spec-design.md conteudo/textos-base.md
git commit -m "Cria o projeto Quarto com a marca e as ferramentas de teste

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 2: Maquinaria Lua comum, rascunhos e contagem de visitas

**Arquivos:**
- Criar: `filtros/comum.lua`, `filtros/montar.lua`, `filtros/validar.lua`, `filtros/tipografia.lua`, `filtros/contagem.lua`, `ferramentas/apagar-rascunhos.lua`, `assets/js/menu.js`
- Criar: `_quarto-rascunhos.yml`, `_quarto-subcaminho.yml`, `ferramentas/og.html`, `assets/marca/png/macroliga-og.png`
- Modificar: `_quarto.yml` (filtros, pós-render, Open Graph, link "Pular para o conteúdo")
- Testar: `testes/t02-maquinaria.sh`, `testes/e02-maquinaria.sh`

**Interfaces:**
- Produz `filtros/comum.lua`, uma tabela carregada com `local comum = dofile(quarto.utils.resolve_path("comum.lua"))`. Funções:
  - `texto(v) -> string`: texto simples de um valor do YAML, sem espaços nas pontas ("" se nil);
  - `esc(s) -> string`: escapa HTML e troca "nº " por "nº&nbsp;";
  - `html(s) -> RawBlock`;
  - `raiz()`, `caminho(...)`, `existe(c)`, `ler_arquivo(c)`, `ler_yaml(c)`, `cabecalho(qmd) -> Meta|nil` (só o YAML do topo, sem a normalização do Quarto);
  - `pasta_atual()`, `relativo(c)`, `parar(msg)` (escreve `[MacroLiga] msg` e sai com código 1);
  - `script(nome)`: anexa `assets/js/<nome>.js` à página;
  - `perfil_rascunhos()`, `rascunho(y)`, `visivel(y)`;
  - `subpastas(pasta)`, `fasciculos(apenas_visiveis) -> {numero, pasta, meta}[]` (ordem crescente), `textos_do_fasciculo(pasta, apenas_visiveis) -> {slug, meta, ordem}[]`, `em_breve() -> Meta[]`, `eventos() -> {pasta, meta}[]`, `tem_evento(situacao)`, `graficos(apenas_visiveis) -> {pasta, meta}[]`;
  - `slug(s)`, `partes_data(v) -> d, m, a`, `data_extenso(v)`, `data_abnt(v)`;
  - `questionario(meta, frase, titulo) -> RawBlock|nil`, `aviso_institucional() -> RawBlock`, `link_instagram(meta) -> string`, `acao_inscricao(v) -> string`, `ocultar(blocos, ids) -> Blocks`.
- Produz `filtros/montar.lua`: para cada página, anexa `menu.js` e, se `meta.pagina` existir e houver `filtros/paginas/<pagina>.lua`, chama esse módulo. Cada módulo é `return function(doc, comum) ... return doc end`.
- Produz `filtros/validar.lua` com as regras da spec 3.6 para `pagina` = `texto`, `fasciculo`, `evento` e `grafico`. Os testes de cada regra ficam nas Tarefas 9, 11, 12 e 15.

- [ ] **Passo 1: Escrever o teste (falha primeiro)**

`testes/t02-maquinaria.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 2: maquinaria comum (Open Graph, menu, pular para o conteúdo, rascunhos).
source "$(dirname "$0")/lib.sh"
tem index.html '<a class="pular" href="#quarto-document-content">Pular para o conteúdo</a>' "link Pular para o conteúdo"
tem index.html 'id="quarto-document-content"' "alvo do link de pular existe"
tem index.html 'site_libs/macroliga-menu-1\.0/menu\.js' "menu.js anexado"
existe site_libs/macroliga-menu-1.0/menu.js "menu.js copiado para site_libs"
tem index.html '<meta property="og:title"' "og:title"
tem index.html '<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/assets/marca/png/macroliga-og\.png"' "og:image padrão é o selo"
tem index.html '<meta property="og:description" content="[^"]+' "og:description preenchida"
nao_tem index.html 'goatcounter' "sem GoatCounter com o código vazio"
nenhum_html '(href|src)="/[^/]' "nenhum link começa com / (exceto a 404)" '/404\.html$'
fim
```

`testes/e02-maquinaria.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 2: estados (GoatCounter preenchido, rascunho, nº + número).
source "$(dirname "$0")/lib.sh"

echo "-- GoatCounter com código"
trocar _variables.yml 's|goatcounter: ""|goatcounter: "macroliga-teste"|'
renderizar index.qmd
tem index.html 'https://macroliga-teste\.goatcounter\.com/count' "script do GoatCounter com o código"
tem index.html 'location\.hostname' "o script não roda em localhost"
desfazer

echo "-- página em rascunho e nº"
criar teste-rascunho.qmd <<'EOF'
---
title: "Teste de rascunho"
draft: true
---
Fascículo nº 1 e nº 12.
EOF
renderizar
nao_existe teste-rascunho.html "rascunho não existe no _site (página vazia apagada)"
quarto render --profile rascunhos > testes/.render-estado.log 2>&1
SITE=_site-rascunhos tem teste-rascunho.html "Teste de rascunho" "rascunho aparece no perfil rascunhos"
SITE=_site-rascunhos tem teste-rascunho.html "Fascículo ${NO}1 e ${NO}12" "nº e número unidos por espaço inseparável"
fim
```

Rode `bash testes/t02-maquinaria.sh`. Esperado: FALHA (sem link de pular, sem menu.js, sem og:image).

- [ ] **Passo 2: Escrever `filtros/comum.lua`**

```lua
-- filtros/comum.lua: funções usadas pelos filtros do site (maquinaria: não mexa).
-- Uso, num filtro: local comum = dofile(quarto.utils.resolve_path("comum.lua"))
local M = {}

M.NBSP = "\u{00A0}"

-- ---- Texto e HTML -----------------------------------------------------------

-- Texto simples de um valor do YAML ("" se não existir), sem espaços nas pontas.
function M.texto(valor)
  if valor == nil then return "" end
  if type(valor) == "boolean" then return tostring(valor) end
  local s = pandoc.utils.stringify(valor)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Escapa texto para HTML e junta "nº" ao número com espaço inseparável.
function M.esc(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
  s = s:gsub("nº%s+(%d)", "nº&nbsp;%1")
  return s
end

function M.html(s) return pandoc.RawBlock("html", s) end

-- ---- Arquivos ---------------------------------------------------------------

function M.raiz() return quarto.project.directory end
function M.caminho(...) return pandoc.path.join({ ... }) end
function M.pasta_atual() return pandoc.path.directory(quarto.doc.input_file) end

function M.existe(caminho)
  local f = io.open(caminho, "r")
  if f then f:close() return true end
  return false
end

function M.ler_arquivo(caminho)
  local f = io.open(caminho, "r")
  if not f then return nil end
  local txt = f:read("a")
  f:close()
  return txt
end

-- Sem "smart" (aspas retas continuam retas) e sem HTML cru: o texto sai como o aluno escreveu.
local function yaml_para_meta(yaml)
  return pandoc.read("---\n" .. yaml .. "\n---\n", "markdown-smart-raw_html").meta
end

function M.ler_yaml(caminho)
  local txt = M.ler_arquivo(caminho)
  if not txt then return nil end
  return yaml_para_meta(txt)
end

-- Só o cabeçalho YAML de um .qmd, como o aluno escreveu (sem a normalização do Quarto).
function M.cabecalho(caminho_qmd)
  local txt = M.ler_arquivo(caminho_qmd)
  if not txt then return nil end
  txt = txt:gsub("^\239\187\191", "")
  local yaml = txt:match("^%-%-%-%s*\r?\n(.-)\r?\n%-%-%-")
  if not yaml then return nil end
  return yaml_para_meta(yaml)
end

function M.relativo(caminho)
  local r = M.raiz()
  if caminho:sub(1, #r) == r then return (caminho:sub(#r + 2):gsub("\\", "/")) end
  return caminho
end

function M.parar(mensagem)
  io.stderr:write("\n[MacroLiga] " .. mensagem .. "\n\n")
  os.exit(1)
end

-- Anexa assets/js/<nome>.js à página (o Quarto copia para site_libs/).
function M.script(nome)
  quarto.doc.add_html_dependency({
    name = "macroliga-" .. nome,
    version = "1.0",
    scripts = { { path = M.caminho(M.raiz(), "assets", "js", nome .. ".js"), afterBody = true } },
  })
end

-- ---- Rascunhos --------------------------------------------------------------

function M.perfil_rascunhos()
  local p = os.getenv("QUARTO_PROFILE") or ""
  return p:find("rascunhos", 1, true) ~= nil
end
function M.rascunho(y) return y ~= nil and y.draft == true end
function M.visivel(y) return not M.rascunho(y) or M.perfil_rascunhos() end

-- ---- Conteúdo do site ---------------------------------------------------------

-- Subpastas (com index.qmd) de uma pasta, em ordem alfabética, sem as que começam com "_".
function M.subpastas(pasta)
  local ok, nomes = pcall(pandoc.system.list_directory, pasta)
  if not ok then return {} end
  local r = {}
  for _, n in ipairs(nomes) do
    if not n:match("^_") and M.existe(M.caminho(pasta, n, "index.qmd")) then table.insert(r, n) end
  end
  table.sort(r)
  return r
end

function M.fasciculos(apenas_visiveis)
  local base = M.caminho(M.raiz(), "publicacoes")
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    if nome:match("^n%d+$") then
      local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
      if y and (not apenas_visiveis or M.visivel(y)) then
        table.insert(r, { numero = tonumber(M.texto(y.numero)) or 0, pasta = nome, meta = y })
      end
    end
  end
  table.sort(r, function(a, b) return a.numero < b.numero end)
  return r
end

function M.textos_do_fasciculo(pasta, apenas_visiveis)
  local base = M.caminho(M.raiz(), "publicacoes", pasta)
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
    if y and (not apenas_visiveis or M.visivel(y)) then
      table.insert(r, { slug = nome, meta = y, ordem = tonumber(M.texto(y.ordem)) or 99 })
    end
  end
  table.sort(r, function(a, b) return a.ordem < b.ordem end)
  return r
end

-- Itens de publicacoes/em-breve.yml (uma lista no topo do arquivo).
function M.em_breve()
  local txt = M.ler_arquivo(M.caminho(M.raiz(), "publicacoes", "em-breve.yml"))
  if not txt then return {} end
  local recuado = "  " .. txt:gsub("\r?\n", "\n  ")
  local itens = yaml_para_meta("itens:\n" .. recuado).itens
  if type(itens) ~= "table" then return {} end
  return itens
end

function M.eventos()
  local base = M.caminho(M.raiz(), "eventos")
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
    if y then table.insert(r, { pasta = nome, meta = y }) end
  end
  return r
end

function M.tem_evento(situacao)
  for _, e in ipairs(M.eventos()) do
    if M.texto(e.meta.situacao) == situacao then return true end
  end
  return false
end

function M.graficos(apenas_visiveis)
  local base = M.caminho(M.raiz(), "graficos")
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
    if y and (not apenas_visiveis or M.visivel(y)) then table.insert(r, { pasta = nome, meta = y }) end
  end
  return r
end

-- ---- Slugs e datas ---------------------------------------------------------------

local ACENTOS = {
  ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a",
  ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["í"] = "i", ["ì"] = "i",
  ["ó"] = "o", ["ò"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ü"] = "u",
  ["ç"] = "c", ["ñ"] = "n",
}

-- "Atividade econômica, mercado de trabalho e crédito" -> "atividade-economica-mercado-de-trabalho-e-credito"
function M.slug(s)
  s = pandoc.text.lower(M.texto(s))
  for de, para in pairs(ACENTOS) do s = s:gsub(de, para) end
  s = s:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  return s
end

local MESES = { "janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho",
  "agosto", "setembro", "outubro", "novembro", "dezembro" }
local MESES_ABNT = { "jan.", "fev.", "mar.", "abr.", "maio", "jun.", "jul.",
  "ago.", "set.", "out.", "nov.", "dez." }

-- Aceita "2026-11-27", "27 de novembro de 2026" ou "27/11/2026". Devolve 27, 11, 2026 (ou nil).
function M.partes_data(valor)
  local s = M.texto(valor)
  local a, m, d = s:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
  if a then return tonumber(d), tonumber(m), tonumber(a) end
  local d2, nome, a2 = s:match("^(%d+) de (%S+) de (%d%d%d%d)$")
  if d2 then
    for i, n in ipairs(MESES) do
      if n == pandoc.text.lower(nome) then return tonumber(d2), i, tonumber(a2) end
    end
  end
  local d3, m3, a3 = s:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
  if d3 then return tonumber(d3), tonumber(m3), tonumber(a3) end
  return nil
end

function M.data_extenso(valor)
  local d, m, a = M.partes_data(valor)
  if not d then return M.texto(valor) end
  return d .. " de " .. MESES[m] .. " de " .. a
end

function M.data_abnt(valor)
  local d, m, a = M.partes_data(valor)
  if not d then return "" end
  return MESES_ABNT[m] .. " " .. a
end

-- ---- Blocos repetidos ------------------------------------------------------------

local function codificar_url(s)
  return (s:gsub("[^%w%-%._~]", function(c) return string.format("%%%02X", string.byte(c)) end))
end

-- Questionário (indicador da extensão). Sem questionario.url, avisa e não mostra nada.
function M.questionario(meta, frase, titulo)
  local q = meta.questionario or {}
  local url = M.texto(q.url)
  if url == "" then
    quarto.log.warning("[MacroLiga] questionario.url está vazio em _variables.yml: o questionário não aparece em "
      .. M.relativo(quarto.doc.input_file) .. ".")
    return nil
  end
  local campo = M.texto(q["campo-pagina"])
  if campo ~= "" then
    local sep = url:find("?", 1, true) and "&" or "?"
    url = url .. sep .. "usp=pp_url&" .. campo .. "=" .. codificar_url(titulo or "")
  end
  return M.html(table.concat({
    '<section class="questionario" aria-label="Questionário de avaliação">',
    '<p>' .. M.esc(frase) .. '</p>',
    '<p class="acoes"><a class="botao" href="' .. M.esc(url) .. '">Responder ao questionário</a></p>',
    '</section>',
  }, "\n"))
end

function M.aviso_institucional()
  return M.html('<p class="aviso">Os textos publicados não representam a posição da MacroLiga UFRGS, da FCE ou da UFRGS.</p>')
end

function M.link_instagram(meta)
  local c = meta.contato or {}
  return '<a href="' .. M.esc(M.texto(c["instagram-url"])) .. '">' .. M.esc(M.texto(c.instagram)) .. '</a>'
end

-- Ação de inscrição de um evento (spec 3.3.4).
function M.acao_inscricao(valor)
  local v = M.texto(valor)
  if v == "" then return '<p class="evento__inscricao">Inscrições em breve.</p>' end
  if v == "livre" then return '<p class="evento__inscricao">Entrada livre, sem inscrição.</p>' end
  return '<p class="acoes"><a class="botao" href="' .. M.esc(v) .. '">Fazer inscrição</a></p>'
end

-- Marca com o atributo hidden as divs cujos ids estão em `ids` (um conjunto: {id = true}).
-- (Ocultar em vez de apagar: as listings do Quarto precisam encontrar a div delas.)
function M.ocultar(blocos, ids)
  return blocos:walk({
    Div = function(d)
      if ids[d.identifier] then
        d.attributes.hidden = ""
        return d
      end
    end,
  })
end

return M
```

- [ ] **Passo 3: Escrever `filtros/montar.lua`, `filtros/tipografia.lua` e `filtros/contagem.lua`**

`filtros/montar.lua`:

```lua
-- filtros/montar.lua: monta as páginas a partir do cabeçalho YAML (maquinaria: não mexa).
-- O tipo de página vem da chave "pagina" (no cabeçalho das páginas fixas e nos
-- _metadata.yml das pastas). Cada tipo tem seu montador em filtros/paginas/<tipo>.lua.
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

function Pandoc(doc)
  comum.script("menu")
  local pagina = comum.texto(doc.meta.pagina)
  if pagina == "" then return doc end
  local arquivo = quarto.utils.resolve_path("paginas/" .. pagina .. ".lua")
  if not comum.existe(arquivo) then return doc end
  local montar = dofile(arquivo)
  return montar(doc, comum)
end
```

`filtros/tipografia.lua`:

```lua
-- filtros/tipografia.lua: "nº" e o número nunca se separam (docs/design-tokens.md).
-- Troca o espaço entre "nº" e um número por um espaço inseparável.
local NBSP = "\u{00A0}"

function Inlines(inlines)
  for i = 1, #inlines - 2 do
    local a, b, c = inlines[i], inlines[i + 1], inlines[i + 2]
    if a.t == "Str" and a.text:match("nº$") and b.t == "Space" and c.t == "Str" and c.text:match("^%d") then
      inlines[i + 1] = pandoc.Str(NBSP)
    end
  end
  return inlines
end
```

`filtros/contagem.lua`:

```lua
-- filtros/contagem.lua: contagem de visitas com o GoatCounter (spec 4.4), sem cookies e sem banner.
-- Só entra com o código preenchido em _variables.yml (contagem.goatcounter), e o script
-- não roda em localhost: nunca conta as visitas do quarto preview.
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

function Meta(meta)
  local codigo = comum.texto(meta.contagem and meta.contagem.goatcounter)
  if codigo == "" then return nil end
  if not codigo:match("^[%w%-]+$") then
    comum.parar('o código do GoatCounter "' .. codigo .. '" (contagem.goatcounter, em _variables.yml) '
      .. 'deve ter só letras, números e hífens, como em "macroliga".')
  end
  quarto.doc.include_text("after-body", string.format([[
<script>
(function () {
  var h = location.hostname;
  if (location.protocol === "file:" || h === "localhost" || h === "127.0.0.1" || h === "[::1]") return;
  var s = document.createElement("script");
  s.async = true;
  s.src = "https://gc.zgo.at/count.js";
  s.setAttribute("data-goatcounter", "https://%s.goatcounter.com/count");
  document.body.appendChild(s);
})();
</script>]], codigo))
  return nil
end
```

- [ ] **Passo 4: Escrever `filtros/validar.lua`**

```lua
-- filtros/validar.lua: confere o cabeçalho YAML de textos, fascículos, eventos e gráficos
-- e interrompe o quarto render com uma mensagem em português (spec 3.6).
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

local NOMES = { texto = "Texto", fasciculo = "Fascículo", evento = "Evento", grafico = "Gráfico" }
local OBRIGATORIOS = {
  texto = { "title", "author", "tipo", "eixo", "fasciculo", "ordem", "sintese", "revisao" },
  fasciculo = { "numero", "date" },
  evento = { "title", "date", "local", "situacao" },
  grafico = { "title", "author", "date", "eixo", "fonte" },
}

local function lista(valor)
  local r = {}
  for _, v in ipairs(valor or {}) do table.insert(r, comum.texto(v)) end
  return r
end

local function contem(t, v)
  for _, x in ipairs(t) do if x == v then return true end end
  return false
end

function Meta(meta)
  local pagina = comum.texto(meta.pagina)
  if not OBRIGATORIOS[pagina] then return nil end
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local nome = comum.texto(y.title)
  if nome == "" and pagina == "fasciculo" then nome = "nº " .. comum.texto(y.numero) end
  local pasta = comum.pasta_atual()

  local function parar(msg)
    comum.parar(string.format('%s "%s" (%s): %s', NOMES[pagina], nome, comum.relativo(quarto.doc.input_file), msg))
  end
  local function checar_opcao(valor, opcoes, rotulo)
    if not contem(opcoes, valor) then
      parar(string.format('o %s "%s" não existe. Use um destes: %s.', rotulo, valor, table.concat(opcoes, "; ")))
    end
  end
  local function checar_pdf()
    local pdf = comum.texto(y.pdf)
    if pdf == "" then parar('falta o campo "pdf". Ele é obrigatório num item publicado (sem draft: true).') end
    if not comum.existe(comum.caminho(pasta, pdf)) then
      parar(string.format('o arquivo "%s" (campo "pdf") não está na pasta %s.', pdf, comum.relativo(pasta)))
    end
  end

  for _, campo in ipairs(OBRIGATORIOS[pagina]) do
    if comum.texto(y[campo]) == "" then
      parar(string.format('o campo "%s" está vazio. Preencha-o no cabeçalho do index.qmd.', campo))
    end
  end
  if pagina == "texto" or pagina == "grafico" then checar_opcao(comum.texto(y.eixo), lista(meta.eixos), "eixo") end
  if pagina == "texto" then checar_opcao(comum.texto(y.tipo), lista(meta.tipos), "tipo") end
  if pagina == "evento" then
    local s = comum.texto(y.situacao)
    if s ~= "proximo" and s ~= "realizado" then
      parar(string.format('a situação "%s" não existe. Use "proximo" ou "realizado".', s))
    end
  end
  if (pagina == "evento" or pagina == "fasciculo") and comum.texto(y.capa) ~= "" and comum.texto(y["capa-alt"]) == "" then
    parar('a capa precisa de uma descrição no campo "capa-alt".')
  end

  if comum.rascunho(y) then return nil end   -- em rascunho, sintese, revisao, doi e pdf aceitam placeholder
  if pagina == "texto" then
    if comum.texto(y.doi) == "" then
      local fasc = comum.cabecalho(comum.caminho(pasta, "..", "index.qmd")) or {}
      if comum.texto(fasc.doi) == "" then parar('falta o DOI: preencha "doi" no texto ou no fascículo.') end
    end
    checar_pdf()
  elseif pagina == "fasciculo" then
    checar_pdf()
  end
  return nil
end
```

- [ ] **Passo 5: Escrever `assets/js/menu.js`**

```js
// Menu principal (maquinaria: não mexa).
// 1. Marca a seção da página atual: fascículo e texto marcam Publicações; evento marca
//    Eventos; gráfico marca Gráficos comentados. (O Quarto só marca a página exata.)
// 2. Dá ao botão do menu do celular um rótulo visível e acessível: "Abrir menu" / "Fechar menu".
(function () {
  function pronto(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }
  pronto(function () {
    var meta = document.querySelector('meta[name="quarto:offset"]');
    var raiz = new URL(meta ? meta.content : "./", location.href).pathname;
    var aqui = location.pathname;
    document.querySelectorAll("#navbarCollapse .nav-link").forEach(function (a) {
      var secao = new URL(a.getAttribute("href"), location.href).pathname.replace(/index\.html$/, "");
      if (secao === raiz) return;
      if (aqui.indexOf(secao) === 0) {
        a.classList.add("active");
        a.setAttribute("aria-current", "page");
      }
    });

    var botao = document.querySelector(".navbar-toggler");
    var menu = document.getElementById("navbarCollapse");
    if (!botao || !menu) return;
    botao.removeAttribute("role");
    function rotular(aberto) {
      var t = aberto ? "Fechar menu" : "Abrir menu";
      botao.textContent = t;
      botao.setAttribute("aria-label", t);
    }
    rotular(false);
    menu.addEventListener("show.bs.collapse", function () { rotular(true); });
    menu.addEventListener("hide.bs.collapse", function () { rotular(false); });
  });
})();
```

- [ ] **Passo 6: Escrever o pós-render e os perfis**

`ferramentas/apagar-rascunhos.lua`:

```lua
-- Pós-render (maquinaria: não mexa). Com draft: true, o Quarto deixa no lugar da página
-- um HTML vazio (<html ...></html>). Este script apaga esses arquivos de _site/, para
-- que os rascunhos não existam no site publicado (spec 3.4).
local saida = os.getenv("QUARTO_PROJECT_OUTPUT_DIR")
if not saida then return end

local function varrer(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    local f = io.open(caminho, "r")
    local conteudo = f and f:read("a")
    if f then f:close() end
    if conteudo then
      if nome:match("%.html$") and conteudo:match("^%s*<!DOCTYPE html>%s*<html[^>]*></html>%s*$") then
        os.remove(caminho)
      end
    else
      varrer(caminho)
    end
  end
end

varrer(saida)
```

`_quarto-rascunhos.yml`:

```yaml
# Perfil para ver os rascunhos (draft: true) completos:
#   quarto preview --profile rascunhos
# Gera o site em _site-rascunhos/, que nunca é publicado.
project:
  output-dir: _site-rascunhos
website:
  draft-mode: visible
```

`_quarto-subcaminho.yml`:

```yaml
# Perfil de teste: o site servido sob um subcaminho, como seria em ufrgs.br/macroliga.
#   quarto render --profile subcaminho   (usado na Tarefa 14)
project:
  output-dir: _site-subcaminho
website:
  site-url: "http://127.0.0.1:8772/macroliga"
```

- [ ] **Passo 7: Gerar a imagem de compartilhamento (Open Graph)**

`ferramentas/og.html`:

```html
<!doctype html>
<html lang="pt">
<head>
<meta charset="utf-8">
<title>Imagem de compartilhamento</title>
<style>
  html, body { margin: 0; width: 1200px; height: 630px; background: #FAF8F4; }
  body { display: grid; place-items: center; }
  img { width: 420px; height: 420px; }
</style>
</head>
<body><img src="../assets/marca/svg/macroliga-selo-cor.svg" alt=""></body>
</html>
```

```bash
python -m http.server 8773 --bind 127.0.0.1 >/dev/null 2>&1 & P=$!
for _ in $(seq 1 300); do curl -s -o /dev/null http://127.0.0.1:8773/ && break; done
npx --yes playwright@1.56.0 screenshot --channel chrome --viewport-size=1200,630 \
  http://127.0.0.1:8773/ferramentas/og.html assets/marca/png/macroliga-og.png
kill $P
```

Abra `assets/marca/png/macroliga-og.png`: o selo aparece centrado, sem distorção, sobre off-white, em 1200 × 630.

- [ ] **Passo 8: Ligar tudo no `_quarto.yml`**

No bloco `project:`, depois de `render:`, acrescente:

```yaml
  post-render: ferramentas/apagar-rascunhos.lua
```

No bloco `website:`, depois de `favicon:`, acrescente:

```yaml
  image: assets/marca/png/macroliga-og.png
  open-graph: true
```

No bloco `format: html:`, depois de `include-in-header:`, acrescente:

```yaml
    include-before-body:
      text: '<a class="pular" href="#quarto-document-content">Pular para o conteúdo</a>'
```

No fim do arquivo, acrescente:

```yaml

filters:
  - filtros/validar.lua
  - filtros/montar.lua
  - filtros/tipografia.lua
  - filtros/contagem.lua
```

No `index.qmd` provisório, acrescente ao cabeçalho a linha `description: "Site da MacroLiga UFRGS."`.

- [ ] **Passo 9: Rodar os testes**

```bash
bash testes/rodar.sh 02
```

Esperado: `Tudo certo.` nos dois arquivos. Se `menu.js` não for encontrado em `site_libs/macroliga-menu-1.0/`, veja onde o Quarto o pôs (`find _site/site_libs -name menu.js`) e ajuste o teste ao caminho real. O que importa é o script estar anexado com caminho relativo. Se o render reclamar da chave `afterBody` em `comum.script`, apague-a: os scripts já esperam o `DOMContentLoaded`.

- [ ] **Passo 10: Commit**

```bash
git add filtros ferramentas assets/js/menu.js assets/marca/png/macroliga-og.png _quarto.yml _quarto-rascunhos.yml _quarto-subcaminho.yml index.qmd testes/t02-maquinaria.sh testes/e02-maquinaria.sh
git commit -m "Adiciona a maquinaria Lua, o perfil de rascunhos e a contagem de visitas

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 3: Tema: base, botões, navbar, rodapé e componentes da prancha

**Arquivos:**
- Modificar: `estilos/macroliga.scss` (seções novas depois dos tokens), `_quarto.yml` (`page-footer`)
- Testar: `testes/t03-tema.sh`

**Interfaces:**
- Consome: tokens da Tarefa 1; `menu.js` da Tarefa 2.
- Produz as classes que as tarefas seguintes usam: `.conteiner`, `.pagina`, `.pagina__intro`, `.fundo-azul`, `.botao`, `.botao--secundario`, `.acoes`, `.pular`, `.so-celular`, `.so-desktop`, `.abertura*`, `.mapa-*`, `.fasciculo*`, `.sumario*`, `.lista-textos`, `.item-texto*`, `.grafico*`, `.rodape__*`, `.bloco__titulo`, `.trilha`, `.titulo-longo`, `.dados`, `.nota`, `.aviso`, `.estado-vazio`, `.questionario`.

- [ ] **Passo 1: Escrever o teste (falha primeiro)**

`testes/t03-tema.sh`:

```bash
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
n=$(grep -c 'var(--vermelho)' estilos/macroliga.scss)
[ "$n" -le 2 ] && ok "var(--vermelho) usado no máximo 2 vezes no SCSS ($n)" || falha "var(--vermelho) usado $n vezes"
n=$(grep -c 'tabular-nums' estilos/macroliga.scss)
[ "$n" -eq 1 ] && ok "tabular-nums numa única regra" || falha "tabular-nums em $n regras"
fim
```

Rode `bash testes/t03-tema.sh`. Esperado: FALHA.

- [ ] **Passo 2: Acrescentar ao SCSS a base e os ajustes do Quarto**

Acrescente a `estilos/macroliga.scss`, depois do bloco `@media` dos tokens:

```scss
// ---- Base -------------------------------------------------------------------
body {
  background: var(--offwhite);
  color: var(--grafite);
  font-family: var(--fonte-texto);
  font-size: var(--fs-corpo);
  font-weight: var(--peso-texto);
  line-height: var(--lh-texto);
}

[hidden] { display: none !important; }

// Algarismos tabulares só onde números se alinham (tabelas, dados, gráficos).
// No corpo, a Inter com tabular-nums também alarga o hífen.
.numeros, table, .dados, .item-texto__dados { font-variant-numeric: tabular-nums; }

h1, h2, h3 {
  font-family: var(--fonte-titulo);
  color: var(--azul-marinho);
  line-height: var(--lh-titulo);
  margin: 0;
  padding: 0;
  border: 0;
  text-wrap: balance;
}
h1 { font-size: var(--fs-h1); font-weight: var(--peso-h1); }
h2 { font-size: var(--fs-h2); font-weight: var(--peso-h2); }
h3 { font-size: var(--fs-h3); font-weight: var(--peso-h3); }

img { max-width: 100%; height: auto; display: block; }

a {
  color: var(--azul-marinho);
  text-decoration-thickness: 1px;
  text-underline-offset: 0.18em;
}
a:hover { color: var(--azul-marinho); text-decoration-thickness: 2px; }

:focus-visible {
  outline: 3px solid var(--cor-foco);
  outline-offset: 3px;
  box-shadow: none;
}

// Contexto azul-marinho: texto, links e foco passam a off-white.
.fundo-azul {
  --cor-foco: var(--offwhite);
  background: var(--azul-marinho);
  color: var(--offwhite);
}
.fundo-azul a, .fundo-azul a:hover { color: var(--offwhite); }
.fundo-azul h1, .fundo-azul h2, .fundo-azul h3 { color: var(--offwhite); }

.conteiner {
  width: 100%;
  max-width: calc(var(--largura-max) + 2 * var(--margem));
  margin-inline: auto;
  padding-inline: var(--margem);
}

.pular {
  position: absolute;
  left: var(--margem);
  top: -10rem;
  z-index: 2000;
  padding: var(--esp-3) var(--esp-4);
  background: var(--offwhite);
  color: var(--azul-marinho);
  font-weight: var(--peso-forte);
}
.pular:focus { top: var(--esp-2); }

.so-desktop { display: none; }
@media (min-width: 992px) {
  .so-desktop { display: block; }
  .so-celular { display: none; }
}

// ---- Ajustes do Quarto ------------------------------------------------------
// Cada página escreve o próprio h1; o título padrão do Quarto (e o aviso de rascunho) some.
#title-block-header { display: none; }
#quarto-content, main.content, #quarto-document-content { margin: 0; padding: 0; max-width: none; }
// O cabeçalho rola com a página: sem a animação de esconder e reaparecer.
#quarto-header { position: relative; }
body.nav-fixed { padding-top: 0 !important; }
.quarto-figure, figure { margin: 0; }

// ---- Componente: página (fluxo de texto das páginas fixas) --------------------
.pagina { padding-block: var(--esp-7) var(--secao); }
.pagina h1 { margin-bottom: var(--esp-5); }
.pagina h2 { margin: var(--secao) 0 var(--esp-4); }
.pagina h3 { margin: var(--esp-6) 0 var(--esp-3); }
.pagina p, .pagina ul, .pagina ol { max-width: var(--medida); margin: 0 0 var(--esp-4); }
.pagina__intro p { max-width: 46ch; }
.bloco__titulo { font-size: var(--fs-h2); font-weight: var(--peso-h2); margin-bottom: var(--esp-5); }
.trilha { font-size: var(--fs-meta); margin-bottom: var(--esp-5); }
.titulo-longo { font-size: var(--fs-titulo-longo); font-weight: var(--peso-titulo-longo); max-width: 24em; }
.nota { font-size: var(--fs-meta); max-width: var(--medida); margin-top: var(--esp-5); }
.estado-vazio { max-width: var(--medida); }
.aviso {
  margin-top: var(--secao);
  padding-top: var(--esp-4);
  border-top: var(--linha-grade);
  font-size: var(--fs-pequeno);
  max-width: var(--medida);
}
.dados {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: var(--esp-1) var(--esp-3);
  font-size: var(--fs-meta);
}
.dados dt { font-weight: var(--peso-forte); }
.dados dd { margin: 0; overflow-wrap: anywhere; }
.questionario {
  margin-top: var(--esp-7);
  padding: var(--esp-5);
  border: var(--linha-grade);
  max-width: var(--medida);
}
.questionario .acoes { margin-top: var(--esp-4); }
```

- [ ] **Passo 3: Acrescentar os componentes da prancha**

Acrescente a seguir, copiando de `design/macroliga.css` sem mudar valores: botões (linhas 169–193), abertura (linhas 242–325), fascículo e sumário (linhas 327–364), lista de textos (linhas 366–396) e gráfico comentado (linhas 398–413). Duas adaptações:

- troque cada cabeçalho `/* ---- Componente: x ---- */` por `// ---- Componente: x ----`;
- em `.item-texto__dados`, apague a linha `font-variant-numeric: tabular-nums;`, porque a regra única de algarismos tabulares, na seção Base, já cobre `.item-texto__dados`.

Mantenha o bloco `@media (prefers-reduced-motion: reduce)` da abertura. Depois desses blocos, acrescente o reset de margens dos componentes:

```scss
// Dentro dos componentes, parágrafos e listas não têm margem (o espaçamento é do componente).
:is(.abertura, .fasciculo, .item-texto, .sumario, .grafico, .nav-footer, .questionario, .dados)
  :is(p, ul, ol, dl, dd, figure) { margin: 0; }
.questionario .acoes { margin-top: var(--esp-4); }
```

- [ ] **Passo 4: Acrescentar ao SCSS a navbar e o rodapé do Quarto**

```scss
// ---- Componente: cabeçalho (G1), sobre a navbar do Quarto --------------------
// Na Início, a navbar azul se funde à abertura azul (D-C): sem borda nem sombra.
.navbar {
  --bs-navbar-color: var(--offwhite);
  --bs-navbar-hover-color: var(--offwhite);
  --bs-navbar-active-color: var(--offwhite);
  --cor-foco: var(--offwhite);
  padding-block: 0;
  border: 0;
  box-shadow: none;
}
.navbar > .container-fluid {
  max-width: calc(var(--largura-max) + 2 * var(--margem));
  margin-inline: auto;
  padding-inline: var(--margem);
  min-height: 4rem;
}
.navbar-brand { padding-block: var(--esp-3); margin-right: 0; }
.navbar-brand .navbar-logo { height: 2.25rem; max-height: none; width: auto; }
.navbar .navbar-toggler {
  min-height: 2.75rem;
  padding: 0 var(--esp-4);
  border: 2px solid var(--offwhite);
  border-radius: var(--raio-0);
  color: var(--offwhite);
  font: var(--peso-forte) var(--fs-meta)/1 var(--fonte-texto);
}
.navbar .navbar-toggler:focus { box-shadow: none; }
.navbar .nav-link {
  display: flex;
  align-items: center;
  min-height: 2.75rem;
  color: var(--offwhite);
  font-size: var(--fs-meta);
  text-decoration: none;
}
.navbar .nav-link:hover { color: var(--offwhite); text-decoration: underline 1px; text-underline-offset: 0.45em; }
.navbar .nav-link.active, .navbar .nav-link[aria-current="page"] {
  color: var(--offwhite);
  font-weight: var(--peso-forte);
  text-decoration: underline 2px;
  text-underline-offset: 0.45em;
}
@media (max-width: 991.98px) {
  .navbar-collapse .navbar-nav { padding-block: var(--esp-3) var(--esp-5); }
  .navbar .nav-link { min-height: var(--alvo-min); font-size: var(--fs-corpo); }
}
@media (min-width: 992px) {
  .navbar > .container-fluid { min-height: 5rem; }
  .navbar-brand .navbar-logo { height: 2.75rem; }
  .navbar-nav { gap: var(--esp-5); }
}

// ---- Componente: rodapé (G2), sobre o rodapé do Quarto ------------------------
footer.footer { background: var(--azul-marinho); border: 0; }
.nav-footer {
  --cor-foco: var(--offwhite);
  display: grid;
  gap: var(--esp-7);
  align-items: start;
  max-width: calc(var(--largura-max) + 2 * var(--margem));
  min-height: 0;
  margin-inline: auto;
  padding: var(--esp-8) var(--margem) var(--esp-6);
  border: 0;
  color: var(--offwhite);
  font-size: var(--fs-meta);
  text-align: left;
}
.nav-footer > div {
  order: initial;
  width: auto;
  min-height: 0;
  margin: 0;
  text-align: left;
  justify-content: flex-start;
}
.nav-footer a, .nav-footer a:hover { color: var(--offwhite); }
.nav-footer p + p { margin-top: var(--esp-3); }
.nav-footer ul { list-style: none; padding: 0; margin-bottom: var(--esp-5); }
.nav-footer li + li { margin-top: var(--esp-2); }
.rodape__logo { height: 2.5rem; width: auto; margin-bottom: var(--esp-5); }
.rodape__nome { font-weight: var(--peso-forte); }
.rodape__titulo {
  font-size: var(--fs-h3);
  font-weight: var(--peso-h2);
  color: var(--offwhite);
  margin-bottom: var(--esp-4);
}
.nav-footer .botao--secundario { background: transparent; border-color: var(--offwhite); color: var(--offwhite); }
@media (min-width: 992px) {
  .nav-footer { grid-template-columns: 5fr 3fr 4fr; }
}
```

- [ ] **Passo 5: Escrever o rodapé no `_quarto.yml`**

No bloco `website:`, depois de `navbar:`, acrescente:

```yaml
  page-footer:
    left: |
      ![](/assets/marca/svg/macroliga-horizontal-branco.svg){.rodape__logo fig-alt="MacroLiga UFRGS" width="188" height="40"}

      [MacroLiga UFRGS, Liga Acadêmica de Macroeconomia.]{.rodape__nome}

      Projeto de extensão da Faculdade de Ciências Econômicas da UFRGS, coordenado pelo {{< var coordenacao >}}.
    center: |
      <h2 class="rodape__titulo">Contato</h2>

      - E-mail: [{{< var contato.email >}}](mailto:{{< var contato.email >}})
      - Instagram: [{{< var contato.instagram >}}]({{< var contato.instagram-url >}})
      - LinkedIn: [{{< var contato.linkedin >}}]({{< var contato.linkedin-url >}})

      [Escrever para a liga](mailto:{{< var contato.email >}}){.botao .botao--secundario}
    right: |
      Textos publicados sob a licença [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.pt-br).

      Site feito pela equipe de Comunicação da liga, com Quarto, e publicado no GitHub Pages.

      © 2026 MacroLiga UFRGS
```

- [ ] **Passo 6: Rodar os testes**

```bash
bash testes/rodar.sh 0
```

Esperado: `Tudo certo.` em t01, t02, e02 e t03. Se o teste do e-mail ou do Instagram falhar porque o shortcode não foi resolvido dentro do destino do link (confira com `grep -o 'mailto:[^"]*' _site/index.html`), escreva os três itens do `center:` em HTML, por exemplo `- E-mail: <a href="mailto:{{< var contato.email >}}">{{< var contato.email >}}</a>`, e o botão como `<a class="botao botao--secundario" href="mailto:{{< var contato.email >}}">Escrever para a liga</a>`. Rode o teste de novo.

- [ ] **Passo 7: Verificação visual**

```bash
bash ferramentas/capturar.sh inicio=index.html
```

Compare `capturas/inicio-*.png` com `capturas/prancha-*.png`, conforme a Verificação visual. Confira em especial: navbar azul com logo branco e "Abrir menu" (texto, não ícone) em 390 px; menu em linha em 1280 px; rodapé em três blocos (coluna em 390, lado a lado em 1280); nenhum espaço entre a navbar e o topo; foco visível em off-white sobre azul (navegue com Tab num Chrome normal: `python -m http.server -d _site` e abra `localhost:8000`).

- [ ] **Passo 8: Commit**

```bash
git add estilos/macroliga.scss _quarto.yml testes/t03-tema.sh
git commit -m "Aplica o tema da prancha à navbar, ao rodapé e aos componentes

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 4: Início (I1, I2 em breve, I4 vazio, I5, I6)

**Arquivos:**
- Modificar: `design/gerar-mapa.py` (grava também `assets/img/mapa-pontos.svg`)
- Criar: `assets/img/mapa-pontos.svg` (gerado), `publicacoes/em-breve.yml`, `filtros/paginas/inicio.lua`
- Criar: `modelos-listing/em-breve-inicio.ejs`, `modelos-listing/fasciculo-destaque.ejs`, `modelos-listing/evento-proximo.ejs`
- Modificar: `index.qmd` (substitui o provisório), `estilos/macroliga.scss` (seções Início e etapas)
- Testar: `testes/t04-inicio.sh`

**Interfaces:**
- Consome: `comum.fasciculos`, `comum.em_breve`, `comum.tem_evento`, `comum.ocultar`, `comum.esc`, `comum.html`.
- Produz os ids `fasciculo`, `i2-fasciculo`, `i2-em-breve`, `lista-fasciculo-destaque`, `lista-em-breve`, `i3` (Tarefa 15), `i4`, `lista-proximo-evento`, `i4-vazio` e `como-funcionamos`, e o componente `.etapas` / `.etapa` / `.etapa--publicacao`, reusado pela Sobre (Tarefa 5).
- Produz o formato de `publicacoes/em-breve.yml` (spec 3.3.3), lido também pela Tarefa 8.

- [ ] **Passo 1: Escrever o teste (falha primeiro)**

`testes/t04-inicio.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 4: Início no estado de 18/10 (fascículo em breve, sem gráfico, sem evento até a Tarefa 9).
source "$(dirname "$0")/lib.sh"
tem index.html '<h1 class="abertura__titulo" id="abertura-titulo">A conjuntura brasileira, explicada pela teoria\.</h1>' "I1 frase"
tem index.html 'Somos a Liga Acadêmica de Macroeconomia da UFRGS\. Buscamos promover o ensino e o debate da macroeconomia e seus impactos\.' "I1 subtítulo"
tem index.html "<a class=\"botao\" href=\"#fasciculo\">Ver os textos do ${NO}1</a>" "I1 botão antes do lançamento"
tem index.html 'href="#como-funcionamos">Ver como funcionamos' "I1 segundo botão"
conta index.html 'class="mapa-ponto"' 175 "175 pontos do logo"
conta index.html 'class="mapa-destaque"' 1 "um ponto vermelho (Porto Alegre)"
tem index.html 'id="fasciculo"' "âncora do I2"
tem index.html "Fascículo ${NO}1: em breve" "I2 em breve"
tem index.html 'O primeiro fascículo está em produção\.' "I2 texto do em breve"
tem index.html 'Endividamento das famílias e financeirização no Brasil' "I2 lista: Pedone"
tem index.html 'Subdesenvolvimento: uma visão schumpeteriana' "I2 lista: Pittella"
tem index.html 'Seguir @macroliga\.ufrgs para saber do lançamento' "I2 botão Seguir"
tem index.html 'id="i2-fasciculo"[^>]*hidden' "I2 publicado oculto"
tem index.html 'Nenhum evento agendado\.' "I4 estado vazio"
tem index.html 'Todo texto passa pelas mesmas quatro etapas' "I5 título"
conta index.html 'class="etapa( |")' 4 "I5 quatro etapas"
conta index.html 'etapa--publicacao' 1 "I5 etapa Publicação marcada"
tem index.html 'Ler sobre a liga' "I5 botão"
tem index.html 'Seguir no Instagram' "I6 Instagram"
tem index.html 'Seguir no LinkedIn' "I6 LinkedIn"
nao_tem index.html 'id="i3"' "I3 ausente até a Tarefa 15 (D1)"
corpo_nao_tem index.html 'nº [0-9]' "nenhum nº separado do número"
fim
```

Rode-o. Esperado: FALHA.

- [ ] **Passo 2: Gerar o mapa também em `assets/img/`**

Em `design/gerar-mapa.py`, troque as três últimas linhas (de `saida = SITE / "design/mapa-pontos.svg"` até o `print`) por:

```python
svg = "\n".join(linhas) + "\n"
for saida in (SITE / "design/mapa-pontos.svg", SITE / "assets/img/mapa-pontos.svg"):
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(svg, encoding="utf-8")
print(f"{len(pontos)} pontos; Porto Alegre em ({poa[0]}, {poa[1]}); {len(svg.encode())} bytes")
```

Troque também o comentário `# Saída: design/mapa-pontos.svg, para colar no HTML (ou incluir no Quarto).` por `# Saída: design/mapa-pontos.svg (prancha) e assets/img/mapa-pontos.svg (Início do site).`

```bash
python design/gerar-mapa.py && cmp design/mapa-pontos.svg assets/img/mapa-pontos.svg && git diff --stat design/mapa-pontos.svg
```

Esperado: `175 pontos; ...`, `cmp` sem saída e nenhuma mudança em `design/mapa-pontos.svg`.

- [ ] **Passo 3: Criar `publicacoes/em-breve.yml`**

```yaml
# Fascículo anunciado e ainda não publicado. Aparece na Início (I2) e em Publicações (P2).
# No dia do lançamento, apague os itens (deixe só "[]"). Pode anunciar o fascículo seguinte depois.
- numero: 1
  textos:
    - { titulo: "Endividamento das famílias e financeirização no Brasil", autor: "João Pedone" }
    - { titulo: "Impactos setoriais do acordo Mercosul e União Europeia", autor: "Miguel Amorin" }
    - { titulo: "Notas sobre a eficácia da política monetária sob a hipótese de expectativas racionais: uma breve revisão da literatura", autor: "Gabriel Vieira" }
    - { titulo: "Subdesenvolvimento: uma visão schumpeteriana", autor: "Arthur Pittella" }
```

- [ ] **Passo 4: Escrever os templates do I2 e do I4**

`modelos-listing/em-breve-inicio.ejs`:

````text
```{=html}
<% for (const item of items) { const n = item.numero; %>
<article class="fasciculo fasciculo--em-breve">
<div>
<h2 class="fasciculo__titulo">Fascículo nº&nbsp;<%= n %>: em breve</h2>
<p class="fasciculo__frase"><% if (Number(n) === 1) { %>O primeiro fascículo está em produção.<% } else { %>O fascículo nº&nbsp;<%= n %> está em produção.<% } %> O lançamento será em um evento presencial na FCE, em data a ser confirmada.</p>
</div>
<div class="fasciculo__corpo">
<ul class="sumario">
<% for (const t of (item.textos || [])) { %><li><span class="sumario__titulo"><%= t.titulo %></span><span class="sumario__autor"><%= t.autor %></span></li>
<% } %></ul>
</div>
</article>
<% } %>
```
````

`modelos-listing/fasciculo-destaque.ejs`:

````text
```{=html}
<%
const fasciculos = items.filter(i => i.numero !== undefined && i.ordem === undefined)
  .sort((a, b) => Number(b.numero) - Number(a.numero));
const textos = items.filter(i => i.ordem !== undefined);
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const autor = i => [].concat(i.author || []).map(a => (a && a.name) ? (a.name.literal || a.name) : a).join(", ");
const f = fasciculos[0];
if (f) {
  const n = Number(f.numero);
  const seus = textos.filter(x => Number(x.fasciculo) === n).sort((a, b) => Number(a.ordem) - Number(b.ordem));
%>
<h2 class="bloco__titulo">Fascículo mais recente</h2>
<article class="fasciculo">
<% if (f.image) { %><img class="fasciculo__capa" src="<%- f.image %>" alt="Capa do fascículo nº&nbsp;<%= n %>"><% } %>
<div>
<h3 class="fasciculo__titulo"><a href="<%- f.path %>"><%= f.publicacao.nome %> nº&nbsp;<%= n %></a></h3>
<p class="fasciculo__frase"><%= f.date %>. <%= seus.length %> <%= seus.length === 1 ? "texto" : "textos" %> sobre a economia brasileira, revisados por professores da FCE.</p>
</div>
<div class="fasciculo__corpo">
<ul class="sumario">
<% for (const x of seus) { %><li><a class="sumario__titulo" href="<%- x.path %>"><%= t(x.title) %></a><span class="sumario__autor"><%= autor(x) %></span></li>
<% } %></ul>
<div class="acoes">
<a class="botao" href="<%- f.path %>">Ler o fascículo</a>
<a class="botao botao--secundario" href="/publicacoes/index.qmd">Ver todos os fascículos</a>
</div>
</div>
</article>
<% } %>
```
````

`modelos-listing/evento-proximo.ejs`:

````text
```{=html}
<%
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const acao = v => !v ? '<p class="evento__inscricao">Inscrições em breve.</p>'
  : (v === "livre" ? '<p class="evento__inscricao">Entrada livre, sem inscrição.</p>'
  : '<p class="acoes"><a class="botao" href="' + v + '">Fazer inscrição</a></p>');
const e = items[0];
if (e) {
%>
<h2 class="bloco__titulo">Próximo evento</h2>
<h3 class="evento__nome"><a href="<%- e.path %>"><%= t(e.title) %></a></h3>
<p class="evento__quando"><%= e.quando || e.date %><% if (e.horario) { %>, <%= e.horario %><% } %>. <%= e.local %>.</p>
<%- acao(e.inscricao) %>
<% } %>
```
````

- [ ] **Passo 5: Escrever o `index.qmd`**

````markdown
---
title: "Início"
pagina: inicio
description: "A MacroLiga UFRGS publica textos curtos sobre a conjuntura brasileira, escritos por estudantes de graduação e revisados por professores da FCE."
abertura:
  frase: "A conjuntura brasileira, explicada pela teoria."
  subtitulo: "Somos a Liga Acadêmica de Macroeconomia da UFRGS. Buscamos promover o ensino e o debate da macroeconomia e seus impactos."
listing:
  - id: lista-fasciculo-destaque
    contents:
      - "publicacoes/n*/index.qmd"
      - "publicacoes/n*/*/index.qmd"
    template: modelos-listing/fasciculo-destaque.ejs
    date-format: "D [de] MMMM [de] YYYY"
  - id: lista-em-breve
    contents: publicacoes/em-breve.yml
    template: modelos-listing/em-breve-inicio.ejs
  - id: lista-proximo-evento
    contents: "eventos/*/index.qmd"
    template: modelos-listing/evento-proximo.ejs
    include:
      situacao: "proximo"
    sort: "date"
    max-items: 1
    date-format: "D [de] MMMM [de] YYYY"
---

::::::: {.conteiner .inicio}

:::::: {.inicio__producao}

::::: {#fasciculo .inicio__fasciculo}
:::: {#i2-fasciculo}
::: {#lista-fasciculo-destaque}
:::
::::
:::: {#i2-em-breve}
::: {#lista-em-breve}
:::
::: {.acoes}
[Seguir {{< var contato.instagram >}} para saber do lançamento]({{< var contato.instagram-url >}}){.botao}
:::
::::
:::::

::::: {.inicio__lateral}
:::: {#i4 .inicio__evento}
::: {#lista-proximo-evento}
:::
::: {#i4-vazio}
```{=html}
<h2 class="bloco__titulo">Próximo evento</h2>
```
Nenhum evento agendado. Siga [{{< var contato.instagram >}}]({{< var contato.instagram-url >}}) para saber do próximo.
:::
::::
:::::

::::::

::::: {#como-funcionamos .inicio__etapas}
```{=html}
<h2 class="bloco__titulo">Todo texto passa pelas mesmas quatro etapas</h2>
<ol class="etapas">
<li class="etapa"><p class="etapa__titulo">1. Texto</p><p>Um membro escreve sobre um dos temas associados à macroeconomia.</p></li>
<li class="etapa"><p class="etapa__titulo">2. Debate entre pares</p><p>Os membros leem e discutem o texto antes da revisão.</p></li>
<li class="etapa"><p class="etapa__titulo">3. Revisão docente</p><p>Um professor revisa o texto, garantindo a qualidade acadêmica.</p></li>
<li class="etapa etapa--publicacao"><p class="etapa__titulo">4. Publicação</p><p>Os textos aprovados formam um fascículo numerado, com DOI no Zenodo.</p></li>
</ol>
```
::: {.acoes}
[Ler sobre a liga](sobre.qmd){.botao .botao--secundario}
:::
:::::

::::: {.inicio__redes}
```{=html}
<h2 class="bloco__titulo">Acompanhe a liga</h2>
```
Estamos no Instagram e no LinkedIn debatendo sobre macroeconomia e divulgando informações sobre a MacroLiga.

::: {.acoes}
[Seguir no Instagram]({{< var contato.instagram-url >}}){.botao .botao--secundario}
[Seguir no LinkedIn]({{< var contato.linkedin-url >}}){.botao .botao--secundario}
:::
:::::

:::::::
````

- [ ] **Passo 6: Escrever `filtros/paginas/inicio.lua`**

```lua
-- filtros/paginas/inicio.lua: Início (spec 2.2).
-- I1: abertura com o mapa de pontos; o texto vem de "abertura", no cabeçalho do index.qmd.
-- I2: fascículo mais recente ou, se nenhum estiver publicado, o "em breve".
-- I3/I4: oculta o bloco ou o estado vazio que não se aplica.
return function(doc, comum)
  local m = doc.meta
  local visiveis = comum.fasciculos(true)
  local ultimo = visiveis[#visiveis]
  local em_breve = comum.em_breve()[1]
  local ocultos = {}

  local botao
  if ultimo then
    botao = string.format('<a class="botao" href="/publicacoes/%s/index.qmd">Ler o fascículo nº&nbsp;%d</a>',
      ultimo.pasta, ultimo.numero)
    ocultos["i2-em-breve"] = true
  elseif em_breve then
    botao = '<a class="botao" href="#fasciculo">Ver os textos do nº&nbsp;' .. comum.esc(comum.texto(em_breve.numero)) .. '</a>'
    ocultos["i2-fasciculo"] = true
  else
    botao = '<a class="botao" href="/publicacoes/index.qmd">Ver as publicações</a>'
    ocultos["fasciculo"] = true
  end
  if comum.tem_evento("proximo") then ocultos["i4-vazio"] = true end
  if #comum.graficos(true) == 0 then ocultos["i3"] = true end

  local mapa = comum.ler_arquivo(comum.caminho(comum.raiz(), "assets", "img", "mapa-pontos.svg")) or ""
  local abertura = table.concat({
    '<section class="fundo-azul abertura-faixa" aria-labelledby="abertura-titulo">',
    '<div class="conteiner abertura">',
    '<div class="abertura__texto">',
    '<h1 class="abertura__titulo" id="abertura-titulo">' .. comum.esc(comum.texto(m.abertura.frase)) .. '</h1>',
    '<p class="abertura__subtitulo">' .. comum.esc(comum.texto(m.abertura.subtitulo)) .. '</p>',
    '<div class="acoes">',
    botao,
    '<a class="botao botao--secundario" href="#como-funcionamos">Ver como funcionamos</a>',
    '</div>',
    '</div>',
    '<figure class="abertura__mapa">',
    mapa,
    '</figure>',
    '</div>',
    '</section>',
  }, "\n")

  doc.blocks = comum.ocultar(doc.blocks, ocultos)
  doc.blocks:insert(1, comum.html(abertura))
  return doc
end
```

- [ ] **Passo 7: Acrescentar ao SCSS as seções Início e etapas**

```scss
// ---- Componente: Início (I2–I6) ---------------------------------------------
.inicio { display: grid; gap: var(--secao); padding-block: var(--secao); }
.inicio__producao { display: grid; gap: var(--esp-8); }
.inicio__lateral { display: grid; gap: var(--esp-7); align-content: start; }
.inicio__evento { border-top: var(--linha-eixo); padding-top: var(--esp-5); }
.inicio__evento p + p, .inicio__evento .acoes { margin-top: var(--esp-3); }
.evento__nome { font-size: var(--fs-h3); font-weight: var(--peso-h3); line-height: 1.3; }
.evento__nome a { text-decoration: none; }
.evento__nome a:hover { text-decoration: underline 1px; }
.evento__quando { margin-top: var(--esp-2); font-size: var(--fs-meta); }
.evento__inscricao { margin-top: var(--esp-3); font-weight: var(--peso-forte); }
.inicio__etapas .acoes, .inicio__redes .acoes { margin-top: var(--esp-6); }
.inicio__redes p { max-width: var(--medida); }
@media (min-width: 992px) {
  .inicio__producao { grid-template-columns: minmax(0, 2fr) minmax(0, 1fr); align-items: start; }
}

// ---- Componente: etapas (I5, S2) --------------------------------------------
// A sequência real "texto → debate → revisão → publicação": pontos ligados por uma linha.
// A etapa Publicação leva o ponto vermelho (um dos três usos previstos do vermelho).
.etapas {
  list-style: none;
  margin: var(--esp-6) 0 0;
  padding: 0;
  max-width: none;
  display: grid;
  gap: var(--esp-5);
}
.etapa { position: relative; padding-left: var(--esp-6); }
.etapa p { margin: 0; max-width: 34ch; }
.etapa::before {
  content: "";
  position: absolute;
  left: 0;
  top: 0.4em;
  width: 0.75rem;
  height: 0.75rem;
  border-radius: var(--raio-ponto);
  background: var(--azul-marinho);
}
.etapa::after {
  content: "";
  position: absolute;
  left: calc(0.375rem - 1px);
  top: 1.3em;
  bottom: calc(-1 * var(--esp-5) - 0.4em);
  width: 2px;
  background: var(--grade);
}
.etapa:last-child::after { display: none; }
.etapa--publicacao::before { background: var(--vermelho); }
.etapa__titulo {
  font: var(--peso-h3) var(--fs-h3)/1.3 var(--fonte-titulo);
  color: var(--azul-marinho);
  margin-bottom: var(--esp-2) !important;
}
@media (min-width: 992px) {
  .etapas { grid-template-columns: repeat(4, minmax(0, 1fr)); gap: var(--esp-6); }
  .etapa { padding: var(--esp-6) 0 0; }
  .etapa::before { top: 0; }
  .etapa::after { left: 0.75rem; right: calc(-1 * var(--esp-6)); top: calc(0.375rem - 1px); bottom: auto; width: auto; height: 2px; }
}
```

Este é o 2º e último `var(--vermelho)` permitido no SCSS (o 1º é `.mapa-destaque`, copiado da prancha).

- [ ] **Passo 8: Rodar os testes**

```bash
bash testes/rodar.sh 0
```

Esperado: `Tudo certo.` O Quarto vai avisar (WARN) que as listings de `publicacoes/n*` e `eventos/*` não encontram arquivos e que `sobre.qmd` não existe. Esses avisos somem nas Tarefas 5, 9 e 11.

- [ ] **Passo 9: Verificação visual**

```bash
bash ferramentas/capturar.sh -l "360 390 1280" inicio=index.html
```

Compare com `wireframes/screenshots/inicio-b-*.png` e `capturas/abertura-*.png`. Confira em especial: navbar e abertura fundidas num só bloco azul; mapa inteiro em 390 e à direita em 1280; "A conjuntura" na primeira linha em 360 px; Porto Alegre em vermelho com borda off-white; I2 em breve sem capa; I4 ao lado no desktop; etapas em coluna (celular) e em linha (desktop), com a linha de grade ligando os pontos.

- [ ] **Passo 10: Commit**

```bash
git add design/gerar-mapa.py assets/img/mapa-pontos.svg publicacoes/em-breve.yml filtros/paginas/inicio.lua modelos-listing index.qmd estilos/macroliga.scss testes/t04-inicio.sh
git commit -m "Monta a Início com a abertura de pontos e o fascículo em breve

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 5: Sobre

**Arquivos:**
- Criar: `sobre.qmd`, `filtros/paginas/sobre.lua`
- Modificar: `_quarto.yml` (menu), `estilos/macroliga.scss` (seção Sobre)
- Testar: `testes/t05-sobre.sh`

**Interfaces:**
- Consome: `.etapas` (Tarefa 4), `comum.slug`, `meta.eixos`.
- Produz: links `publicacoes/index.html?eixo=<slug>`, que os filtros da Tarefa 13 leem.

- [ ] **Passo 1: Escrever o teste (falha primeiro)**

`testes/t05-sobre.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 5: Sobre.
source "$(dirname "$0")/lib.sh"
existe sobre.html "página Sobre"
tem sobre.html '<h1[^>]*>Sobre a liga</h1>' "S1 título"
tem sobre.html 'integração entre a teoria e prática científica' "S1 missão"
tem sobre.html 'macroliga-selo-cor\.svg' "selo"
tem sobre.html 'id="como-funcionamos"' "S2 âncora"
conta sobre.html 'class="etapa( |")' 4 "S2 quatro etapas"
tem sobre.html 'Cada fascículo é lançado em um evento presencial na FCE' "S2 texto longo"
conta sobre.html 'href="publicacoes/index\.html\?eixo=' 6 "S3 seis eixos com link filtrado"
tem sobre.html 'href="publicacoes/index\.html\?eixo=atividade-economica-mercado-de-trabalho-e-credito"' "slug sem acento nem vírgula"
tem sobre.html 'class="[^"]*pluralidade[^"]*fundo-azul|class="[^"]*fundo-azul[^"]*pluralidade' "S4 em bloco azul"
tem sobre.html 'A coordenação é do prof\. Leonardo Xavier da Silva' "S5 coordenação de _variables.yml"
tem sobre.html 'Ver a equipe' "S5 botão equipe"
tem index.html 'class="nav-link[^"]*" href="\./sobre\.html"' "Sobre no menu"
fim
```

- [ ] **Passo 2: Escrever `sobre.qmd`**

````markdown
---
title: "Sobre"
pagina: sobre
description: "Como a MacroLiga UFRGS funciona: textos de estudantes, debate entre pares, revisão docente e publicação com DOI."
---

:::::: {.conteiner .pagina .sobre}

::::: {.sobre__abertura}
:::: {.sobre__missao}
# Sobre a liga

## Missão

A MacroLiga, um projeto idealizado e criado pelos alunos e alunas de Ciências Econômicas da Universidade Federal do Rio Grande do Sul, tem como objetivo a integração entre a teoria e prática científica e profissional na área da Macroeconomia. Por meio da elaboração e debate coletivo da produção científica, busca-se criar um ambiente propício para o domínio das competências necessárias ao exercício da profissão de economista.
::::
![](assets/marca/svg/macroliga-selo-cor.svg){.sobre__selo .so-desktop fig-alt="Selo da MacroLiga UFRGS" width="240" height="240"}
:::::

::::: {#como-funcionamos .sobre__etapas}
## Como funcionamos

Todo texto passa pelas mesmas quatro etapas.

```{=html}
<ol class="etapas etapas--longas">
<li class="etapa"><p class="etapa__titulo">1. Texto</p><p>Um membro escreve sobre um dos temas associados à macroeconomia. Nossos textos baseiam-se em análise de conjuntura, revisão de literatura, nota de pesquisa ou texto de opinião.</p></li>
<li class="etapa"><p class="etapa__titulo">2. Debate entre pares</p><p>Os membros leem e discutem o texto antes da revisão. A discussão testa os dados, os argumentos e a clareza.</p></li>
<li class="etapa"><p class="etapa__titulo">3. Revisão docente</p><p>Um professor revisa o texto, garantindo a qualidade acadêmica do texto.</p></li>
<li class="etapa etapa--publicacao"><p class="etapa__titulo">4. Publicação</p><p>Os textos aprovados formam um fascículo numerado. Cada texto recebe um DOI no Zenodo. O DOI é um identificador permanente: o link não quebra e o texto pode ser citado em trabalhos acadêmicos. Cada fascículo é lançado em um evento presencial na FCE, com um debatedor para cada texto.</p></li>
</ol>
```
:::::

::::: {.sobre__grade}
:::: {.sobre__eixos}
## Nossos eixos

::: {#lista-eixos}
:::
::::
:::: {.pluralidade .fundo-azul}
## Regra da pluralidade

A liga não toma posição sobre política econômica, governos ou partidos. Nossos membros têm visões teóricas diferentes, e isso faz parte do projeto. Criamos textos baseados em fatos. Eles mostram o que aconteceu, com número, data e fonte. A opinião de cada autor é de sua responsabilidade única e aparece só em seus textos individuais, assinados e identificados.
::::
:::::

::::: {.sobre__extensao}
![](assets/marca/svg/macroliga-selo-cor.svg){.sobre__selo .so-celular fig-alt="Selo da MacroLiga UFRGS" width="144" height="144"}

## Vínculo com a extensão

A MacroLiga UFRGS é um projeto de extensão da Faculdade de Ciências Econômicas (FCE) da UFRGS, na modalidade Produção e Publicação. A coordenação é do {{< var coordenacao >}}.

Extensão universitária é a atividade que leva à comunidade o conhecimento produzido na universidade. Por isso, todos os textos do site são abertos e gratuitos. Ao fim de cada texto e de cada fascículo, há um questionário curto. As respostas ajudam a avaliar o projeto.

::: {.acoes}
[Ver a equipe](equipe.qmd){.botao .botao--secundario}
[Ver as publicações](publicacoes/index.qmd){.botao .botao--secundario}
:::
:::::

::::::
````

- [ ] **Passo 3: Escrever `filtros/paginas/sobre.lua`**

```lua
-- filtros/paginas/sobre.lua: Sobre (spec 2.10). S3 lista os eixos de _variables.yml,
-- cada um com link para Publicações já filtrada por ele.
return function(doc, comum)
  local itens = {}
  for _, e in ipairs(doc.meta.eixos or {}) do
    local nome = comum.texto(e)
    table.insert(itens, string.format('<li><a href="publicacoes/index.html?eixo=%s">%s</a></li>', comum.slug(nome), comum.esc(nome)))
  end
  local lista = comum.html('<ul class="lista-eixos">\n' .. table.concat(itens, "\n") .. '\n</ul>')
  doc.blocks = doc.blocks:walk({
    Div = function(d)
      if d.identifier == "lista-eixos" then d.content = { lista } return d end
    end,
  })
  return doc
end
```

- [ ] **Passo 4: Acrescentar ao SCSS a seção Sobre e pôr a Sobre no menu**

```scss
// ---- Componente: Sobre (S1–S5) ----------------------------------------------
.sobre__abertura { display: grid; gap: var(--esp-6); }
.sobre__selo { width: 9rem; height: auto; }
.sobre__grade { display: grid; gap: var(--esp-7); margin-top: var(--secao); }
.sobre__grade h2 { margin-top: 0; }
.lista-eixos { list-style: none; padding: 0; margin: 0; border-bottom: var(--linha-eixo); max-width: none !important; }
.lista-eixos li { border-top: var(--linha-grade); }
.lista-eixos a {
  display: flex;
  align-items: center;
  min-height: var(--alvo-min);
  padding-block: var(--esp-2);
  font: var(--peso-h3) var(--fs-h3)/1.3 var(--fonte-titulo);
  text-decoration: none;
}
.lista-eixos a:hover { text-decoration: underline 1px; text-underline-offset: 0.18em; }
.pluralidade { padding: var(--esp-6) var(--esp-5); }
.pluralidade p { max-width: 60ch; margin: 0; }
.sobre__extensao { margin-top: var(--secao); }
.sobre__extensao .sobre__selo { margin-bottom: var(--esp-5); }
@media (min-width: 992px) {
  .sobre__abertura { grid-template-columns: minmax(0, 1fr) 15rem; align-items: start; gap: var(--esp-8); }
  .sobre__selo.so-desktop { width: 15rem; margin-top: var(--esp-7); }
  .sobre__grade { grid-template-columns: 1fr 1fr; gap: var(--esp-8); align-items: start; }
  .pluralidade { padding: var(--esp-7) var(--esp-6); }
}
```

Em `_quarto.yml`, no menu (`navbar: right:`), depois de Início, acrescente:

```yaml
      - text: "Sobre"
        href: sobre.qmd
```

- [ ] **Passo 5: Rodar os testes, verificar a tela e fazer o commit**

```bash
bash testes/rodar.sh 0
bash ferramentas/capturar.sh sobre=sobre.html
```

Compare com `wireframes/screenshots/sobre-*.png`. Confira: selo ao lado de S1 no desktop e acima de S5 no celular; S3 e S4 lado a lado no desktop; S4 em azul com texto off-white; etapas numeradas.

```bash
git add sobre.qmd filtros/paginas/sobre.lua _quarto.yml estilos/macroliga.scss testes/t05-sobre.sh
git commit -m "Adiciona a página Sobre

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 6: Equipe

**Arquivos:**
- Criar: `equipe.qmd`, `equipe.yml`, `filtros/paginas/equipe.lua`
- Modificar: `_quarto.yml` (menu), `estilos/macroliga.scss` (seção Equipe)
- Testar: `testes/t06-equipe.sh`, `testes/e06-equipe.sh`

**Interfaces:**
- Consome: `comum.ler_yaml`, `comum.slug`, `meta.eixos`.
- Produz: o formato de `equipe.yml` (spec 3.3.6).

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t06-equipe.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 6: Equipe.
source "$(dirname "$0")/lib.sh"
existe equipe.html "página Equipe"
tem equipe.html '<h1[^>]*>Equipe</h1>' "EQ1 título"
tem equipe.html 'Cerca de 15 estudantes de graduação da UFRGS' "EQ1 frase"
for d in "Presidência \(Research\)" "Vice-Presidência e Tesouraria" "Comunicação \(Marketing e Design\)" "Outreach"; do
  tem equipe.html "<h3>$d</h3>" "EQ2 diretoria $d"
done
conta equipe.html 'class="equipe-grupo equipe-eixo"' 6 "EQ3 seis eixos"
conta equipe.html 'href="publicacoes/index\.html\?eixo=' 6 "EQ3 links filtrados"
nao_tem equipe.html 'class="membro__foto"' "sem fotos enquanto o campo foto está vazio"
tem equipe.html 'Ver como participar' "EQ4 botão"
nao_tem equipe.html 'Leonardo Xavier' "coordenação não aparece na Equipe (só G2 e S5)"
fim
```

`testes/e06-equipe.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 6: estados da Equipe (foto preenchida; eixo com nome errado).
source "$(dirname "$0")/lib.sh"
criar assets/equipe/teste.png < assets/marca/png/macroliga-favicon-512.png
trocar equipe.yml '0,/foto: ""/s||foto: "assets/equipe/teste.png"|'
renderizar equipe.qmd
tem equipe.html '<img class="membro__foto" src="assets/equipe/teste\.png" alt="Foto de [^"]+"' "foto aparece acima do nome"
desfazer
trocar equipe.yml 's|- nome: "Mercados externos"|- nome: "Mercados Externos"|'
deve_falhar 'o eixo "Mercados Externos" não existe' "eixo da equipe fora de _variables.yml para o render" equipe.qmd
fim
```

- [ ] **Passo 2: Escrever `equipe.yml` e `equipe.qmd`**

`equipe.yml`:

```yaml
# Membros da liga. Atualize a cada gestão (veja o LEIA-ME).
# foto: deixe vazio até haver termo de uso de imagem (decisão 5 do CLAUDE.md).
#       Depois, ponha a foto quadrada em assets/equipe/ e escreva o caminho, ex.: "assets/equipe/nome.jpg".
# Os nomes dos eixos precisam ser iguais aos de _variables.yml.
diretorias:
  - nome: "Presidência (Research)"
    membros:
      - { nome: "[a preencher]", cargo: "Presidente", foto: "" }
  - nome: "Vice-Presidência e Tesouraria"
    membros:
      - { nome: "[a preencher]", cargo: "Vice-presidente", foto: "" }
  - nome: "Comunicação (Marketing e Design)"
    membros:
      - { nome: "[a preencher]", cargo: "Comunicação", foto: "" }
      - { nome: "[a preencher]", cargo: "Comunicação", foto: "" }
  - nome: "Outreach"
    membros:
      - { nome: "[a preencher]", cargo: "Outreach", foto: "" }
eixos:
  - nome: "Política monetária e inflação"
    membros: ["[a preencher]"]
  - nome: "Setor externo e câmbio"
    membros: ["[a preencher]"]
  - nome: "Atividade econômica, mercado de trabalho e crédito"
    membros: ["[a preencher]"]
  - nome: "Política fiscal e contas públicas"
    membros: ["[a preencher]"]
  - nome: "Mercados externos"
    membros: ["[a preencher]"]
  - nome: "Conjuntura política"
    membros: ["[a preencher]"]
```

`equipe.qmd`:

```markdown
---
title: "Equipe"
pagina: equipe
description: "Quem faz a MacroLiga UFRGS: diretorias e eixos temáticos."
---

:::: {.conteiner .pagina .equipe}
# Equipe

::: {.pagina__intro}
Cerca de 15 estudantes de graduação da UFRGS, organizados em diretorias e em seis eixos temáticos.
:::

::: {#equipe-membros}
:::

::: {.equipe__chamada}
A liga reúne estudantes de graduação da UFRGS pertencentes a qualquer curso.

[Ver como participar](participe.qmd){.botao}
:::
::::
```

- [ ] **Passo 3: Escrever `filtros/paginas/equipe.lua`**

```lua
-- filtros/paginas/equipe.lua: Equipe (spec 2.11), lida de equipe.yml.
return function(doc, comum)
  local dados = comum.ler_yaml(comum.caminho(comum.raiz(), "equipe.yml")) or {}
  local eixos_validos = {}
  for _, e in ipairs(doc.meta.eixos or {}) do eixos_validos[comum.texto(e)] = true end

  local h = { '<section aria-labelledby="t-diretorias">', '<h2 id="t-diretorias">Diretorias</h2>',
    '<div class="equipe-grade equipe-diretorias">' }
  for _, d in ipairs(dados.diretorias or {}) do
    table.insert(h, '<div class="equipe-grupo"><h3>' .. comum.esc(comum.texto(d.nome)) .. '</h3><ul class="membros">')
    for _, p in ipairs(d.membros or {}) do
      local nome, foto = comum.texto(p.nome), comum.texto(p.foto)
      local img = ""
      if foto ~= "" then
        img = '<img class="membro__foto" src="' .. comum.esc(foto) .. '" alt="Foto de ' .. comum.esc(nome) .. '" width="96" height="96">'
      end
      table.insert(h, '<li class="membro">' .. img .. '<span class="membro__nome">' .. comum.esc(nome)
        .. '</span><span class="membro__cargo">' .. comum.esc(comum.texto(p.cargo)) .. '</span></li>')
    end
    table.insert(h, '</ul></div>')
  end
  table.insert(h, '</div></section>')

  table.insert(h, '<section aria-labelledby="t-eixos"><h2 id="t-eixos">Eixos temáticos</h2>')
  table.insert(h, '<div class="equipe-grade equipe-eixos">')
  for _, e in ipairs(dados.eixos or {}) do
    local nome = comum.texto(e.nome)
    if not eixos_validos[nome] then
      comum.parar('equipe.yml: o eixo "' .. nome .. '" não existe. Use os nomes de _variables.yml.')
    end
    local membros = {}
    for _, p in ipairs(e.membros or {}) do table.insert(membros, comum.esc(comum.texto(p))) end
    table.insert(h, string.format('<div class="equipe-grupo equipe-eixo"><h3><a href="publicacoes/index.html?eixo=%s">%s</a></h3><p>%s</p></div>',
      comum.slug(nome), comum.esc(nome), table.concat(membros, ", ")))
  end
  table.insert(h, '</div></section>')

  local bloco = comum.html(table.concat(h, "\n"))
  doc.blocks = doc.blocks:walk({
    Div = function(d) if d.identifier == "equipe-membros" then d.content = { bloco } return d end end,
  })
  return doc
end
```

- [ ] **Passo 4: Acrescentar ao SCSS a seção Equipe e pôr a Equipe no menu**

```scss
// ---- Componente: Equipe (EQ1–EQ4) -------------------------------------------
.equipe-grade { display: grid; gap: var(--esp-6); }
.equipe-grupo { border-top: var(--linha-grade); padding-top: var(--esp-4); }
.equipe-grupo h3 { margin: 0 0 var(--esp-3); }
.equipe-grupo h3 a { text-decoration: none; }
.equipe-grupo h3 a:hover { text-decoration: underline 1px; }
.equipe-grupo p { margin: 0; }
.membros { list-style: none; padding: 0; margin: 0 !important; }
.membro + .membro { margin-top: var(--esp-3); }
.membro__foto { width: 6rem; height: 6rem; object-fit: cover; margin-bottom: var(--esp-2); }
.membro__nome { display: block; font-weight: var(--peso-forte); }
.membro__cargo { display: block; font-size: var(--fs-meta); }
.equipe__chamada { margin-top: var(--secao); }
.equipe__chamada .botao { margin-top: var(--esp-3); }
@media (min-width: 768px) { .equipe-grade { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (min-width: 992px) {
  .equipe-diretorias { grid-template-columns: repeat(4, minmax(0, 1fr)); }
  .equipe-eixos { grid-template-columns: repeat(3, minmax(0, 1fr)); }
}
```

No menu do `_quarto.yml`, depois de Sobre, acrescente:

```yaml
      - text: "Equipe"
        href: equipe.qmd
```

- [ ] **Passo 5: Rodar os testes, verificar a tela e fazer o commit**

```bash
bash testes/rodar.sh 06
bash ferramentas/capturar.sh equipe=equipe.html
```

Compare com `wireframes/screenshots/equipe-*.png`. Confira que não há cards com caixa e sombra: só colunas separadas por linhas de grade.

```bash
git add equipe.qmd equipe.yml filtros/paginas/equipe.lua _quarto.yml estilos/macroliga.scss testes/t06-equipe.sh testes/e06-equipe.sh
git commit -m "Adiciona a página Equipe, lida de equipe.yml

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 7: Participe

**Arquivos:**
- Criar: `participe.qmd`, `filtros/paginas/participe.lua`, `modelos/modelo-macroliga.docx`, `modelos/modelo-macroliga.zip`
- Modificar: `_quarto.yml` (menu e `resources`), `estilos/macroliga.scss` (seção Participe)
- Testar: `testes/t07-participe.sh`, `testes/e07-participe.sh`

**Interfaces:**
- Consome: `comum.link_instagram`, `comum.parar`, `meta.selecao`.

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t07-participe.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 7: Participe com a seleção fechada.
source "$(dirname "$0")/lib.sh"
existe participe.html "página Participe"
tem participe.html '<h1[^>]*>Participe</h1>' "PA1 título"
tem participe.html 'pertencentes a qualquer curso' "PA1 texto"
tem participe.html 'Não há processo seletivo aberto agora\.' "PA2 seleção fechada"
nao_tem participe.html 'Fazer inscrição no processo seletivo' "sem botão de inscrição com a seleção fechada"
tem participe.html 'O que se espera do membro' "PA3"
tem participe.html 'href="modelos/modelo-macroliga\.docx"[^>]*>Baixar modelo em Word' "PA4 Word"
tem participe.html 'href="modelos/modelo-macroliga\.zip"[^>]*>Baixar modelo em LaTeX' "PA4 LaTeX"
existe modelos/modelo-macroliga.docx "modelo Word copiado para o site"
existe modelos/modelo-macroliga.zip "modelo LaTeX copiado para o site"
tem participe.html 'Escrever para a liga' "PA5"
fim
```

`testes/e07-participe.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 7: seleção aberta e seleção aberta sem formulário.
source "$(dirname "$0")/lib.sh"
trocar participe.qmd 's|aberta: false|aberta: true|' 's|prazo: ""|prazo: "30 de outubro de 2026"|' \
  's|formulario: ""|formulario: "https://forms.gle/teste"|'
renderizar participe.qmd
tem participe.html 'Inscrições abertas até 30 de outubro de 2026\.' "PA2 seleção aberta"
tem participe.html 'id="pa-inscricao-topo"[^>]*>' "bloco de inscrição no topo"
tem participe.html 'href="https://forms\.gle/teste">Fazer inscrição no processo seletivo' "botão com o formulário"
nao_tem participe.html 'Não há processo seletivo aberto agora' "sem o aviso de fechada"
desfazer
trocar participe.qmd 's|aberta: false|aberta: true|'
deve_falhar 'falta o link do formulário' "seleção aberta sem formulário para o render" participe.qmd
fim
```

- [ ] **Passo 2: Copiar os modelos para autores**

```bash
mkdir -p modelos
cp "../Materiais/Publicacao/Word/Modelo_Texto_MacroLiga.docx" modelos/modelo-macroliga.docx
cp "../Materiais/Publicacao/MacroLiga_LaTeX_Overleaf.zip" modelos/modelo-macroliga.zip
```

Em `_quarto.yml`, no bloco `project:`, acrescente:

```yaml
  resources:
    - modelos/
```

- [ ] **Passo 3: Escrever `participe.qmd`**

```markdown
---
title: "Participe"
pagina: participe
description: "Como entrar na MacroLiga UFRGS: quem pode participar, como funciona a seleção e modelos para autores."
selecao:
  aberta: false
  prazo: ""          # ex.: "30 de outubro de 2026"
  formulario: ""     # link do formulário do Google Forms
---

::::: {.conteiner .pagina .participe}

:::: {#pa1}
# Participe

## Quem pode entrar

A liga reúne estudantes de graduação da UFRGS pertencentes a qualquer curso. Todos aqueles que desejam aprender sobre Macroeconomia são livres para participar, mas conhecimento prévio de macroeconomia ajuda a acompanhar as discussões. Não é preciso já saber escrever um texto acadêmico. Os textos passam por debate entre pares e por revisão docente justamente para que todos aprendam no processo.
::::

::: {#pa-inscricao-topo}
:::

:::: {.participe__grade}
::: {#pa2}
## Como funciona a seleção

As vagas abrem por processo seletivo periódico. A inscrição é feita por formulário on-line. Divulgamos as datas aqui e no Instagram.

::: {#selecao-situacao}
:::
:::

::: {#pa3}
## O que se espera do membro

- Escrever textos para os fascículos, dentro de um dos eixos ligados à Macroeconomia.
- Ler e debater os textos dos colegas antes da revisão docente.
- Participar das reuniões da liga.
- Atuar nas atividades que garantam a manutenção e expansão institucional da liga.
- Membros recebem certificados de horas de extensão por sua participação nas atividades da liga.
:::
::::

:::: {#pa4}
## Modelos para autores

Use os modelos para escrever no formato dos fascículos: com título, autor, eixo e tipo de texto.

::: {.acoes}
[Baixar modelo em Word]({{< var modelos.word >}}){.botao .botao--secundario}
[Baixar modelo em LaTeX]({{< var modelos.latex >}}){.botao .botao--secundario}
:::
::::

:::: {#pa5}
## Dúvidas?

E-mail: [{{< var contato.email >}}](mailto:{{< var contato.email >}})

::: {.acoes}
[Escrever para a liga](mailto:{{< var contato.email >}}){.botao}
[Seguir no Instagram]({{< var contato.instagram-url >}}){.botao .botao--secundario}
:::
::::

:::::
```

- [ ] **Passo 4: Escrever `filtros/paginas/participe.lua`**

```lua
-- filtros/paginas/participe.lua: Participe (spec 2.12). A situação da seleção vem de
-- "selecao" no cabeçalho do participe.qmd.
return function(doc, comum)
  local s = doc.meta.selecao or {}
  local aberta = s.aberta == true
  local prazo, formulario = comum.texto(s.prazo), comum.texto(s.formulario)
  local situacao, topo
  if aberta then
    if formulario == "" then comum.parar('participe.qmd: a seleção está aberta, mas falta o link do formulário (selecao.formulario).') end
    if prazo == "" then comum.parar('participe.qmd: a seleção está aberta, mas falta o prazo (selecao.prazo).') end
    situacao = '<p class="selecao__aberta">Inscrições abertas até ' .. comum.esc(prazo) .. '.</p>'
    topo = '<p class="acoes"><a class="botao" href="' .. comum.esc(formulario) .. '">Fazer inscrição no processo seletivo</a></p>'
  else
    situacao = '<p class="estado-vazio selecao__fechada">Não há processo seletivo aberto agora. Siga '
      .. comum.link_instagram(doc.meta) .. ' para saber do próximo.</p>'
  end
  doc.blocks = doc.blocks:walk({
    Div = function(d)
      if d.identifier == "selecao-situacao" then d.content = { comum.html(situacao) } return d end
      if d.identifier == "pa-inscricao-topo" then
        if topo then d.content = { comum.html(topo) } else d.attributes.hidden = "" end
        return d
      end
    end,
  })
  return doc
end
```

- [ ] **Passo 5: Acrescentar ao SCSS a seção Participe e pôr a Participe no menu**

```scss
// ---- Componente: Participe (PA1–PA5) ----------------------------------------
.participe__grade { display: grid; gap: 0 var(--esp-8); }
.selecao__fechada, .selecao__aberta { padding: var(--esp-4); border: var(--linha-grade); }
.selecao__aberta { font-weight: var(--peso-forte); }
#pa-inscricao-topo .acoes { margin-top: var(--esp-5); }
.participe .acoes { margin-top: var(--esp-4); }
@media (min-width: 992px) { .participe__grade { grid-template-columns: 1fr 1fr; } }
```

No menu, depois de Equipe:

```yaml
      - text: "Participe"
        href: participe.qmd
```

- [ ] **Passo 6: Rodar os testes, verificar a tela e fazer o commit**

```bash
bash testes/rodar.sh 07
bash ferramentas/capturar.sh participe=participe.html
```

Compare com `wireframes/screenshots/participe-*.png`.

```bash
git add participe.qmd filtros/paginas/participe.lua modelos _quarto.yml estilos/macroliga.scss testes/t07-participe.sh testes/e07-participe.sh
git commit -m "Adiciona a página Participe com a situação da seleção

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 8: Publicações no estado "em breve"

**Arquivos:**
- Criar: `publicacoes/index.qmd`, `filtros/paginas/publicacoes.lua`
- Criar: `modelos-listing/em-breve-publicacoes.ejs`, `modelos-listing/fasciculos.ejs`, `modelos-listing/textos.ejs` (sem os controles de filtro, que entram na Tarefa 13)
- Modificar: `_quarto.yml` (menu)
- Testar: `testes/t08-publicacoes.sh`, `testes/e08-publicacoes.sh`

**Interfaces:**
- Consome: `publicacoes/em-breve.yml` (Tarefa 4), `comum.fasciculos`, `comum.em_breve`, `comum.ocultar`.
- Produz os ids `lista-em-breve`, `lista-fasciculos` e `lista-textos`, e a lista `<ul class="lista-textos lista-textos--filtravel">` com `data-eixo` e `data-tipo` em cada `<li class="item-texto">`, que a Tarefa 13 filtra.

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t08-publicacoes.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 8: Publicações em 18/10 (P1 + P2 em breve; P3 e P4 ocultos).
source "$(dirname "$0")/lib.sh"
existe publicacoes/index.html "página Publicações"
tem publicacoes/index.html '<h1[^>]*>Publicações</h1>' "P1 título"
tem publicacoes/index.html 'Todos têm DOI e podem ser citados\.' "P1 frase"
tem publicacoes/index.html "Fascículo ${NO}1: em breve" "P2 em breve"
tem publicacoes/index.html "O fascículo ${NO}1 está em revisão\. O lançamento será realizado em data a ser definida\." "P2 aviso"
tem publicacoes/index.html 'Impactos setoriais do acordo Mercosul e União Europeia' "P2 lista de títulos"
nao_tem publicacoes/index.html 'class="lista-textos' "P4 oculto sem texto publicado"
nao_tem publicacoes/index.html 'Filtrar por eixo' "P3 oculto sem texto publicado"
tem index.html 'class="nav-link[^"]*" href="\./publicacoes/index\.html"' "Publicações no menu"
fim
```

`testes/e08-publicacoes.sh` (Foco de revisão 4):

```bash
#!/usr/bin/env bash
# Tarefa 8: nenhum fascículo publicado e em-breve.yml vazio.
source "$(dirname "$0")/lib.sh"
cp publicacoes/em-breve.yml publicacoes/em-breve.yml.bak-teste && ALTERADOS+=("publicacoes/em-breve.yml")
printf '[]\n' > publicacoes/em-breve.yml
renderizar index.qmd publicacoes/index.qmd
tem index.html '<a class="botao" href="(\./)?publicacoes/index\.html">Ver as publicações</a>' "I1 vira Ver as publicações"
tem index.html 'id="fasciculo"[^>]*hidden' "I2 inteiro oculto"
nao_tem publicacoes/index.html 'em breve' "P2 sem em breve"
fim
```

- [ ] **Passo 2: Escrever os templates**

`modelos-listing/em-breve-publicacoes.ejs`:

````text
```{=html}
<% for (const item of items) { const n = item.numero; %>
<article class="fasciculo fasciculo--em-breve">
<div>
<h3 class="fasciculo__titulo">Fascículo nº&nbsp;<%= n %>: em breve</h3>
<p class="fasciculo__frase">O fascículo nº&nbsp;<%= n %> está em revisão. O lançamento será realizado em data a ser definida.</p>
</div>
<div class="fasciculo__corpo">
<ul class="sumario">
<% for (const t of (item.textos || [])) { %><li><span class="sumario__titulo"><%= t.titulo %></span><span class="sumario__autor"><%= t.autor %></span></li>
<% } %></ul>
</div>
</article>
<% } %>
```
````

`modelos-listing/fasciculos.ejs`:

````text
```{=html}
<%
const fasciculos = items.filter(i => i.numero !== undefined && i.ordem === undefined)
  .sort((a, b) => Number(b.numero) - Number(a.numero));
const textos = items.filter(i => i.ordem !== undefined);
%>
<% for (const f of fasciculos) {
  const n = Number(f.numero);
  const qtd = textos.filter(x => Number(x.fasciculo) === n).length; %>
<article class="fasciculo fasciculo--lista">
<% if (f.image) { %><img class="fasciculo__capa" src="<%- f.image %>" alt="Capa do fascículo nº&nbsp;<%= n %>" loading="lazy"><% } %>
<div>
<h3 class="fasciculo__titulo"><a href="<%- f.path %>"><%= f.publicacao.nome %> nº&nbsp;<%= n %></a></h3>
<p class="fasciculo__frase"><%= f.date %>. <%= qtd %> <%= qtd === 1 ? "texto" : "textos" %>.</p>
<p class="acoes"><a class="botao" href="<%- f.path %>">Ler o fascículo</a></p>
</div>
</article>
<% } %>
```
````

`modelos-listing/textos.ejs` (P4; a Tarefa 13 acrescenta P3):

````text
```{=html}
<%
const slug = s => String(s || "").normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()
  .replace(/[^a-z0-9\s-]/g, "").trim().replace(/\s+/g, "-").replace(/-+/g, "-");
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const autor = i => [].concat(i.author || []).map(a => (a && a.name) ? (a.name.literal || a.name) : a).join(", ");
if (items.length > 0) {
%>
<h2>Textos</h2>
<ul class="lista-textos lista-textos--filtravel">
<% for (const item of items) { %>
<li class="item-texto" data-eixo="<%= slug(item.eixo) %>" data-tipo="<%= slug(item.tipo) %>">
<div>
<p class="item-texto__tipo"><%= item.tipo %></p>
<h3 class="item-texto__titulo"><a href="<%- item.path %>"><%= t(item.title) %></a></h3>
<p class="item-texto__autor"><%= autor(item) %></p>
</div>
<dl class="item-texto__dados"><dt>Eixo</dt><dd><%= item.eixo %></dd><dt>Fascículo</dt><dd>nº&nbsp;<%= item.fasciculo %></dd></dl>
</li>
<% } %>
</ul>
<% } %>
```
````

- [ ] **Passo 3: Escrever `publicacoes/index.qmd`**

```markdown
---
title: "Publicações"
pagina: publicacoes
description: "Textos curtos de estudantes de graduação, revisados por professores da FCE e reunidos em fascículos numerados."
listing:
  - id: lista-em-breve
    contents: em-breve.yml
    template: ../modelos-listing/em-breve-publicacoes.ejs
  - id: lista-fasciculos
    contents:
      - "n*/index.qmd"
      - "n*/*/index.qmd"
    template: ../modelos-listing/fasciculos.ejs
    date-format: "D [de] MMMM [de] YYYY"
  - id: lista-textos
    contents: "n*/*/index.qmd"
    template: ../modelos-listing/textos.ejs
    sort: ["fasciculo desc", "ordem"]
---

:::: {.conteiner .pagina .publicacoes}
# Publicações

::: {.pagina__intro}
Textos curtos de estudantes de graduação, revisados por professores da FCE e reunidos em fascículos numerados. Todos têm DOI e podem ser citados.
:::

## Fascículos

::: {#lista-em-breve}
:::

::: {#lista-fasciculos}
:::

::: {#lista-textos}
:::
::::
```

- [ ] **Passo 4: Escrever `filtros/paginas/publicacoes.lua` e pôr Publicações no menu**

```lua
-- filtros/paginas/publicacoes.lua: Publicações (spec 2.3). Oculta o "em breve" quando o
-- fascículo anunciado já está visível (publicado, ou rascunho no perfil rascunhos) e
-- anexa o script dos filtros.
return function(doc, comum)
  local visiveis = {}
  for _, f in ipairs(comum.fasciculos(true)) do visiveis[f.numero] = true end
  local eb = comum.em_breve()[1]
  if eb and visiveis[tonumber(comum.texto(eb.numero))] then
    doc.blocks = comum.ocultar(doc.blocks, { ["lista-em-breve"] = true })
  end
  comum.script("filtros")
  return doc
end
```

Na Tarefa 13, `assets/js/filtros.js` ganha o código. Por ora, crie o arquivo com só o comentário de cabeçalho, para a dependência existir:

```js
// Filtros de Publicações (spec 3.5). O código entra na Tarefa 13.
```

Faça o mesmo ajuste em `filtros/paginas/inicio.lua`: troque o bloco `if ultimo then ... end` da escolha do botão para considerar o em breve já publicado:

```lua
  local eb_visivel = false
  if em_breve then
    for _, f in ipairs(visiveis) do
      if f.numero == tonumber(comum.texto(em_breve.numero)) then eb_visivel = true end
    end
  end
  if eb_visivel then em_breve = nil end
```

Insira esse trecho logo depois da linha `local ocultos = {}`. O efeito: no perfil rascunhos, com o nº 1 visível, o "em breve" do nº 1 some da Início.

No menu, depois de Início:

```yaml
      - text: "Publicações"
        href: publicacoes/index.qmd
```

- [ ] **Passo 5: Rodar os testes, verificar a tela e fazer o commit**

```bash
bash testes/rodar.sh 0
bash ferramentas/capturar.sh publicacoes=publicacoes/index.html
```

Compare com `wireframes/screenshots/publicacoes-*.png` (estado "Antes do nº 1").

```bash
git add publicacoes/index.qmd filtros/paginas/publicacoes.lua filtros/paginas/inicio.lua modelos-listing assets/js/filtros.js _quarto.yml testes/t08-publicacoes.sh testes/e08-publicacoes.sh
git commit -m "Adiciona Publicações no estado em breve

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 9: Eventos e o evento de lançamento

**Arquivos:**
- Criar: `eventos/index.qmd`, `eventos/_metadata.yml`, `eventos/_modelo/index.qmd`, `eventos/2026-11-27-lancamento-n01/index.qmd`
- Criar: `filtros/paginas/eventos.lua`, `filtros/paginas/evento.lua`, `modelos-listing/eventos-proximos.ejs`, `modelos-listing/eventos-passados.ejs`
- Modificar: `_quarto.yml` (menu), `estilos/macroliga.scss` (seção Eventos)
- Testar: `testes/t09-eventos.sh`, `testes/e09-eventos.sh`

**Interfaces:**
- Consome: `comum.acao_inscricao`, `comum.data_extenso`, `comum.textos_do_fasciculo`, `comum.em_breve`, `comum.tem_evento`; `validar.lua` (regras de evento).
- Produz: `data-exibida` (meta, para o Open Graph) e o formato de evento (spec 3.3.4).

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t09-eventos.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 9: Eventos e o lançamento (estado de 18/10).
source "$(dirname "$0")/lib.sh"
P=eventos/2026-11-27-lancamento-n01/index.html
existe eventos/index.html "página Eventos"
tem eventos/index.html 'Lançamentos de fascículos, debates e outros encontros promovidos pela liga\.' "EV1"
tem eventos/index.html "Lançamento do fascículo ${NO}1" "EV2 lançamento"
tem eventos/index.html 'Semana de 23/11/2026, data a confirmar' "EV2 usa quando"
tem eventos/index.html 'Inscrições em breve\.' "EV2 inscrição vazia"
tem eventos/index.html 'id="ev2-vazio"[^>]*hidden' "EV2 estado vazio oculto"
tem eventos/index.html "Ainda não realizamos eventos\. O primeiro será o lançamento do fascículo ${NO}1\." "EV3 estado vazio"
nao_existe eventos/_modelo/index.html "pasta-modelo não vira página"
nao_tem eventos/index.html '_modelo' "pasta-modelo fora da listing"
existe "$P" "página do lançamento"
tem "$P" 'href="\.\./index\.html">Voltar aos eventos' "EVP1"
tem "$P" "<h1 class=\"titulo-longo\">Lançamento do fascículo ${NO}1</h1>" "EVP2 nome"
tem "$P" 'FCE/UFRGS, sala a definir' "EVP2 local do campo"
tem "$P" 'Impactos setoriais do acordo Mercosul e União Europeia' "EVP2 textos do fascículo (do em-breve)"
tem "$P" 'Inscrições em breve\.' "EVP3"
tem "$P" '<meta property="og:description" content="Semana de 23/11/2026, data a confirmar, FCE/UFRGS, sala a definir">' "Open Graph: data e local"
tem index.html "Lançamento do fascículo ${NO}1" "I4 mostra o lançamento"
tem index.html 'id="i4-vazio"[^>]*hidden' "I4 estado vazio oculto"
tem index.html 'class="nav-link[^"]*" href="\./eventos/index\.html"' "Eventos no menu"
fim
```

`testes/e09-eventos.sh` (inclui o Foco de revisão 5):

```bash
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
```

- [ ] **Passo 2: Escrever o `_metadata.yml`, o modelo e o evento de lançamento**

`eventos/_metadata.yml`:

```yaml
# Maquinaria dos eventos (não mexa). Vale para todas as pastas de evento.
pagina: evento
data-exibida: ""    # calculado pelo filtro (quando ou date), usado no Open Graph
open-graph:
  description: "{{< meta data-exibida >}}, {{< meta local >}}"
```

`eventos/_modelo/index.qmd`:

```markdown
---
# Para criar um evento: copie esta pasta para eventos/aaaa-mm-dd-slug/ e preencha.
title: "Nome do evento"
date: 2026-12-10                 # data do evento (ordena a lista)
quando: ""                       # opcional: substitui a data exibida, ex.: "Semana de 23/11/2026, data a confirmar"
horario: ""                      # ex.: "19h"
local: ""                        # texto livre, ex.: "FCE/UFRGS, sala 101" ou "On-line, link enviado após a inscrição"
situacao: "proximo"              # proximo | realizado (troque à mão depois do evento)
inscricao: ""                    # link do formulário | vazio (= "Inscrições em breve.") | livre
fasciculo:                       # só em lançamento: o número do fascículo, ex.: 2
capa: ""                         # depois do evento: arquivo da foto de capa nesta pasta, ex.: "capa.jpg"
capa-alt: ""                     # descrição da foto (obrigatória se houver capa)
fotos: ""                        # link do álbum externo da liga
---

Descrição do evento em um ou dois parágrafos: o que acontece, para quem é e quem participa.
```

`eventos/2026-11-27-lancamento-n01/index.qmd`:

```markdown
---
title: "Lançamento do fascículo nº 1"
date: 2026-11-27
quando: "Semana de 23/11/2026, data a confirmar"
horario: ""
local: "FCE/UFRGS, sala a definir"
situacao: "proximo"
inscricao: ""
fasciculo: 1
capa: ""
capa-alt: ""
fotos: ""
---

Apresentação dos quatro textos do fascículo nº 1, cada um com um debatedor designado. A programação e os nomes dos debatedores serão divulgados aqui e no Instagram.
```

- [ ] **Passo 3: Escrever os templates de EV2 e EV3**

`modelos-listing/eventos-proximos.ejs`:

````text
```{=html}
<%
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const acao = v => !v ? '<p class="evento__inscricao">Inscrições em breve.</p>'
  : (v === "livre" ? '<p class="evento__inscricao">Entrada livre, sem inscrição.</p>'
  : '<p class="acoes"><a class="botao" href="' + v + '">Fazer inscrição</a></p>');
if (items.length > 0) {
%>
<ul class="lista-eventos">
<% for (const e of items) { %>
<li class="item-evento">
<p class="item-evento__data"><%= e.quando || e.date %></p>
<div class="item-evento__corpo">
<h3 class="item-evento__nome"><a href="<%- e.path %>"><%= t(e.title) %></a></h3>
<p class="item-evento__local"><% if (e.horario) { %><%= e.horario %>, <% } %><%= e.local %></p>
<% if (e.description) { %><p class="item-evento__frase"><%= e.description %></p><% } %>
<%- acao(e.inscricao) %>
</div>
</li>
<% } %>
</ul>
<% } %>
```
````

`modelos-listing/eventos-passados.ejs`:

````text
```{=html}
<%
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const pad = n => String(n).padStart(2, "0");
if (items.length > 0) {
%>
<ul class="lista-eventos">
<% for (const e of items) { %>
<li class="item-evento item-evento--passado">
<% if (e.image) { %><img class="item-evento__capa" src="<%- e.image %>" alt="<%= e["capa-alt"] || "" %>" loading="lazy"><% } else { %><p class="item-evento__data"><%= e.date %></p><% } %>
<div class="item-evento__corpo">
<h3 class="item-evento__nome"><a href="<%- e.path %>"><%= t(e.title) %></a></h3>
<p class="item-evento__local"><%= e.date %>, <%= e.local %></p>
<% if (e.fotos || e.fasciculo) { %><p class="acoes">
<% if (e.fotos) { %><a class="botao botao--secundario" href="<%- e.fotos %>">Ver as fotos</a><% } %>
<% if (e.fasciculo) { %><a class="botao botao--secundario" href="/publicacoes/n<%= pad(e.fasciculo) %>/index.qmd">Ler o fascículo</a><% } %>
</p><% } %>
</div>
</li>
<% } %>
</ul>
<% } %>
```
````

- [ ] **Passo 4: Escrever `eventos/index.qmd`**

```markdown
---
title: "Eventos"
pagina: eventos
description: "Lançamentos de fascículos, debates e outros encontros promovidos pela MacroLiga UFRGS."
open-graph:
  description: "Lançamentos de fascículos, debates e outros encontros promovidos pela MacroLiga UFRGS."
listing:
  - id: lista-proximos
    contents: "*/index.qmd"
    template: ../modelos-listing/eventos-proximos.ejs
    include:
      situacao: "proximo"
    sort: "date"
    date-format: "D [de] MMMM [de] YYYY"
  - id: lista-passados
    contents: "*/index.qmd"
    template: ../modelos-listing/eventos-passados.ejs
    include:
      situacao: "realizado"
    sort: "date desc"
    date-format: "D [de] MMMM [de] YYYY"
---

:::: {.conteiner .pagina .eventos}
# Eventos

::: {.pagina__intro}
Lançamentos de fascículos, debates e outros encontros promovidos pela liga.
:::

## Próximos eventos

::: {#lista-proximos}
:::

::: {#ev2-vazio .estado-vazio}
Nenhum evento agendado. Siga [{{< var contato.instagram >}}]({{< var contato.instagram-url >}}) para saber do próximo.
:::

## Eventos passados

::: {#lista-passados}
:::

::: {#ev3-vazio .estado-vazio}
Ainda não realizamos eventos. O primeiro será o lançamento do fascículo nº 1.
:::
::::
```

- [ ] **Passo 5: Escrever os montadores**

`filtros/paginas/eventos.lua`:

```lua
-- filtros/paginas/eventos.lua: lista de eventos (spec 2.8): oculta os estados vazios que não se aplicam.
return function(doc, comum)
  local ocultos = {}
  if comum.tem_evento("proximo") then ocultos["ev2-vazio"] = true end
  if comum.tem_evento("realizado") then ocultos["ev3-vazio"] = true end
  doc.blocks = comum.ocultar(doc.blocks, ocultos)
  return doc
end
```

`filtros/paginas/evento.lua`:

```lua
-- filtros/paginas/evento.lua: página de um evento (spec 2.9). Tudo vem do cabeçalho YAML;
-- a descrição é o corpo do index.qmd. Nenhum texto fixo de local: o local vem do campo.
return function(doc, comum)
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local quando = comum.texto(y.quando)
  local data = quando ~= "" and quando or comum.data_extenso(y.date)
  doc.meta["data-exibida"] = pandoc.Inlines(data)

  local topo = {
    '<p class="trilha"><a href="../index.qmd">Voltar aos eventos</a></p>',
    '<header class="evento__cabecalho">',
    '<h1 class="titulo-longo">' .. comum.esc(comum.texto(y.title)) .. '</h1>',
    '<dl class="dados evento__dados">',
    '<dt>Data</dt><dd>' .. comum.esc(data) .. '</dd>',
  }
  if comum.texto(y.horario) ~= "" then
    table.insert(topo, '<dt>Horário</dt><dd>' .. comum.esc(comum.texto(y.horario)) .. '</dd>')
  end
  table.insert(topo, '<dt>Local</dt><dd>' .. comum.esc(comum.texto(y["local"])) .. '</dd>')
  table.insert(topo, '</dl>')
  table.insert(topo, '</header>')

  local depois = {}
  local n = tonumber(comum.texto(y.fasciculo))
  if n then
    local pasta = string.format("n%02d", n)
    local itens = {}
    for _, t in ipairs(comum.textos_do_fasciculo(pasta, true)) do
      table.insert(itens, { titulo = comum.texto(t.meta.title), autor = comum.texto(t.meta.author) })
    end
    if #itens == 0 then
      for _, eb in ipairs(comum.em_breve()) do
        if tonumber(comum.texto(eb.numero)) == n then
          for _, t in ipairs(eb.textos or {}) do
            table.insert(itens, { titulo = comum.texto(t.titulo), autor = comum.texto(t.autor) })
          end
        end
      end
    end
    if #itens > 0 then
      table.insert(depois, '<section class="evento__textos" aria-labelledby="t-textos-evento">')
      table.insert(depois, '<h2 id="t-textos-evento">Textos do fascículo nº&nbsp;' .. n .. '</h2>')
      table.insert(depois, '<ul class="sumario">')
      for _, it in ipairs(itens) do
        table.insert(depois, '<li><span class="sumario__titulo">' .. comum.esc(it.titulo)
          .. '</span><span class="sumario__autor">' .. comum.esc(it.autor) .. '</span></li>')
      end
      table.insert(depois, '</ul></section>')
    end
  end

  table.insert(depois, '<div class="evento__acao">')
  if comum.texto(y.situacao) == "proximo" then
    table.insert(depois, comum.acao_inscricao(y.inscricao))
  else
    local capa = comum.texto(y.capa)
    if capa ~= "" then
      table.insert(depois, '<img class="evento__capa preview-image" src="' .. comum.esc(capa) .. '" alt="'
        .. comum.esc(comum.texto(y["capa-alt"])) .. '">')
    end
    local botoes = {}
    if comum.texto(y.fotos) ~= "" then
      table.insert(botoes, '<a class="botao botao--secundario" href="' .. comum.esc(comum.texto(y.fotos)) .. '">Ver as fotos</a>')
    end
    if n then
      table.insert(botoes, string.format('<a class="botao botao--secundario" href="/publicacoes/n%02d/index.qmd">Ler o fascículo</a>', n))
    end
    if #botoes > 0 then table.insert(depois, '<p class="acoes">' .. table.concat(botoes, "\n") .. '</p>') end
  end
  table.insert(depois, '</div>')

  doc.blocks = pandoc.Blocks({
    pandoc.Div({
      comum.html(table.concat(topo, "\n")),
      pandoc.Div(doc.blocks, pandoc.Attr("", { "evento__descricao" })),
      comum.html(table.concat(depois, "\n")),
    }, pandoc.Attr("", { "conteiner", "pagina", "evento" })),
  })
  return doc
end
```

- [ ] **Passo 6: Acrescentar ao SCSS a seção Eventos e pôr Eventos no menu**

```scss
// ---- Componente: eventos (EV2, EV3, EVP1–EVP3) ------------------------------
.lista-eventos { list-style: none; padding: 0; margin: 0 0 var(--esp-5); border-bottom: var(--linha-eixo); max-width: none !important; }
.item-evento { display: grid; gap: var(--esp-3); padding-block: var(--esp-5); border-top: var(--linha-grade); }
.item-evento p { margin: 0; }
.item-evento__data { font: var(--peso-h3) var(--fs-h3)/1.3 var(--fonte-titulo); color: var(--azul-marinho); }
.item-evento__nome { font-size: var(--fs-h3); font-weight: var(--peso-h3); line-height: 1.3; margin: 0 !important; }
.item-evento__nome a { text-decoration: none; }
.item-evento__nome a:hover { text-decoration: underline 1px; }
.item-evento__local { font-size: var(--fs-meta); margin-top: var(--esp-1) !important; }
.item-evento__frase { margin-top: var(--esp-3) !important; max-width: var(--medida); }
.item-evento__corpo .acoes, .item-evento__corpo .evento__inscricao { margin-top: var(--esp-4) !important; }
.item-evento__capa { width: 100%; aspect-ratio: 3 / 2; object-fit: cover; border: var(--linha-grade); }
.evento__dados { margin-top: var(--esp-5); max-width: 36rem; }
.evento__descricao { margin-top: var(--esp-6); }
.evento__textos { margin-top: var(--esp-7); }
.evento__textos h2 { margin: 0 0 var(--esp-3); font-size: var(--fs-h3); font-weight: var(--peso-h3); }
.evento__acao { margin-top: var(--esp-6); }
.evento__capa { max-width: 56rem; width: 100%; border: var(--linha-grade); margin-bottom: var(--esp-5); }
@media (min-width: 992px) { .item-evento { grid-template-columns: 15rem minmax(0, 1fr); gap: var(--esp-6); } }
```

No menu, depois de Publicações:

```yaml
      - text: "Eventos"
        href: eventos/index.qmd
```

- [ ] **Passo 7: Rodar os testes**

```bash
bash testes/rodar.sh 09
```

Esperado: `Tudo certo.` Se o teste `Open Graph: data e local` falhar com `og:description` vazio, troque em `eventos/_metadata.yml` o bloco `open-graph: description:` por `description: "{{< meta data-exibida >}}, {{< meta local >}}"`. O efeito colateral (EV2 passa a mostrar data e local como frase) é aceitável; nesse caso, apague a linha `<% if (e.description) ... %>` de `eventos-proximos.ejs`.

- [ ] **Passo 8: Verificação visual e commit**

```bash
bash ferramentas/capturar.sh eventos=eventos/index.html lancamento=eventos/2026-11-27-lancamento-n01/index.html inicio=index.html
```

Compare com `wireframes/screenshots/eventos-*.png` e com a Início da Tarefa 4 (agora I4 mostra o lançamento).

```bash
git add eventos filtros/paginas/eventos.lua filtros/paginas/evento.lua modelos-listing _quarto.yml estilos/macroliga.scss testes/t09-eventos.sh testes/e09-eventos.sh
git commit -m "Adiciona Eventos e a página do lançamento do nº 1

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 10: Página 404

**Arquivos:**
- Criar: `404.qmd`
- Testar: `testes/t10-404.sh`

- [ ] **Passo 1: Escrever o teste (falha primeiro)**

`testes/t10-404.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 10: 404. O Quarto escreve os links da 404 a partir do caminho do site-url,
# para que funcionem quando ela é servida de um endereço profundo.
source "$(dirname "$0")/lib.sh"
existe 404.html "404 gerada"
tem 404.html '<h1[^>]*>Página não encontrada</h1>' "E1 título"
tem 404.html 'Não encontramos esta página\. O endereço pode ter mudado\.' "E1 texto"
tem 404.html 'href="/index\.html"[^>]*>Voltar ao início' "Voltar ao início com caminho do site"
tem 404.html 'href="/publicacoes/index\.html"[^>]*>Ver as publicações' "Ver as publicações com caminho do site"
tem 404.html 'href="/site_libs/' "CSS com caminho do site"
fim
```

- [ ] **Passo 2: Escrever `404.qmd`**

```markdown
---
title: "Página não encontrada"
pagina: "404"
description: "Esta página não existe ou mudou de endereço."
---

:::: {.conteiner .pagina .pagina-404}
# Página não encontrada

Não encontramos esta página. O endereço pode ter mudado.

::: {.acoes}
[Voltar ao início](index.qmd){.botao}
[Ver as publicações](publicacoes/index.qmd){.botao .botao--secundario}
:::
::::
```

Acrescente ao SCSS, na seção "página": `.pagina-404 { min-height: 50vh; }`.

- [ ] **Passo 3: Rodar o teste, verificar a tela e fazer o commit**

```bash
bash testes/rodar.sh 10
bash ferramentas/capturar.sh pagina404=404.html
```

```bash
git add 404.qmd estilos/macroliga.scss testes/t10-404.sh
git commit -m "Adiciona a página 404

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 11: Fascículo nº 1 em rascunho

**Arquivos:**
- Criar: `publicacoes/_modelo-fasciculo/index.qmd`, `publicacoes/_modelo-fasciculo/_metadata.yml`
- Criar: `publicacoes/n01/index.qmd`, `publicacoes/n01/_metadata.yml`, `publicacoes/n01/capa.png`
- Criar: `filtros/paginas/fasciculo.lua`, `modelos-listing/sumario.ejs`
- Modificar: `estilos/macroliga.scss` (seção da página de fascículo)
- Testar: `testes/t11-fasciculo.sh`, `testes/r11-fasciculo.sh`, `testes/e11-fasciculo.sh`

**Interfaces:**
- Consome: `comum.textos_do_fasciculo`, `comum.questionario`, `comum.aviso_institucional`, `comum.data_extenso`; regras de fascículo do `validar.lua`.
- Produz: o id `lista-sumario` e o campo `quantidade-textos` (meta, para a descrição do Open Graph).

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t11-fasciculo.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 11: o fascículo em rascunho não existe no site publicado.
source "$(dirname "$0")/lib.sh"
nao_existe publicacoes/n01/index.html "fascículo nº 1 ausente do _site"
nao_existe publicacoes/n01/capa.png "capa ausente do _site"
nao_existe publicacoes/_modelo-fasciculo "pasta-modelo ausente"
nao_tem sitemap.xml 'publicacoes/n01' "fora do sitemap"
nao_tem index.html 'Fascículo mais recente' "I2 continua em breve"
nao_tem publicacoes/index.html 'class="fasciculo fasciculo--lista"' "P2 sem fascículo publicado"
fim
```

`testes/r11-fasciculo.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 11: o fascículo completo no perfil rascunhos (F1–F6).
SITE=_site-rascunhos
source "$(dirname "$0")/lib.sh"
P=publicacoes/n01/index.html
existe "$P" "fascículo nº 1 no perfil rascunhos"
tem "$P" "<title>Pontos de Macro ${NO}1 – MacroLiga UFRGS</title>" "<title> montado com o nome da publicação"
tem "$P" "href=\"\.\./index\.html\">Publicações</a> / Fascículo ${NO}1" "F1 trilha"
tem "$P" "<h1 class=\"fasciculo-pagina__titulo\">Pontos de Macro ${NO}1</h1>" "F2 título"
tem "$P" '<img class="fasciculo__capa" src="capa\.png" alt="Capa do fascículo' "F2 capa com alt"
tem "$P" 'Publicado em: 27 de novembro de 2026' "F2 data"
tem "$P" 'O PDF fica disponível no lançamento do fascículo\.' "F2 sem PDF"
tem "$P" '<h2 id="t-sumario">Sumário</h2>' "F3 título"
tem "$P" "Ver o evento de lançamento" "F4 link para o evento"
tem "$P" 'Os textos publicados não representam a posição da MacroLiga UFRGS' "F6"
tem "$P" '<meta property="og:title" content="Pontos de Macro nº 1">' "og:title do fascículo"
tem "$P" '<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/publicacoes/n01/capa\.png"' "og:image é a capa"
tem publicacoes/index.html 'id="lista-em-breve"[^>]*hidden' "P2: em breve oculto quando o nº 1 está visível"
tem publicacoes/index.html '<img class="fasciculo__capa" src="[^"]*n01/capa\.png"' "P2 com a capa"
fim
```

`testes/e11-fasciculo.sh` (Foco de revisão 2):

```bash
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
trocar _variables.yml 's|  url: ""|  url: "https://docs.google.com/forms/d/e/TESTE/viewform"|' 's|campo-pagina: ""|campo-pagina: "entry.123"|'
quarto render "$F" --profile rascunhos > testes/.render-estado.log 2>&1
SITE=_site-rascunhos tem publicacoes/n01/index.html 'viewform\?usp=pp_url&amp;entry\.123=Pontos%20de%20Macro%20n%C2%BA%C2%A01' "F5 abre o formulário com o título"
SITE=_site-rascunhos tem publicacoes/n01/index.html 'Leu este fascículo\? Conte o que achou em um questionário curto\.' "F5 frase"
fim
```

- [ ] **Passo 2: Escrever as pastas-modelo do fascículo**

`publicacoes/_modelo-fasciculo/_metadata.yml`:

```yaml
# Maquinaria do fascículo (não mexa). Copiado junto com a pasta; vale para o index.qmd dela.
pagina: fasciculo
image: "capa.png"
quantidade-textos: ""
description: "{{< meta date >}}. {{< meta quantidade-textos >}} textos sobre a economia brasileira, revisados por professores da FCE."
open-graph:
  title: "{{< var publicacao.nome >}} nº {{< meta numero >}}"
listing:
  id: lista-sumario
  contents: "*/index.qmd"
  template: ../../modelos-listing/sumario.ejs
  sort: "ordem"
```

`publicacoes/_modelo-fasciculo/index.qmd`:

```markdown
---
# Para criar um fascículo: copie esta pasta para publicacoes/nNN/ (dois dígitos: n02, n03...)
# e preencha. O título ("Nome da publicação nº N") é montado sozinho.
numero: 2
date: 2027-05-20                    # data do lançamento
capa: "capa.png"                    # a capa fica nesta pasta, com este nome
capa-alt: "Capa do fascículo nº 2"
pdf: "fasciculo.pdf"                # o PDF completo, nesta pasta (só no lançamento)
doi: ""                             # DOI do fascículo no Zenodo, ex.: "10.5281/zenodo.1234567"
evento: ""                          # opcional: nome da pasta do evento de lançamento, ex.: "2027-05-20-lancamento-n02"
draft: true                         # apague esta linha no dia do lançamento
---
```

Copie a pasta-modelo para o nº 1 e ajuste:

```bash
cp -r publicacoes/_modelo-fasciculo publicacoes/n01
cp design/img/capa-modelo.png publicacoes/n01/capa.png
```

`publicacoes/n01/index.qmd`:

```markdown
---
numero: 1
date: 2026-11-27
capa: "capa.png"
capa-alt: "Capa do fascículo nº 1"
pdf: "fasciculo.pdf"
doi: "10.5281/zenodo.XXXXXXX"       # [a confirmar no depósito do Zenodo]
evento: "2026-11-27-lancamento-n01"
draft: true
---
```

- [ ] **Passo 3: Escrever o template do sumário (F3)**

`modelos-listing/sumario.ejs`:

````text
```{=html}
<%
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const autor = i => [].concat(i.author || []).map(a => (a && a.name) ? (a.name.literal || a.name) : a).join(", ");
if (items.length > 0) {
%>
<ul class="lista-textos">
<% for (const item of items) { %>
<li class="item-texto">
<div>
<p class="item-texto__tipo"><%= item.tipo %></p>
<h3 class="item-texto__titulo"><a href="<%- item.path %>"><%= t(item.title) %></a></h3>
<p class="item-texto__autor"><%= autor(item) %></p>
</div>
<dl class="item-texto__dados"><dt>Eixo</dt><dd><%= item.eixo %></dd></dl>
</li>
<% } %>
</ul>
<% } %>
```
````

- [ ] **Passo 4: Escrever `filtros/paginas/fasciculo.lua`**

```lua
-- filtros/paginas/fasciculo.lua: página do fascículo (spec 2.4). Tudo vem do cabeçalho YAML.
return function(doc, comum)
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local m = doc.meta
  local pasta = comum.pasta_atual()
  local nome_pasta = pandoc.path.filename(pasta)
  local n = comum.texto(y.numero)
  local nome = comum.texto(m.publicacao.nome)
  local textos = comum.textos_do_fasciculo(nome_pasta, true)
  local qtd = #textos

  m.pagetitle = pandoc.Inlines(nome .. " nº" .. comum.NBSP .. n)
  m["quantidade-textos"] = pandoc.Inlines(tostring(qtd))

  local pdf, doi = comum.texto(y.pdf), comum.texto(y.doi)
  local acoes = {}
  if pdf ~= "" and comum.existe(comum.caminho(pasta, pdf)) then
    table.insert(acoes, '<a class="botao" href="' .. comum.esc(pdf) .. '">Baixar PDF</a>')
  else
    table.insert(acoes, '<p class="aviso-pdf">O PDF fica disponível no lançamento do fascículo.</p>')
  end
  if doi ~= "" then
    table.insert(acoes, '<a class="botao botao--secundario" href="https://doi.org/' .. comum.esc(doi) .. '">Abrir no Zenodo</a>')
  end

  local quantidade = qtd == 1 and "1 texto, revisado por professores da FCE"
    or (qtd .. " textos, revisados por professores da FCE")
  local topo = {
    '<p class="trilha"><a href="../index.qmd">Publicações</a> / Fascículo nº&nbsp;' .. comum.esc(n) .. '</p>',
    '<header class="fasciculo-pagina">',
    '<img class="fasciculo__capa" src="' .. comum.esc(comum.texto(y.capa)) .. '" alt="' .. comum.esc(comum.texto(y["capa-alt"])) .. '">',
    '<div class="fasciculo-pagina__dados">',
    '<h1 class="fasciculo-pagina__titulo">' .. comum.esc(nome .. " nº " .. n) .. '</h1>',
    '<p>Publicado em: ' .. comum.esc(comum.data_extenso(y.date)) .. '</p>',
    '<p>' .. quantidade .. '</p>',
    doi ~= "" and ('<p class="numeros">DOI: ' .. comum.esc(doi) .. '</p>') or '',
    '<div class="acoes">', table.concat(acoes, "\n"), '</div>',
    '</div>',
    '</header>',
    '<section class="sumario-fasciculo" aria-labelledby="t-sumario">',
    '<h2 id="t-sumario">Sumário</h2>',
  }

  local depois = { '</section>' }
  local evento = comum.texto(y.evento)
  if evento ~= "" then
    local ev = comum.cabecalho(comum.caminho(comum.raiz(), "eventos", evento, "index.qmd"))
    if not ev then comum.parar('Fascículo nº ' .. n .. ': o evento "' .. evento .. '" (campo "evento") não existe em eventos/.') end
    local realizado = comum.texto(ev.situacao) == "realizado"
    table.insert(depois, '<section class="lancamento" aria-labelledby="t-lancamento">')
    table.insert(depois, '<h2 id="t-lancamento">Lançamento</h2>')
    if realizado then
      table.insert(depois, '<p>Lançado em evento presencial, com um debatedor para cada texto.</p>')
    else
      table.insert(depois, '<p>O lançamento será em um evento presencial, com um debatedor para cada texto.</p>')
    end
    table.insert(depois, string.format('<p class="acoes"><a class="botao botao--secundario" href="/eventos/%s/index.qmd">%s</a></p>',
      comum.esc(evento), realizado and "Ver as fotos" or "Ver o evento de lançamento"))
    table.insert(depois, '</section>')
  end

  local blocos = pandoc.Blocks({
    comum.html(table.concat(topo, "\n")),
    pandoc.Div({}, pandoc.Attr("lista-sumario")),
    comum.html(table.concat(depois, "\n")),
  })
  local q = comum.questionario(m, "Leu este fascículo? Conte o que achou em um questionário curto. As respostas ajudam a avaliar o projeto de extensão.",
    nome .. " nº" .. comum.NBSP .. n)
  if q then blocos:insert(q) end
  blocos:insert(comum.aviso_institucional())
  doc.blocks = pandoc.Blocks({ pandoc.Div(blocos, pandoc.Attr("", { "conteiner", "pagina", "fasciculo-pagina-conteudo" })) })
  return doc
end
```

- [ ] **Passo 5: Acrescentar ao SCSS a seção da página de fascículo**

```scss
// ---- Componente: página do fascículo (F1–F6) --------------------------------
// No celular, a capa fica pequena ao lado do título, para "Baixar PDF" aparecer sem rolar.
.fasciculo-pagina { display: grid; grid-template-columns: 7rem minmax(0, 1fr); gap: var(--esp-4); align-items: start; }
.fasciculo-pagina .fasciculo__capa { aspect-ratio: 210 / 297; object-fit: cover; }
.fasciculo-pagina__titulo { font-size: var(--fs-titulo-longo); font-weight: var(--peso-titulo-longo); margin-bottom: var(--esp-3) !important; }
.fasciculo-pagina__dados p { margin: 0; font-size: var(--fs-meta); }
.fasciculo-pagina__dados .acoes { margin-top: var(--esp-4); grid-column: 1 / -1; }
.aviso-pdf { font-size: var(--fs-meta); max-width: 36ch; }
.sumario-fasciculo h2, .lancamento h2 { margin-top: var(--esp-8); }
@media (max-width: 991.98px) {
  .fasciculo-pagina__dados { display: contents; }
  .fasciculo-pagina__dados > :not(.fasciculo-pagina__titulo) { grid-column: 1 / -1; }
}
@media (min-width: 992px) {
  .fasciculo-pagina { grid-template-columns: 15rem minmax(0, 1fr); gap: var(--esp-6); }
  .fasciculo-pagina__titulo { font-size: var(--fs-h1); font-weight: var(--peso-h1); }
}
```

- [ ] **Passo 6: Rodar os testes**

```bash
bash testes/rodar.sh 11
```

Esperado: `Tudo certo.` Ainda sem textos, o sumário fica vazio e o fascículo diz "0 textos". A Tarefa 12 preenche.

- [ ] **Passo 7: Verificação visual e commit**

```bash
bash ferramentas/capturar.sh -s _site-rascunhos fasciculo=publicacoes/n01/index.html
bash ferramentas/capturar.sh -s _site-rascunhos -l "390" fasciculo-700=publicacoes/n01/index.html
```

Compare com `wireframes/screenshots/fasciculo-*.png`. Em `capturas/fasciculo-700-390.png`, a mensagem do PDF (ou "Baixar PDF", quando houver) precisa estar acima da linha dos 700 px.

```bash
git add publicacoes/_modelo-fasciculo publicacoes/n01/index.qmd publicacoes/n01/_metadata.yml publicacoes/n01/capa.png filtros/paginas/fasciculo.lua modelos-listing/sumario.ejs estilos/macroliga.scss testes/t11-fasciculo.sh testes/r11-fasciculo.sh testes/e11-fasciculo.sh
git commit -m "Adiciona o fascículo nº 1 em rascunho e sua pasta-modelo

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 12: Os quatro textos do nº 1 em rascunho

**Arquivos:**
- Criar: `publicacoes/_modelo-texto/index.qmd`, `publicacoes/_modelo-texto/_metadata.yml`
- Criar: `publicacoes/n01/{endividamento-familias-financeirizacao,impactos-setoriais-mercosul-ue,eficacia-politica-monetaria-expectativas-racionais,subdesenvolvimento-visao-schumpeteriana}/{index.qmd,_metadata.yml}`
- Criar: `filtros/paginas/texto.lua`, `modelos-listing/outros.ejs`, `assets/js/citacao.js`
- Modificar: `estilos/macroliga.scss` (seção da página de texto)
- Testar: `testes/t12-textos.sh`, `testes/r12-textos.sh`, `testes/e12-textos.sh`

**Interfaces:**
- Consome: `comum.*`; regras de texto do `validar.lua`; `lista-sumario` (Tarefa 11); `textos.ejs` (Tarefa 8).
- Produz: o id `lista-outros` e o botão `[data-copiar="citacao-texto"]` com o aviso `.citacao__aviso`.

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t12-textos.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 12: os textos em rascunho não existem no site publicado.
source "$(dirname "$0")/lib.sh"
for s in endividamento-familias-financeirizacao impactos-setoriais-mercosul-ue eficacia-politica-monetaria-expectativas-racionais subdesenvolvimento-visao-schumpeteriana; do
  nao_existe "publicacoes/n01/$s/index.html" "texto $s ausente do _site"
done
nao_existe publicacoes/_modelo-texto "pasta-modelo ausente"
nao_tem publicacoes/index.html 'class="lista-textos' "P4 continua oculto"
nao_tem sitemap.xml 'n01/' "textos fora do sitemap"
r=$(git ls-files '*.pdf' | wc -l | tr -d ' ')
[ "$r" = "0" ] && ok "nenhum PDF no Git" || falha "há $r PDF(s) no Git"
fim
```

`testes/r12-textos.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 12: os textos completos no perfil rascunhos (T1–T11), o sumário e P4.
SITE=_site-rascunhos
source "$(dirname "$0")/lib.sh"
P=publicacoes/n01/impactos-setoriais-mercosul-ue/index.html
existe "$P" "texto do Miguel no perfil rascunhos"
tem "$P" "href=\"\.\./index\.html\">Voltar ao fascículo ${NO}1</a>" "T1"
tem "$P" '<p class="texto__tipo">Análise de conjuntura</p>' "T2 tipo"
tem "$P" '<h1 class="titulo-longo">Impactos setoriais do acordo Mercosul e União Europeia</h1>' "T2 título"
tem "$P" '<p class="texto__autor">Miguel Amorin</p>' "T2 autor"
tem "$P" 'O PDF fica disponível no lançamento do fascículo\.' "T3 sem PDF"
tem "$P" 'href="https://doi\.org/10\.5281/zenodo\.XXXXXXX">Abrir no Zenodo' "T3 DOI herdado do fascículo"
tem "$P" '<p class="texto__sintese">' "T4"
tem "$P" 'As opiniões expressas são de responsabilidade de quem assina o texto\.' "T5"
tem "$P" 'A revisão docente não implica concordância do revisor com o conteúdo\.' "T6"
tem "$P" 'AMORIN, Miguel\. Impactos setoriais do acordo Mercosul e União Europeia\. <strong>Pontos de Macro</strong>, Porto Alegre, n\. 1, nov\. 2026\. DOI: 10\.5281/zenodo\.XXXXXXX\.' "T7 citação ABNT"
tem "$P" 'data-copiar="citacao-texto" hidden>Copiar citação' "T7 botão (aparece com JS)"
tem "$P" 'class="citacao__aviso" role="status"' "T7 aviso para leitor de tela"
conta "$P" 'class="dados texto__dados' 2 "T3 lateral (desktop) e T9 (celular)"
tem "$P" "Outros textos do fascículo ${NO}1" "T10 título"
conta "$P" 'class="outros__titulo"' 3 "T10 três outros textos"
nao_tem "$P" 'class="outros__titulo"[^>]*>Impactos setoriais' "T10 sem o próprio texto"
tem "$P" 'Os textos publicados não representam a posição' "T11"
tem "$P" 'site_libs/macroliga-citacao-1\.0/citacao\.js' "citacao.js anexado"
tem "$P" '<meta property="og:title" content="Impactos setoriais do acordo Mercosul e União Europeia">' "og:title do texto"
tem "$P" '<meta property="og:image" content="https://macroliga-ufrgs\.github\.io/publicacoes/n01/capa\.png"' "og:image é a capa do fascículo"
F=publicacoes/n01/index.html
conta "$F" 'class="item-texto"' 4 "F3 quatro textos"
tem "$F" '4 textos, revisados por professores da FCE' "F2 conta os textos"
tem publicacoes/index.html 'class="lista-textos lista-textos--filtravel"' "P4 aparece"
conta publicacoes/index.html 'class="item-texto" data-eixo=' 4 "P4 quatro textos"
tem publicacoes/index.html 'data-eixo="setor-externo-e-cambio" data-tipo="analise-de-conjuntura"' "P4 data-eixo e data-tipo em slug"
tem index.html 'Fascículo mais recente' "I2 mostra o nº 1 no perfil rascunhos"
tem index.html "Ler o fascículo ${NO}1" "I1 aponta para o fascículo"
fim
```

`testes/e12-textos.sh` (Focos de revisão 2 e 3):

```bash
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
SITE=_site-rascunhos tem "$S" '<h1 class="titulo-longo">Brasil &amp; Argentina: o &quot;acordo&quot; &lt;revisto&gt;</h1>' "título escapado"
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
```

Os PDFs de teste são apagados pelo `desfazer` no fim do script. Depois de rodá-lo, confirme com `git status --short | grep pdf` (sem saída).

- [ ] **Passo 2: Escrever as pastas-modelo do texto**

`publicacoes/_modelo-texto/_metadata.yml`:

```yaml
# Maquinaria do texto (não mexa). Copiado junto com a pasta; vale para o index.qmd dela.
pagina: texto
image: "../capa.png"
description: "{{< meta sintese >}}"
open-graph:
  title: "{{< meta title >}}"
listing:
  id: lista-outros
  contents: "../*/index.qmd"
  template: ../../../modelos-listing/outros.ejs
  sort: "ordem"
```

`publicacoes/_modelo-texto/index.qmd`:

```markdown
---
# Para publicar um texto: copie esta pasta para dentro da pasta do fascículo
# (ex.: publicacoes/n02/), renomeie com um slug curto (minúsculas, sem acento, com hífens)
# e preencha. A página inteira é montada a partir deste cabeçalho.
title: "Título do texto em sentence case"
author: "Nome Sobrenome"
autor-citacao: ""                   # opcional: só para sobrenome composto, ex.: "SILVA, Leonardo Xavier da"
tipo: "Análise de conjuntura"       # Análise de conjuntura | Revisão de literatura | Nota de pesquisa | Texto de opinião
eixo: "Setor externo e câmbio"      # um dos 6 eixos de _variables.yml, escrito igual
fasciculo: 2                        # número do fascículo
ordem: 1                            # posição no sumário
date: 2027-05-20                    # data do lançamento
sintese: "Duas a três frases que resumem o texto."
revisao: "Prof. Fulano de Tal (FCE/UFRGS)"
doi: ""                             # vazio = usa o DOI do fascículo
pdf: "texto.pdf"                    # o PDF do texto, nesta pasta (só no lançamento)
draft: true                         # apague esta linha no dia do lançamento
---
```

- [ ] **Passo 3: Criar os quatro textos**

Para cada slug, copie a pasta-modelo e escreva o cabeçalho:

```bash
for s in endividamento-familias-financeirizacao impactos-setoriais-mercosul-ue eficacia-politica-monetaria-expectativas-racionais subdesenvolvimento-visao-schumpeteriana; do
  cp -r publicacoes/_modelo-texto "publicacoes/n01/$s"
done
```

`publicacoes/n01/endividamento-familias-financeirizacao/index.qmd`:

```markdown
---
title: "Endividamento das famílias e financeirização no Brasil"
author: "João Pedone"
autor-citacao: ""
tipo: "Análise de conjuntura"       # [a confirmar]
eixo: "Atividade econômica, mercado de trabalho e crédito"
fasciculo: 1
ordem: 1                            # [ordem provisória: definida pela Presidência]
date: 2026-11-27
sintese: "[síntese provisória: a preencher pelo autor]"
revisao: "[revisor a confirmar]"
doi: ""
pdf: "texto.pdf"
draft: true
---
```

`publicacoes/n01/impactos-setoriais-mercosul-ue/index.qmd`:

```markdown
---
title: "Impactos setoriais do acordo Mercosul e União Europeia"
author: "Miguel Amorin"
autor-citacao: ""
tipo: "Análise de conjuntura"
eixo: "Setor externo e câmbio"
fasciculo: 1
ordem: 2                            # [ordem provisória: definida pela Presidência]
date: 2026-11-27
sintese: "[síntese provisória: a preencher pelo autor]"
revisao: "[revisor a confirmar]"
doi: ""
pdf: "texto.pdf"
draft: true
---
```

`publicacoes/n01/eficacia-politica-monetaria-expectativas-racionais/index.qmd`:

```markdown
---
title: "Notas sobre a eficácia da política monetária sob a hipótese de expectativas racionais: uma breve revisão da literatura"
author: "Gabriel Vieira"
autor-citacao: ""
tipo: "Revisão de literatura"
eixo: "Política monetária e inflação"
fasciculo: 1
ordem: 3                            # [ordem provisória: definida pela Presidência]
date: 2026-11-27
sintese: "[síntese provisória: a preencher pelo autor]"
revisao: "[revisor a confirmar]"
doi: ""
pdf: "texto.pdf"
draft: true
---
```

`publicacoes/n01/subdesenvolvimento-visao-schumpeteriana/index.qmd`:

```markdown
---
title: "Subdesenvolvimento: uma visão schumpeteriana"
author: "Arthur Pittella"
autor-citacao: ""
tipo: "Texto de opinião"            # [a confirmar]
eixo: "Atividade econômica, mercado de trabalho e crédito"   # [a confirmar]
fasciculo: 1
ordem: 4                            # [ordem provisória: definida pela Presidência]
date: 2026-11-27
sintese: "[síntese provisória: a preencher pelo autor]"
revisao: "[revisor a confirmar]"
doi: ""
pdf: "texto.pdf"
draft: true
---
```

- [ ] **Passo 4: Escrever o template de T10 e o script de citação**

`modelos-listing/outros.ejs`:

````text
```{=html}
<%
const t = s => String(s || "").replace(/nº /g, "nº\u00a0");
const autor = i => [].concat(i.author || []).map(a => (a && a.name) ? (a.name.literal || a.name) : a).join(", ");
if (items.length > 0) {
%>
<ul class="outros">
<% for (const item of items) { %><li><a class="outros__titulo" href="<%- item.path %>"><%= t(item.title) %></a><span class="outros__autor"><%= autor(item) %></span></li>
<% } %></ul>
<% } %>
```
````

`assets/js/citacao.js`:

```js
// "Copiar citação" (spec T7): copia a citação e anuncia "Citação copiada." a leitores de tela.
// Sem JavaScript, o botão fica oculto e a citação continua selecionável.
(function () {
  function pronto(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }
  function copiarAntigo(texto) {
    var area = document.createElement("textarea");
    area.value = texto;
    area.setAttribute("readonly", "");
    area.style.position = "absolute";
    area.style.left = "-9999px";
    document.body.appendChild(area);
    area.select();
    document.execCommand("copy");
    document.body.removeChild(area);
  }
  pronto(function () {
    document.querySelectorAll("[data-copiar]").forEach(function (botao) {
      var alvo = document.getElementById(botao.getAttribute("data-copiar"));
      var aviso = botao.parentNode.querySelector(".citacao__aviso");
      if (!alvo || !aviso) return;
      botao.hidden = false;
      botao.addEventListener("click", function () {
        var texto = alvo.innerText.trim();
        function avisar() {
          aviso.textContent = "";
          setTimeout(function () { aviso.textContent = "Citação copiada."; }, 50);
        }
        if (navigator.clipboard && window.isSecureContext) {
          navigator.clipboard.writeText(texto).then(avisar, function () { copiarAntigo(texto); avisar(); });
        } else {
          copiarAntigo(texto);
          avisar();
        }
      });
    });
  });
})();
```

- [ ] **Passo 5: Escrever `filtros/paginas/texto.lua`**

```lua
-- filtros/paginas/texto.lua: página de um texto (spec 2.5). O aluno preenche só o YAML.

-- "Miguel Amorin" -> "AMORIN, Miguel"; autor-citacao, se preenchido, substitui a regra.
local function referencia_autor(comum, y)
  local manual = comum.texto(y["autor-citacao"])
  if manual ~= "" then return manual end
  local palavras = {}
  for p in comum.texto(y.author):gmatch("%S+") do table.insert(palavras, p) end
  if #palavras == 0 then return "" end
  local sobrenome = pandoc.text.upper(table.remove(palavras))
  if #palavras == 0 then return sobrenome end
  return sobrenome .. ", " .. table.concat(palavras, " ")
end

local function com_ponto(s)
  if s:match("[%.%?!]$") then return s end
  return s .. "."
end

return function(doc, comum)
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local m = doc.meta
  local pasta = comum.pasta_atual()
  local fasc = comum.cabecalho(comum.caminho(pasta, "..", "index.qmd")) or {}
  local nome_pub = comum.texto(m.publicacao.nome)
  local n = comum.texto(y.fasciculo)
  local titulo, autor = comum.texto(y.title), comum.texto(y.author)
  local tipo, eixo, revisao = comum.texto(y.tipo), comum.texto(y.eixo), comum.texto(y.revisao)
  local doi = comum.texto(y.doi)
  if doi == "" then doi = comum.texto(fasc.doi) end
  local data = comum.data_extenso(y.date)
  local pdf = comum.texto(y.pdf)

  local acoes = {}
  if pdf ~= "" and comum.existe(comum.caminho(pasta, pdf)) then
    table.insert(acoes, '<a class="botao" href="' .. comum.esc(pdf) .. '">Baixar PDF</a>')
  else
    table.insert(acoes, '<p class="aviso-pdf">O PDF fica disponível no lançamento do fascículo.</p>')
  end
  if doi ~= "" then
    table.insert(acoes, '<a class="botao botao--secundario" href="https://doi.org/' .. comum.esc(doi) .. '">Abrir no Zenodo</a>')
  end

  local function dados(classe)
    return table.concat({
      '<dl class="dados texto__dados ' .. classe .. '">',
      '<dt>Autor</dt><dd>' .. comum.esc(autor) .. '</dd>',
      '<dt>Tipo de texto</dt><dd>' .. comum.esc(tipo) .. '</dd>',
      '<dt>Eixo</dt><dd>' .. comum.esc(eixo) .. '</dd>',
      '<dt>Fascículo</dt><dd><a href="../index.qmd">' .. comum.esc(nome_pub .. " nº " .. n) .. '</a></dd>',
      '<dt>Publicado em</dt><dd>' .. comum.esc(data) .. '</dd>',
      '<dt>Revisão</dt><dd>' .. comum.esc(revisao) .. '</dd>',
      doi ~= "" and ('<dt>DOI</dt><dd>' .. comum.esc(doi) .. '</dd>') or '',
      '</dl>',
    }, "\n")
  end

  local citacao = string.format('%s %s <strong>%s</strong>, Porto Alegre, n. %s, %s. DOI: %s.',
    comum.esc(com_ponto(referencia_autor(comum, y))), comum.esc(com_ponto(titulo)), comum.esc(nome_pub),
    comum.esc(n), comum.esc(comum.data_abnt(y.date)), comum.esc(doi ~= "" and doi or "[a definir]"))

  local blocos = pandoc.Blocks({ comum.html(table.concat({
    '<p class="trilha"><a href="../index.qmd">Voltar ao fascículo nº&nbsp;' .. comum.esc(n) .. '</a></p>',
    '<header class="texto__cabecalho">',
    '<p class="texto__tipo">' .. comum.esc(tipo) .. '</p>',
    '<h1 class="titulo-longo">' .. comum.esc(titulo) .. '</h1>',
    '<p class="texto__autor">' .. comum.esc(autor) .. '</p>',
    '</header>',
    '<div class="texto__grade">',
    '<aside class="texto__lateral" aria-label="Dados do texto">',
    '<div class="acoes texto__acoes">', table.concat(acoes, "\n"), '</div>',
    dados("texto__dados--lateral"),
    '</aside>',
    '<div class="texto__corpo">',
    '<p class="texto__sintese">' .. comum.esc(comum.texto(y.sintese)) .. '</p>',
    '<p class="nota">As opiniões expressas são de responsabilidade de quem assina o texto.</p>',
    '<p class="nota">Texto revisado por ' .. comum.esc(revisao) .. '. A revisão docente não implica concordância do revisor com o conteúdo. A responsabilidade pelo texto é de quem o assina.</p>',
    '<section class="citacao" aria-labelledby="titulo-citacao">',
    '<h2 id="titulo-citacao">Como citar</h2>',
    '<p class="citacao__texto" id="citacao-texto">' .. citacao .. '</p>',
    '<button class="botao botao--secundario" type="button" data-copiar="citacao-texto" hidden>Copiar citação</button>',
    '<p class="citacao__aviso" role="status"></p>',
    '</section>',
  }, "\n")) })

  local q = comum.questionario(m, "Leu este texto? Conte o que achou em um questionário curto. As respostas ajudam a avaliar o projeto de extensão.", titulo)
  if q then blocos:insert(q) end
  blocos:insert(comum.html(dados("texto__dados--celular") .. "\n</div>\n</div>"))

  local irmaos = comum.textos_do_fasciculo(pandoc.path.filename(pandoc.path.directory(pasta)), true)
  if #irmaos > 1 then
    blocos:insert(comum.html('<section class="outros-textos" aria-labelledby="titulo-outros">\n<h2 id="titulo-outros">Outros textos do fascículo nº&nbsp;' .. comum.esc(n) .. '</h2>'))
    blocos:insert(pandoc.Div({}, pandoc.Attr("lista-outros")))
    blocos:insert(comum.html('</section>'))
  end
  blocos:insert(comum.aviso_institucional())

  doc.blocks = pandoc.Blocks({ pandoc.Div(blocos, pandoc.Attr("", { "conteiner", "pagina", "texto" })) })
  comum.script("citacao")
  return doc
end
```

- [ ] **Passo 6: Acrescentar ao SCSS a seção da página de texto**

```scss
// ---- Componente: página de texto (T1–T11) -----------------------------------
// Celular: T2, T3 (botões), T4–T8, T9 (dados). Desktop: coluna lateral fixa com dados e botões.
.texto__tipo { font-size: var(--fs-meta); font-weight: var(--peso-forte); margin: 0 0 var(--esp-3) !important; }
.texto__autor { margin: var(--esp-3) 0 0 !important; }
.texto__grade { display: grid; gap: var(--esp-6); margin-top: var(--esp-6); }
.texto__dados--lateral { display: none; }
.texto__sintese { font: var(--peso-texto) var(--fs-sintese)/var(--lh-serifa) var(--fonte-titulo); max-width: var(--medida); margin: 0 !important; }
.texto__dados--celular { margin-top: var(--esp-7); padding-top: var(--esp-5); border-top: var(--linha-grade); }
.citacao { margin-top: var(--esp-7); max-width: var(--medida); }
.citacao h2 { font-size: var(--fs-h3); font-weight: var(--peso-h3); margin: 0 0 var(--esp-3) !important; }
.citacao__texto { padding: var(--esp-4); border: var(--linha-grade); font-size: var(--fs-meta); margin: 0 0 var(--esp-3) !important; overflow-wrap: anywhere; }
.citacao__aviso { font-size: var(--fs-meta); min-height: 1.6em; margin: var(--esp-2) 0 0 !important; }
.outros-textos h2 { font-size: var(--fs-h3); font-weight: var(--peso-h3); margin: var(--esp-8) 0 var(--esp-3); }
.outros { list-style: none; padding: 0; margin: 0; display: grid; gap: var(--esp-4); max-width: none !important; }
.outros li { border-top: var(--linha-grade); padding-top: var(--esp-3); }
.outros__titulo { display: block; font: 500 1.0625rem/1.4 var(--fonte-titulo); text-decoration: none; }
.outros__titulo:hover { text-decoration: underline 1px; }
.outros__autor { display: block; font-size: var(--fs-meta); margin-top: var(--esp-1); }
@media (min-width: 992px) {
  .texto__grade { grid-template-columns: minmax(0, 1fr) 20rem; gap: var(--esp-8); align-items: start; }
  .texto__lateral { grid-column: 2; grid-row: 1; position: sticky; top: var(--esp-5); display: flex; flex-direction: column; gap: var(--esp-5); }
  .texto__lateral .texto__dados--lateral { display: grid; order: 1; }
  .texto__lateral .texto__acoes { order: 2; }
  .texto__corpo { grid-column: 1; grid-row: 1; }
  .texto__dados--celular { display: none; }
  .outros { grid-template-columns: repeat(3, minmax(0, 1fr)); }
}
```

O título do sumário curto em `.outros__titulo` reusa os valores de `.sumario__titulo` da prancha (1.0625rem, peso 500, entrelinha 1,4).

- [ ] **Passo 7: Rodar os testes**

```bash
bash testes/rodar.sh 1
```

Esperado: `Tudo certo.` em t10, t11, r11, e11, t12, r12 e e12.

- [ ] **Passo 8: Verificação visual e commit**

```bash
bash ferramentas/capturar.sh -s _site-rascunhos texto=publicacoes/n01/impactos-setoriais-mercosul-ue/index.html texto-longo=publicacoes/n01/eficacia-politica-monetaria-expectativas-racionais/index.html fasciculo=publicacoes/n01/index.html publicacoes-rascunho=publicacoes/index.html inicio-rascunho=index.html
```

Compare com `wireframes/screenshots/texto-*.png` e `fasciculo-*.png`. Confira: o título longo do Gabriel cabe sem estourar em 390 px; a coluna lateral fica fixa ao rolar em 1280 px; "Baixar PDF" (ou a mensagem) aparece antes da síntese no celular.

```bash
git add publicacoes/_modelo-texto publicacoes/n01 filtros/paginas/texto.lua modelos-listing/outros.ejs assets/js/citacao.js estilos/macroliga.scss testes/t12-textos.sh testes/r12-textos.sh testes/e12-textos.sh
git status --short | grep -i pdf && echo "PARE: há PDF no stage" || true
git commit -m "Adiciona os quatro textos do nº 1 em rascunho e a pasta-modelo de texto

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 13: Filtros de Publicações por eixo e tipo

**Arquivos:**
- Modificar: `modelos-listing/textos.ejs` (P3), `assets/js/filtros.js`, `estilos/macroliga.scss` (seção filtros)
- Testar: `testes/r13-filtros.sh`, `testes/t13-filtros.sh`

**Interfaces:**
- Consome: `<ul class="lista-textos lista-textos--filtravel">` com `data-eixo`/`data-tipo` (Tarefa 8); links `?eixo=` (Tarefas 5 e 6).
- Produz: `[data-filtros]` (oculto sem JS), `select[data-filtro="eixo|tipo"]`, `input[name="filtro-eixo|filtro-tipo"]`, `[data-limpar]`, `#filtros-resultado` (status) e `#filtros-vazio`.

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/r13-filtros.sh` (HTML sem JavaScript):

```bash
#!/usr/bin/env bash
# Tarefa 13: controles de filtro no HTML (sem JavaScript, ficam ocultos e a lista aparece inteira).
SITE=_site-rascunhos
source "$(dirname "$0")/lib.sh"
P=publicacoes/index.html
tem "$P" '<div class="filtros" data-filtros hidden>' "controles ocultos sem JS"
conta "$P" '<option value="[a-z-]+">' 10 "6 eixos + 4 tipos nas listas suspensas"
conta "$P" 'name="filtro-eixo"' 7 "botões de eixo: Todos + 6"
conta "$P" 'name="filtro-tipo"' 5 "botões de tipo: Todos + 4"
tem "$P" '<label for="filtro-eixo">Filtrar por eixo</label>' "rótulo do eixo"
tem "$P" 'id="filtros-resultado" role="status"' "resultado anunciado"
tem "$P" 'id="filtros-vazio" hidden' "estado vazio oculto"
tem "$P" 'Ainda não há textos com esses filtros\. Limpe os filtros para ver todos os textos\.' "texto do estado vazio"
nao_tem "$P" '<li class="item-texto"[^>]*hidden' "nenhum item oculto sem JS"
fim
```

`testes/t13-filtros.sh` (com JavaScript, pelo Chrome; inclui o Foco de revisão 1):

```bash
#!/usr/bin/env bash
# Tarefa 13: filtros com JavaScript (DOM depois de o script rodar).
source "$(dirname "$0")/lib.sh"
dom() { bash ferramentas/dom.sh -s _site-rascunhos "publicacoes/index.html$1"; }
visiveis() { grep -o '<li class="item-texto"[^>]*>' | grep -vc 'hidden'; }
confere() { # confere <consulta> <esperado> <descrição>
  local n; n=$(dom "$1" | visiveis)
  [ "$n" = "$2" ] && ok "$3 ($n)" || falha "$3: $n visíveis, esperado $2"
}
confere "" 4 "sem filtro: todos"
confere "?eixo=setor-externo-e-cambio" 1 "eixo sozinho"
confere "?eixo=atividade-economica-mercado-de-trabalho-e-credito" 2 "eixo com dois textos"
confere "?tipo=analise-de-conjuntura" 2 "tipo sozinho"
confere "?eixo=atividade-economica-mercado-de-trabalho-e-credito&tipo=analise-de-conjuntura" 1 "eixo E tipo"
confere "?eixo=mercados-externos" 0 "sem resultado"
dom "?eixo=mercados-externos" | grep -q 'id="filtros-vazio" hidden' && falha "estado vazio deveria aparecer" || ok "estado vazio aparece"
confere "?eixo=inexistente&tipo=xyz" 4 "filtro inválido no endereço: lista inteira"
dom "?eixo=inexistente" | grep -q 'id="filtros-vazio" hidden' && ok "filtro inválido não mostra estado vazio" || falha "filtro inválido mostrou estado vazio"
dom "" | grep -q 'data-filtros hidden' && falha "controles deveriam aparecer com JS" || ok "controles aparecem com JS"
dom "?eixo=setor-externo-e-cambio" | grep -Eq '1 texto encontrado\.' && ok "resultado anunciado no singular" || falha "anúncio do resultado"
fim
```

- [ ] **Passo 2: Acrescentar P3 ao `textos.ejs`**

Em `modelos-listing/textos.ejs`, troque a linha `<h2>Textos</h2>` por:

````text
<% const eixos = items[0].eixos || []; const tipos = items[0].tipos || []; %>
<h2>Textos</h2>
<div class="filtros" data-filtros hidden>
<div class="filtros__celular">
<label for="filtro-eixo">Filtrar por eixo</label>
<select id="filtro-eixo" data-filtro="eixo"><option value="">Todos os eixos</option><% for (const e of eixos) { %><option value="<%= slug(e) %>"><%= e %></option><% } %></select>
<label for="filtro-tipo">Filtrar por tipo</label>
<select id="filtro-tipo" data-filtro="tipo"><option value="">Todos os tipos</option><% for (const x of tipos) { %><option value="<%= slug(x) %>"><%= x %></option><% } %></select>
</div>
<div class="filtros__desktop">
<fieldset><legend>Filtrar por eixo</legend><div class="opcoes">
<label class="opcao"><input type="radio" name="filtro-eixo" value="" checked><span>Todos</span></label>
<% for (const e of eixos) { %><label class="opcao"><input type="radio" name="filtro-eixo" value="<%= slug(e) %>"><span><%= e %></span></label><% } %>
</div></fieldset>
<fieldset><legend>Filtrar por tipo</legend><div class="opcoes">
<label class="opcao"><input type="radio" name="filtro-tipo" value="" checked><span>Todos</span></label>
<% for (const x of tipos) { %><label class="opcao"><input type="radio" name="filtro-tipo" value="<%= slug(x) %>"><span><%= x %></span></label><% } %>
</div></fieldset>
</div>
<p class="acoes"><button type="button" class="botao botao--secundario" data-limpar>Limpar filtros</button></p>
<p class="filtros__resultado" id="filtros-resultado" role="status"></p>
</div>
````

Depois do `</ul>` da lista, antes de `<% } %>`, acrescente:

````text
<div class="filtros__vazio" id="filtros-vazio" hidden>
<p>Ainda não há textos com esses filtros. Limpe os filtros para ver todos os textos.</p>
<p class="acoes"><button type="button" class="botao botao--secundario" data-limpar>Limpar filtros</button></p>
</div>
````

- [ ] **Passo 3: Escrever `assets/js/filtros.js`**

```js
// Filtros de Publicações (spec 3.5): mostram os textos que atendem ao eixo E ao tipo
// escolhidos, com o estado no endereço (?eixo=…&tipo=…). Sem JavaScript, os controles
// ficam ocultos e a lista aparece inteira. Valor desconhecido no endereço = "todos".
(function () {
  function pronto(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }
  pronto(function () {
    var raiz = document.querySelector("[data-filtros]");
    if (!raiz) return;
    var itens = Array.prototype.slice.call(document.querySelectorAll(".lista-textos--filtravel .item-texto"));
    var vazio = document.getElementById("filtros-vazio");
    var resultado = document.getElementById("filtros-resultado");
    var campos = ["eixo", "tipo"];
    var validos = {};
    campos.forEach(function (c) {
      validos[c] = Array.prototype.map.call(raiz.querySelectorAll('select[data-filtro="' + c + '"] option'),
        function (o) { return o.value; });
    });

    function lerEndereco() {
      var p = new URLSearchParams(location.search);
      var e = {};
      campos.forEach(function (c) {
        var v = p.get(c) || "";
        e[c] = validos[c].indexOf(v) === -1 ? "" : v;
      });
      return e;
    }
    function gravarEndereco(e) {
      var p = new URLSearchParams(location.search);
      campos.forEach(function (c) { if (e[c]) p.set(c, e[c]); else p.delete(c); });
      var q = p.toString();
      history.replaceState(null, "", location.pathname + (q ? "?" + q : "") + location.hash);
    }
    function sincronizar(e) {
      campos.forEach(function (c) {
        raiz.querySelector('select[data-filtro="' + c + '"]').value = e[c];
        var r = raiz.querySelector('input[name="filtro-' + c + '"][value="' + e[c] + '"]');
        if (r) r.checked = true;
      });
    }
    function aplicar(e, gravar) {
      var n = 0;
      itens.forEach(function (li) {
        var mostra = (!e.eixo || li.getAttribute("data-eixo") === e.eixo) &&
                     (!e.tipo || li.getAttribute("data-tipo") === e.tipo);
        li.hidden = !mostra;
        if (mostra) n++;
      });
      vazio.hidden = n > 0;
      resultado.textContent = n === 1 ? "1 texto encontrado." : n + " textos encontrados.";
      sincronizar(e);
      if (gravar) gravarEndereco(e);
    }

    var estado = lerEndereco();
    raiz.hidden = false;
    raiz.addEventListener("change", function (ev) {
      var alvo = ev.target;
      var c = alvo.getAttribute("data-filtro") || (alvo.name || "").replace("filtro-", "");
      if (campos.indexOf(c) === -1) return;
      estado[c] = alvo.value;
      aplicar(estado, true);
    });
    document.querySelectorAll("[data-limpar]").forEach(function (b) {
      b.addEventListener("click", function () {
        estado = { eixo: "", tipo: "" };
        aplicar(estado, true);
        // O botão do estado vazio some ao limpar: o foco vai para o primeiro controle visível.
        var controles = raiz.querySelectorAll("select, input");
        for (var i = 0; i < controles.length; i++) {
          if (controles[i].offsetParent !== null) { controles[i].focus(); break; }
        }
      });
    });
    aplicar(estado, false);
  });
})();
```

- [ ] **Passo 4: Acrescentar ao SCSS a seção filtros**

```scss
// ---- Componente: filtros de Publicações (P3) --------------------------------
// Celular: duas listas suspensas. Desktop: botões de opção visíveis (cantos retos).
.filtros { margin: var(--esp-5) 0 var(--esp-6); }
.filtros label[for], .filtros legend {
  display: block;
  font-size: var(--fs-meta);
  font-weight: var(--peso-forte);
  margin-bottom: var(--esp-2);
}
.filtros select {
  width: 100%;
  min-height: var(--alvo-min);
  padding: 0 var(--esp-3);
  margin-bottom: var(--esp-4);
  border: 2px solid var(--azul-marinho);
  border-radius: var(--raio-0);
  background: var(--offwhite);
  color: var(--grafite);
  font: inherit;
}
.filtros fieldset { border: 0; padding: 0; margin: 0 0 var(--esp-4); }
.filtros__desktop { display: none; }
.opcoes { display: flex; flex-wrap: wrap; gap: var(--esp-2); }
.opcao { position: relative; margin: 0; }
.opcao input { position: absolute; opacity: 0; width: 1px; height: 1px; }
.opcao span {
  display: inline-flex;
  align-items: center;
  min-height: 2.75rem;
  padding: 0 var(--esp-4);
  border: 1px solid var(--azul-marinho);
  font-size: var(--fs-meta);
  cursor: pointer;
}
.opcao input:checked + span { background: var(--azul-marinho); color: var(--offwhite); font-weight: var(--peso-forte); }
.opcao input:focus-visible + span { outline: 3px solid var(--cor-foco); outline-offset: 3px; }
.filtros__resultado { font-size: var(--fs-meta); margin: var(--esp-3) 0 0 !important; }
.filtros__vazio { margin-top: var(--esp-5); }
@media (min-width: 992px) {
  .filtros__celular { display: none; }
  .filtros__desktop { display: block; }
}
```

- [ ] **Passo 5: Rodar os testes**

```bash
bash testes/rodar.sh 13
```

Esperado: `Tudo certo.`

- [ ] **Passo 6: Testar o teclado à mão**

```bash
python -m http.server 8000 -d _site-rascunhos
```

Abra `http://localhost:8000/publicacoes/` num Chrome normal, em 1280 px e em 390 px (DevTools). Só com o teclado: Tab chega aos controles; setas trocam o botão de opção; a lista muda; "Limpar filtros" funciona com Enter; o foco fica sempre visível. Ative um leitor de tela (Narrador do Windows: Ctrl+Win+Enter) e confira que "N textos encontrados." é lido ao trocar o filtro. Abra `http://localhost:8000/sobre.html`, clique em "Setor externo e câmbio" e confira que Publicações abre já filtrada.

- [ ] **Passo 7: Verificação visual e commit**

```bash
bash ferramentas/capturar.sh -s _site-rascunhos publicacoes-filtros=publicacoes/index.html "publicacoes-vazio=publicacoes/index.html?eixo=mercados-externos"
```

Compare com `wireframes/screenshots/publicacoes-*.png` (P3: listas no celular, botões no desktop).

```bash
git add modelos-listing/textos.ejs assets/js/filtros.js estilos/macroliga.scss testes/r13-filtros.sh testes/t13-filtros.sh
git commit -m "Adiciona os filtros por eixo e tipo em Publicações

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 14: Marco "site mínimo" (spec 6.1)

**Arquivos:**
- Criar: `ferramentas/conferir-links.py`, `testes/t14-marco.sh`, `testes/e14-marco.sh`, `LEIA-ME.md` (versão mínima)
- Modificar: os arquivos que a revisão apontar

**Interfaces:**
- Consome: todo o site.
- Produz: `python ferramentas/conferir-links.py <url-inicial>`, que sai com código 1 se algum link interno ou recurso der erro ou sair do subcaminho.

- [ ] **Passo 1: Escrever o conferidor de links**

`ferramentas/conferir-links.py`:

```python
"""Confere todos os links internos e recursos de um site servido localmente.

Uso: python ferramentas/conferir-links.py http://127.0.0.1:8772/macroliga/index.html
Percorre as páginas a partir do endereço dado, sem sair do prefixo dele, e lista os
links e recursos (href/src) que dão erro ou saem do subcaminho. Sai com código 1 se houver algum.
"""
import sys
from html.parser import HTMLParser
from urllib.error import HTTPError, URLError
from urllib.parse import urldefrag, urljoin, urlparse
from urllib.request import urlopen


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.encontrados = []

    def handle_starttag(self, tag, attrs):
        for nome, valor in attrs:
            if nome in ("href", "src") and valor:
                self.encontrados.append(valor)


def main():
    inicio = sys.argv[1]
    base = urlparse(inicio)
    prefixo = inicio.rsplit("/", 1)[0] + "/"
    fila, vistos, erros = [inicio], set(), []
    while fila:
        url = fila.pop()
        if url in vistos:
            continue
        vistos.add(url)
        try:
            with urlopen(url) as resposta:
                tipo = resposta.headers.get("Content-Type", "")
                corpo = resposta.read().decode("utf-8", "replace") if "html" in tipo else ""
        except (HTTPError, URLError) as erro:
            erros.append(f"{url}: {erro}")
            continue
        parser = Links()
        parser.feed(corpo)
        for bruto in parser.encontrados:
            alvo = urldefrag(urljoin(url, bruto))[0]
            p = urlparse(alvo)
            if p.scheme not in ("http", "https") or p.netloc != base.netloc:
                continue
            if not alvo.startswith(prefixo):
                erros.append(f"{url}: sai do subcaminho -> {bruto}")
                continue
            fila.append(alvo)
    print(f"{len(vistos)} endereços conferidos.")
    for e in erros:
        print("ERRO", e)
    sys.exit(1 if erros else 0)


if __name__ == "__main__":
    main()
```

- [ ] **Passo 2: Escrever os testes do marco**

`testes/t14-marco.sh`:

```bash
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
```

`testes/e14-marco.sh`:

```bash
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
curl -s http://127.0.0.1:8772/macroliga/404.html | grep -q 'href="/macroliga/index.html"' \
  && ok "404 com links sob /macroliga (funciona aberta de um endereço profundo)" || falha "404 sem o caminho do subcaminho"
curl -s http://127.0.0.1:8772/macroliga/404.html | grep -q 'href="/macroliga/site_libs/' \
  && ok "404 com CSS sob /macroliga" || falha "CSS da 404 fora do subcaminho"
kill $SERVIDOR
rm -rf capturas/servidor
fim
```

- [ ] **Passo 3: Rodar todos os testes**

```bash
bash testes/rodar.sh
```

Esperado: `Tudo certo.` em todos os arquivos, com no máximo o AVISO de `equipe.yml`.

- [ ] **Passo 4: Escrever o LEIA-ME mínimo**

`LEIA-ME.md` (para quem nunca usou Quarto):

````markdown
# Site da MacroLiga UFRGS

O site é feito com o [Quarto](https://quarto.org) e publicado no GitHub Pages. Não tem custo.

## Instalar (uma vez)

1. Instale o [Quarto](https://quarto.org/docs/get-started/) e o [Git](https://git-scm.com/downloads).
2. Para gráficos em R, instale também o R e, dentro dele, `install.packages(c("rmarkdown", "knitr", "ggplot2", "scales", "ragg", "systemfonts", "jsonlite"))`.
3. Baixe o repositório: `git clone https://github.com/macroliga-ufrgs/macroliga-ufrgs.github.io.git`.

## Ver o site no seu computador

No terminal, dentro da pasta do site:

```
quarto preview
```

O navegador abre o site. Cada vez que você salva um arquivo, a página se atualiza.

Para ver também o que ainda é rascunho (`draft: true`), como o fascículo antes do lançamento:

```
quarto preview --profile rascunhos
```

## Publicar

```
quarto publish gh-pages
```

Rascunhos nunca são publicados.

## Atualizar a equipe

Edite `equipe.yml`. Cada pessoa tem `nome`, `cargo` e `foto` (deixe a foto vazia até haver termo de uso de imagem). Os nomes dos eixos precisam ser iguais aos de `_variables.yml`.

## Abrir ou fechar o processo seletivo

No cabeçalho de `participe.qmd`, mude `selecao`:

```yaml
selecao:
  aberta: true
  prazo: "30 de outubro de 2026"
  formulario: "https://forms.gle/..."
```

Para fechar, volte `aberta` para `false`.

## Criar um evento

Copie a pasta `eventos/_modelo/` para `eventos/aaaa-mm-dd-nome-curto/` (minúsculas, sem acento, com hífens) e preencha o cabeçalho do `index.qmd`. A descrição vai abaixo do cabeçalho.

## Arquivos que não se mexem

`_quarto.yml`, `_brand.yml`, `filtros/`, `modelos-listing/`, `estilos/`, `assets/js/`, `ferramentas/`, `testes/` e os `_metadata.yml` são a maquinaria do site. Para mudar textos que se repetem (nome da publicação, e-mail, redes, questionário), edite `_variables.yml`.

## Se o render der erro

O site confere o cabeçalho de cada item. Se algo estiver errado, `quarto render` para com uma mensagem em português que começa com `[MacroLiga]`, diz qual arquivo e o que corrigir.
````

- [ ] **Passo 5: Capturar todas as páginas em todas as larguras**

```bash
bash ferramentas/capturar.sh -l "360 390 430 1280" inicio=index.html publicacoes=publicacoes/index.html eventos=eventos/index.html lancamento=eventos/2026-11-27-lancamento-n01/index.html sobre=sobre.html equipe=equipe.html participe=participe.html pagina404=404.html
bash ferramentas/capturar.sh -s _site-rascunhos -l "360 390 430 1280" fasciculo=publicacoes/n01/index.html texto=publicacoes/n01/impactos-setoriais-mercosul-ue/index.html publicacoes-rascunho=publicacoes/index.html
```

Faça a Verificação visual de cada uma (são 44 imagens). Liste os problemas por gravidade, corrija os graves, rode `bash testes/rodar.sh` de novo e recapture o que mudou.

- [ ] **Passo 6: Acessibilidade, desempenho e movimento**

```bash
python -m http.server 8000 -d _site >/dev/null 2>&1 & P=$!
for _ in $(seq 1 300); do curl -s -o /dev/null http://127.0.0.1:8000/ && break; done
npx --yes lighthouse@12 http://127.0.0.1:8000/index.html --only-categories=performance,accessibility \
  --form-factor=mobile --chrome-flags="--headless=new" --output=json --output-path=capturas/lh-inicio.json --quiet
python -c "import json; r=json.load(open('capturas/lh-inicio.json', encoding='utf-8')); c=r['categories']; print('Desempenho', round(c['performance']['score']*100), 'Acessibilidade', round(c['accessibility']['score']*100), 'Bytes', r['audits']['total-byte-weight']['numericValue'])"
kill $P
```

Esperado: Desempenho ≥ 90, Acessibilidade ≥ 90 e bytes ≤ 512000. Se os bytes passarem do limite, veja em `capturas/lh-inicio.json` (`audits.total-byte-weight.details.items`) o que pesa mais e reduza.

À mão, num Chrome normal servindo `_site/`:
- Tab desde o topo: o primeiro foco é "Pular para o conteúdo", que leva ao conteúdo; a ordem segue a leitura; o foco é sempre visível (off-white sobre azul, azul sobre off-white).
- Em 390 px, "Abrir menu" abre o menu, o rótulo vira "Fechar menu" e cada item tem 44 px ou mais.
- DevTools → Rendering → "Emulate CSS prefers-reduced-motion: reduce": recarregue a Início; o mapa já aparece aceso, sem animação.
- DevTools → Lighthouse/axe: nenhuma imagem sem `alt`; um único `h1` visível por página; landmarks `header`, `main`, `footer`.
- Servindo `_site-rascunhos/`, numa página de texto: "Copiar citação" aparece, copia a citação (cole num editor para conferir) e o Narrador lê "Citação copiada.".

- [ ] **Passo 7: Conferir a lista da spec 6.1 item a item**

Percorra `docs/spec-design.md`, seção 6.1, e marque cada item com a evidência (teste, captura ou conferência manual). Itens que dependem de publicação (site no ar, GoatCounter ativo, Post Inspector do LinkedIn) ficam para a fase 7 do PLANO-SITE; registre-os como pendentes. Mostre ao Miguel as capturas de todas as páginas, inclusive as de rascunho, e a lista conferida.

- [ ] **Passo 8: Commit**

```bash
git add ferramentas/conferir-links.py testes/t14-marco.sh testes/e14-marco.sh LEIA-ME.md
git commit -m "Confere o marco do site mínimo e adiciona o LEIA-ME

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 15: Gráficos comentados (até 22/11, D1)

**Arquivos:**
- Criar: `graficos/index.qmd`, `graficos/_metadata.yml`, `graficos/_modelo/index.qmd`
- Criar: `filtros/paginas/grafico.lua`, `filtros/paginas/graficos.lua`, `modelos-listing/graficos.ejs`, `modelos-listing/grafico-destaque.ejs`
- Modificar: `assets/graficos/tema_macroliga.R` (classe `preview-image` no `<img>` de `grafico_site()`), `index.qmd` (I3), `_quarto.yml` (menu), `estilos/macroliga.scss` (lista de gráficos), `testes/t14-marco.sh` (o menu passa a ter Gráficos)
- Testar: `testes/t15-graficos.sh`, `testes/e15-graficos.sh`

**Interfaces:**
- Consome: `grafico_site(g, alt)` de `assets/graficos/tema_macroliga.R`; `comum.graficos`; `.grafico*` (Tarefa 3); regras de gráfico do `validar.lua`; o id `i3` (já tratado em `inicio.lua`).
- Produz: os ids `lista-graficos`, `gc2-vazio` e `lista-grafico-destaque`.

- [ ] **Passo 1: Escrever os testes (falham primeiro)**

`testes/t15-graficos.sh`:

```bash
#!/usr/bin/env bash
# Tarefa 15: Gráficos comentados sem nenhum gráfico publicado.
source "$(dirname "$0")/lib.sh"
existe graficos/index.html "lista de gráficos"
tem graficos/index.html '<h1[^>]*>Gráficos comentados</h1>' "GC1 título"
tem graficos/index.html 'Um gráfico, um comentário e a fonte dos dados\.' "GC1 frase"
tem graficos/index.html 'O primeiro gráfico comentado ainda não saiu\.' "GC2 vazio"
tem index.html 'class="nav-link[^"]*" href="\./graficos/index\.html"' "Gráficos comentados no menu"
tem index.html 'id="i3"[^>]*hidden' "I3 oculto sem gráfico"
nao_existe graficos/_modelo "pasta-modelo ausente"
fim
```

`testes/e15-graficos.sh` (inclui o teste do freeze, ponto em aberto 1):

```bash
#!/usr/bin/env bash
# Tarefa 15: um gráfico de teste a partir do _modelo (precisa de internet para a série do BCB).
source "$(dirname "$0")/lib.sh"
G=graficos/2099-01-01-teste-freeze
criar_pasta "$G"
CRIADOS+=("_freeze/$G")
cp graficos/_modelo/index.qmd "$G/index.qmd"
quarto render "$G/index.qmd" index.qmd graficos/index.qmd > testes/.render-estado.log 2>&1 || { tail -20 testes/.render-estado.log; falha "render do gráfico de teste"; fim; }
[ -f "_freeze/$G/index/figure-html/grafico.png" ] && ok "freeze: grafico.png" || falha "freeze sem grafico.png"
[ -f "_freeze/$G/index/figure-html/grafico-celular.png" ] && ok "freeze: grafico-celular.png" || falha "freeze sem grafico-celular.png"
rm -rf "$G/index_files" "_site/$G"
QUARTO_R="C:/nao-existe/R.exe" quarto render "$G/index.qmd" > testes/.render-estado.log 2>&1
existe "$G/index_files/figure-html/grafico.png" "_site recebe grafico.png do freeze"
existe "$G/index_files/figure-html/grafico-celular.png" "_site recebe grafico-celular.png do freeze"
P="$G/index.html"
tem "$P" '<h1 class="titulo-longo">Juros já pesam 10% da renda das famílias</h1>' "GC3 título-afirmação"
tem "$P" '<source media="\(min-width: 768px\)" srcset="index_files/figure-html/grafico\.png"' "GC4 horizontal a partir de 768 px"
tem "$P" '<img class="preview-image" src="index_files/figure-html/grafico-celular\.png" alt="[^"]+"' "GC4 celular com alt"
tem "$P" 'Abrir o gráfico em tamanho maior' "GC4 ampliar"
tem "$P" 'Fonte: Banco Central do Brasil, série SGS 29034\. Elaboração: MacroLiga UFRGS\.' "GC5 fonte"
tem "$P" 'class="grafico__comentario"' "GC6 comentário"
tem "$P" 'href="\.\./index\.html">Ver todos os gráficos' "GC8"
tem "$P" '<meta property="og:image" content="[^"]*grafico' "og:image é o gráfico"
tem "$P" '<meta property="og:description" content="Comprometimento' "og:description é o subtítulo"
tem index.html 'id="i3"' "I3 aparece"
nao_tem index.html 'id="i3"[^>]*hidden' "I3 não oculto com gráfico"
tem index.html 'Juros já pesam 10% da renda das famílias' "I3 título"
tem graficos/index.html 'id="gc2-vazio"[^>]*hidden' "GC2 vazio oculto"
echo "-- validação"
trocar "$G/index.qmd" 's|^fonte: .*|fonte: ""|'
deve_falhar 'o campo "fonte" está vazio' "fonte vazia para o render" "$G/index.qmd"
desfazer
fim
```

- [ ] **Passo 2: Ajustar `grafico_site()` para a imagem de compartilhamento**

Em `assets/graficos/tema_macroliga.R`, na função `grafico_site()`, troque:

```r
    '<img src="', arquivos[["celular"]], '" alt="', escapar(alt),
```

por:

```r
    '<img class="preview-image" src="', arquivos[["celular"]], '" alt="', escapar(alt),
```

e acrescente ao comentário acima da função a linha `# A classe preview-image faz desta imagem a do Open Graph e da miniatura nas listas.` Não altere o original em `../Materiais/Graficos/`.

- [ ] **Passo 3: Escrever o `_metadata.yml` e o modelo**

`graficos/_metadata.yml`:

```yaml
# Maquinaria dos gráficos comentados (não mexa).
pagina: grafico
open-graph:
  description: "{{< meta subtitle >}}"
```

`graficos/_modelo/index.qmd`:

````markdown
---
# Para publicar um gráfico comentado: copie esta pasta para graficos/aaaa-mm-dd-slug/ e preencha.
# Regras dos gráficos: ../Materiais/Graficos/LEIA-ME.md. Comentário com até 150 palavras.
title: "Juros já pesam 10% da renda das famílias"       # o título afirma o fato
subtitle: "Comprometimento da renda com juros, em %, jan/2015 a ago/2026"   # unidade e período
author: "Nome Sobrenome"
date: 2026-11-10
eixo: "Atividade econômica, mercado de trabalho e crédito"
fonte: "Banco Central do Brasil, série SGS 29034"
---

```{r}
#| echo: false
source("../../assets/graficos/tema_macroliga.R")
dados <- sgs(29034, "01/01/2015")   # baixa a série do Banco Central (precisa de internet)
g <- ggplot(dados, aes(data, valor)) +
  geom_line(colour = cores_macroliga[["azul_marinho"]], linewidth = 0.9) +
  rotulos_finais(dados, "data", "valor", formato = pct_br(accuracy = 0.1), tamanho = 3.9) +
  scale_y_continuous(labels = pct_br()) +
  scale_x_date(expand = expansion(mult = c(0.01, 0.14))) +
  labs(x = NULL, y = NULL) +
  theme_macroliga(base_size = 12)
grafico_site(g, alt = "Gráfico de linha do comprometimento da renda das famílias com juros, de 2015 a 2026. O último dado está marcado em vermelho.")
```

Comentário de até 150 palavras. Descreva o que o gráfico mostra, com número, data e fonte. Explique o conceito por trás da série.
````

- [ ] **Passo 4: Escrever os templates e a página de lista**

`modelos-listing/graficos.ejs`:

````text
```{=html}
<% if (items.length > 0) { %>
<ul class="lista-graficos">
<% for (const g of items) { %>
<li class="item-grafico">
<% if (g.image) { %><img src="<%- g.image %>" alt="" loading="lazy"><% } %>
<div>
<h2 class="item-grafico__titulo"><a href="<%- g.path %>"><%= g.title %></a></h2>
<p class="item-grafico__dados"><%= g.date %></p>
<p class="item-grafico__dados">Eixo: <%= g.eixo %></p>
</div>
</li>
<% } %>
</ul>
<% } %>
```
````

`modelos-listing/grafico-destaque.ejs`:

````text
```{=html}
<% const g = items[0]; if (g) { %>
<h2 class="bloco__titulo">Gráfico comentado</h2>
<% if (g.image) { %><a href="<%- g.path %>" tabindex="-1" aria-hidden="true"><img class="grafico-destaque__imagem" src="<%- g.image %>" alt=""></a><% } %>
<h3 class="grafico-destaque__titulo"><a href="<%- g.path %>"><%= g.title %></a></h3>
<p class="acoes"><a class="botao botao--secundario" href="<%- g.path %>">Ler o comentário</a></p>
<% } %>
```
````

`graficos/index.qmd`:

```markdown
---
title: "Gráficos comentados"
pagina: graficos
description: "Um gráfico, um comentário e a fonte dos dados: a versão web do formato-assinatura da MacroLiga UFRGS."
open-graph:
  description: "Um gráfico, um comentário e a fonte dos dados."
listing:
  id: lista-graficos
  contents: "*/index.qmd"
  template: ../modelos-listing/graficos.ejs
  sort: "date desc"
  date-format: "D [de] MMMM [de] YYYY"
---

:::: {.conteiner .pagina .graficos}
# Gráficos comentados

::: {.pagina__intro}
Um gráfico, um comentário e a fonte dos dados.
:::

::: {#lista-graficos}
:::

::: {#gc2-vazio .estado-vazio}
O primeiro gráfico comentado ainda não saiu. Siga [{{< var contato.instagram >}}]({{< var contato.instagram-url >}}) para ver quando for publicado.
:::
::::
```

- [ ] **Passo 5: Escrever os montadores**

`filtros/paginas/graficos.lua`:

```lua
-- filtros/paginas/graficos.lua: lista de gráficos (spec 2.6): oculta o estado vazio quando há gráfico.
return function(doc, comum)
  if #comum.graficos(true) > 0 then doc.blocks = comum.ocultar(doc.blocks, { ["gc2-vazio"] = true }) end
  return doc
end
```

`filtros/paginas/grafico.lua`:

```lua
-- filtros/paginas/grafico.lua: página de um gráfico comentado (spec 2.7).
-- Ordem igual à do post no Instagram: título, gráfico, fonte, comentário.
local function tem_figura(bloco)
  if bloco.t == "Figure" then return true end
  local html = pandoc.write(pandoc.Pandoc({ bloco }), "html")
  return html:find("grafico__figura", 1, true) ~= nil or html:find("<img", 1, true) ~= nil
end

return function(doc, comum)
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local figura, comentario = nil, pandoc.Blocks({})
  for _, b in ipairs(doc.blocks) do
    if not figura and tem_figura(b) then figura = b else comentario:insert(b) end
  end
  if not figura then
    comum.parar('Gráfico "' .. comum.texto(y.title) .. '" (' .. comum.relativo(quarto.doc.input_file)
      .. '): falta o gráfico. Use grafico_site(g, alt = "...") ou uma imagem com texto alternativo.')
  end
  if figura.t == "Figure" or not pandoc.write(pandoc.Pandoc({ figura }), "html"):find("grafico__figura", 1, true) then
    local img
    figura:walk({ Image = function(i) img = img or i end })
    local alt = img and (img.attributes["fig-alt"] or pandoc.utils.stringify(img.caption)) or ""
    if not img or alt == "" then
      comum.parar('Gráfico "' .. comum.texto(y.title) .. '": a imagem precisa de texto alternativo (fig-alt).')
    end
    figura = comum.html('<figure class="grafico__figura"><img class="preview-image" src="' .. comum.esc(img.src)
      .. '" alt="' .. comum.esc(alt) .. '"></figure>\n<a class="grafico__ampliar" href="' .. comum.esc(img.src)
      .. '">Abrir o gráfico em tamanho maior</a>')
  end

  local blocos = pandoc.Blocks({
    comum.html(table.concat({
      '<article class="grafico">',
      '<h1 class="titulo-longo grafico__titulo">' .. comum.esc(comum.texto(y.title)) .. '</h1>',
      '<p class="grafico__subtitulo">' .. comum.esc(comum.texto(y.subtitle)) .. '</p>',
      '<p class="grafico__assinatura">' .. comum.esc(comum.texto(y.author)) .. '. ' .. comum.esc(comum.data_extenso(y.date)) .. '.</p>',
    }, "\n")),
    figura,
    comum.html('<p class="grafico__fonte">Fonte: ' .. comum.esc(comum.texto(y.fonte)) .. '. Elaboração: MacroLiga UFRGS.</p>'),
    pandoc.Div(comentario, pandoc.Attr("", { "grafico__comentario" })),
    comum.html('<p class="grafico__assinatura"><strong>Eixo:</strong> ' .. comum.esc(comum.texto(y.eixo)) .. '</p>\n</article>'),
  })
  local q = comum.questionario(doc.meta, "Leu este gráfico comentado? Conte o que achou em um questionário curto. As respostas ajudam a avaliar o projeto de extensão.", comum.texto(y.title))
  if q then blocos:insert(q) end
  blocos:insert(comum.aviso_institucional())
  blocos:insert(comum.html('<p class="acoes"><a class="botao botao--secundario" href="../index.qmd">Ver todos os gráficos</a></p>'))
  doc.blocks = pandoc.Blocks({ pandoc.Div(blocos, pandoc.Attr("", { "conteiner", "pagina", "pagina-grafico" })) })
  return doc
end
```

- [ ] **Passo 6: Ligar I3, o menu e o SCSS**

Em `index.qmd`, acrescente ao `listing:` do cabeçalho:

```yaml
  - id: lista-grafico-destaque
    contents: "graficos/*/index.qmd"
    template: modelos-listing/grafico-destaque.ejs
    sort: "date desc"
    max-items: 1
```

e, dentro de `::::: {.inicio__lateral}`, antes de `:::: {#i4 .inicio__evento}`, acrescente:

```markdown
:::: {#i3 .inicio__grafico}
::: {#lista-grafico-destaque}
:::
::::
```

No menu do `_quarto.yml`, depois de Publicações:

```yaml
      - text: "Gráficos comentados"
        href: graficos/index.qmd
```

Em `testes/t14-marco.sh`, apague as duas linhas `nao_tem index.html 'Gráficos comentados' ...` e `nao_existe graficos ...`.

Acrescente ao SCSS:

```scss
// ---- Componente: lista de gráficos (GC2, I3) --------------------------------
.lista-graficos { list-style: none; padding: 0; margin: 0; border-bottom: var(--linha-eixo); max-width: none !important; }
.item-grafico { display: grid; grid-template-columns: 7rem minmax(0, 1fr); gap: var(--esp-4); align-items: start; padding-block: var(--esp-5); border-top: var(--linha-grade); }
.item-grafico img { border: var(--linha-grade); }
.item-grafico__titulo { font-size: var(--fs-h3); font-weight: var(--peso-h3); line-height: 1.3; margin: 0 !important; }
.item-grafico__titulo a, .grafico-destaque__titulo a { text-decoration: none; }
.item-grafico__titulo a:hover, .grafico-destaque__titulo a:hover { text-decoration: underline 1px; }
.item-grafico__dados { font-size: var(--fs-meta); margin: var(--esp-1) 0 0 !important; }
.inicio__grafico { border-top: var(--linha-eixo); padding-top: var(--esp-5); }
.grafico-destaque__imagem { border: var(--linha-grade); margin-bottom: var(--esp-3); }
.grafico-destaque__titulo { font-size: var(--fs-h3); font-weight: var(--peso-h3); line-height: 1.3; }
.inicio__grafico .acoes { margin-top: var(--esp-3); }
.pagina-grafico .grafico__comentario p { margin: 0 0 var(--esp-4); }
@media (min-width: 992px) { .item-grafico { grid-template-columns: 15rem minmax(0, 1fr); gap: var(--esp-6); } }
```

- [ ] **Passo 7: Rodar todos os testes**

```bash
bash testes/rodar.sh
```

Esperado: `Tudo certo.` em todos os arquivos. O `e15` precisa de internet (série do BCB). Se a API do BCB estiver fora do ar, rode de novo mais tarde; não troque o modelo. Se o freeze não guardar as imagens ou elas não chegarem a `_site/`, aplique a saída aprovada (ponto em aberto 1): em `grafico_site()`, troque `pasta <- if (...) dirname(knitr::fig_path()) else "."` por `pasta <- "."`, acrescente `resources: ["graficos/*/grafico*.png"]` ao `project:` do `_quarto.yml` e commite os PNG de cada gráfico.

- [ ] **Passo 8: Verificação visual e commit**

Com o gráfico de teste temporário (o `e15` o apaga no fim), gere as capturas:

```bash
mkdir -p graficos/2099-01-01-teste-freeze && cp graficos/_modelo/index.qmd graficos/2099-01-01-teste-freeze/
quarto render
bash ferramentas/capturar.sh grafico=graficos/2099-01-01-teste-freeze/index.html graficos=graficos/index.html inicio=index.html
rm -rf graficos/2099-01-01-teste-freeze _freeze/graficos/2099-01-01-teste-freeze && quarto render
```

Confira contra a seção "Gráfico comentado" de `capturas/prancha-*.png`: o gráfico é o herói; versão 4:5 em 390 px e horizontal em 1280 px; texto do gráfico com cerca de 15 px nas duas; último dado em vermelho; fonte logo abaixo; I3 aparece na coluna lateral da Início, acima do I4.

```bash
git add graficos filtros/paginas/grafico.lua filtros/paginas/graficos.lua modelos-listing/graficos.ejs modelos-listing/grafico-destaque.ejs assets/graficos/tema_macroliga.R index.qmd _quarto.yml estilos/macroliga.scss testes/t14-marco.sh testes/t15-graficos.sh testes/e15-graficos.sh
git status --short _freeze | grep 2099 && echo "PARE: freeze do teste no stage" || true
git commit -m "Adiciona Gráficos comentados com a pasta-modelo em R

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Tarefa 16: LEIA-ME completo e teste do aluno (spec 6.2)

**Arquivos:**
- Modificar: `LEIA-ME.md`

- [ ] **Passo 1: Completar o LEIA-ME**

Acrescente a `LEIA-ME.md`, antes de "Arquivos que não se mexem":

````markdown
## Publicar um texto

1. Copie a pasta `publicacoes/_modelo-texto/` para dentro da pasta do fascículo (ex.: `publicacoes/n02/`).
2. Renomeie a cópia com um nome curto: minúsculas, sem acento, com hífens (ex.: `inflacao-de-servicos`).
3. Abra o `index.qmd` da cópia e preencha o cabeçalho. Escreva o `eixo` e o `tipo` exatamente como em `_variables.yml`.
4. Rode `quarto preview --profile rascunhos` e confira a página.

## Criar um fascículo

1. Copie `publicacoes/_modelo-fasciculo/` para `publicacoes/nNN/` (dois dígitos: `n02`, `n03`).
2. Ponha a capa nessa pasta com o nome `capa.png` e preencha o cabeçalho.
3. Anuncie o fascículo em `publicacoes/em-breve.yml`, com os títulos e autores, enquanto ele não sai.

## No dia do lançamento

1. Deposite os PDFs no Zenodo e anote os DOIs.
2. Copie `fasciculo.pdf` para a pasta do fascículo e cada `texto.pdf` para a pasta do texto.
3. Preencha os campos `doi` (do fascículo e, se houver, de cada texto).
4. Apague a linha `draft: true` do fascículo e de cada texto.
5. Em `publicacoes/em-breve.yml`, apague os itens e deixe só `[]`.
6. Confira com `quarto preview` (sem perfil: agora tudo é publicado) e publique com `quarto publish gh-pages`.

## Depois de um evento

1. No `index.qmd` do evento, troque `situacao: "proximo"` por `situacao: "realizado"`.
2. Ponha uma foto de capa na pasta do evento (ex.: `capa.jpg`), preencha `capa` e `capa-alt` (a descrição da foto).
3. Em `fotos`, ponha o link do álbum da liga.

## Publicar um gráfico comentado

1. Copie `graficos/_modelo/` para `graficos/aaaa-mm-dd-slug/`.
2. Preencha o cabeçalho: o título afirma o fato; o subtítulo traz unidade e período.
3. Ajuste o bloco de código R (série, rótulos e o texto `alt`, que é obrigatório) e escreva o comentário (até 150 palavras).
4. Rode `quarto render` no seu computador, com R instalado. A pasta `_freeze/` guarda o resultado: commite-a junto, para que a publicação não precise de R.

## Mensagens de erro comuns

| Mensagem | O que fazer |
|---|---|
| `o eixo "..." não existe` | Copie o nome do eixo de `_variables.yml`, com as mesmas maiúsculas e acentos. |
| `o campo "..." está vazio` | Preencha o campo indicado no cabeçalho do `index.qmd`. |
| `o arquivo "texto.pdf" (campo "pdf") não está na pasta ...` | Copie o PDF para a pasta indicada ou devolva `draft: true`. |
| `falta o DOI` | Preencha `doi` no texto ou no fascículo. |
````

- [ ] **Passo 2: Teste do aluno**

Peça a alguém da Comunicação que nunca usou Quarto que, seguindo só o LEIA-ME: crie um texto de teste em `publicacoes/n01/`, escreva um eixo errado de propósito, leia a mensagem, corrija e veja o texto no `quarto preview --profile rascunhos`. Anote as dúvidas e ajuste o LEIA-ME onde a pessoa travou. Apague o texto de teste no fim.

- [ ] **Passo 3: Commit**

```bash
git add LEIA-ME.md
git commit -m "Completa o LEIA-ME com lançamento, eventos e gráficos

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

## Cobertura da spec

| Spec | Tarefa |
|---|---|
| 2.1 / 4.1 G1 cabeçalho, menu, `aria-current`, Abrir/Fechar menu, 44 px | 2 (menu.js), 3 (SCSS), 5–9 e 15 (itens de menu), 14 (manual) |
| 2.2 Início I1–I6 | 4 (I1, I2, I4, I5, I6), 9 (I4 com evento), 12 (I2 publicado), 15 (I3) |
| 2.3 Publicações P1–P4 | 8 (P1, P2, P4), 12 (P4 no perfil rascunhos), 13 (P3) |
| 2.4 Fascículo F1–F6 | 11, 12 (F3 preenchido) |
| 2.5 Texto T1–T11, "Como citar" | 12 |
| 2.6–2.7 Gráficos GC1–GC8 | 15 |
| 2.8–2.9 Eventos EV1–EV3, EVP1–EVP3 | 9 |
| 2.10 Sobre, 2.11 Equipe, 2.12 Participe, 2.13 404 | 5, 6, 7, 10 |
| 3.2 Pastas, 3.3 cabeçalhos, pastas-modelo | 9, 11, 12, 15 |
| 3.4 Listings (I2, I3, I4, P2, P4, F3, T10, GC2, EV2, EV3) e rascunhos | 4, 8, 9, 11, 12, 15; 2 (perfil e pós-render) |
| 3.5 Filtros | 8 (data-*), 13 |
| 3.6 Validação | 2 (código), 9, 11, 12, 15 (testes) |
| 3.7 `_variables.yml`, questionário com `campo-pagina` | 1, 11 (teste do campo da página) |
| 4.3 Rodapé, 4.4 GoatCounter, 4.5 Open Graph, 4.6 subcaminho | 3, 2, 2/9/11/12/15, 14 |
| 5 Princípios visuais | Verificação visual em toda tarefa; 14 |
| 6.1 Site mínimo | 14 |
| 6.2 Publicações e gráficos até 22/11 | 12, 13, 15, 16 |
