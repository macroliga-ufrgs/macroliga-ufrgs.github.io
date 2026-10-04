-- filtros/paginas/eventos.lua: lista de eventos (spec 2.8): oculta os estados vazios que não se aplicam.
return function(doc, comum)
  local ocultos = {}
  if comum.tem_evento("proximo") then ocultos["ev2-vazio"] = true end
  if comum.tem_evento("realizado") then ocultos["ev3-vazio"] = true end
  doc.blocks = comum.ocultar(doc.blocks, ocultos)
  return doc
end
