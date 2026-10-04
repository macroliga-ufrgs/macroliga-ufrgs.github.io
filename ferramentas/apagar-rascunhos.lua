-- Pós-render (maquinaria: não mexa). Com draft: true, o Quarto deixa no lugar da página
-- um HTML vazio (<html ...></html>). Este script apaga esses arquivos de _site/, para
-- que os rascunhos não existam no site publicado (spec 3.4). Apaga também o search.json.
local saida = os.getenv("QUARTO_PROJECT_OUTPUT_DIR")
if not saida then return end
-- Só na renderização completa (quarto render e quarto publish). Na parcial do quarto preview,
-- o Quarto ainda vai reabrir as páginas que acabou de gerar (inclusive as de rascunho) para
-- recarregar o navegador; apagá-las aqui o faz parar com "NotFound ... index.html".
if os.getenv("QUARTO_PROJECT_RENDER_ALL") ~= "1" then return end

local pastas_de_rascunho = {}

local function varrer(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    if nome:match("%.html$") then
      local f = io.open(caminho, "r")
      local conteudo = f and f:read("a")
      if f then f:close() end
      if conteudo and conteudo:match("^%s*<!DOCTYPE html>%s*<html[^>]*></html>%s*$") then
        os.remove(caminho)
        pastas_de_rascunho[pasta] = true
      end
    elseif not nome:match("%.%w+$") then
      local ok = pcall(pandoc.system.list_directory, caminho)
      if ok then varrer(caminho) end
    end
  end
end
varrer(saida)

-- O Quarto também copia os arquivos da pasta de um rascunho (ex.: a capa do fascículo).
-- Numa pasta que só tinha rascunhos (nenhum .html sobrou), apague todos os arquivos.
local function tem_html(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    if nome:match("%.html$") then return true end
    if not nome:match("%.%w+$") and pcall(pandoc.system.list_directory, caminho) and tem_html(caminho) then return true end
  end
  return false
end
local function apagar_arquivos(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    if pcall(pandoc.system.list_directory, caminho) and not nome:match("%.%w+$") then
      apagar_arquivos(caminho)
    else
      os.remove(caminho)
    end
  end
end
for pasta in pairs(pastas_de_rascunho) do
  if not tem_html(pasta) then apagar_arquivos(pasta) end
end

-- listings.json cita os endereços de todas as páginas com listing, inclusive rascunhos.
-- Ficam só as entradas (e itens) cujas páginas existem em _site/.
local arquivo_listings = pandoc.path.join({ saida, "listings.json" })
local f = io.open(arquivo_listings, "r")
if f then
  local ok, lista = pcall(pandoc.json.decode, f:read("a"), false)
  f:close()
  local function existe(href)
    local g = io.open(pandoc.path.join({ saida, (href:gsub("^/", "")) }), "r")
    if g then g:close() return true end
    return false
  end
  if ok and type(lista) == "table" then
    local filtrada = {}
    for _, entrada in ipairs(lista) do
      if existe(entrada.listing) then
        local itens = pandoc.List({})
        for _, it in ipairs(entrada.items or {}) do
          if existe(it) then itens:insert(it) end
        end
        entrada.items = itens
        table.insert(filtrada, entrada)
      end
    end
    local g = io.open(arquivo_listings, "w")
    g:write(pandoc.json.encode(filtrada))
    g:close()
  end
end

-- A busca está desligada (D10), mas o Quarto escreve search.json quando a página tem
-- <main>. Nada o lê; ele só repetiria o texto das páginas. Apague-o.
os.remove(pandoc.path.join({ saida, "search.json" }))
