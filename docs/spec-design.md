# Spec de design: site da MacroLiga UFRGS

- **Status:** aprovada na conversa de brainstorming de 03/10/2026; aguarda revisão do texto escrito.
- **Fontes:** `CLAUDE.md`, `PLANO-SITE.md`, `conteudo/textos-base.md` e os wireframes aprovados em `wireframes/` (Início = antiga alternativa B).
- **Próxima etapa:** direção visual com a skill `frontend-design` (`docs/design-tokens.md` + `design/prancha.html`) e, depois, o plano de implementação.

Restrições que esta spec não discute: Quarto + GitHub Pages, custo zero, marca fixa (CLAUDE.md, seção 6) e manutenção por alunos sem experiência em web.

---

## 0. Decisões tomadas nesta spec

| # | Decisão |
|---|---|
| D1 | **Gráficos comentados** entram até 22/11, junto com Publicações (resolve a decisão 4 do CLAUDE.md). Até lá, o item de menu e o bloco I3 não aparecem. |
| D2 | **Publicações e Eventos** entram no ar em 18/10, em versão simples (estado "em breve" e lançamento com data a confirmar). |
| D3 | **Fascículo nº 1 e os 4 textos** são construídos já para 18/10, como **rascunho** (`draft: true`): completos no `quarto preview`, ausentes do site publicado. |
| D4 | **Inscrição em eventos** é por link para o Google Forms, nunca embutida. |
| D5 | **DOI:** o campo `doi` é opcional no texto; vazio, o texto herda o DOI do fascículo. A decisão editorial (decisão 2 do CLAUDE.md) fica para novembro sem mudar o modelo. |
| D6 | **Abordagem técnica:** listings do Quarto + templates EJS próprios + um script pequeno (`assets/js/filtros.js`) para combinar os filtros de eixo e tipo. O campo `categories` sai do modelo de texto. |
| D7 | **Nota de responsabilidade autoral** ("As opiniões expressas são de responsabilidade de quem assina o texto.") aparece em **todo** texto, não só em Texto de opinião. |
| D8 | **Eventos** aceitam qualquer tipo de evento. O que é específico de lançamento só aparece quando o campo `fasciculo` está preenchido. Não há campo de tipo de evento. |
| D9 | **Fotos de eventos** ficam em álbum externo da conta da liga. O repositório guarda só uma foto de capa por evento. |
| D10 | **Busca** do Quarto fica fora da 1ª versão. |
| D11 | **Contagem de visitas:** GoatCounter, sem cookies e sem banner. |

---

## 1. Páginas: objetivo, públicos e marco

Públicos (CLAUDE.md, seção 2): (1) estudantes da FCE, (2) calouros e cursos próximos, (3) professores e pesquisadores, (4) comunidade externa.

| Página | Objetivo: o que a pessoa precisa conseguir | Públicos | No ar em |
|---|---|---|---|
| Início | Em 10 segundos, entender o que é a liga e chegar ao fascículo mais recente. A maioria chega pelo link da bio do Instagram. | 2, 1, 4 | 18/10 |
| Publicações | Encontrar qualquer texto por eixo e tipo e chegar ao PDF. | 1, 3, 4 | 18/10 (simples); 22/11 (completa) |
| Fascículo | Ver o sumário, baixar o fascículo inteiro e responder ao questionário. | 1, 4 | rascunho em 18/10; publicado no lançamento |
| Texto | Decidir se vale ler (síntese), baixar o PDF, citar e confiar (revisão docente). | 3, 1, 4 | rascunho em 18/10; publicado no lançamento |
| Gráficos comentados (lista e página) | Ver a versão web do formato-assinatura das redes: gráfico, comentário e fonte. | 2, 4 | 22/11 |
| Eventos (lista e página do evento) | Saber do próximo evento e se inscrever; ver o que já aconteceu. A página do evento é o link divulgado nas redes. | 1, 2 | 18/10 |
| Sobre | Avaliar a seriedade: processo em 4 etapas, regra da pluralidade, vínculo com a extensão. | 3, 2 | 18/10 |
| Equipe | Ver quem faz a liga: Conselho Executivo, membros e fundadores. | 1, 3 | 18/10 |
| Participe | Virar membro ou autor: quem pode entrar, seleção, modelos. | 1, 2 | 18/10 |
| 404 | Não se perder: voltar ao início ou às publicações. | todos | 18/10 |

Não há página Contato: o rodapé (G2) e o bloco PA5 cumprem esse papel.

**Site publicado em 18/10:** Início, Publicações (estado "em breve"), Eventos, página do evento de lançamento, Sobre, Equipe, Participe e 404. Nenhum botão do site publicado leva a página inexistente ou vazia.

**No dia do lançamento do nº 1** (semana de 23/11, ref. 27/11): o fascículo e os textos deixam de ser rascunho.

---

## 2. Estrutura final por bloco

Os blocos são os dos wireframes aprovados; esta seção registra o que eles não dizem: estados, condições e origem de cada dado. Textos fixos vêm de `conteudo/textos-base.md`.

### 2.1 Comuns a todas as páginas

- **G1 cabeçalho** e **G2 rodapé**: ver seção 4.

### 2.2 Início (`index.qmd`, `page-layout: custom` se necessário)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| I1 | Abertura com grade de pontos em bloco azul-marinho; frase "A conjuntura brasileira, explicada pela teoria."; subtítulo; 2 botões. | Botão principal: com fascículo publicado, "Ler o fascículo nº {n}" (leva ao fascículo); antes disso, "Ver os textos do nº 1" (âncora para I2). Segundo botão: "Ver como funcionamos" (âncora para I5). Os pontos se acendendo em sequência são o único movimento do site. |
| I2 | Fascículo mais recente: capa, "{nome} nº {n}", frase "{data}. {quantidade} textos sobre a economia brasileira, revisados por professores da FCE.", lista dos textos, botões "Ler o fascículo" e "Ver todos os fascículos". | Mostra o último fascículo publicado. Se nenhum estiver publicado, mostra o estado "em breve" lido de `publicacoes/em-breve.yml`: título "Fascículo nº {n}: em breve", texto de textos-base 1, lista de títulos e autores sem link, botão "Seguir @macroliga.ufrgs para saber do lançamento". A quantidade de textos é contada automaticamente. |
| I3 | Último gráfico comentado: miniatura, título-afirmação, "Ler o comentário". | Só aparece com pelo menos 1 gráfico publicado. Enquanto não aparece, I4 ocupa a coluna lateral sozinho. |
| I4 | Próximo evento: nome (link para a página do evento), data, horário e local, ação de inscrição. | Ação conforme `inscricao` (seção 3.3.4). Sem evento com `situacao: proximo`: estado vazio "Nenhum evento agendado. Siga @macroliga.ufrgs para saber do próximo." |
| I5 | "Todo texto passa pelas mesmas quatro etapas": 4 etapas numeradas, ligadas por linha com pontos; botão "Ler sobre a liga". | Fixo. |
| I6 | "Acompanhe a liga": frase + "Seguir no Instagram" e "Seguir no LinkedIn". | Links de `_variables.yml`. |

### 2.3 Publicações (`publicacoes/index.qmd`)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| P1 | Título "Publicações" + "Textos curtos de estudantes de graduação, revisados por professores da FCE e reunidos em fascículos numerados. Todos têm DOI e podem ser citados." | Fixo. |
| P2 | Fascículos do mais recente ao mais antigo: capa, "{nome} nº {n}", data, quantidade de textos, "Ler o fascículo". | Se `em-breve.yml` tiver item, ele aparece como "Fascículo nº {n}: em breve", com o aviso de textos-base 5.2 e a lista de títulos sem link. |
| P3 | Filtros: "Filtrar por eixo" (6) e "Filtrar por tipo" (4), "Limpar filtros". Celular: duas listas suspensas. Desktop: botões de opção visíveis. | Oculto enquanto não houver texto publicado. Comportamento na seção 3.5. |
| P4 | Lista de todos os textos: título (é o link para o texto), autor, fascículo, tipo, eixo. Lista, não grade de cards. | Oculto enquanto não houver texto publicado. Ordem: fascículo mais recente primeiro; dentro dele, `ordem`. Filtros sem resultado: estado vazio de textos-base 5.2 com botão "Limpar filtros". |

### 2.4 Fascículo (`publicacoes/nNN/index.qmd`)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| F1 | Trilha "Publicações / Fascículo nº {n}". | — |
| F2 | Capa, "{nome} nº {n}" (maior texto da página), "Publicado em: {data}", "{quantidade} textos, revisados por professores da FCE", DOI, "Baixar PDF" e "Abrir no Zenodo". | No celular, "Baixar PDF" fica visível sem rolar (390 × 700). Sem PDF: "O PDF fica disponível no lançamento do fascículo." |
| F3 | "Sumário": cada texto com título (é o link para o texto), autor, tipo e eixo. | Automático, pelas pastas de texto, em ordem de `ordem`. |
| F4 | "Lançamento": frase + link para a página do evento ("Ver as fotos" quando realizado). | Só aparece se o campo `evento` estiver preenchido. |
| F5 | Questionário: "Leu este fascículo? Conte o que achou em um questionário curto. As respostas ajudam a avaliar o projeto de extensão." + "Responder ao questionário". | Obrigatório (indicador da extensão). Regras na seção 3.7. |
| F6 | "Os textos publicados não representam a posição da MacroLiga UFRGS, da FCE ou da UFRGS." | Fixo. |

### 2.5 Texto (`publicacoes/nNN/<slug>/index.qmd`)

O texto completo vive no PDF; a página é a porta de entrada. **O aluno preenche só o YAML; a página inteira é montada a partir dele.**

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| T1 | "Voltar ao fascículo nº {n}". | — |
| T2 | Tipo de texto, título (maior texto da página), autor. | — |
| T3 | "Baixar PDF" e "Abrir no Zenodo". | Celular: logo abaixo de T2, antes da síntese. Desktop: coluna lateral fixa com os metadados (autor, tipo, eixo, fascículo, publicado em, revisão, DOI). |
| T4 | Síntese (campo `sintese`). | — |
| T5 | "As opiniões expressas são de responsabilidade de quem assina o texto." | **Fixa em todo texto** (D7). |
| T6 | "Texto revisado por {revisao}. A revisão docente não implica concordância do revisor com o conteúdo. A responsabilidade pelo texto é de quem o assina." | Fixa. |
| T7 | "Como citar" (ABNT) + "Copiar citação"; confirmação "Citação copiada." anunciada a leitores de tela. | Gerada automaticamente (regra abaixo). |
| T8 | Questionário: "Leu este texto? …" + "Responder ao questionário". | Obrigatório. Regras na seção 3.7. |
| T9 | Metadados em lista, no celular, depois do questionário. | Só celular. |
| T10 | "Outros textos do fascículo nº {n}": título + autor. | Automático: textos da mesma pasta de fascículo, menos o próprio, em ordem de `ordem`. |
| T11 | Aviso de posição institucional (igual a F6). | Fixo. |

**Regra do "Como citar":**

```
SOBRENOME, Nome. Título do texto. **{nome da publicação}**, Porto Alegre, n. {fasciculo}, {mês abreviado} {ano}. DOI: {doi}.
```

- Autor: a última palavra do `author` vira o sobrenome em caixa alta ("Miguel Amorin" → "AMORIN, Miguel"). Para sobrenome composto, o campo opcional `autor-citacao` substitui a regra ("SILVA, Leonardo Xavier da").
- Mês abreviado (ABNT): jan., fev., mar., abr., maio, jun., jul., ago., set., out., nov., dez.
- DOI: o do texto; se vazio, o do fascículo (D5).

### 2.6 Gráficos comentados (`graficos/index.qmd`)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| GC1 | Título "Gráficos comentados" + "Um gráfico, um comentário e a fonte dos dados." | Fixo. |
| GC2 | Lista do mais recente ao mais antigo: miniatura, título-afirmação, data, eixo. Lista, não grade de cards. | Vazia: "O primeiro gráfico comentado ainda não saiu. Siga @macroliga.ufrgs para ver quando for publicado." |

### 2.7 Gráfico comentado (`graficos/aaaa-mm-dd-slug/index.qmd`)

Ordem no celular igual à do post no Instagram: título, gráfico, fonte, comentário.

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| GC3 | Título-afirmação (o fato; maior texto da página), subtítulo com unidade e período, autor, data. | — |
| GC4 | O gráfico (chunk R com `tema_macroliga.R`, ou PNG pronto) + "Abrir o gráfico em tamanho maior" (link para a imagem). | `fig-alt` (ou `alt`) obrigatório. O gráfico é o herói da página. |
| GC5 | "Fonte: {fonte}. Elaboração: MacroLiga UFRGS." | Campo `fonte`. |
| GC6 | Comentário (até 150 palavras; regra editorial do LEIA-ME, não aparece no site). | Corpo do `.qmd`. |
| GC7 | Questionário. | Mesmas regras de T8. |
| GC8 | Aviso de posição institucional + "Ver todos os gráficos". | Fixo. |

### 2.8 Eventos (`eventos/index.qmd`)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| EV1 | Título "Eventos" + "Lançamentos de fascículos, debates e outros encontros promovidos pela liga." | Fixo. |
| EV2 | "Próximos eventos": data em destaque, nome (link para a página), horário e local, frase curta, ação de inscrição. | Eventos com `situacao: proximo`, do mais próximo ao mais distante. Vazio: "Nenhum evento agendado. Siga @macroliga.ufrgs para saber do próximo." |
| EV3 | "Eventos passados": foto de capa, nome, data e local, "Ver as fotos" e, se for lançamento, "Ler o fascículo". | Eventos com `situacao: realizado`, do mais recente ao mais antigo. Vazio: "Ainda não realizamos eventos. O primeiro será o lançamento do fascículo nº 1." |

### 2.9 Evento (`eventos/aaaa-mm-dd-slug/index.qmd`)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| EVP1 | "Voltar aos eventos". | — |
| EVP2 | Nome, data (ou `quando`), horário, local, descrição (corpo do `.qmd`). | Com `fasciculo` preenchido: lista dos textos do fascículo e espaço para os debatedores na descrição. Nenhum template escreve "FCE/UFRGS" fixo: o local vem sempre do campo. |
| EVP3 | Ação. | Evento próximo: ação de inscrição (seção 3.3.4). Evento realizado: foto de capa, "Ver as fotos" (se `fotos`) e "Ler o fascículo" (se `fasciculo`). |

### 2.10 Sobre (`sobre.qmd`)

S1 a S5 como no wireframe, com o texto de textos-base 2. S2 numera as 4 etapas (sequência real). S3 lista os 6 eixos, cada um com link para Publicações filtrada (`publicacoes/?eixo={slug}`). S4 (regra da pluralidade) é bloco em azul-marinho. O selo fica ao lado de S1 no desktop e em S5 no celular.

### 2.11 Equipe (`equipe.qmd` + `equipe.yml`)

| Bloco | Conteúdo | Estados e regras |
|---|---|---|
| EQ1 | Título "Equipe" + "Cerca de 15 estudantes de graduação da UFRGS. O Conselho Executivo coordena o trabalho e decide em conjunto, sem hierarquia formal entre seus integrantes." | Fixo. |
| EQ2 | Conselho Executivo: nome + cargo. A presidência vem primeiro, com o mesmo peso visual dos demais; o cargo é "Presidente", "Conselheira" ou "Conselheiro", conforme o campo `genero`. | De `equipe.yml`. Campo `foto` opcional em todas as seções: quando preenchido (depois do termo de uso de imagem, decisão 5), a foto quadrada aparece acima do nome. O render para se houver mais de um `presidente: true` ou um `genero` fora da lista. Seção vazia não aparece. |
| EQ3 | Membros (sem posição no conselho): só o nome. | De `equipe.yml`. |
| EQ4 | Membros fundadores + "Quem criou a MacroLiga UFRGS." | De `equipe.yml`. Lista permanente: um nome pode se repetir no conselho ou entre os membros. |
| EQ5 | "A liga reúne estudantes de graduação da UFRGS pertencentes a qualquer curso." + "Ver como participar". | Fixo. |

A coordenação aparece só em G2 e S5; os revisores, em T6.

### 2.12 Participe (`participe.qmd`)

PA1 a PA5 como no wireframe, com o texto de textos-base 3. A situação da seleção fica no cabeçalho de `participe.qmd`:

```yaml
selecao:
  aberta: false
  prazo: ""          # "30 de outubro de 2026"
  formulario: ""     # link do Google Forms
```

- Fechada: PA2 mostra "Não há processo seletivo aberto agora. Siga @macroliga.ufrgs para saber do próximo."
- Aberta: "Inscrições abertas até {prazo}." + "Fazer inscrição no processo seletivo", e esse botão sobe para logo abaixo de PA1.
- PA4: "Baixar modelo em Word" e "Baixar modelo em LaTeX", com os arquivos de `modelos/` (caminhos em `_variables.yml`).
- PA5: e-mail, "Escrever para a liga" e "Seguir no Instagram".

### 2.13 404 (`404.qmd`)

- E1: "Página não encontrada" + "Não encontramos esta página. O endereço pode ter mudado." + "Voltar ao início" e "Ver as publicações".
- Os links funcionam quando a 404 é servida a partir de um endereço profundo e sob o subcaminho `ufrgs.br/macroliga`.

---

## 3. Modelo de conteúdo em Quarto

### 3.1 Princípio

O cabeçalho YAML que o aluno preenche contém **só campos de conteúdo**. Configuração de listings, filtros e templates fica em arquivos de maquinaria (`_quarto.yml`, `_brand.yml`, `_metadata.yml` de cada pasta, `modelos-listing/`, `filtros/`, `assets/js/`, `estilos/`), que o LEIA-ME marca como "não mexa". Publicar um item novo é copiar a pasta `_modelo` correspondente e preencher o cabeçalho.

### 3.2 Pastas

```
site/
├── _quarto.yml                 maquinaria: site, navbar, rodapé, formatos
├── _brand.yml                  maquinaria: cores, fontes, logos
├── _variables.yml              o que muda: nome, contato, questionário, eixos, tipos
├── index.qmd                   Início
├── sobre.qmd
├── equipe.qmd
├── equipe.yml                  membros (editado a cada gestão)
├── participe.qmd               inclui o estado da seleção no cabeçalho
├── 404.qmd
├── publicacoes/
│   ├── index.qmd               Publicações
│   ├── em-breve.yml            fascículo anunciado e ainda não publicado
│   ├── _metadata.yml           maquinaria da pasta
│   ├── _modelo-fasciculo/index.qmd
│   ├── _modelo-texto/index.qmd
│   └── n01/
│       ├── index.qmd           fascículo nº 1
│       ├── capa.png
│       ├── fasciculo.pdf       só no lançamento
│       ├── endividamento-familias-financeirizacao/index.qmd
│       ├── impactos-setoriais-mercosul-ue/index.qmd
│       ├── eficacia-politica-monetaria-expectativas-racionais/index.qmd
│       └── subdesenvolvimento-visao-schumpeteriana/index.qmd
├── graficos/
│   ├── index.qmd
│   ├── _modelo/index.qmd
│   └── aaaa-mm-dd-slug/index.qmd
├── eventos/
│   ├── index.qmd
│   ├── _modelo/index.qmd
│   └── 2026-11-27-lancamento-n01/index.qmd (+ capa.jpg depois do evento)
├── modelos/                    Word e LaTeX para autores (PA4)
├── assets/
│   ├── marca/                  logos
│   ├── graficos/tema_macroliga.R
│   └── js/filtros.js
├── estilos/macroliga.scss
├── modelos-listing/            templates EJS
├── filtros/                    filtros Lua (montagem de páginas, validação)
├── rascunhos/                  ignorada pelo Git: PDFs e textos não publicados
└── LEIA-ME.md
```

- Pastas que começam com `_` são ignoradas pelo Quarto: servem de modelo.
- Fascículos em `nNN` com dois dígitos (`n01`, `n02`), para ordenar.
- Slugs em minúsculas, sem acento, com hífens. Os slugs dos textos do nº 1 acima são provisórios.

### 3.3 Cabeçalhos YAML

#### 3.3.1 Texto (`publicacoes/nNN/<slug>/index.qmd`; corpo vazio)

```yaml
title: "Impactos setoriais do acordo Mercosul e União Europeia"
author: "Miguel Amorin"
autor-citacao: ""        # opcional: só para sobrenome composto ("SILVA, Leonardo Xavier da")
tipo: "Análise de conjuntura"        # um dos 4 tipos de _variables.yml
eixo: "Setor externo e câmbio"       # um dos 6 eixos de _variables.yml
fasciculo: 1
ordem: 2                 # posição no sumário
date: 2026-11-27
sintese: "Duas a três frases."
revisao: "Prof. Fulano (FCE/UFRGS)"
doi: ""                  # vazio = usa o DOI do fascículo
pdf: "texto.pdf"
draft: true              # apagar no dia do lançamento
```

- Títulos em sentence case (padrão ABNT).
- `categories` não existe no modelo (D6).

#### 3.3.2 Fascículo (`publicacoes/nNN/index.qmd`)

```yaml
numero: 1
date: 2026-11-27
capa: "capa.png"
capa-alt: "Capa do fascículo nº 1"
pdf: "fasciculo.pdf"
doi: "10.5281/zenodo.XXXXXXX"
evento: "2026-11-27-lancamento-n01"   # opcional: nome da pasta do evento de lançamento (F4)
draft: true
```

O aluno não escreve o título: "{nome da publicação} nº {numero}" é montado a partir de `_variables.yml`, na página, nas listings e no `<title>`.

#### 3.3.3 Fascículo em breve (`publicacoes/em-breve.yml`)

```yaml
- numero: 1
  textos:
    - { titulo: "Endividamento das famílias e financeirização no Brasil", autor: "João Pedone" }
    - { titulo: "Impactos setoriais do acordo Mercosul e União Europeia", autor: "Miguel Amorin" }
    - { titulo: "Notas sobre a eficácia da política monetária sob a hipótese de expectativas racionais: uma breve revisão da literatura", autor: "Gabriel Vieira" }
    - { titulo: "Subdesenvolvimento: uma visão schumpeteriana", autor: "Arthur Pittella" }
```

Esvaziado no lançamento. Pode anunciar o fascículo seguinte depois.

#### 3.3.4 Evento (`eventos/aaaa-mm-dd-slug/index.qmd`; descrição no corpo)

```yaml
title: "Lançamento do fascículo nº 1"
date: 2026-11-27
quando: "Semana de 23/11/2026, data a confirmar"   # opcional: substitui a data exibida
horario: "19h"
local: "FCE/UFRGS, sala [a definir]"               # texto livre; aceita "On-line, link enviado após a inscrição"
situacao: "proximo"      # proximo | realizado (trocado à mão depois do evento)
inscricao: ""            # link do formulário | vazio | livre
fasciculo: 1             # opcional: só em lançamento
capa: ""                 # foto de capa, depois do evento
capa-alt: ""
fotos: ""                # link do álbum externo
```

Ação de inscrição (EV2, EVP3, I4):

| `inscricao` | O que aparece |
|---|---|
| link | Botão "Fazer inscrição" (abre o formulário) |
| vazio | "Inscrições em breve." |
| `livre` | "Entrada livre, sem inscrição." |

A `situacao` é manual porque o site é estático: um cálculo por data só rodaria quando alguém republicasse, e esconderia a regra do aluno.

#### 3.3.5 Gráfico (`graficos/aaaa-mm-dd-slug/index.qmd`)

```yaml
title: "Juros já pesam 10% da renda das famílias"
subtitle: "Comprometimento da renda com juros, em %, jan/2015 a ago/2026"
author: "…"
date: 2026-11-10
eixo: "Atividade econômica, mercado de trabalho e crédito"
fonte: "Banco Central do Brasil, série SGS 29034"
```

Corpo: chunk R que carrega `assets/graficos/tema_macroliga.R`, com `fig-alt` obrigatório, seguido do comentário. Alternativa aceita: imagem PNG pronta no lugar do chunk, com `alt` obrigatório. `execute: freeze: auto`: o resultado congelado (`_freeze/`) vai para o repositório, e publicar não exige R.

#### 3.3.6 Equipe (`equipe.yml`)

```yaml
conselho:
  - { nome: "…", genero: "feminino", presidente: true, foto: "" }    # genero: feminino | masculino
  - { nome: "…", genero: "masculino", presidente: false, foto: "" }
membros:
  - { nome: "…", foto: "" }
fundadores:                                                          # lista fixa: nunca apagar
  - { nome: "…", foto: "" }
```

Formato antigo (até 2026, substituído pela reestruturação da equipe), que agora para o render com aviso:

```yaml
diretorias:
  - nome: "Presidência (Research)"
    membros:
      - { nome: "…", cargo: "Presidente", foto: "" }
  - nome: "Vice-Presidência e Tesouraria"
    membros: [...]
  - nome: "Comunicação (Marketing e Design)"
    membros: [...]
  - nome: "Outreach"
    membros: [...]
eixos:
  - nome: "Política monetária e inflação"
    membros: ["…", "…"]
  # … os 6 eixos, com os nomes de _variables.yml
```

### 3.4 Listings

Todas usam template EJS próprio em `modelos-listing/` e mostram só os campos do bloco correspondente (sem a data, o autor e o tempo de leitura que o Quarto insere por padrão).

| Bloco | Lê | Ordem e filtro | Itens |
|---|---|---|---|
| I2 | `publicacoes/n*/index.qmd` + `em-breve.yml` | último fascículo publicado; se não houver, o "em breve" | 1 |
| I3 | `graficos/*/index.qmd` | `date` decrescente; bloco some se vazio | 1 |
| I4 | `eventos/*/index.qmd` | `situacao: proximo`, `date` crescente; estado vazio | 1 |
| P2 | `publicacoes/n*/index.qmd` + `em-breve.yml` | `numero` decrescente | todos |
| P4 | `publicacoes/n*/*/index.qmd` | `fasciculo` decrescente, depois `ordem` | todos |
| F3 | textos da pasta do fascículo | `ordem` | todos |
| T10 | textos da mesma pasta, menos o próprio | `ordem` | todos |
| GC2 | `graficos/*/index.qmd` | `date` decrescente | todos |
| EV2 | `eventos/*/index.qmd` | `situacao: proximo`, `date` crescente | todos |
| EV3 | `eventos/*/index.qmd` | `situacao: realizado`, `date` decrescente | todos |

Rascunhos (`draft: true`) aparecem em todas as listings no `quarto preview` e não existem no site publicado (nem página, nem item de listing, nem sitemap, nem busca).

### 3.5 Filtros (P3)

- O template de P4 grava `data-eixo` e `data-tipo` (slugs) em cada item.
- `assets/js/filtros.js` lê os dois controles e mostra só os itens que atendem **eixo e tipo** ao mesmo tempo.
- O estado vai para o endereço: `publicacoes/?eixo=setor-externo-e-cambio&tipo=analise-de-conjuntura`. Abrir esse endereço aplica os filtros, e é assim que S3 e EQ3 linkam.
- As opções são sempre os 6 eixos e os 4 tipos, mesmo sem textos. Sem resultado: estado vazio de textos-base 5.2 com "Limpar filtros".
- Sem JavaScript, os controles ficam ocultos e a lista aparece inteira.
- Operável só pelo teclado; o número de resultados é anunciado a leitores de tela.

Slugs:

| Eixo | Slug |
|---|---|
| Política monetária e inflação | `politica-monetaria-e-inflacao` |
| Setor externo e câmbio | `setor-externo-e-cambio` |
| Atividade econômica, mercado de trabalho e crédito | `atividade-economica-mercado-de-trabalho-e-credito` |
| Política fiscal e contas públicas | `politica-fiscal-e-contas-publicas` |
| Mercados externos | `mercados-externos` |
| Conjuntura política | `conjuntura-politica` |

| Tipo | Slug |
|---|---|
| Análise de conjuntura | `analise-de-conjuntura` |
| Revisão de literatura | `revisao-de-literatura` |
| Nota de pesquisa | `nota-de-pesquisa` |
| Texto de opinião | `texto-de-opiniao` |

O slug é derivado do nome (minúsculas, sem acento, sem pontuação, espaços viram hífen); ninguém o escreve à mão.

### 3.6 Validação na renderização

Um filtro Lua em `filtros/` confere cada texto, fascículo, gráfico e evento e **interrompe o `quarto render` com mensagem em português** quando encontra:

- `eixo` ou `tipo` fora das listas de `_variables.yml`, com as opções válidas na mensagem. Exemplo: `Texto "Impactos setoriais…": o eixo "Setor Externo" não existe. Use um destes: Política monetária e inflação; Setor externo e câmbio; …`;
- campo obrigatório vazio. Texto: `title`, `author`, `tipo`, `eixo`, `fasciculo`, `ordem`, `sintese`, `revisao`. Fascículo: `numero`, `date`. Gráfico: `title`, `author`, `date`, `eixo`, `fonte`. Evento: `title`, `date`, `local`, `situacao`;
- `situacao` diferente de `proximo` ou `realizado`;
- em item publicado (sem `draft`): texto sem `doi` quando o fascículo também não tem; texto ou fascículo sem `pdf`.

Em rascunho, `sintese`, `revisao`, `doi` e `pdf` aceitam placeholder (ex.: `"[síntese provisória]"`).

Se `questionario.url` estiver vazio em `_variables.yml`, o render emite **aviso** (não erro) e os blocos de questionário não aparecem.

### 3.7 `_variables.yml`

```yaml
publicacao:
  nome: "Pontos de Macro"          # provisório (decisão 1)
contato:
  email: "macroliga.ufrgs@gmail.com"
  instagram: "@macroliga.ufrgs"
  instagram-url: "https://www.instagram.com/macroliga.ufrgs/"
  linkedin: "MacroLiga UFRGS"
  linkedin-url: "https://www.linkedin.com/company/…"
coordenacao: "prof. Leonardo Xavier da Silva"
questionario:
  url: ""              # um único formulário do Google Forms para o site todo
  campo-pagina: ""     # opcional: id do campo (entry.NNN) que recebe o título da página
modelos:
  word: "modelos/modelo-macroliga.docx"
  latex: "modelos/modelo-macroliga.zip"
contagem:
  goatcounter: ""      # código da conta; vazio = nada é carregado
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

- **Questionário:** um formulário só. Com `campo-pagina` preenchido, "Responder ao questionário" abre o formulário com o título do texto, fascículo ou gráfico já marcado; sem ele, o link é o mesmo em todas as páginas.
- **Regra do nome:** "Pontos de Macro" só pode aparecer em `_variables.yml`, inclusive nos títulos de fascículo e nas listings.

---

## 4. Navegação, rodapé e compartilhamento

### 4.1 Cabeçalho (G1)

- Primeiro elemento: "Pular para o conteúdo", visível ao receber foco.
- Logo horizontal à esquerda, link para a Início, `alt` "MacroLiga UFRGS, página inicial".
- Menu: Início, Publicações, Gráficos comentados, Eventos, Sobre, Equipe, Participe. "Gráficos comentados" entra em 22/11 (D1).
- Desktop: menu em linha; a página atual marcada com `aria-current="page"`. Fascículo e texto marcam Publicações; gráfico marca Gráficos comentados; evento marca Eventos.
- Celular: navbar do Quarto recolhida em botão com rótulo acessível "Abrir menu" / "Fechar menu". Alvos de toque com pelo menos 44 px.
- Sem busca na 1ª versão (D10). Ela entra quando houver uns três fascículos.

### 4.2 Trilhas

Próprias, no lugar das do Quarto: F1 "Publicações / Fascículo nº {n}", T1 "Voltar ao fascículo nº {n}", EVP1 "Voltar aos eventos", GC8 "Ver todos os gráficos".

### 4.3 Rodapé (G2)

Bloco azul-marinho, 3 blocos (em coluna no celular, lado a lado no desktop), texto de textos-base 4 e valores de `_variables.yml`:

1. **Identidade:** logo horizontal branca; "MacroLiga UFRGS, Liga Acadêmica de Macroeconomia."; "Projeto de extensão da Faculdade de Ciências Econômicas da UFRGS, coordenado pelo {coordenacao}."
2. **Contato:** e-mail, Instagram e LinkedIn como links; botão "Escrever para a liga" (`mailto:`).
3. **Créditos:** "Textos publicados sob a licença CC BY-NC 4.0." (link para creativecommons.org/licenses/by-nc/4.0/deed.pt-br); "Site feito por membros da liga, com Quarto, e publicado no GitHub Pages."; "© 2026 MacroLiga UFRGS".

O vermelho nunca é usado para texto no rodapé (2,1:1 sobre azul).

### 4.4 Contagem de visitas

GoatCounter (gratuito para uso não comercial, sem cookies, sem banner): um script incluído pelo `_quarto.yml`, só no site publicado (nunca no `quarto preview`), e só se `contagem.goatcounter` estiver preenchido.

### 4.5 Compartilhamento (Open Graph)

Toda página tem título, descrição e imagem de Open Graph.

| Página | Imagem | Descrição |
|---|---|---|
| Fixas (Início, Sobre etc.) | selo da liga | campo `description` do cabeçalho de cada página |
| Fascículo | capa do fascículo | frase do I2 |
| Texto | capa do fascículo | `sintese` |
| Gráfico | o próprio gráfico | `subtitle` |
| Evento | capa, se houver; senão, o selo | data e local |

### 4.6 Links e endereço

Nenhum link começa com "/". O `site-url` só é usado no Open Graph e no sitemap. Mudar de `macroliga-ufrgs.github.io` para `ufrgs.br/macroliga` exige só trocar o `site-url` e republicar.

---

## 5. Princípios visuais

O detalhe fica para a etapa `frontend-design`. A spec só fixa:

1. **Marca fixa:** cores, fontes e logos entram pelo `_brand.yml`, exatamente como na seção 6 do CLAUDE.md. Nenhuma cor nova.
2. **Os pontos marcam em um lugar só: o I1.** No resto, aparecem só como marcador pequeno (etapas de I5 e S2, o "último dado" em vermelho nos gráficos).
3. **Azul-marinho em blocos inteiros:** I1, S4 e G2. Vermelho raro, nunca como texto sobre azul.
4. **Hierarquia pela escala:** título da página com 3× ou mais o tamanho do corpo. Libre Baskerville nos títulos, Inter no resto.
5. **Conteúdo em listas, não em grades de cards iguais:** P4, F3, GC2, EV2, EV3.
6. **Na página de gráfico, o gráfico é o herói.**
7. **Movimento só no I1**, só CSS, desligado com `prefers-reduced-motion`.
8. **A lista "Evitar" da seção 7 do CLAUDE.md** é checklist de revisão de toda tela.
9. Celular primeiro (360–430 px); linhas de até ~75 caracteres.

---

## 6. Critérios de pronto

### 6.1 Site mínimo, no ar até 18/10/2026

**Conteúdo e estados**
- [ ] `quarto render` sem erros; site publicado em `macroliga-ufrgs.github.io`.
- [ ] No ar: Início (I2 em breve, I3 oculto, I4 com o lançamento e "Inscrições em breve."), Publicações (P1 + P2 em breve), Eventos, página do evento de lançamento, Sobre, Equipe, Participe (seleção fechada) e 404.
- [ ] Menu sem "Gráficos comentados"; nenhum botão leva a página inexistente.
- [ ] Fascículo nº 1 e os 4 textos em rascunho aparecem completos no `quarto preview` (F1–F6, T1–T11, P3 e P4 funcionando) e **não existem** no `_site/`, nas listings nem no sitemap.
- [ ] Estados testados no preview, trocando o YAML: seleção aberta; evento com link de inscrição; evento `livre`; evento realizado com capa e fotos; filtros sem resultado; fascículo publicado (sem `draft`).
- [ ] Validação: um eixo inválido num texto faz o render falhar com a mensagem em português.

**Regras técnicas**
- [ ] "Pontos de Macro" não aparece em nenhum arquivo do site fora de `_variables.yml` (excluídos `docs/`, `conteudo/` e `wireframes/`). Trocar o nome e renderizar muda o nome em todas as páginas.
- [ ] `_site/` servido a partir de um subcaminho: todos os links funcionam, inclusive na 404 aberta de um endereço profundo.
- [ ] Nenhum PDF nem texto do nº 1 commitado; `rascunhos/` ignorada.
- [ ] GoatCounter ativo no site publicado, sem banner; ausente no preview.
- [ ] Open Graph conferido (título, descrição, imagem) no Post Inspector do LinkedIn para Início, Sobre e Eventos.

**Qualidade**
- [ ] Screenshots em 360, 390, 430 e 1280 px de cada página, criticadas contra a seção 7 do CLAUDE.md e a seção 5 desta spec.
- [ ] WCAG AA: contraste, foco visível, ordem de tabulação, `alt` em todas as imagens, landmarks, `lang` português.
- [ ] Linhas de até ~75 caracteres; alvos de toque de pelo menos 44 px; menu do celular funciona.
- [ ] Animação do I1 desligada com `prefers-reduced-motion`.
- [ ] Início com até 500 KB transferidos no primeiro acesso; Lighthouse mobile com pelo menos 90 em Desempenho e Acessibilidade.
- [ ] Todo texto visível revisado contra a seção 5 do CLAUDE.md (sem "Saiba mais", sem "→" colado, sentence case).

**Manutenção**
- [ ] LEIA-ME mínimo: instalar, pré-visualizar, publicar; editar `equipe.yml`, a seleção em `participe.qmd` e um evento.

### 6.2 Página Publicações: pronta até 22/11/2026, publicada no dia do lançamento

**Até 22/11, no preview**
- [ ] Dados reais do nº 1 nos 4 textos e no fascículo: sínteses, revisores, tipos e eixos confirmados, DOIs (ou herança do fascículo); PDFs em `rascunhos/`.
- [ ] Filtros: cada um dos 6 eixos e dos 4 tipos funciona sozinho e combinado; `?eixo=` vindo de S3 e EQ3 funciona; estado vazio e "Limpar filtros" funcionam; operável só pelo teclado; sem JS, a lista aparece inteira.
- [ ] "Como citar" dos 4 textos confere com o modelo ABNT de textos-base 5.3; "Copiar citação" anuncia "Citação copiada." a leitores de tela.
- [ ] "Baixar PDF" visível sem rolar em 390 × 700, no fascículo e nos textos.
- [ ] Questionário em todo texto, fascículo e gráfico; com `campo-pagina`, o formulário abre com o título preenchido.
- [ ] Gráficos comentados no ar: item de menu, lista e página, com o estado vazio ou o primeiro gráfico; `graficos/_modelo/` renderiza com o tema e o `freeze`; I3 aparece com o primeiro gráfico.
- [ ] Pastas-modelo completas: `_modelo-texto`, `_modelo-fasciculo`, `eventos/_modelo`, `graficos/_modelo`.
- [ ] LEIA-ME completo: adicionar fascículo, texto, gráfico e evento; o que fazer no dia do lançamento; o que fazer depois de um evento.
- [ ] Teste do aluno: alguém da Comunicação que nunca usou Quarto cria um texto de teste seguindo só o LEIA-ME, provoca o erro de validação, corrige e vê o texto no preview.

**No dia do lançamento**
- [ ] `draft: true` removido do fascículo e dos 4 textos; PDFs copiados; `em-breve.yml` esvaziado.
- [ ] I1 passa a "Ler o fascículo nº 1"; I2 mostra o nº 1; P3 e P4 aparecem.
- [ ] Todo link de DOI resolve em `doi.org`.
- [ ] Revisão curta (fase 6 do PLANO-SITE) e publicação.

---

## 7. Fora de escopo e pontos ainda abertos

| Ponto | Situação |
|---|---|
| Nome da publicação (decisão 1) | Provisório em `_variables.yml`; trocar não exige mudar mais nada. |
| DOI por texto ou só por fascículo (decisão 2) | Modelo suporta os dois (D5); decisão editorial até o depósito no Zenodo. |
| `ufrgs.br/macroliga` (decisão 3) | Depende do CPD; o site já funciona em subcaminho. |
| Fotos da equipe (decisão 5) | Campo `foto` pronto; fica vazio até o termo de uso de imagem. |
| Marca UFRGS (decisão 6) | A confirmar com a FCE; nada nesta spec usa a marca UFRGS. |
| Tipo e eixo dos textos de João Pedone e Arthur Pittella | A confirmar. Nos rascunhos, valores válidos provisórios com comentário `# [a confirmar]`. |
| Ordem do sumário do nº 1 | Provisória (a do CLAUDE.md); definida pela Presidência. |
| Lista de membros (`equipe.yml`) | A preencher pela gestão. |
| Endereço da página no LinkedIn e código do GoatCounter | A preencher em `_variables.yml` quando as contas existirem. |
| Link do questionário | A criar no Google Forms antes do lançamento do nº 1. |
| Busca, filtro de eventos por tipo, página de debatedores | Fora da 1ª versão. |

---

## 8. Microcopy nova criada nesta spec

Já incorporada a `conteudo/textos-base.md`:

| Onde | Texto |
|---|---|
| I1, antes do lançamento | Ver os textos do nº 1 |
| I1, segundo botão | Ver como funcionamos |
| I5 | Ler sobre a liga |
| EQ4 | Ver como participar |
| Evento sem link de inscrição | Inscrições em breve. |
| Evento de entrada livre | Entrada livre, sem inscrição. |
| EVP1 | Voltar aos eventos |
| EV1 | Lançamentos de fascículos, debates e outros encontros promovidos pela liga. |
| GC1 e I3 | Um gráfico, um comentário e a fonte dos dados. |
| P1 | Textos curtos de estudantes de graduação, revisados por professores da FCE e reunidos em fascículos numerados. Todos têm DOI e podem ser citados. |
| EQ1 | Cerca de 15 estudantes de graduação da UFRGS. O Conselho Executivo coordena o trabalho e decide em conjunto, sem hierarquia formal entre seus integrantes. |
| F5 | Leu este fascículo? Conte o que achou em um questionário curto. As respostas ajudam a avaliar o projeto de extensão. |
| 404, título | Página não encontrada |
