-- filtros/paginas/equipe.lua: Equipe (spec 2.11), lida de equipe.yml.
-- Ordem das seções: Conselho Executivo, Membros, Membros fundadores.
local CARGO = { feminino = "Conselheira", masculino = "Conselheiro" }

return function(doc, comum)
  local dados = comum.ler_yaml(comum.caminho(comum.raiz(), "equipe.yml")) or {}
  if dados.diretorias ~= nil or dados.eixos ~= nil then
    comum.parar('equipe.yml está no formato antigo (diretorias/eixos). Use conselho, membros e fundadores: veja o LEIA-ME, seção 7.9.')
  end

  local function pessoa(p, cargo)
    local nome, foto = comum.texto(p.nome), comum.texto(p.foto)
    local img, linha_cargo = "", ""
    if foto ~= "" then
      img = '<img class="membro__foto" src="' .. comum.esc(foto) .. '" alt="Foto de ' .. comum.esc(nome) .. '" width="96" height="96">'
    end
    if cargo then linha_cargo = '<span class="membro__cargo">' .. cargo .. '</span>' end
    return '<li class="membro">' .. img .. '<span class="membro__nome">' .. comum.esc(nome) .. '</span>' .. linha_cargo .. '</li>'
  end

  local function secao(id, titulo, classe, frase, itens)
    if #itens == 0 then return "" end
    local p = frase and ('<p class="equipe__frase">' .. frase .. '</p>') or ""
    return '<section class="secao" aria-labelledby="t-' .. id .. '"><h2 id="t-' .. id .. '">' .. titulo .. '</h2>' .. p
      .. '<ul class="equipe-grade ' .. classe .. '">' .. table.concat(itens, "\n") .. '</ul></section>'
  end

  -- Conselho: a presidência vem primeiro; o resto segue a ordem do equipe.yml.
  local presidencia, conselheiros = {}, {}
  for _, p in ipairs(dados.conselho or {}) do
    local genero = comum.texto(p.genero)
    if not CARGO[genero] then
      comum.parar('equipe.yml: o gênero "' .. genero .. '" não é válido (' .. comum.texto(p.nome)
        .. '). Escreva genero: "feminino" ou genero: "masculino".')
    end
    if p.presidente == true then
      table.insert(presidencia, pessoa(p, "Presidente"))
    else
      table.insert(conselheiros, pessoa(p, CARGO[genero]))
    end
  end
  if #presidencia > 1 then
    comum.parar("equipe.yml: há mais de uma pessoa com presidente: true no conselho. Deixe true em uma só.")
  elseif #presidencia == 0 and #conselheiros > 0 then
    quarto.log.warning("[MacroLiga] equipe.yml: ninguém no conselho tem presidente: true.")
  end
  for _, item in ipairs(conselheiros) do table.insert(presidencia, item) end

  local membros, fundadores = {}, {}
  for _, p in ipairs(dados.membros or {}) do table.insert(membros, pessoa(p)) end
  for _, p in ipairs(dados.fundadores or {}) do table.insert(fundadores, pessoa(p)) end

  local h = {
    secao("conselho", "Conselho Executivo", "equipe-conselho", nil, presidencia),
    secao("membros", "Membros", "equipe-membros", nil, membros),
    secao("fundadores", "Membros fundadores", "equipe-fundadores", "Quem criou a MacroLiga UFRGS.", fundadores),
  }

  local bloco = comum.html(table.concat(h, "\n"))
  doc.blocks = doc.blocks:walk({
    Div = function(d) if d.identifier == "equipe-membros" then d.content = { bloco } return d end end,
  })
  return doc
end
