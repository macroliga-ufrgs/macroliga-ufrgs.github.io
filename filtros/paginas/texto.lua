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
    '<nav class="trilha" aria-label="Trilha"><a href="../index.qmd">Voltar ao fascículo nº&nbsp;' .. comum.esc(n) .. '</a></nav>',
    '<header class="texto__cabecalho">',
    '<p class="texto__tipo">' .. comum.esc(tipo) .. '</p>',
    '<h1 class="titulo-longo">' .. comum.esc(titulo) .. '</h1>',
    '<p class="texto__autor">' .. comum.esc(autor) .. '</p>',
    '</header>',
    '<div class="texto__grade">',
    '<div class="texto__lateral" role="complementary" aria-label="Dados do texto">',
    '<div class="acoes texto__acoes">', table.concat(acoes, "\n"), '</div>',
    dados("texto__dados--lateral"),
    '</div>',
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
    blocos:insert(comum.html('<section class="outros-textos secao" aria-labelledby="titulo-outros">\n<h2 id="titulo-outros">Outros textos do fascículo nº&nbsp;' .. comum.esc(n) .. '</h2>'))
    blocos:insert(pandoc.Div({}, pandoc.Attr("lista-outros")))
    blocos:insert(comum.html('</section>'))
  end
  blocos:insert(comum.aviso_institucional())

  doc.blocks = pandoc.Blocks({ pandoc.Div(blocos, pandoc.Attr("", { "conteiner", "pagina", "texto" })) })
  comum.script("citacao")
  return doc
end
