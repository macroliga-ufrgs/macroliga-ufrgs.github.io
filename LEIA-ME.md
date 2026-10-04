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
