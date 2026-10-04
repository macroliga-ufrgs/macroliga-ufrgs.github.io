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
