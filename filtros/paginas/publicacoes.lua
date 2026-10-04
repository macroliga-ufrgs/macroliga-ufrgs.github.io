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
