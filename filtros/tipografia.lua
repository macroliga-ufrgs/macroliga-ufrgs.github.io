-- filtros/tipografia.lua: "nº" e o número nunca se separam (docs/design-tokens.md).
-- Troca o espaço entre "nº" e um número por um espaço inseparável.
local NBSP = "\u{00A0}"

function Inlines(inlines)
  for i = 1, #inlines - 2 do
    local a, b, c = inlines[i], inlines[i + 1], inlines[i + 2]
    if a.t == "Str" and a.text:match("nº$") and b.t == "Space" and c.t == "Str" and c.text:match("^%d") then
      inlines[i + 1] = pandoc.Str(NBSP)
    end
  end
  return inlines
end

-- O site não usa citações do Pandoc: "@macroliga.ufrgs" (de _variables.yml) volta a ser texto.
function Cite(c)
  return c.content
end
