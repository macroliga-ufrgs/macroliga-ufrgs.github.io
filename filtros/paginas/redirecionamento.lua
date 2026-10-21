-- filtros/paginas/redirecionamento.lua: endereços curtos da página final do fascículo
-- (nNN, nNN/opine, nNN/opine/pdf). O PDF depositado no Zenodo não muda mais; estes
-- endereços podem ser redirecionados depois. Com "destino", leva a uma página do site
-- (caminho relativo); com "numero" e "canal", leva ao questionário com a origem
-- "<nome da publicação> nº <numero> · <canal>" já preenchida. O validar.lua confere os campos.
return function(doc, comum)
  local m = doc.meta
  local url = comum.texto(m.destino)
  if url == "" then
    local nome = comum.texto(m.publicacao and m.publicacao.nome)
    local origem = string.format("%s nº %s · %s", nome, comum.texto(m.numero), comum.texto(m.canal))
    url = comum.url_questionario(m, origem)
    if not url then
      comum.parar("questionario.url está vazio em _variables.yml: o endereço "
        .. comum.relativo(quarto.doc.input_file) .. " não tem para onde levar.")
    end
  end
  local destino = comum.esc(url)
  quarto.doc.include_text("in-header", table.concat({
    '<meta http-equiv="refresh" content="0; url=' .. destino .. '">',
    '<meta name="robots" content="noindex">',
  }, "\n"))
  doc.blocks = pandoc.Blocks({ comum.html(table.concat({
    '<div class="conteiner pagina">',
    '<h1>Redirecionando…</h1>',
    '<p><a href="' .. destino .. '">Se nada acontecer, toque aqui.</a></p>',
    '</div>',
  }, "\n")) })
  return doc
end
