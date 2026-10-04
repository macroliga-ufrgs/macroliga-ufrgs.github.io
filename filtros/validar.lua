-- filtros/validar.lua: confere o cabeçalho YAML de textos, fascículos, eventos e gráficos
-- e interrompe o quarto render com uma mensagem em português (spec 3.6).
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

local NOMES = { texto = "Texto", fasciculo = "Fascículo", evento = "Evento", grafico = "Gráfico" }
local OBRIGATORIOS = {
  texto = { "title", "author", "tipo", "eixo", "fasciculo", "ordem", "sintese", "revisao" },
  fasciculo = { "numero", "date" },
  evento = { "title", "date", "local", "situacao" },
  grafico = { "title", "author", "date", "eixo", "fonte" },
}

local function lista(valor)
  local r = {}
  for _, v in ipairs(valor or {}) do table.insert(r, comum.texto(v)) end
  return r
end

local function contem(t, v)
  for _, x in ipairs(t) do if x == v then return true end end
  return false
end

function Meta(meta)
  local pagina = comum.texto(meta.pagina)
  if not OBRIGATORIOS[pagina] then return nil end
  local y = comum.cabecalho(quarto.doc.input_file) or {}
  local nome = comum.texto(y.title)
  if nome == "" and pagina == "fasciculo" then nome = "nº " .. comum.texto(y.numero) end
  local pasta = comum.pasta_atual()

  local function parar(msg)
    comum.parar(string.format('%s "%s" (%s): %s', NOMES[pagina], nome, comum.relativo(quarto.doc.input_file), msg))
  end
  local function checar_opcao(valor, opcoes, rotulo)
    if not contem(opcoes, valor) then
      parar(string.format('o %s "%s" não existe. Use um destes: %s.', rotulo, valor, table.concat(opcoes, "; ")))
    end
  end
  local function checar_pdf()
    local pdf = comum.texto(y.pdf)
    if pdf == "" then parar('falta o campo "pdf". Ele é obrigatório num item publicado (sem draft: true).') end
    if not comum.existe(comum.caminho(pasta, pdf)) then
      parar(string.format('o arquivo "%s" (campo "pdf") não está na pasta %s.', pdf, comum.relativo(pasta)))
    end
  end

  for _, campo in ipairs(OBRIGATORIOS[pagina]) do
    if comum.texto(y[campo]) == "" then
      parar(string.format('o campo "%s" está vazio. Preencha-o no cabeçalho do index.qmd.', campo))
    end
  end
  if pagina == "texto" or pagina == "grafico" then checar_opcao(comum.texto(y.eixo), lista(meta.eixos), "eixo") end
  if pagina == "texto" then checar_opcao(comum.texto(y.tipo), lista(meta.tipos), "tipo") end
  if pagina == "evento" then
    local s = comum.texto(y.situacao)
    if s ~= "proximo" and s ~= "realizado" then
      parar(string.format('a situação "%s" não existe. Use "proximo" ou "realizado".', s))
    end
  end
  if (pagina == "evento" or pagina == "fasciculo") and comum.texto(y.capa) ~= "" and comum.texto(y["capa-alt"]) == "" then
    parar('a capa precisa de uma descrição no campo "capa-alt".')
  end

  if comum.rascunho(y) then return nil end   -- em rascunho, sintese, revisao, doi e pdf aceitam placeholder
  if pagina == "texto" then
    if comum.texto(y.doi) == "" then
      local fasc = comum.cabecalho(comum.caminho(pasta, "..", "index.qmd")) or {}
      if comum.texto(fasc.doi) == "" then parar('falta o DOI: preencha "doi" no texto ou no fascículo.') end
    end
    checar_pdf()
  elseif pagina == "fasciculo" then
    checar_pdf()
  end
  return nil
end
