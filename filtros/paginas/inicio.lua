-- filtros/paginas/inicio.lua: Início (spec 2.2).
-- I1: abertura com o mapa de pontos; o texto vem de "abertura", no cabeçalho do index.qmd.
-- I2: fascículo mais recente ou, se nenhum estiver publicado, o "em breve".
-- I3/I4: oculta o bloco ou o estado vazio que não se aplica.
return function(doc, comum)
  local m = doc.meta
  local visiveis = comum.fasciculos(true)
  local ultimo = visiveis[#visiveis]
  local em_breve = comum.em_breve()[1]
  local ocultos = {}

  local botao
  if ultimo then
    botao = string.format('<a class="botao" href="/publicacoes/%s/index.qmd">Ler o fascículo nº&nbsp;%d</a>',
      ultimo.pasta, ultimo.numero)
    ocultos["i2-em-breve"] = true
  elseif em_breve then
    botao = '<a class="botao" href="#fasciculo">Ver os textos do nº&nbsp;' .. comum.esc(comum.texto(em_breve.numero)) .. '</a>'
    ocultos["i2-fasciculo"] = true
  else
    botao = '<a class="botao" href="/publicacoes/index.qmd">Ver as publicações</a>'
    ocultos["fasciculo"] = true
  end
  if comum.tem_evento("proximo") then ocultos["i4-vazio"] = true end
  if #comum.graficos(true) == 0 then ocultos["i3"] = true end

  local mapa = comum.ler_arquivo(comum.caminho(comum.raiz(), "assets", "img", "mapa-pontos.svg")) or ""
  local abertura = table.concat({
    '<section class="fundo-azul abertura-faixa" aria-labelledby="abertura-titulo">',
    '<div class="conteiner abertura">',
    '<div class="abertura__texto">',
    '<h1 class="abertura__titulo" id="abertura-titulo">' .. comum.esc(comum.texto(m.abertura.frase)) .. '</h1>',
    '<p class="abertura__subtitulo">' .. comum.esc(comum.texto(m.abertura.subtitulo)) .. '</p>',
    '<div class="acoes">',
    botao,
    '<a class="botao botao--secundario" href="#como-funcionamos">Ver como funcionamos</a>',
    '</div>',
    '</div>',
    '<figure class="abertura__mapa">',
    mapa,
    '</figure>',
    '</div>',
    '</section>',
  }, "\n")

  doc.blocks = comum.ocultar(doc.blocks, ocultos)
  doc.blocks:insert(1, comum.html(abertura))
  return doc
end
