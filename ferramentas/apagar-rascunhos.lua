-- Pós-render (maquinaria: não mexa). Com draft: true, o Quarto deixa no lugar da página
-- um HTML vazio (<html ...></html>). Este script apaga esses arquivos de _site/, para
-- que os rascunhos não existam no site publicado (spec 3.4).
local saida = os.getenv("QUARTO_PROJECT_OUTPUT_DIR")
if not saida then return end

local function varrer(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    local f = io.open(caminho, "r")
    local conteudo = f and f:read("a")
    if f then f:close() end
    if conteudo then
      if nome:match("%.html$") and conteudo:match("^%s*<!DOCTYPE html>%s*<html[^>]*></html>%s*$") then
        os.remove(caminho)
      end
    else
      varrer(caminho)
    end
  end
end

varrer(saida)
