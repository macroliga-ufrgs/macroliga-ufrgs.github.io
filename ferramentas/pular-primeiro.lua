-- Pós-render (maquinaria: não mexa). O Quarto escreve o include-before-body depois do
-- cabeçalho; este script move o link "Pular para o conteúdo" para logo depois de <body>,
-- para ele ser o primeiro item da página ao navegar com o teclado (spec 4.1).
local saida = os.getenv("QUARTO_PROJECT_OUTPUT_DIR")
if not saida then return end
local LINK = '<a class="pular" href="#quarto%-document%-content">Pular para o conteúdo</a>'

local function varrer(pasta)
  for _, nome in ipairs(pandoc.system.list_directory(pasta)) do
    local caminho = pandoc.path.join({ pasta, nome })
    local f = io.open(caminho, "r")
    local conteudo = f and f:read("a")
    if f then f:close() end
    if conteudo then
      if nome:match("%.html$") then
        local link = conteudo:match(LINK)
        local corpo = conteudo:find("<body[^>]*>")
        if link and corpo and conteudo:find(LINK) > corpo then
          local sem = conteudo:gsub("\n?" .. LINK, "", 1)
          local novo = sem:gsub("(<body[^>]*>)", "%1\n" .. link:gsub("%%", "%%%%"), 1)
          local g = io.open(caminho, "w")
          g:write(novo)
          g:close()
        end
      end
    else
      varrer(caminho)
    end
  end
end

varrer(saida)
