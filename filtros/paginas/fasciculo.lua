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
    '<nav class="trilha" aria-label="Trilha"><a href="../index.qmd">Publicações</a> / Fascículo nº&nbsp;' .. comum.esc(n) .. '</nav>',
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
    '<section class="sumario-fasciculo secao" aria-labelledby="t-sumario">',
    '<h2 id="t-sumario">Sumário</h2>',
  }

  local depois = { '</section>' }
  local evento = comum.texto(y.evento)
  if evento ~= "" then
    local ev = comum.cabecalho(comum.caminho(comum.raiz(), "eventos", evento, "index.qmd"))
    if not ev then comum.parar('Fascículo nº ' .. n .. ': o evento "' .. evento .. '" (campo "evento") não existe em eventos/.') end
    local realizado = comum.texto(ev.situacao) == "realizado"
    table.insert(depois, '<section class="lancamento secao" aria-labelledby="t-lancamento">')
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
