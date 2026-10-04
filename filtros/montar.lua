-- filtros/montar.lua: monta as páginas a partir do cabeçalho YAML (maquinaria: não mexa).
-- O tipo de página vem da chave "pagina" (no cabeçalho das páginas fixas e nos
-- _metadata.yml das pastas). Cada tipo tem seu montador em filtros/paginas/<tipo>.lua.
-- Com page-layout: custom o Quarto não escreve <main>: este filtro envolve o conteúdo
-- num <main id="quarto-document-content">, alvo do link "Pular para o conteúdo".
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

function Pandoc(doc)
  comum.script("menu")
  local pagina = comum.texto(doc.meta.pagina)
  -- Cada página escreve o próprio h1. O título vai só para o <title> (pagetitle): assim o
  -- Quarto não monta o bloco de título padrão, que leria o YAML como Markdown com HTML cru.
  if doc.meta.title ~= nil then
    if comum.texto(doc.meta.pagetitle) == "" then doc.meta.pagetitle = pandoc.Inlines(pandoc.utils.stringify(doc.meta.title)) end
    doc.meta.title = nil
  end
  if pagina ~= "" then
    local arquivo = quarto.utils.resolve_path("paginas/" .. pagina .. ".lua")
    if comum.existe(arquivo) then
      -- O Quarto põe no corpo divs ocultas (ex.: #quarto-meta-markdown, com o og:title a
      -- renderizar). Os montadores trocam doc.blocks; estas divs são guardadas e repostas.
      local ocultas, resto = pandoc.Blocks({}), pandoc.Blocks({})
      for _, b in ipairs(doc.blocks) do
        if b.t == "Div" and b.classes:includes("hidden") and b.identifier:match("^quarto%-") then
          ocultas:insert(b)
        else
          resto:insert(b)
        end
      end
      doc.blocks = resto
      local montar = dofile(arquivo)
      doc = montar(doc, comum)
      doc.blocks:extend(ocultas)
    end
  end
  doc.blocks:insert(1, comum.html('<main id="quarto-document-content" class="content" tabindex="-1">'))
  doc.blocks:insert(comum.html('</main>'))
  return doc
end
