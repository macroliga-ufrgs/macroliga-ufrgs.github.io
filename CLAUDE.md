# MacroLiga UFRGS: site institucional

Este arquivo dá ao Claude Code o contexto do projeto. Leia inteiro antes de qualquer tarefa. O plano de construção, fase a fase, está em `PLANO-SITE.md`.

Idioma de trabalho: **português do Brasil**, no código (comentários, nomes de arquivos de conteúdo) e no site.

---

## 1. O que é a liga

A **MacroLiga UFRGS** (Liga Acadêmica de Macroeconomia da UFRGS) é um projeto de extensão da Faculdade de Ciências Econômicas (FCE/UFRGS), na modalidade *Produção e Publicação*.

- **Coordenação:** prof. Leonardo Xavier da Silva
- **Vigência:** 01/09/2026 a 31/07/2027, 450 h, cerca de 15 membros
- **E-mail:** macroliga.ufrgs@gmail.com
- **Redes:** @macroliga.ufrgs (Instagram) e a página MacroLiga UFRGS no LinkedIn. As duas abrem em 19/10/2026.

**O produto central são textos curtos**, de até 3 páginas, escritos por alunos de graduação e **revisados por docentes**. Os textos são reunidos em **fascículos numerados** (nº 1, nº 2…). A liga também promove debates entre os membros e eventos presenciais de lançamento.

**Frase de posicionamento** (uso interno): para estudantes de Economia e interessados em entender a economia brasileira, a MacroLiga é a liga que traduz teoria macroeconômica e conjuntura em textos e gráficos curtos, escritos por alunos e revisados por professores. Diferente de boletins de conjuntura e perfis de mercado, a liga explica o porquê teórico, abre espaço a visões diferentes e assume que está aprendendo em público.

### Estrutura interna

- **Presidência (Research)**, com 6 eixos temáticos:
  1. Política Monetária e Inflação
  2. Setor Externo e Câmbio
  3. Atividade Econômica, Mercado de Trabalho e Crédito
  4. Política Fiscal e Contas Públicas
  5. Mercados Externos
  6. Conjuntura Política
- Vice-Presidência/Tesouraria
- Comunicação (Marketing e Design), com 2 pessoas
- Outreach

### Origem das diretrizes editoriais

As diretrizes vêm da ata da reunião com o prof. Horn (30/04/2026):

- Textos **"mais descritivos do que normativos"**, por causa da heterogeneidade doutrinária do grupo.
- "Não ter receio de falar o básico": o público é discente.
- Formato de referência: **comentário de gráficos**, no modelo de Adam Tooze (um gráfico com um comentário autoral curto).
- Um "Boletim Focus interno": bolão de projeções entre membros. É uma brincadeira de aprendizado, **nunca uma projeção oficial**.
- Lançamentos presenciais de cada fascículo, com debatedor designado para cada texto.

---

## 2. Função do site

O Instagram gera alcance, o LinkedIn gera credibilidade e **o site guarda a produção**. Todo post nas redes aponta para o site, que é o único lugar onde o fascículo completo vive.

### Públicos, em ordem de prioridade

1. Estudantes de Economia da FCE que já cursaram Macro I/II: leitores e futuros membros.
2. Calouros e alunos de cursos próximos (RI, Administração, Direito): querem entender notícias econômicas sem jargão.
3. Professores e pesquisadores da FCE: avaliam seriedade, atuam como revisores e parceiros.
4. Comunidade externa (egressos, profissionais, público geral): buscam leituras curtas e confiáveis. Esse público conta como indicador de extensão.

**A maioria chega pelo celular, vinda do link na bio do Instagram.** Projete primeiro para telas de 360–430 px.

### O site precisa alimentar os indicadores da proposta de extensão

| Indicador da proposta | Como o site contribui |
|---|---|
| Artigos e fascículos publicados | Página Publicações completa; cada PDF com DOI no Zenodo |
| Público nas atividades | Página Eventos, com inscrição (Google Forms) |
| Avaliação do público leitor | Link do questionário em **toda** página de texto e de fascículo |
| Alcance | Contagem de visitas (ferramenta gratuita, sem banner de cookies, ex.: GoatCounter) |

---

## 3. Restrições técnicas (não negociáveis)

- **Custo zero.** A liga não tem receita. Nada de hospedagem paga, domínio pago, fontes pagas, CMS pago ou serviço com plano "grátis por 30 dias".
- **Stack:** [Quarto](https://quarto.org) (site estático) publicado no **GitHub Pages**, sob uma organização do GitHub da liga (`macroliga-ufrgs`). O endereço provisório é `macroliga-ufrgs.github.io`; o definitivo, se a coordenação conseguir com o CPD, `ufrgs.br/macroliga`. O site precisa funcionar em qualquer subcaminho: use links relativos e nada fixo na raiz do domínio.
- **Design implementado do jeito Quarto:**
  - `_brand.yml` para cores, fontes e logos;
  - SCSS customizado (`theme: [<base>, estilos/macroliga.scss]`);
  - templates EJS de *listing* para cards de publicação;
  - `page-layout: custom` na página inicial, se necessário.
- **O que não usar:** React, Next, Tailwind, bundlers ou frameworks JS. O site é HTML + CSS do Quarto, com JS mínimo e opcional.
- **Gráficos em R** com o tema da marca (`assets/graficos/tema_macroliga.R`). Use `execute: freeze: auto`, para que a publicação não precise rodar R no servidor.
- **PDFs:** a fonte de verdade é o Zenodo, com DOI. O site linka para o DOI e pode manter uma cópia local do PDF.
- **Manutenção por estudantes que trocam todo ano.** Para publicar um texto novo, basta **copiar uma pasta e preencher o cabeçalho YAML**. Toda escolha técnica deve passar neste teste: "um aluno de Economia que nunca programou para web consegue manter isto seguindo o LEIA-ME?"
- **Nome da publicação ainda não definido.** Nunca escreva o nome direto no código. Use `_variables.yml` (`{{< var publicacao.nome >}}`). Valor provisório: "Pontos de Macro".

---

## 4. Mapa do site

| Página | Conteúdo |
|---|---|
| **Início** | O que é a liga em uma frase; último fascículo (capa + botão de leitura); último Gráfico Comentado; próximo evento; links das redes |
| **Publicações** | Lista de fascículos por número; filtros por eixo e por tipo de texto |
| ↳ **Fascículo** (ex.: nº 1) | Capa, data, sumário (textos com autor e tipo), PDF completo + DOI, questionário |
| ↳ **Texto** | Tipo, título, autor, eixo, síntese, botão do PDF/DOI, como citar (ABNT), nota de revisão docente e de responsabilidade autoral, questionário |
| **Gráfico Comentado** | Gráfico + comentário de até 150 palavras + fonte. É a versão web do formato-assinatura das redes. Fica opcional na 1ª versão |
| **Eventos** | Próximos eventos (com inscrição) e eventos passados (com fotos) |
| **Sobre** | Missão, como funcionamos (texto → debate entre pares → revisão docente → publicação), regra da pluralidade, vínculo com a extensão |
| **Equipe** | Coordenação, professores revisores, diretorias e eixos (com membros) |
| **Participe** | Processo seletivo, formulário, modelos para autores (Word/LaTeX) |
| **Contato** | E-mail e redes (pode ficar no rodapé, em vez de página própria) |

### Modelo de conteúdo (cabeçalho YAML de cada texto)

```yaml
title: "Impactos setoriais do acordo Mercosul–União Europeia"
author: "Miguel Amorin"
tipo: "Análise de conjuntura"   # Análise de conjuntura | Revisão de literatura | Nota de pesquisa | Texto de opinião
eixo: "Setor Externo e Câmbio"   # um dos 6 eixos
fasciculo: 1
date: 2026-11-27
sintese: "Duas a três frases."
doi: "10.5281/zenodo.XXXXXXX"
pdf: "texto.pdf"
revisao: "Prof. Fulano (FCE/UFRGS)"
categories: ["Setor Externo e Câmbio", "Análise de conjuntura"]
```

Os **Textos de opinião** sempre exibem: "As opiniões expressas são de responsabilidade do autor."

### Conteúdo real para o nº 1 (em revisão; não publicar antes do lançamento)

- *Endividamento das Famílias e Financeirização no Brasil*, de João Pedone
- *Impactos Setoriais do Acordo Mercosul e União Europeia*, de Miguel Amorin
- *Notas sobre a eficácia da política monetária sob a hipótese de expectativas racionais: uma breve revisão da literatura*, de Gabriel Vieira
- *Subdesenvolvimento: uma visão schumpeteriana*, de Arthur Pittella

Use esses títulos nos wireframes e protótipos, no lugar de *lorem ipsum*.

---

## 5. Voz e texto do site

| Somos | Não somos |
|---|---|
| Descritivos: "o Copom elevou a Selic para X%; o comunicado cita Y" | Normativos na voz da liga: "o Copom errou ao…" |
| Didáticos: explicamos siglas e conceitos | Herméticos |
| Precisos: número, data e fonte | Sensacionalistas |
| Próximos: 1ª pessoa do plural, frases curtas | Informais demais, com gírias forçadas |

**Regra da pluralidade:** a liga não toma posição sobre política econômica, governo ou partidos. Em temas controversos, o formato é "o que dizem as diferentes visões". Opinião só aparece em texto individual assinado.

**Microcopy:**

- Sentence case nos títulos e botões.
- Verbos que dizem o que acontece: "Ler o fascículo", "Baixar PDF", "Responder ao questionário".
- Nada de "Saiba mais" genérico.

**Formato brasileiro:** 1.234,5; 10,5%; datas "27 de novembro de 2026" ou "27/11/2026". Configure `lang: pt` no Quarto.

---

## 6. Identidade visual (já definida: aplicar, não reinventar)

### Logo

O conceito é o **mapa do Brasil formado por pontos vermelhos** dentro de um círculo azul-marinho. Os pontos remetem a dados e a pontos de um gráfico. Arquivos em `assets/marca/` (cópia de `../Materiais/Marca/`):

| Versão | Arquivo | Uso no site |
|---|---|---|
| Horizontal | `svg/macroliga-horizontal-{cor,azul,branco}.svg` | Cabeçalho, rodapé |
| Símbolo | `svg/macroliga-simbolo-{cor,azul,branco}.svg` | Favicon, marcadores, marca-d'água |
| Selo | `svg/macroliga-selo-{cor,azul,branco}.svg` | Página Sobre, capas |
| Favicon | `png/macroliga-favicon-512.png` | `favicon` |

Sobre fundo azul-marinho, use sempre a versão **branca**. Não distorça, não recolora e não aplique sombra ao logo.

### Cores

| Token | Hex | Papel | Contraste |
|---|---|---|---|
| `azul-marinho` | `#083D6B` | Cor dominante | 10,5:1 sobre off-white |
| `vermelho` | `#D51E23` | Destaque pontual (o "dado" que importa) | 4,9:1 sobre off-white: texto OK; **2,1:1 sobre azul: nunca usar para texto sobre azul** |
| `offwhite` | `#FAF8F4` | Fundo | — |
| `grafite` | `#1F2933` | Texto | 13,9:1 |
| `grade` | `#D9D4CA` | Linhas, divisórias | Decorativa |
| `contexto` | `#9AA5B1` | Séries secundárias em gráficos | 2,4:1: **não usar para texto** |

Paleta de gráficos com 2 a 4 séries, em ordem fixa e validada para daltonismo: `#1F5FA8`, `#D51E23`, `#C98A0B`, `#2E9C78`. Séries múltiplas sempre levam rótulo direto.

### Tipografia (Google Fonts, gratuitas)

- **Libre Baskerville:** títulos. Tem poucos pesos, então o contraste vem do **tamanho** (saltos grandes de escala), não do peso.
- **Inter:** texto, interface e gráficos. É uma fonte variável (100–900): use pesos extremos para hierarquia.

### Gráficos

- O título afirma o fato ("Juros já pesam 10% da renda das famílias"); o subtítulo traz unidade e período.
- Rodapé: "Fonte: [instituição], [série]. Elaboração: MacroLiga UFRGS."
- Uma série: azul-marinho, com o último dado em vermelho.
- Sem 3D, sem dois eixos y, no máximo 3–4 cores.

---

## 7. Direção estética para o site

Esta seção adapta o guia [*Prompting for frontend aesthetics*](https://platform.claude.com/cookbook/coding-prompting-for-frontend-aesthetics) e a skill `frontend-design` ao caso da liga.

<frontend_aesthetics>
Você tende a convergir para saídas genéricas, "na média". Evite isso: este site precisa parecer feito para a MacroLiga e para mais ninguém.

**A marca manda.** Cores, fontes e logo da seção 6 são fixos. A liberdade criativa está no layout, no ritmo, na composição e nos detalhes. Atenção: off-white + serifa de alto contraste é um padrão comum de sites gerados por IA. Por isso, a identidade não pode depender só disso. O diferencial tem que vir do assunto.

**A ideia-assinatura vem do logo: pontos.** O Brasil feito de pontos é, ao mesmo tempo, mapa, dado e gráfico de dispersão. Explore essa linguagem com moderação e em um só lugar marcante. Exemplos:
- uma grade de pontos que forma ou revela algo na página inicial;
- marcadores de dado ("o ponto vermelho" como o dado que importa);
- o gráfico como herói, porque é o objeto mais característico do mundo da liga.

**Cor:** azul-marinho dominante (blocos inteiros, não só detalhes) e vermelho como acento afiado e raro, que marca o que importa. Paletas tímidas e equilibradas são o padrão a evitar.

**Tipografia:** a escala é a ferramenta. Use saltos de 3× ou mais entre o título da página e o texto. A tipografia é parte ativa do design.

**Movimento:** um único momento orquestrado, por exemplo na página inicial (os pontos se acendendo em sequência, com `animation-delay`). Só CSS. Respeite `prefers-reduced-motion`. Nada de fade-in em cada seção, nem hover animado em todo card.

**Fundo e profundidade:** atmosfera com padrões geométricos sutis (grade de pontos, linhas de grade de gráfico em `#D9D4CA`), em vez de gradientes decorativos.

**Evitar, porque denuncia um site genérico:**
- Kit SaaS: tudo em cards arredondados iguais, com a mesma sombra cinza.
- Rótulo em CAIXA ALTA espaçada acima de todo título.
- Destacar uma palavra do título em outra cor ou em itálico.
- Numeração 01/02/03 em conteúdo que não é sequência. (A sequência real "texto → debate → revisão → publicação" pode ser numerada.)
- Metadados unidos por "·" em toda parte.
- "→" colado em todo link.
- Hero com número grande + rótulo pequeno + gradiente.
- Gradiente roxo, glassmorphism, emojis como ícones.

**Piso de qualidade, sem anunciar:**
- responsivo desde 360 px;
- foco de teclado visível;
- contraste WCAG AA;
- textos com até ~75 caracteres por linha (serifa pode ter um pouco mais de entrelinha);
- `alt` em todas as imagens;
- site leve (abre bem em 4G).
</frontend_aesthetics>

---

## 8. Arquivos de referência (pasta-mãe `../`)

| Caminho | O que é |
|---|---|
| `../Materiais/Marca/` | Logos SVG/PNG e a prancha de aprovação (`prancha-logo.png`) |
| `../Materiais/Graficos/tema_macroliga.R` | Tema ggplot2, paleta, `sgs()` (séries do BCB), formatação brasileira |
| `../Materiais/Graficos/LEIA-ME.md` | Regras dos gráficos |
| `../Materiais/Publicacao/` | Modelos Word/LaTeX dos textos e do fascículo (para a página Participe) |
| `../Proposta atualizada - Projeto de extensão.docx` | Proposta oficial: objetivos e indicadores |
| `../20260430_Ata_Horn.pdf` | Ata com as diretrizes editoriais |
| `../Textos para discussão/nº 1 - 25-08-2026/` | Versões em revisão dos 4 textos do nº 1 (**não publicar**) |

Copie para `assets/` só o que o site usar. Nunca altere os originais em `../Materiais/`.

---

## 9. Calendário

| Data | Marco |
|---|---|
| até 18/10/2026 | Site mínimo no ar: Início, Sobre, Equipe, Participe/Contato. O link vai na bio quando as contas abrirem |
| 19/10/2026 | Abertura do Instagram e do LinkedIn |
| até 22/11/2026 | Página Publicações pronta e rascunho do nº 1 no Zenodo |
| semana de 23/11/2026 (ref. 27/11, a confirmar) | Lançamento do fascículo nº 1, com evento presencial na FCE |

---

## 10. Decisões em aberto

Não decida estes pontos sozinho: pergunte ao Miguel.

1. **Nome da publicação:** a recomendação é "Pontos de Macro"; está provisório em `_variables.yml`.
2. **DOI por texto ou só por fascículo?** A recomendação é por texto, mais um registro do fascículo inteiro.
3. **Endereço `ufrgs.br/macroliga`:** depende de o coordenador pedir ao CPD.
4. **Página Gráfico Comentado** entra já na 1ª versão ou depois do lançamento?
5. **Fotos dos membros na página Equipe:** dependem de termo de uso de imagem.
6. **Regras de uso do nome e da marca UFRGS** em materiais de extensão: a confirmar com a FCE.

## 11. Convenções do repositório

- Conteúdo em `.qmd`, um diretório por item: `publicacoes/n01/<slug>/index.qmd`, `graficos/<aaaa-mm-dd>-<slug>/index.qmd`, `eventos/<aaaa-mm-dd>-<slug>/index.qmd`.
- Slugs em minúsculas, sem acento, com hífens.
- `LEIA-ME.md` na raiz: como instalar, pré-visualizar (`quarto preview`), publicar (`quarto publish gh-pages`) e adicionar fascículo, texto, gráfico ou evento. Escrito para quem nunca usou Quarto.
- Commits pequenos, em português, no imperativo ("Adiciona página Sobre").
- Antes de dar uma tela por pronta, renderize, tire screenshots em 390 px e 1280 px e critique o resultado contra a seção 7.
