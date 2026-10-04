-- filtros/paginas/equipe.lua: Equipe (spec 2.11), lida de equipe.yml.
return function(doc, comum)
  local dados = comum.ler_yaml(comum.caminho(comum.raiz(), "equipe.yml")) or {}
  local eixos_validos = {}
  for _, e in ipairs(doc.meta.eixos or {}) do eixos_validos[comum.texto(e)] = true end

  local h = { '<section class="secao" aria-labelledby="t-diretorias">', '<h2 id="t-diretorias">Diretorias</h2>',
    '<div class="equipe-grade equipe-diretorias">' }
  for _, d in ipairs(dados.diretorias or {}) do
    table.insert(h, '<div class="equipe-grupo"><h3>' .. comum.esc(comum.texto(d.nome)) .. '</h3><ul class="membros">')
    for _, p in ipairs(d.membros or {}) do
      local nome, foto = comum.texto(p.nome), comum.texto(p.foto)
      local img = ""
      if foto ~= "" then
        img = '<img class="membro__foto" src="' .. comum.esc(foto) .. '" alt="Foto de ' .. comum.esc(nome) .. '" width="96" height="96">'
      end
      table.insert(h, '<li class="membro">' .. img .. '<span class="membro__nome">' .. comum.esc(nome)
        .. '</span><span class="membro__cargo">' .. comum.esc(comum.texto(p.cargo)) .. '</span></li>')
    end
    table.insert(h, '</ul></div>')
  end
  table.insert(h, '</div></section>')

  table.insert(h, '<section class="secao" aria-labelledby="t-eixos"><h2 id="t-eixos">Eixos temáticos</h2>')
  table.insert(h, '<div class="equipe-grade equipe-eixos">')
  for _, e in ipairs(dados.eixos or {}) do
    local nome = comum.texto(e.nome)
    if not eixos_validos[nome] then
      comum.parar('equipe.yml: o eixo "' .. nome .. '" não existe. Use os nomes de _variables.yml.')
    end
    local membros = {}
    for _, p in ipairs(e.membros or {}) do table.insert(membros, comum.esc(comum.texto(p))) end
    table.insert(h, string.format('<div class="equipe-grupo equipe-eixo"><h3><a href="publicacoes/index.html?eixo=%s">%s</a></h3><p>%s</p></div>',
      comum.slug(nome), comum.esc(nome), table.concat(membros, ", ")))
  end
  table.insert(h, '</div></section>')

  local bloco = comum.html(table.concat(h, "\n"))
  doc.blocks = doc.blocks:walk({
    Div = function(d) if d.identifier == "equipe-membros" then d.content = { bloco } return d end end,
  })
  return doc
end
