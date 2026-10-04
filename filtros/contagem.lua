-- filtros/contagem.lua: contagem de visitas com o GoatCounter (spec 4.4), sem cookies e sem banner.
-- Só entra com o código preenchido em _variables.yml (contagem.goatcounter), e o script
-- não roda em localhost: nunca conta as visitas do quarto preview.
local comum = dofile(quarto.utils.resolve_path("comum.lua"))

function Meta(meta)
  local codigo = comum.texto(meta.contagem and meta.contagem.goatcounter)
  if codigo == "" then return nil end
  if not codigo:match("^[%w%-]+$") then
    comum.parar('o código do GoatCounter "' .. codigo .. '" (contagem.goatcounter, em _variables.yml) '
      .. 'deve ter só letras, números e hífens, como em "macroliga".')
  end
  quarto.doc.include_text("after-body", string.format([[
<script>
(function () {
  var h = location.hostname;
  if (location.protocol === "file:" || h === "localhost" || h === "127.0.0.1" || h === "[::1]") return;
  var s = document.createElement("script");
  s.async = true;
  s.src = "https://gc.zgo.at/count.js";
  s.setAttribute("data-goatcounter", "https://%s.goatcounter.com/count");
  document.body.appendChild(s);
})();
</script>]], codigo))
  return nil
end
