-- filtros/paginas/participe.lua: Participe (spec 2.12). A situação da seleção vem de
-- "selecao" no cabeçalho do participe.qmd.
return function(doc, comum)
  local s = doc.meta.selecao or {}
  local aberta = s.aberta == true
  local prazo, formulario = comum.texto(s.prazo), comum.texto(s.formulario)
  local situacao, topo
  if aberta then
    if formulario == "" then comum.parar('participe.qmd: a seleção está aberta, mas falta o link do formulário (selecao.formulario).') end
    if prazo == "" then comum.parar('participe.qmd: a seleção está aberta, mas falta o prazo (selecao.prazo).') end
    situacao = '<p class="selecao__aberta">Inscrições abertas até ' .. comum.esc(prazo) .. '.</p>'
    topo = '<p class="acoes"><a class="botao" href="' .. comum.esc(formulario) .. '">Fazer inscrição no processo seletivo</a></p>'
  else
    situacao = '<p class="estado-vazio selecao__fechada">Não há processo seletivo aberto agora. Siga '
      .. comum.link_instagram(doc.meta) .. ' para saber do próximo.</p>'
  end
  doc.blocks = doc.blocks:walk({
    Div = function(d)
      if d.identifier == "selecao-situacao" then d.content = { comum.html(situacao) } return d end
      if d.identifier == "pa-inscricao-topo" then
        if topo then d.content = { comum.html(topo) } else d.attributes.hidden = "" end
        return d
      end
    end,
  })
  return doc
end
