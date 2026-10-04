-- Pós-render (maquinaria: não mexa). Com draft: true, o Quarto deixa no lugar da página
-- um HTML vazio (<html ...></html>). Este script apaga esses arquivos de _site/, para
-- que os rascunhos não existam no site publicado (spec 3.4). Apaga também o search.json.
local saida = os.getenv("QUARTO_PROJECT_OUTPUT_DIR")
if not saida then return end

local function varrer(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    if nome:match("%.html$") then
      local f = io.open(caminho, "r")
      local conteudo = f and f:read("a")
      if f then f:close() end
      if conteudo and conteudo:match("^%s*<!DOCTYPE html>%s*<html[^>]*></html>%s*$") then
        os.remove(caminho)
      end
    elseif not nome:match("%.%w+$") then
      local ok = pcall(pandoc.system.list_directory, caminho)
      if ok then varrer(caminho) end
    end
  end
end
varrer(saida)

-- A busca está desligada (D10), mas o Quarto escreve search.json quando a página tem
-- <main>. Nada o lê; ele só repetiria o texto das páginas. Apague-o.
os.remove(pandoc.path.join({ saida, "search.json" }))
