# LEIA-ME: como cuidar do site da MacroLiga UFRGS

Este guia é para quem nunca usou Quarto, Git ou terminal. Siga na ordem. Cada passo diz o que fazer, o que digitar e o que você deve ver na tela.

O site está em <https://macroliga-ufrgs.github.io>. Não tem custo: é gerado com o [Quarto](https://quarto.org) e hospedado de graça no GitHub Pages.

## Sumário

1. [Como o site funciona, em 1 minuto](#1-como-o-site-funciona-em-1-minuto)
2. [Instalar (uma vez só)](#2-instalar-uma-vez-só)
3. [A rotina de trabalho](#3-a-rotina-de-trabalho)
4. [Ver o site no seu computador](#4-ver-o-site-no-seu-computador)
5. [Rascunho ou definitivo](#5-rascunho-ou-definitivo)
6. [Como preencher um cabeçalho (YAML)](#6-como-preencher-um-cabeçalho-yaml)
7. [Receitas: textos, fascículos, eventos e páginas](#7-receitas-textos-fascículos-eventos-e-páginas)
8. [Salvar e enviar ao GitHub](#8-salvar-e-enviar-ao-github)
9. [Publicar](#9-publicar)
10. [Quando algo dá errado](#10-quando-algo-dá-errado)
11. [Arquivos que não se mexem](#11-arquivos-que-não-se-mexem)

---

## 1. Como o site funciona, em 1 minuto

O site é uma pasta de arquivos de texto. Cada página, texto, fascículo e evento é um arquivo `index.qmd` dentro de uma pasta própria. Você não programa: copia uma pasta-modelo e preenche um formulário no topo do arquivo, chamado **cabeçalho**.

O trabalho sempre segue quatro etapas:

1. **Editar** os arquivos no seu computador.
2. **Conferir** o resultado no navegador, com o site rodando só na sua máquina (`quarto preview`).
3. **Guardar** a mudança no GitHub, para que o resto da equipe a receba (`git commit` e `git push`).
4. **Publicar** o site, para que o público veja (`quarto publish gh-pages`).

Até a etapa 4, nada muda no site que o público vê. Você pode testar à vontade.

### Palavras que aparecem neste guia

| Palavra | O que é |
|---|---|
| **Terminal** | Janela onde você digita comandos. Usaremos o terminal que vem dentro do VS Code. |
| **Comando** | Uma linha que você digita no terminal e confirma com Enter. Neste guia, os comandos aparecem em caixas cinzas. Copie e cole. |
| **Quarto** | O programa que transforma os arquivos `.qmd` em páginas de site. |
| **Git** | O programa que guarda o histórico de todas as mudanças, como o "controle de alterações" do Word, só que para a pasta inteira. |
| **GitHub** | O site onde a pasta da liga fica guardada na nuvem, com o histórico do Git. |
| **Repositório** | A pasta do site, com todo o histórico. |
| **Commit** | Um "ponto de salvamento" com uma frase que descreve a mudança. |
| **Push** e **pull** | Enviar seus commits ao GitHub (push) e receber os commits dos colegas (pull). |
| **YAML** | O formato do cabeçalho: linhas `campo: valor`. |
| **Rascunho** | Item com `draft: true` no cabeçalho. Não aparece no site publicado. |

---

## 2. Instalar (uma vez só)

Leva cerca de 30 minutos. Todos os programas são gratuitos.

### 2.1 Conta no GitHub e acesso à liga

1. Crie uma conta em <https://github.com/signup> (pode usar o e-mail pessoal).
2. Mande o seu nome de usuário do GitHub para quem já administra a organização `macroliga-ufrgs` e peça um convite com permissão de escrita.
3. Aceite o convite: ele chega por e-mail e também aparece em <https://github.com/macroliga-ufrgs>.

### 2.2 Programas

Instale os quatro, nesta ordem. Em todos, aceite as opções que já vêm marcadas.

| Programa | Para quê | Windows | Mac |
|---|---|---|---|
| **VS Code** | Editar os arquivos e abrir o terminal | <https://code.visualstudio.com> | <https://code.visualstudio.com> |
| **Git** | Histórico e envio das mudanças | <https://git-scm.com/downloads/win> | Abra o app Terminal, digite `git --version` e aceite instalar as "ferramentas de linha de comando" |
| **GitHub CLI** | Fazer login no GitHub pelo terminal | <https://cli.github.com> (botão de download) | <https://cli.github.com> (botão de download) |
| **Quarto** | Gerar o site | <https://quarto.org/docs/get-started/> | <https://quarto.org/docs/get-started/> |

O R **não** é necessário para textos, fascículos, eventos ou para a equipe. Ele só será usado nos gráficos comentados (seção 7.9).

### 2.3 Abrir o terminal

1. Abra o VS Code.
2. No menu, clique em **Terminal → New Terminal** (ou **Terminal → Novo Terminal**, se o VS Code estiver em português).
3. Uma janela aparece na parte de baixo. É ali que você digita os comandos.

Confira se tudo foi instalado. Digite cada linha e aperte Enter:

```
git --version
gh --version
quarto --version
```

Cada uma deve responder com um número de versão (por exemplo, `1.10.18`). Se aparecer "não reconhecido" ou "command not found", feche o VS Code inteiro, abra de novo e repita. Se ainda falhar, reinstale o programa que falhou.

### 2.4 Fazer login no GitHub

Digite:

```
gh auth login
```

O terminal faz algumas perguntas. Use as setas do teclado para escolher e Enter para confirmar:

| Pergunta | Resposta |
|---|---|
| Where do you use GitHub? | `GitHub.com` |
| What is your preferred protocol for Git operations? | `HTTPS` |
| Authenticate Git with your GitHub credentials? | `Yes` |
| How would you like to authenticate GitHub CLI? | `Login with a web browser` |

O terminal mostra um código de 8 letras. Aperte Enter, o navegador abre, cole o código e autorize. No fim, o terminal diz `Logged in as seu-usuario`.

### 2.5 Dizer ao Git quem você é

Troque o nome e o e-mail pelos seus (use o mesmo e-mail da conta do GitHub):

```
git config --global user.name "Seu Nome"
git config --global user.email "seu-email@exemplo.com"
```

Isso fica gravado no computador. Seu nome aparece no histórico de cada mudança que você fizer.

Digite também estas duas linhas, exatamente como estão. Elas fazem o `git pull` juntar as suas mudanças com as dos colegas sem abrir janelas nem fazer perguntas:

```
git config --global pull.rebase true
git config --global rebase.autoStash true
```

### 2.6 Baixar o site

Escolha onde guardar a pasta. O exemplo abaixo usa a pasta Documentos:

```
cd ~/Documents
gh repo clone macroliga-ufrgs/macroliga-ufrgs.github.io
```

Isso cria a pasta `macroliga-ufrgs.github.io` dentro de Documentos.

Agora abra a pasta no VS Code: **File → Open Folder** (ou **Arquivo → Abrir Pasta**), escolha `Documentos/macroliga-ufrgs.github.io` e confirme. Se o VS Code perguntar se você confia nos autores da pasta, responda que sim.

A partir daqui, **sempre** trabalhe com essa pasta aberta no VS Code. O terminal do VS Code já abre dentro dela.

> Se o VS Code sugerir instalar a extensão "Quarto", pode aceitar. Ela colore o cabeçalho e ajuda a achar erros, mas não é obrigatória.

---

## 3. A rotina de trabalho

Toda vez que for mexer no site, siga esta sequência. Guarde-a.

| Passo | O que digitar no terminal | O que acontece |
|---|---|---|
| 1 | `git pull` | Recebe as mudanças dos colegas |
| 2 | `quarto preview --profile rascunhos` | Abre o site no navegador. Deixe rodando |
| 3 | (nada) | Edite os arquivos e confira no navegador |
| 4 | Ctrl+C | Para o preview |
| 5 | `git add -A` | Separa tudo o que mudou |
| 6 | `git commit -m "Adiciona evento de dezembro"` | Salva, com uma frase que descreve a mudança |
| 7 | `git push` | Envia ao GitHub |
| 8 | `quarto publish gh-pages` | Publica. Só quando for para o público ver |

**Por que começar com `git pull`?** Se um colega mudou algo ontem e você não puxou, seu computador está desatualizado. Pior: se você publicar assim, a mudança do colega some do site.

---

## 4. Ver o site no seu computador

No terminal do VS Code, digite:

```
quarto preview
```

Depois de alguns segundos, o navegador abre o site. Ele roda só no seu computador: ninguém mais vê. Cada vez que você salva um arquivo (Ctrl+S, ou Cmd+S no Mac), a página se atualiza sozinha.

Para ver também os **rascunhos** (itens com `draft: true`, como o fascículo antes do lançamento), use:

```
quarto preview --profile rascunhos
```

Na dúvida, use sempre este segundo comando enquanto estiver trabalhando. O primeiro mostra o site exatamente como ficará depois de publicado.

**Para parar o preview**, clique no terminal e aperte **Ctrl+C** (também no Mac). Você precisa parar o preview para digitar outros comandos, ou então abrir um segundo terminal com o botão **+** do painel.

**Se a página não mudou depois de salvar**, olhe o terminal. Se houver um erro, ele aparece ali (veja a seção 10) e o navegador continua mostrando a última versão que funcionou.

---

## 5. Rascunho ou definitivo

Textos, fascículos e eventos podem existir em dois estados:

| | Rascunho (`draft: true`) | Definitivo (sem a linha `draft`) |
|---|---|---|
| Aparece no `quarto preview --profile rascunhos` | Sim | Sim |
| Aparece no `quarto preview` | Não | Sim |
| Aparece no site publicado | **Não** (nem página, nem item de lista) | Sim |
| Aceita campos provisórios (`"[a preencher]"`) em `sintese`, `revisao`, `doi`, `pdf` | Sim | Não: o site recusa e mostra o erro |

**Para criar um rascunho:** deixe a linha `draft: true` no cabeçalho. Os modelos já vêm com ela.

**Para tornar definitivo:** apague a linha `draft: true` inteira. Não escreva `draft: false`; apague.

> **Atenção: o repositório é público.** Um rascunho não aparece no site, mas qualquer pessoa pode abrir os arquivos no GitHub. O cabeçalho (título, autor, síntese) fica visível ali. Por isso:
>
> - **nunca** ponha PDFs ou textos em revisão dentro de `publicacoes/` antes do lançamento;
> - guarde esse material na pasta `rascunhos/`, na raiz do site. Ela existe só no seu computador: o Git a ignora e ela nunca vai para o GitHub.

---

## 6. Como preencher um cabeçalho (YAML)

O cabeçalho fica no topo de cada `index.qmd`, entre duas linhas `---`. Exemplo real, do texto do Miguel no fascículo nº 1:

```yaml
---
title: "Impactos setoriais do acordo Mercosul e União Europeia"
author: "Miguel Amorin"
tipo: "Análise de conjuntura"
eixo: "Setor externo e câmbio"
fasciculo: 1
ordem: 2
date: 2026-11-27
draft: true
---
```

Cada linha é `campo: valor`. As regras:

1. **Não mude o nome do campo** (a parte antes dos dois-pontos). Mude só o valor.
2. **Texto vai entre aspas duplas:** `title: "Inflação de serviços"`. Isso evita quase todos os erros.
3. **Números e datas vão sem aspas:** `fasciculo: 2`, `date: 2027-05-20`.
4. **Datas sempre no formato ano-mês-dia:** `2027-05-20`. O site mostra "20 de maio de 2027" sozinho.
5. **Um espaço depois dos dois-pontos:** `ordem: 1`, nunca `ordem:1`.
6. **Não use a tecla Tab** para alinhar. Use espaços.
7. **Tudo depois de `#` é comentário:** o site ignora. Os modelos usam comentários para explicar cada campo. Pode deixar ou apagar.
8. **Campo vazio é `""`** (duas aspas coladas), não um espaço em branco.
9. **Aspas dentro do texto:** se o título tiver aspas, use aspas simples dentro: `title: "O 'pouso suave' da economia"`.

### Erros de YAML mais comuns

| Você escreveu | Problema | Correção |
|---|---|---|
| `sintese: O Copom: juros em alta` | Dois-pontos no meio de um texto sem aspas | `sintese: "O Copom: juros em alta"` |
| `title: "Inflação de serviços` | Aspas abertas e não fechadas | `title: "Inflação de serviços"` |
| `eixo: "Setor Externo"` | O eixo precisa ser escrito exatamente como na lista | `eixo: "Setor externo e câmbio"` |
| `date: 20/05/2027` | Formato de data errado | `date: 2027-05-20` |
| `draft: false` | Funciona, mas confunde | Apague a linha |

As listas oficiais de **eixos** e **tipos** ficam em `_variables.yml`. Copie de lá, letra por letra, com as mesmas maiúsculas e acentos.

---

## 7. Receitas: textos, fascículos, eventos e páginas

### 7.1 Copiar uma pasta-modelo (vale para todas as receitas)

Os modelos ficam em pastas que começam com `_` (sublinhado). O Quarto ignora essas pastas, então elas nunca aparecem no site.

No VS Code, na barra da esquerda (Explorer):

1. Clique com o botão direito na pasta-modelo (por exemplo, `publicacoes/_modelo-texto`) e escolha **Copy** (Copiar).
2. Clique com o botão direito na pasta de destino (por exemplo, `publicacoes/n02`) e escolha **Paste** (Colar).
3. Clique com o botão direito na cópia, escolha **Rename** (Renomear) e dê o nome novo.

Copie **a pasta inteira**, não só o `index.qmd`: ela tem também um arquivo `_metadata.yml`, que faz a página funcionar.

**Nomes de pasta** (o "slug", que vira o endereço da página): minúsculas, sem acento, sem cedilha, palavras separadas por hífen, curto.

| Título | Nome da pasta |
|---|---|
| Inflação de serviços e o mercado de trabalho | `inflacao-servicos-mercado-trabalho` |
| Lançamento do fascículo nº 2 (evento em 20/05/2027) | `2027-05-20-lancamento-n02` |

### 7.2 Adicionar um texto como rascunho

**Exemplo:** o fascículo nº 2 vai ter um texto de Fulana de Tal sobre inflação de serviços.

1. `git pull` no terminal.
2. Copie `publicacoes/_modelo-texto/` para dentro de `publicacoes/n02/` e renomeie a cópia para `inflacao-servicos-mercado-trabalho` (seção 7.1). Se a pasta `n02` ainda não existir, crie primeiro o fascículo (seção 7.4).
3. Abra `publicacoes/n02/inflacao-servicos-mercado-trabalho/index.qmd` e preencha:

```yaml
---
title: "Inflação de serviços e o mercado de trabalho"
author: "Fulana de Tal"
autor-citacao: ""
tipo: "Análise de conjuntura"
eixo: "Política monetária e inflação"
fasciculo: 2
ordem: 1
date: 2027-05-20
sintese: "[síntese provisória: a preencher pela autora]"
revisao: "[revisor a confirmar]"
doi: ""
pdf: "texto.pdf"
draft: true
---
```

4. Salve e rode `quarto preview --profile rascunhos`. Abra **Publicações**: o texto aparece na lista e no sumário do fascículo nº 2.
5. Pare o preview (Ctrl+C) e envie ao GitHub (seção 8) com a mensagem `"Adiciona rascunho do texto sobre inflação de serviços"`.

Não precisa escrever nada abaixo do cabeçalho: a página do texto inteira (autor, eixo, botão do PDF, citação ABNT, nota de revisão, questionário) é montada a partir dele.

**O que cada campo significa:**

| Campo | O que escrever | Obrigatório |
|---|---|---|
| `title` | Título em *sentence case*: só a primeira letra e os nomes próprios em maiúscula | Sim |
| `author` | Nome e sobrenome de quem assina (um nome só) | Sim |
| `autor-citacao` | Só se o sobrenome for composto. O site monta "TAL, Fulana de" sozinho; se o certo for "SILVA, Leonardo Xavier da", escreva assim aqui | Não |
| `tipo` | Um destes: `Análise de conjuntura`, `Revisão de literatura`, `Nota de pesquisa`, `Texto de opinião` | Sim |
| `eixo` | Um dos 6 eixos de `_variables.yml`, escrito igual | Sim |
| `fasciculo` | O número do fascículo (o mesmo da pasta: `n02` → `2`) | Sim |
| `ordem` | A posição do texto no sumário: 1, 2, 3… | Sim |
| `date` | A data de lançamento do fascículo | Sim |
| `sintese` | Duas ou três frases que resumem o texto. Aparece na página e no Instagram/LinkedIn quando alguém compartilha o link | Sim |
| `revisao` | Professor que revisou, no formato `"Prof. Nome Sobrenome (FCE/UFRGS)"` | Sim |
| `doi` | O DOI do texto no Zenodo, por exemplo `"10.5281/zenodo.1234567"`. Vazio = usa o DOI do fascículo | Só no definitivo, se o fascículo não tiver DOI |
| `pdf` | O nome do arquivo PDF do texto, que fica nesta mesma pasta | Só no definitivo |
| `draft` | `true` enquanto for rascunho. Apague a linha para publicar | Não |

> Coautoria: o modelo aceita um nome por texto. Se um texto tiver mais de uma pessoa autora, fale com quem mantém o site antes de publicar.

### 7.3 Transformar um texto em definitivo

Faça isso **só no dia do lançamento** (seção 7.5), porque é aí que os PDFs podem ficar públicos.

1. Copie o PDF do texto para a pasta dele, com o nome que está no campo `pdf` (por exemplo, `texto.pdf`).
2. Troque os campos provisórios pelos reais:

```yaml
sintese: "O texto mostra como a inflação de serviços acompanha os salários desde 2022 e o que isso significa para a política monetária."
revisao: "Prof. Fulano de Tal (FCE/UFRGS)"
doi: "10.5281/zenodo.1234567"
pdf: "texto.pdf"
```

3. Apague a linha `draft: true`.
4. Rode `quarto preview` (sem `--profile`): agora o texto aparece mesmo no modo que imita o site publicado. Se faltar algo (PDF, DOI, síntese), o terminal diz exatamente o quê (seção 10).

### 7.4 Criar um fascículo

**Exemplo:** criar o nº 2, a ser lançado em 20/05/2027.

1. Copie `publicacoes/_modelo-fasciculo/` para `publicacoes/` e renomeie a cópia para `n02`. Sempre dois dígitos: `n02`, `n03`… `n10`.
2. Ponha a imagem da capa dentro de `publicacoes/n02/`, com o nome `capa.png`. Formato retrato A4 (por exemplo, 910 × 1287 px), com até 300 KB.
3. Preencha `publicacoes/n02/index.qmd`:

```yaml
---
numero: 2
date: 2027-05-20
capa: "capa.png"
capa-alt: "Capa do fascículo nº 2"
pdf: "fasciculo.pdf"
doi: ""
evento: "2027-05-20-lancamento-n02"
draft: true
---
```

Não escreva o título: "Pontos de Macro nº 2" (ou o nome que a publicação tiver) é montado sozinho.

| Campo | O que escrever |
|---|---|
| `numero` | O número do fascículo |
| `date` | A data do lançamento |
| `capa`, `capa-alt` | O arquivo da capa e uma descrição curta dela, para leitores de tela |
| `pdf` | O nome do PDF completo, que fica nesta pasta (só no lançamento) |
| `doi` | O DOI do fascículo no Zenodo (só no lançamento) |
| `evento` | Opcional: o nome da pasta do evento de lançamento. Liga o fascículo ao evento |
| `draft` | `true` até o lançamento |

4. Os textos do fascículo são as pastas dentro de `publicacoes/n02/` (seção 7.2). O sumário e a contagem de textos se montam sozinhos.
5. **Anuncie o fascículo** enquanto ele não sai. Em `publicacoes/em-breve.yml`, liste os títulos e autores. Eles aparecem na Início e em Publicações como "Fascículo nº 2: em breve", sem link:

```yaml
- numero: 2
  textos:
    - { titulo: "Inflação de serviços e o mercado de trabalho", autor: "Fulana de Tal" }
    - { titulo: "Outro título do fascículo", autor: "Beltrano de Tal" }
```

Se não houver nenhum fascículo anunciado, o arquivo fica só com `[]`.

### 7.5 No dia do lançamento

Siga a lista na ordem. Reserve uma hora.

1. `git pull`.
2. Deposite os PDFs no Zenodo (comunidade da MacroLiga) e anote os DOIs: um do fascículo e, se houver, um de cada texto.
3. Copie `fasciculo.pdf` para a pasta do fascículo (ex.: `publicacoes/n02/`) e cada `texto.pdf` para a pasta do seu texto.
4. No fascículo, preencha `doi` e apague `draft: true`.
5. Em cada texto, preencha `sintese`, `revisao` e `doi` (seção 7.3) e apague `draft: true`.
6. Em `publicacoes/em-breve.yml`, apague o anúncio e deixe só `[]` (ou anuncie o próximo fascículo).
7. Rode `quarto preview` (sem `--profile`) e confira: Início, Publicações, o fascículo e cada texto. Clique em "Baixar PDF" em todos.
8. Em um texto, clique em "Responder ao questionário": o formulário deve abrir com o título do texto já escrito em "O que você leu?". Se não abrir assim, veja a seção 7.8.
9. Envie ao GitHub (seção 8): `"Publica o fascículo nº 2"`.
10. Publique (seção 9).

### 7.6 Criar um evento

**Exemplo:** um debate sobre a reforma tributária em 10/12/2026.

1. Copie `eventos/_modelo/` para `eventos/` e renomeie a cópia para `2026-12-10-debate-reforma-tributaria` (data no começo, como `aaaa-mm-dd-nome`).
2. Preencha `eventos/2026-12-10-debate-reforma-tributaria/index.qmd`:

```yaml
---
title: "Debate: o que muda com a reforma tributária"
date: 2026-12-10
quando: ""
horario: "19h"
local: "FCE/UFRGS, sala 101"
situacao: "proximo"
inscricao: "https://forms.gle/exemplo"
fasciculo:
capa: ""
capa-alt: ""
fotos: ""
---

Dois membros da liga apresentam as principais mudanças da reforma e o que dizem as diferentes visões sobre ela. Aberto a estudantes de qualquer curso.
```

O texto **abaixo** do segundo `---` é a descrição do evento: um ou dois parágrafos.

| Campo | O que escrever |
|---|---|
| `title` | Nome do evento |
| `date` | Data do evento. Ordena a lista |
| `quando` | Opcional: substitui a data exibida, ex.: `"Semana de 23/11/2026, data a confirmar"` |
| `horario` | Ex.: `"19h"` |
| `local` | Texto livre: `"FCE/UFRGS, sala 101"` ou `"On-line, link enviado após a inscrição"` |
| `situacao` | `"proximo"` antes do evento; `"realizado"` depois (troque à mão) |
| `inscricao` | O link do formulário: aparece o botão "Fazer inscrição". Vazio (`""`): aparece "Inscrições em breve.". `"livre"`: aparece "Entrada livre, sem inscrição." |
| `fasciculo` | Só em lançamento: o número do fascículo, ex.: `2`. Nos outros eventos, deixe vazio |
| `capa`, `capa-alt` | Depois do evento: a foto de capa e a descrição dela |
| `fotos` | Depois do evento: o link do álbum de fotos da liga |

3. Confira no `quarto preview`: o evento aparece em **Eventos → Próximos eventos** e, se for o mais próximo, na Início.
4. Envie ao GitHub e publique.

Eventos não precisam de `draft`: em geral eles entram no site assim que são anunciados. Se quiser preparar um evento antes do anúncio, ponha `draft: true` e apague a linha no dia de divulgar.

### 7.7 Depois de um evento

1. No `index.qmd` do evento, troque `situacao: "proximo"` por `situacao: "realizado"`.
2. Ponha **uma** foto de capa na pasta do evento: JPG horizontal (3:2, por exemplo 1500 × 1000 px), com até 400 KB, chamada `capa.jpg`. As outras fotos ficam no álbum externo, não no repositório.
3. Preencha:

```yaml
situacao: "realizado"
capa: "capa.jpg"
capa-alt: "Quatro estudantes sentados à mesa apresentam os textos para o auditório da FCE"
fotos: "https://link-do-album-da-liga"
```

`capa-alt` descreve a foto para quem não pode vê-la. É obrigatório quando há capa: sem ele, o site mostra um erro.

### 7.8 Mudar e-mail, redes, questionário ou o nome da publicação

Tudo o que se repete no site fica em `_variables.yml`. Mude lá e o site inteiro acompanha.

```yaml
publicacao:
  nome: "Pontos de Macro"          # nome dos fascículos
contato:
  email: "macroliga.ufrgs@gmail.com"
  instagram: "@macroliga.ufrgs"
  instagram-url: "https://www.instagram.com/macroliga.ufrgs/"
questionario:
  url: "https://docs.google.com/forms/d/e/1FAIpQL.../viewform"   # aparece em toda página de texto, de fascículo e de gráfico
  campo-pagina: "entry.914996542"   # a pergunta "O que você leu?", que recebe o título da página
```

- **Questionário:** é um formulário só, do Google Forms, na conta da liga. O botão "Responder ao questionário" abre o formulário com o título da página já escrito na pergunta "O que você leu?". Enquanto `url` estiver vazio, o botão não aparece e o terminal mostra um aviso amarelo. É um aviso, não um erro: o site funciona.
  - Em `url`, use o **endereço longo**, que começa com `https://docs.google.com/forms/d/e/` e termina em `/viewform`. Nunca use o encurtado (`forms.gle/...`): ele pode perder o título preenchido.
  - Para achar o `campo-pagina`: no formulário, abra o menu ⋮ e clique em **Obter link preenchido**, escreva `TESTE` em "O que você leu?" e copie o link. O trecho antes de `=TESTE` (ex.: `entry.914996542`) é o valor.
  - Pode mudar o texto das perguntas à vontade. Se apagar e recriar a pergunta "O que você leu?", o número `entry` muda: repita o passo acima.
- **Eixos e tipos:** a lista também está aqui. Só mude com acordo da Presidência, porque os textos já publicados precisam usar os nomes novos.
- **Nunca** escreva o nome da publicação direto em outro arquivo. Ele ainda pode mudar.

### 7.9 Atualizar a equipe

Edite `equipe.yml`. Ele tem três listas, e cada pessoa é uma linha:

```yaml
conselho:
  - { nome: "Fulana de Tal", genero: "feminino", presidente: true, foto: "" }
  - { nome: "Beltrano de Tal", genero: "masculino", presidente: false, foto: "" }
membros:
  - { nome: "Sicrana de Tal", foto: "" }
fundadores:
  - { nome: "Fulana de Tal", foto: "" }
```

- **`conselho`:** quem está no Conselho Executivo. `genero` é `"feminino"` ou `"masculino"` e define se o site escreve "Conselheira" ou "Conselheiro". Uma pessoa só tem `presidente: true` (aparece como "Presidente" e vem primeiro); as demais têm `presidente: false`.
- **`membros`:** quem está na liga e não está no conselho. Ninguém aparece nas duas listas.
- **`fundadores`:** as pessoas que criaram a liga. **Nunca apague ninguém desta lista**, nem quando a pessoa se formar. Por isso um fundador também pode aparecer no conselho ou entre os membros.
- A página mostra as listas nesta ordem: Conselho Executivo, Membros, Membros fundadores. Uma lista vazia não aparece.
- Mantenha o recuo (os espaços no começo da linha) igual ao das linhas vizinhas.
- Se o render parar com uma mensagem `[MacroLiga] equipe.yml: ...`, ela diz o que corrigir: um gênero escrito diferente de `"feminino"`/`"masculino"` ou mais de uma pessoa com `presidente: true`.
- `foto` fica vazia (`""`) até a liga ter o termo de uso de imagem assinado. Depois, ponha a foto quadrada em `assets/equipe/` e escreva o caminho: `foto: "assets/equipe/fulana-de-tal.jpg"`.
- A cada nova gestão, troque os nomes do conselho e dos membros e apague quem saiu (menos dos fundadores).

### 7.10 Abrir ou fechar o processo seletivo

No cabeçalho de `participe.qmd`, mude o bloco `selecao`:

```yaml
selecao:
  aberta: true
  prazo: "30 de outubro de 2026"
  formulario: "https://forms.gle/exemplo"
```

Quando o prazo acabar, volte `aberta` para `false`. Não precisa apagar o prazo nem o link.

### 7.11 Gráfico comentado

A página de gráficos comentados ainda está em construção. Quando ela existir, a receita entra aqui. Ela vai exigir o R instalado no computador de quem cria o gráfico.

---

## 8. Salvar e enviar ao GitHub

Depois de conferir no preview, pare-o (Ctrl+C) e digite, um de cada vez:

```
git add -A
git commit -m "Adiciona rascunho do texto sobre inflação de serviços"
git push
```

- `git add -A` separa todos os arquivos que mudaram.
- `git commit -m "..."` cria o ponto de salvamento. Escreva entre as aspas uma frase curta, no imperativo, que diga o que mudou: "Adiciona evento de dezembro", "Corrige a síntese do texto do João", "Fecha o processo seletivo".
- `git push` envia ao GitHub. Os colegas recebem a mudança no próximo `git pull`.

Para ver o que você mudou antes de salvar, use `git status` (lista os arquivos) ou o ícone **Source Control** (Controle do Código-Fonte) na barra da esquerda do VS Code, que mostra as linhas alteradas em verde e vermelho.

**Enviar ao GitHub não publica o site.** O público só vê depois do passo seguinte.

---

## 9. Publicar

Antes de publicar, confira as três coisas:

1. Você fez `git pull` hoje.
2. Você conferiu o resultado com `quarto preview` (sem `--profile`).
3. Você já fez `git push` das suas mudanças (seção 8).

Então digite:

```
quarto publish gh-pages
```

O terminal pergunta `Publish site to https://macroliga-ufrgs.github.io/ using gh-pages?`. Aperte Enter para confirmar. O Quarto gera o site inteiro e envia. Leva de 1 a 3 minutos e termina com uma mensagem dizendo que o site foi publicado.

O site no ar se atualiza em até 5 minutos. Para ver a versão nova, recarregue a página com **Ctrl+F5** (no Mac, **Cmd+Shift+R**).

- **Rascunhos nunca são publicados**, mesmo que estejam no seu computador.
- **Para desfazer uma publicação:** corrija o arquivo (ou devolva `draft: true`), envie ao GitHub e publique de novo. A publicação nova substitui a anterior.

---

## 10. Quando algo dá errado

Primeiro, **leia o terminal**. Quase sempre a resposta está ali.

### Erros que começam com `[MacroLiga]`

O site confere cada cabeçalho e para com uma mensagem em português que diz o arquivo e o que corrigir. Exemplo real:

```
[MacroLiga] Texto "Inflação de serviços e o mercado de trabalho" (publicacoes/n02/inflacao-servicos-mercado-trabalho/index.qmd): o eixo "Setor Externo" não existe. Use um destes: Política monetária e inflação; Setor externo e câmbio; Atividade econômica, mercado de trabalho e crédito; Política fiscal e contas públicas; Mercados externos; Conjuntura política.
```

| A mensagem diz | O que fazer |
|---|---|
| `o eixo "..." não existe` ou `o tipo "..." não existe` | Copie um dos nomes que a própria mensagem lista, com as mesmas maiúsculas e acentos |
| `o campo "..." está vazio` | Preencha esse campo no cabeçalho do arquivo indicado |
| `o arquivo "texto.pdf" (campo "pdf") não está na pasta ...` | Copie o PDF para a pasta indicada, com esse nome exato. Se ainda não é o lançamento, devolva `draft: true` |
| `falta o campo "pdf"` | Preencha `pdf` com o nome do arquivo, ou devolva `draft: true` |
| `falta o DOI` | Preencha `doi` no texto ou no fascículo |
| `a situação "..." não existe` | Use `"proximo"` ou `"realizado"`, sem acento |
| `a capa precisa de uma descrição no campo "capa-alt"` | Escreva uma descrição curta da imagem em `capa-alt` |

Corrija, salve e o preview tenta de novo sozinho.

### Erros que começam com `ERROR: YAMLException`

O cabeçalho está mal escrito. A mensagem mostra o número da linha e uma seta `^` embaixo do ponto do problema:

```
ERROR: YAMLException: bad indentation of a mapping entry (13:21)

 13 | sintese: dois pontos: quebram
--------------------------^
```

Aqui, a linha 13 tem dois-pontos dentro de um texto sem aspas. Veja a tabela da seção 6. As causas mais comuns são aspas não fechadas, dois-pontos sem aspas e Tab no lugar de espaços.

### Outros problemas

| O que acontece | O que fazer |
|---|---|
| `quarto`, `git` ou `gh` "não é reconhecido" / "command not found" | Feche e abra o VS Code. Se continuar, reinstale o programa (seção 2.2) |
| A página não muda depois de salvar | Olhe o terminal: deve haver um erro. Se não houver, recarregue o navegador |
| O item novo não aparece no preview | Ele está com `draft: true` e você usou `quarto preview` sem `--profile rascunhos`. Ou a pasta foi criada no lugar errado: confira o caminho |
| `git push` diz `rejected` ou `fetch first` | Um colega enviou algo antes. Digite `git pull` e depois `git push` de novo |
| `git pull` diz `divergent branches` | Faltaram as duas linhas de configuração da seção 2.5. Digite-as e repita o `git pull` |
| `git pull` fala em `CONFLICT` | Você e um colega mudaram a mesma linha. Não apague nada e não faça mais commits: peça ajuda a quem mantém o site |
| Quero descartar tudo o que mudei desde o último commit | No VS Code, painel **Source Control**, botão de desfazer (seta curva) ao lado de cada arquivo. Isso apaga suas mudanças: confira antes |
| `quarto publish` pede login ou dá erro de permissão | Refaça `gh auth login` (seção 2.4) e confirme que você aceitou o convite da organização |
| O site publicado ainda mostra a versão velha | Espere 5 minutos e recarregue com Ctrl+F5 |

Se nada disso resolver, copie a mensagem inteira do terminal e mande para quem mantém o site, ou para o e-mail da liga.

---

## 11. Arquivos que não se mexem

Estes arquivos e pastas são a maquinaria do site. Mudar um deles pode quebrar todas as páginas. Só mexa se souber o que está fazendo e tiver combinado com a equipe:

- `_quarto.yml`, `_quarto-rascunhos.yml`, `_quarto-subcaminho.yml`, `_brand.yml`
- todos os `_metadata.yml`
- `filtros/`, `modelos-listing/`, `estilos/`, `assets/js/`, `ferramentas/`, `testes/`
- as pastas-modelo `_modelo-texto/`, `_modelo-fasciculo/` e `eventos/_modelo/` (copie, nunca edite)

O que você edita no dia a dia:

| Para mudar | Edite |
|---|---|
| Um texto, fascículo ou evento | O `index.qmd` da pasta dele |
| O anúncio do próximo fascículo | `publicacoes/em-breve.yml` |
| Membros da equipe | `equipe.yml` |
| Processo seletivo | O cabeçalho de `participe.qmd` |
| E-mail, redes, questionário, nome da publicação | `_variables.yml` |
| Textos das páginas Início, Sobre, Equipe e Participe | O texto (fora do cabeçalho) de `index.qmd`, `sobre.qmd`, `equipe.qmd` e `participe.qmd`. Mude só as frases; não apague as linhas que começam com `:::` |

### Testes automáticos (para quem mexe na maquinaria)

Os testes da pasta `testes/` conferem o site inteiro: geram as páginas, mudam cabeçalhos de propósito para provocar erros e verificam o resultado. Quem só edita conteúdo não precisa rodá-los. Quem mexe na maquinaria roda, antes de enviar ao GitHub:

```
bash testes/rodar.sh
```

Eles precisam de Git Bash (vem com o Git no Windows), Python e Google Chrome, e levam de 10 a 15 minutos. No fim de cada arquivo aparece `Tudo certo.` ou a lista do que falhou.

- **Pare qualquer `quarto preview` antes (Ctrl+C no terminal dele).** Os testes alteram e restauram arquivos enquanto rodam. Um preview aberto reage a essas mudanças e renderiza ao mesmo tempo, e os dois processos se atropelam: aparecem falhas sem sentido, erros como `NotFound ... rename 'index.html'` e arquivos `index.html`, `index-listing.json` e `site_libs/` soltos dentro das pastas do site. Se isso acontecer, apague esses arquivos soltos (eles não são do repositório: `git status` os mostra como novos) e rode os testes de novo, sem preview.
- **Alguns testes conferem o conteúdo atual**, como quantos textos tem o fascículo nº 1. Se você acrescentar um texto e um teste falhar com algo como `5 ocorrência(s) ... esperado 4`, o site está certo: atualize o número esperado no arquivo do teste indicado.
