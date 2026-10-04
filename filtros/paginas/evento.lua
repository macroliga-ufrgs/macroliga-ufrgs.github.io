-- filtros/paginas/evento.lua: página de um evento (spec 2.9). Tudo vem do cabeçalho YAML;
-- a descrição é o corpo do index.qmd. Nenhum texto fixo de local: o local vem do campo.
return function(doc, comum)
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local quando = comum.texto(y.quando)
  local data = quando ~= "" and quando or comum.data_extenso(y.date)
  doc.meta["data-exibida"] = pandoc.Inlines(data)

  local topo = {
    '<nav class="trilha" aria-label="Trilha"><a href="../index.qmd">Voltar aos eventos</a></nav>',
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
