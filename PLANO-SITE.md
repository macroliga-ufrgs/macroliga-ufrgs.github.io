# Plano de criação do site da MacroLiga UFRGS com o Claude Code

**Objetivo:** site mínimo no ar até **18/10/2026**, véspera da abertura das redes, e página Publicações pronta até **22/11/2026**, para o lançamento do nº 1.

**Stack:** Quarto + GitHub Pages, custo zero. O contexto completo está em `CLAUDE.md`, que o Claude Code lê sozinho ao abrir esta pasta.

**Fluxo-base:** o do comentário (Superpowers → wireframes → brainstorming → frontend-design), com três ajustes:

1. Entra uma **fase de conteúdo antes dos wireframes**. A skill `frontend-design` pede conteúdo real, e wireframe com texto de verdade fica muito mais fácil de julgar.
2. O **frontend-design é ancorado no Quarto**. Sem essa trava, ele tende a gerar HTML/React solto, que depois não vira site Quarto.
3. Entra uma **fase de manutenção**, porque a próxima gestão vai herdar o site.

| Fase | O quê | Datas |
|---|---|---|
| 0 | Preparação: programas, plugins, GitHub, pasta | 03–04/10 |
| 1 | Conteúdo-base (textos das páginas) | 05/10 |
| 2 | Wireframes | 06–07/10 |
| 3 | Brainstorming (Superpowers) → spec de design | 08/10 |
| 4 | Direção visual (frontend-design) → tokens + prancha de estilo | 09–10/10 |
| 5 | Plano de implementação + construção em Quarto | 11–16/10 |
| 6 | Revisão: acessibilidade, celular, desempenho | 17/10 |
| 7 | Publicação no GitHub Pages | 18/10 |
| 8 | Manutenção e página Publicações do nº 1 | até 22/11 |

Ao fim de cada fase: **commit**, e `/clear` antes de começar a próxima. O que importa fica gravado nos arquivos, não na conversa.

---

## Fase 0: Preparação (uma vez)

### 0.1 Programas no computador

- [ ] **Git for Windows** (o Claude Code no Windows precisa dele)
- [ ] **Quarto CLI**, versão 1.6 ou superior (`quarto --version`). A partir da 1.6 há suporte a `_brand.yml`
- [ ] **R**, com `install.packages(c("rmarkdown", "knitr", "ggplot2", "scales", "ragg", "systemfonts", "jsonlite"))`
- [ ] Fontes **Inter** e **Libre Baskerville** instaladas (necessárias para os gráficos em R)
- [ ] **Node.js LTS**, necessário para o plugin Playwright, que tira screenshots

### 0.2 GitHub

- [ ] Criar uma conta GitHub com **macroliga.ufrgs@gmail.com**, com verificação em duas etapas
- [ ] Criar a organização **`macroliga-ufrgs`**. O GitHub não aceita ponto no nome, por isso o hífen. Pôr você e mais uma pessoa como *owners*, para garantir a passagem de bastão
- [ ] O repositório `macroliga-ufrgs.github.io` será criado na fase 7. Ele precisa ser **público** para o Pages ser gratuito

> ⚠️ **Repositório público = tudo nele é visível.** Os textos do nº 1 ainda estão em revisão. **Não faça commit de PDFs ou textos não publicados** antes do lançamento; deixe-os em `rascunhos/`, que o Git ignora. Nos wireframes e protótipos, use só títulos e autores.

### 0.3 Pasta e CLAUDE.md

```
MacroLiga/
├── Materiais/        (já existe: marca, gráficos, publicação)
├── ...
└── site/             ← repositório do site; abra o Claude Code aqui
    ├── CLAUDE.md     ← contexto (este pacote)
    └── PLANO-SITE.md ← este plano
```

Abra o terminal em `MacroLiga\site` e rode `claude`.

### 0.4 Plugins (dentro do Claude Code)

```
/plugin install superpowers@claude-plugins-official
/plugin install frontend-design@claude-plugins-official
/plugin install playwright@claude-plugins-official
```

- O Superpowers agora está no marketplace oficial. Os comandos do comentário (`/plugin marketplace add obra/superpowers-marketplace` e `/plugin install superpowers@superpowers-marketplace`) também funcionam. Use **um** dos dois caminhos, não os dois.
- O Playwright não estava no comentário, mas a skill `frontend-design` recomenda que o Claude **veja** o próprio trabalho em screenshots para se criticar. É ele que permite isso.
- Reinicie o Claude Code depois de instalar.

### 0.5 Primeiro prompt (copiar e colar)

```
Leia o CLAUDE.md e o PLANO-SITE.md. Depois:
1. git init; crie um .gitignore para Quarto (_site/, .quarto/, *_files/) e uma pasta
   rascunhos/ também ignorada, para qualquer material ainda não publicado.
2. Copie de ../Materiais/Marca/ para assets/marca/ os SVG e o favicon PNG, e
   ../Materiais/Graficos/tema_macroliga.R para assets/graficos/.
3. Confirme que Quarto, R e Git respondem no terminal e me diga as versões.
Não crie nenhum arquivo do site ainda.
```

**Pronto quando:** `git log` mostra o primeiro commit com `CLAUDE.md`, o plano e os `assets/`.

---

## Fase 1: Conteúdo-base

O design se apoia no texto real. Esta fase produz o texto das páginas fixas, na voz da liga.

```
Com base no CLAUDE.md (seções 1, 2, 4 e 5), escreva conteudo/textos-base.md com o
texto final de:
- Início: frase de abertura (1 linha), subtítulo (até 25 palavras), chamadas dos blocos.
- Sobre: missão (1 parágrafo), "como funcionamos" (texto → debate entre pares →
  revisão docente → publicação), regra da pluralidade, vínculo com a extensão.
- Participe: quem pode entrar, como funciona a seleção, o que se espera do membro.
- Rodapé: créditos, e-mail, redes, menção ao projeto de extensão FCE/UFRGS.
- Microcopy: textos de botões, estados vazios ("Nenhum evento agendado — siga
  @macroliga.ufrgs para saber do próximo") e a nota de responsabilidade autoral.
Regras: voz descritiva e didática, frases curtas, sentence case, sem "Saiba mais".
Marque com [CONFIRMAR] qualquer fato que você não encontrou no CLAUDE.md.
```

**Você revisa:** o texto vai para o grupo? Precisa da aprovação da Presidência?

**Pronto quando:** `conteudo/textos-base.md` revisado por você e sem `[CONFIRMAR]` pendente.

---

## Fase 2: Wireframes (passo 4 do comentário)

Wireframe **não é** mockup: é cinza, sem cor, sem fonte da marca, sem logo. Cada bloco recebe um **código** (I1, I2, P1…), para você pedir mudanças com precisão: "troque I3 com I2", "corte P4".

```
Gere wireframes de baixa fidelidade em wireframes/, como HTML estático simples
(não é o site; é só para discutir estrutura):
- Um arquivo por tela: inicio.html, publicacoes.html, fasciculo.html, texto.html,
  sobre.html, equipe.html, eventos.html, participe.html, e um index.html com links.
- Cada arquivo mostra lado a lado a versão celular (390 px) e a versão desktop (1280 px).
- Só tons de cinza, fonte do sistema, caixas com borda. Nada de cor, logo ou estilo.
- Cada bloco tem um código visível (I1, I2… na Início; P1, P2… em Publicações etc.)
  e uma anotação curta de função ("I2 — último fascículo: capa + título + botão").
- Use o conteúdo real: textos de conteudo/textos-base.md e os 4 títulos/autores
  do nº 1 listados no CLAUDE.md. Nada de lorem ipsum.
- Para a Início, faça 3 alternativas de estrutura (inicio-a/b/c.html): uma que abre
  pelo fascículo, uma que abre por um Gráfico Comentado, uma que abre pela ideia
  da grade de pontos.
Depois, tire screenshots com o Playwright de cada tela (390 e 1280) e me mostre
um resumo do que cada uma contém, por código de bloco.
```

**Como iterar:** abra `wireframes/index.html` no navegador e responda por código. Exemplo: "Início: fico com a B. Suba I4 para logo abaixo de I1, corte I6. Texto: o botão do PDF tem que aparecer sem rolar no celular."

**Pronto quando:** cada tela tem uma versão aprovada. Renomeie a Início escolhida para `inicio.html` e apague as outras.

---

## Fase 3: Brainstorming (passo 5 do comentário)

A skill **brainstorming** do Superpowers faz perguntas, uma por vez, e no fim grava um **documento de design (spec)**. Ela tem uma trava: não deixa implementar nada antes de você aprovar a spec. Isso é bom.

Para chamar:

- `/superpowers:brainstorming`, ou
- escreva "use a skill de brainstorming do Superpowers".

Versões antigas tinham `/superpowers:brainstorm`.

```
/superpowers:brainstorming

Quero desenhar o site da MacroLiga UFRGS. O contexto está no CLAUDE.md, o texto
em conteudo/textos-base.md, e a estrutura aprovada em wireframes/ (veja os
screenshots e as anotações por código de bloco).

O que quero desta conversa: uma spec de design em docs/spec-design.md que cubra
(1) objetivo e públicos de cada página, (2) a estrutura final por bloco, a partir
dos wireframes aprovados, (3) o modelo de conteúdo em Quarto (pastas, YAML de
texto/fascículo/evento/gráfico, listings, filtros por eixo e tipo, _variables.yml),
(4) navegação e rodapé, (5) critérios de "pronto" para o site mínimo de 18/10 e
para a página Publicações de 22/11.

Restrições que não estão em discussão: Quarto + GitHub Pages, custo zero, marca
fixa (CLAUDE.md seção 6), manutenção por alunos sem experiência em web.
A direção visual detalhada fica para a etapa seguinte, com a skill frontend-design;
aqui, só registre princípios.
```

**Respostas que você provavelmente vai precisar dar** (já pense nelas):

- A página Gráfico Comentado entra na versão de 18/10 ou depois? (Decisão 4 do CLAUDE.md)
- Equipe com foto ou só nomes? (Decisão 5)
- Eventos: inscrição via Google Forms embutido ou só link?
- Filtros em Publicações: os 6 eixos, os 4 tipos, ou ambos?

Se ele oferecer o **visual companion** (mockups no navegador), aceite só para perguntas de layout.

**Pronto quando:** `docs/spec-design.md` aprovada por você. Faça commit.

---

## Fase 4: Direção visual (passo 6 do comentário)

A skill `frontend-design` trabalha em duas passadas:

1. propõe um sistema de tokens (4–6 cores, tipos, layout, princípios);
2. **revisa a própria proposta** contra o briefing antes de codar.

Como a marca já existe, o trabalho dela é **aplicar** as cores e fontes de forma distinta, e não escolher outras. Por isso a primeira entrega é uma **prancha de estilo**, não o site.

```
/frontend-design:frontend-design

Briefing: CLAUDE.md (seções 6 e 7 são obrigatórias), docs/spec-design.md e
os wireframes aprovados em wireframes/.

Etapa 1 — plano (sem código):
- Tokens: use exatamente as cores e fontes da marca; defina papéis, escala tipográfica
  (com saltos de 3×+), espaçamentos e raios.
- A ideia-assinatura: como a linguagem de pontos do logo aparece no site, em UM lugar
  marcante. Proponha 3 opções e recomende uma.
- Layout: descreva, com wireframes ASCII, como os blocos aprovados ganham ritmo visual.
- Revise o plano contra a lista "Evitar" do CLAUDE.md e contra os padrões genéricos
  que você conhece (inclusive off-white + serifa). Diga o que mudou e por quê.
Pare e me mostre o plano.

Etapa 2 — depois que eu aprovar:
- Construa design/prancha.html: uma página estática com tipografia, cores, botões,
  card de fascículo, card de texto, bloco de gráfico (use
  ../Materiais/Graficos/exemplo1_grafico_comentado.png), cabeçalho e rodapé, mais a
  seção de abertura da Início nas versões celular e desktop.
- Escreva o CSS já pensando em virar SCSS do Quarto: variáveis CSS nomeadas como os
  tokens, sem Tailwind, sem frameworks, sem JS além do mínimo.
- Tire screenshots (390 e 1280), critique contra o briefing e corrija antes de me mostrar.
```

**Você julga:**

- Parece a MacroLiga ou parece "um site acadêmico qualquer"?
- O vermelho está raro o bastante?
- A leitura de um texto longo no celular é confortável?

Peça mudanças diretas, como "o bloco de pontos está chamando mais atenção que o fascículo; reduza".

**Pronto quando:** `design/prancha.html` aprovada, com as decisões em `docs/design-tokens.md`.

---

## Fase 5: Plano de implementação e construção

### 5.1 Plano

```
Use a skill writing-plans do Superpowers para transformar docs/spec-design.md,
docs/design-tokens.md e design/prancha.html num plano de implementação em Quarto
(docs/plano-implementacao.md), em tarefas pequenas e verificáveis.
A spec manda: estrutura de pastas (3.2), cabeçalhos YAML (3.3), listings (3.4),
filtros (3.5), validação (3.6), _variables.yml (3.7) e critérios de pronto (6).
Requisitos:
- _quarto.yml: website, lang: pt, navbar e rodapé da spec (seção 4), site-url,
  open-graph, execute: freeze: auto. Sem busca na 1ª versão (D10). GoatCounter
  só no site publicado e só com o código preenchido (D11).
- _brand.yml: as 6 cores e os logos da marca; Inter e Libre Baskerville do Google
  Fonts, só com os pesos usados (Libre Baskerville variável, 400–700; ver
  docs/design-tokens.md).
- estilos/macroliga.scss a partir de design/macroliga.css: mesmos tokens e nomes,
  componentes como seções do SCSS, estilizando a navbar do Quarto (Bootstrap,
  que recolhe abaixo de 992 px) no lugar do cabeçalho da prancha.
- Abertura da Início com design/mapa-pontos.svg (gerado por design/gerar-mapa.py),
  incluído no index.qmd com page-layout: custom, se necessário.
- Listings com templates EJS próprios (modelos-listing/) para I2, I3, I4, P2, P4,
  F3, T10, GC2, EV2 e EV3, incluindo o estado "em breve" de publicacoes/em-breve.yml.
- Filtros por eixo e por tipo (D6): data-eixo e data-tipo em cada texto,
  assets/js/filtros.js, estado no endereço (?eixo=&tipo=). Não há campo categories.
- Filtro Lua de validação (spec 3.6), com mensagens em português.
- Pastas-modelo com YAML completo: publicacoes/_modelo-texto/,
  publicacoes/_modelo-fasciculo/, eventos/_modelo/ e graficos/_modelo/ (este com
  grafico_site() de assets/graficos/tema_macroliga.R; uma tarefa testa se o freeze
  guarda as duas imagens e se elas chegam ao _site/).
- Regras de docs/design-tokens.md em todo template: "nº&nbsp;{n}", algarismos
  tabulares só em dados, vermelho só nos três usos previstos.
- Ordem: base e tema → Início → Sobre → Equipe → Participe → Publicações em breve
  → Eventos e evento de lançamento → 404 → fascículo nº 1 e os 4 textos em
  rascunho (D3) → filtros → (marco "site mínimo", spec 6.1) → Gráficos comentados
  (até 22/11, D1).
- Cada tarefa termina com quarto render sem erros + screenshots em 390 e 1280 px,
  comparadas com a prancha e com o wireframe aprovado.
- Antes de escrever o plano, pergunte-me os pontos em aberto de docs/design-tokens.md.
```

Revise o plano e escolha a execução que o Superpowers oferecer: *inline*, mais simples de acompanhar, ou com subagentes, mais rápida. Para um site deste tamanho, **inline** basta.

### 5.2 Construção

```
Execute docs/plano-implementacao.md até o marco "site mínimo" (spec 6.1).
A skill frontend-design deve estar ativa para todo trabalho visual.
A cada página: renderize, tire screenshots em 390 e 1280, compare com a prancha
e com o wireframe aprovado, e corrija antes de seguir. Commit por tarefa.
No marco, confira item a item a lista da spec 6.1 e me mostre as screenshots
de todas as páginas, inclusive as de rascunho.
```

**Pontos de atenção** (cobre do Claude se ele desviar):

- Se aparecer `npm`, `package.json`, React ou Tailwind, **está errado**. É Quarto.
- O nome da publicação só via `{{< var publicacao.nome >}}`.
- Links relativos, para o site funcionar também em `ufrgs.br/macroliga`.
- Fontes: carregar só os pesos usados.
- Rascunhos (`draft: true`) aparecem no `quarto preview` e não existem no `_site/`.

**Pronto quando** (lista completa na spec, seção 6.1):

- `quarto preview` mostra Início (fascículo "em breve", próximo evento com o lançamento), Publicações (em breve), Eventos, a página do evento de lançamento, Sobre, Equipe, Participe (seleção fechada) e 404;
- o fascículo nº 1 e os 4 textos aparecem completos no preview, como rascunho, com os filtros por eixo e tipo funcionando;
- o `quarto render` gera um `_site/` sem nenhum rascunho, sem "Gráficos comentados" no menu e sem botão que leve a página inexistente.

---

## Fase 6: Revisão

```
Faça uma revisão completa do site renderizado:
1. Acessibilidade (WCAG AA): contraste (atenção ao vermelho sobre azul, que dá 2,1:1),
   foco de teclado, ordem de tabulação, alt das imagens, landmarks, lang="pt".
2. Celular: 360, 390 e 430 px — nada cortado, toques ≥ 44 px, menu funciona.
3. prefers-reduced-motion desliga a animação.
4. Desempenho: peso de cada página, fontes, imagens (converter para WebP se preciso).
5. Compartilhamento: título, descrição e imagem Open Graph de cada página
   (o link vai circular no Instagram e no LinkedIn).
6. Voz: releia todo texto visível contra a seção 5 do CLAUDE.md.
Liste os problemas por gravidade, corrija os graves e me mostre o resto.
```

**Pronto quando:** não restar nenhum problema grave.

---

## Fase 7: Publicação

```
Vamos publicar no GitHub Pages:
1. Crie o repositório público macroliga-ufrgs.github.io na organização macroliga-ufrgs
   (me diga os comandos se precisar que eu faça algo no navegador).
2. Configure e rode quarto publish gh-pages.
3. Configure o contador de visitas gratuito definido na spec (sem banner de cookies).
4. Confira o site no ar, no celular, e me passe o link final.
```

Depois:

- [ ] Pôr o link na bio do Instagram e no LinkedIn
- [ ] Pedir ao prof. Leonardo que solicite `ufrgs.br/macroliga` ao CPD (opcional). Quando sair, o mesmo site é copiado para lá
- [ ] Preencher o campo "Página da Web" da proposta de extensão

---

## Fase 8: Manutenção e nº 1 (até 22/11)

### 8.1 Comandos para a equipe

```
Crie comandos do Claude Code em .claude/commands/ para a equipe de Comunicação:
- /novo-texto: pergunta título, autor, tipo, eixo, fascículo, síntese, DOI, revisor;
  cria a pasta a partir de publicacoes/_modelo-texto/ e preenche o YAML.
- /novo-fasciculo: cria o fascículo a partir do modelo e liga os textos.
- /novo-evento e /novo-grafico: idem.
- /publicar: renderiza, confere erros e roda quarto publish gh-pages.
E escreva o LEIA-ME.md da raiz para quem nunca usou Quarto, Git ou Claude Code:
instalar, pré-visualizar, adicionar conteúdo (com e sem Claude Code) e publicar.
```

### 8.2 Lançamento do nº 1 (semana de 16/11)

1. Depositar os PDFs no Zenodo (comunidade "MacroLiga UFRGS") e anotar os DOIs.
2. `/novo-fasciculo` e `/novo-texto` (4×) com os DOIs.
3. Link do questionário em `_variables.yml`.
4. Revisão (fase 6, em versão curta) e `/publicar` **no dia do lançamento**, não antes.

---

## Dicas de uso do Claude Code

- **Uma fase por sessão.** Use `/clear` entre fases; a continuidade está em `CLAUDE.md`, `docs/` e nos commits.
- **Peça para ver.** Toda mudança visual deve vir com screenshot. Se ele disser "pronto" sem mostrar, peça.
- **Feedback por código de bloco e com motivo.** "Corte I5, repete o I2" funciona melhor que "a página está poluída".
- **Lembre o Claude da marca** se ele propuser cores ou fontes novas: "a marca é fixa; ver CLAUDE.md seção 6".
- **Registre o que funcionou.** A `frontend-design` sugere manter notas do que já se tentou; use `docs/notas-design.md`.
