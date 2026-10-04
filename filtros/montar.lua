-- filtros/montar.lua: monta as páginas a partir do cabeçalho YAML (maquinaria: não mexa).
-- O tipo de página vem da chave "pagina" (no cabeçalho das páginas fixas e nos
-- _metadata.yml das pastas). Cada tipo tem seu montador em filtros/paginas/<tipo>.lua.
-- Com page-layout: custom o Quarto não escreve <main>: este filtro envolve o conteúdo
-- num <main id="quarto-document-content">, alvo do link "Pular para o conteúdo".
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

function Pandoc(doc)
  comum.script("menu")
  local pagina = comum.texto(doc.meta.pagina)
  if pagina ~= "" then
    local arquivo = quarto.utils.resolve_path("paginas/" .. pagina .. ".lua")
    if comum.existe(arquivo) then
      local montar = dofile(arquivo)
      doc = montar(doc, comum)
    end
  end
  doc.blocks:insert(1, comum.html('<main id="quarto-document-content" class="content" tabindex="-1">'))
  doc.blocks:insert(comum.html('</main>'))
  return doc
end
