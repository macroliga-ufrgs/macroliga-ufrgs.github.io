-- filtros/comum.lua: funções usadas pelos filtros do site (maquinaria: não mexa).
-- Uso, num filtro: local comum = dofile(quarto.utils.resolve_path("comum.lua"))
local M = {}

M.NBSP = "\u{00A0}"

-- ---- Texto e HTML -----------------------------------------------------------

-- Texto simples de um valor do YAML ("" se não existir), sem espaços nas pontas.
function M.texto(valor)
  if valor == nil then return "" end
  if type(valor) == "boolean" then return tostring(valor) end
  local s = pandoc.utils.stringify(valor)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Escapa texto para HTML e junta "nº" ao número com espaço inseparável.
function M.esc(s)
  s = tostring(s or "")
  s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
  s = s:gsub("nº%s+(%d)", "nº&nbsp;%1")
  return s
end

function M.html(s) return pandoc.RawBlock("html", s) end

-- ---- Arquivos ---------------------------------------------------------------

function M.raiz() return quarto.project.directory end
function M.caminho(...) return pandoc.path.join({ ... }) end
function M.pasta_atual() return pandoc.path.directory(quarto.doc.input_file) end

function M.existe(caminho)
  local f = io.open(caminho, "r")
  if f then f:close() return true end
  return false
end

function M.ler_arquivo(caminho)
  local f = io.open(caminho, "r")
  if not f then return nil end
  local txt = f:read("a")
  f:close()
  return txt
end

-- Sem "smart" (aspas retas continuam retas) e sem HTML cru: o texto sai como o aluno escreveu.
local function yaml_para_meta(yaml)
  return pandoc.read("---\n" .. yaml .. "\n---\n", "markdown-smart-raw_html").meta
end

function M.ler_yaml(caminho)
  local txt = M.ler_arquivo(caminho)
  if not txt then return nil end
  return yaml_para_meta(txt)
end

-- Só o cabeçalho YAML de um .qmd, como o aluno escreveu (sem a normalização do Quarto).
function M.cabecalho(caminho_qmd)
  local txt = M.ler_arquivo(caminho_qmd)
  if not txt then return nil end
  txt = txt:gsub("^\239\187\191", "")
  local yaml = txt:match("^%-%-%-%s*\r?\n(.-)\r?\n%-%-%-")
  if not yaml then return nil end
  return yaml_para_meta(yaml)
end

function M.relativo(caminho)
  local r = M.raiz()
  if caminho:sub(1, #r) == r then return (caminho:sub(#r + 2):gsub("\\", "/")) end
  return caminho
end

function M.parar(mensagem)
  io.stderr:write("\n[MacroLiga] " .. mensagem .. "\n\n")
  os.exit(1)
end

-- Anexa assets/js/<nome>.js à página (o Quarto copia para site_libs/).
function M.script(nome)
  quarto.doc.add_html_dependency({
    name = "macroliga-" .. nome,
    version = "1.0",
    scripts = { { path = M.caminho(M.raiz(), "assets", "js", nome .. ".js"), afterBody = true } },
  })
end

-- ---- Rascunhos --------------------------------------------------------------

function M.perfil_rascunhos()
  local p = os.getenv("QUARTO_PROFILE") or ""
  return p:find("rascunhos", 1, true) ~= nil
end
function M.rascunho(y) return y ~= nil and y.draft == true end
function M.visivel(y) return not M.rascunho(y) or M.perfil_rascunhos() end

-- ---- Conteúdo do site ---------------------------------------------------------

-- Subpastas (com index.qmd) de uma pasta, em ordem alfabética, sem as que começam com "_".
function M.subpastas(pasta)
  local ok, nomes = pcall(pandoc.system.list_directory, pasta)
  if not ok then return {} end
  local r = {}
  for _, n in ipairs(nomes) do
    if not n:match("^_") and M.existe(M.caminho(pasta, n, "index.qmd")) then table.insert(r, n) end
  end
  table.sort(r)
  return r
end

function M.fasciculos(apenas_visiveis)
  local base = M.caminho(M.raiz(), "publicacoes")
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    if nome:match("^n%d+$") then
      local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
      if y and (not apenas_visiveis or M.visivel(y)) then
        table.insert(r, { numero = tonumber(M.texto(y.numero)) or 0, pasta = nome, meta = y })
      end
    end
  end
  table.sort(r, function(a, b) return a.numero < b.numero end)
  return r
end

function M.textos_do_fasciculo(pasta, apenas_visiveis)
  local base = M.caminho(M.raiz(), "publicacoes", pasta)
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
    if y and (not apenas_visiveis or M.visivel(y)) then
      table.insert(r, { slug = nome, meta = y, ordem = tonumber(M.texto(y.ordem)) or 99 })
    end
  end
  table.sort(r, function(a, b) return a.ordem < b.ordem end)
  return r
end

-- Itens de publicacoes/em-breve.yml (uma lista no topo do arquivo).
function M.em_breve()
  local txt = M.ler_arquivo(M.caminho(M.raiz(), "publicacoes", "em-breve.yml"))
  if not txt then return {} end
  local recuado = "  " .. txt:gsub("\r?\n", "\n  ")
  local itens = yaml_para_meta("itens:\n" .. recuado).itens
  if type(itens) ~= "table" then return {} end
  return itens
end

function M.eventos()
  local base = M.caminho(M.raiz(), "eventos")
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
    if y then table.insert(r, { pasta = nome, meta = y }) end
  end
  return r
end

function M.tem_evento(situacao)
  for _, e in ipairs(M.eventos()) do
    if M.texto(e.meta.situacao) == situacao then return true end
  end
  return false
end

function M.graficos(apenas_visiveis)
  local base = M.caminho(M.raiz(), "graficos")
  local r = {}
  for _, nome in ipairs(M.subpastas(base)) do
    local y = M.cabecalho(M.caminho(base, nome, "index.qmd"))
    if y and (not apenas_visiveis or M.visivel(y)) then table.insert(r, { pasta = nome, meta = y }) end
  end
  return r
end

-- ---- Slugs e datas ---------------------------------------------------------------

local ACENTOS = {
  ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a",
  ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["í"] = "i", ["ì"] = "i",
  ["ó"] = "o", ["ò"] = "o", ["ô"] = "o", ["õ"] = "o", ["ú"] = "u", ["ü"] = "u",
  ["ç"] = "c", ["ñ"] = "n",
}

-- "Atividade econômica, mercado de trabalho e crédito" -> "atividade-economica-mercado-de-trabalho-e-credito"
function M.slug(s)
  s = pandoc.text.lower(M.texto(s))
  for de, para in pairs(ACENTOS) do s = s:gsub(de, para) end
  s = s:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  return s
end

local MESES = { "janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho",
  "agosto", "setembro", "outubro", "novembro", "dezembro" }
local MESES_ABNT = { "jan.", "fev.", "mar.", "abr.", "maio", "jun.", "jul.",
  "ago.", "set.", "out.", "nov.", "dez." }

-- Aceita "2026-11-27", "27 de novembro de 2026" ou "27/11/2026". Devolve 27, 11, 2026 (ou nil).
function M.partes_data(valor)
  local s = M.texto(valor)
  local a, m, d = s:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)")
  if a then return tonumber(d), tonumber(m), tonumber(a) end
  local d2, nome, a2 = s:match("^(%d+) de (%S+) de (%d%d%d%d)$")
  if d2 then
    for i, n in ipairs(MESES) do
      if n == pandoc.text.lower(nome) then return tonumber(d2), i, tonumber(a2) end
    end
  end
  local d3, m3, a3 = s:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
  if d3 then return tonumber(d3), tonumber(m3), tonumber(a3) end
  return nil
end

function M.data_extenso(valor)
  local d, m, a = M.partes_data(valor)
  if not d then return M.texto(valor) end
  return d .. " de " .. MESES[m] .. " de " .. a
end

function M.data_abnt(valor)
  local d, m, a = M.partes_data(valor)
  if not d then return "" end
  return MESES_ABNT[m] .. " " .. a
end

-- ---- Blocos repetidos ------------------------------------------------------------

local function codificar_url(s)
  return (s:gsub("[^%w%-%._~]", function(c) return string.format("%%%02X", string.byte(c)) end))
end

-- Questionário (indicador da extensão). Sem questionario.url, avisa e não mostra nada.
function M.questionario(meta, frase, titulo)
  local q = meta.questionario or {}
  local url = M.texto(q.url)
  if url == "" then
    quarto.log.warning("[MacroLiga] questionario.url está vazio em _variables.yml: o questionário não aparece em "
      .. M.relativo(quarto.doc.input_file) .. ".")
    return nil
  end
  local campo = M.texto(q["campo-pagina"])
  if campo ~= "" then
    local sep = url:find("?", 1, true) and "&" or "?"
    url = url .. sep .. "usp=pp_url&" .. campo .. "=" .. codificar_url(titulo or "")
  end
  return M.html(table.concat({
    '<section class="questionario" aria-label="Questionário de avaliação">',
    '<p>' .. M.esc(frase) .. '</p>',
    '<p class="acoes"><a class="botao" href="' .. M.esc(url) .. '">Responder ao questionário</a></p>',
    '</section>',
  }, "\n"))
end

function M.aviso_institucional()
  return M.html('<p class="aviso">Os textos publicados não representam a posição da MacroLiga UFRGS, da FCE ou da UFRGS.</p>')
end

function M.link_instagram(meta)
  local c = meta.contato or {}
  return '<a href="' .. M.esc(M.texto(c["instagram-url"])) .. '">' .. M.esc(M.texto(c.instagram)) .. '</a>'
end

-- Ação de inscrição de um evento (spec 3.3.4).
function M.acao_inscricao(valor)
  local v = M.texto(valor)
  if v == "" then return '<p class="evento__inscricao">Inscrições em breve.</p>' end
  if v == "livre" then return '<p class="evento__inscricao">Entrada livre, sem inscrição.</p>' end
  return '<p class="acoes"><a class="botao" href="' .. M.esc(v) .. '">Fazer inscrição</a></p>'
end

-- Marca com o atributo hidden as divs cujos ids estão em `ids` (um conjunto: {id = true}).
-- (Ocultar em vez de apagar: as listings do Quarto precisam encontrar a div delas.)
function M.ocultar(blocos, ids)
  return blocos:walk({
    Div = function(d)
      if ids[d.identifier] then
        d.attributes.hidden = ""
        return d
      end
    end,
  })
end

return M
