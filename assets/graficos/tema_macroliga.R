# =============================================================================
# tema_macroliga.R — Padrão visual de gráficos da MacroLiga UFRGS
# -----------------------------------------------------------------------------
# Uso:   source("tema_macroliga.R")
# Requer: ggplot2 (>= 3.4) e scales
# Recomendado: ragg (exportação nítida) e systemfonts (detecção de fontes)
# Fontes: instale Inter e Libre Baskerville (Google Fonts) no computador.
#         Sem elas, o tema usa as fontes padrão do sistema e avisa.
# =============================================================================

library(ggplot2)
library(scales)

# ---- Cores ------------------------------------------------------------------
cores_macroliga <- c(
  azul_marinho = "#083D6B",  # série principal (gráfico de uma série)
  vermelho     = "#D51E23",  # destaque: último dado, evento, ponto a observar
  offwhite     = "#FAF8F4",  # fundo (igual ao dos templates do Canva)
  grafite      = "#1F2933",  # textos, eixo, rótulos
  grade        = "#D9D4CA",  # linhas de grade
  contexto     = "#9AA5B1"   # séries de contexto (em segundo plano)
)

# Paleta para comparar 2 a 4 séries: ordem FIXA (nunca reordene nem cicle).
# Aqui o vermelho é a 2ª série (azul x vermelho, como no logo); em gráficos
# de uma série ele fica reservado ao destaque (rotulos_finais()).
# Validada para daltonismo sobre o fundo off-white. O âmbar tem contraste
# < 3:1 com o fundo, por isso séries múltiplas sempre levam rótulo direto
# (use rotulos_finais()).
paleta_macroliga <- c("#1F5FA8", "#D51E23", "#C98A0B", "#2E9C78")

# ---- Fontes -------------------------------------------------------------------
.fonte_ok <- function(familia) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) return(FALSE)
  familia %in% systemfonts::system_fonts()$family
}
fonte_texto  <- if (.fonte_ok("Inter")) "Inter" else "sans"
fonte_titulo <- if (.fonte_ok("Libre Baskerville")) "Libre Baskerville" else "serif"
if (fonte_texto == "sans" || fonte_titulo == "serif") {
  message("[MacroLiga] Inter e/ou Libre Baskerville não encontradas; ",
          "usando fontes padrão. Instale-as do Google Fonts e reinicie o R.")
}

# ---- Formatação brasileira ------------------------------------------------------
# num_br(0.1)(1234.5)   -> "1.234,5"
# pct_br(0.1)(10.5)     -> "10,5%"   (valor já em %)
num_br <- function(accuracy = NULL, ...) {
  label_number(accuracy = accuracy, big.mark = ".", decimal.mark = ",", ...)
}
pct_br <- function(accuracy = NULL, ...) {
  label_number(accuracy = accuracy, big.mark = ".", decimal.mark = ",",
               suffix = "%", ...)
}

# Legenda de fonte no padrão da liga (use em labs(caption = ...) quando o
# gráfico for sair SEM o template do Canva, ex.: site ou publicação).
fonte_macroliga <- function(fonte) {
  paste0("Fonte: ", fonte, ". Elaboração: MacroLiga UFRGS.")
}

# ---- Tema ------------------------------------------------------------------------
# base_size: 16 para redes (exportação 2x); 10 para a publicação (16 cm, 300 dpi)
# fundo:     "offwhite" (padrão, combina com o Canva), "transparente" ou "branco"
# grade:     linhas de grade "y" (padrão), "x", "ambas" ou "nenhuma"
theme_macroliga <- function(base_size = 16,
                            fundo = c("offwhite", "transparente", "branco"),
                            grade = c("y", "x", "ambas", "nenhuma")) {
  fundo <- match.arg(fundo)
  grade <- match.arg(grade)
  bg <- switch(fundo,
               offwhite     = cores_macroliga[["offwhite"]],
               transparente = NA,
               branco       = "#FFFFFF")
  linha_grade <- element_line(colour = cores_macroliga[["grade"]], linewidth = 0.5)
  grafite <- cores_macroliga[["grafite"]]

  theme_minimal(base_size = base_size, base_family = fonte_texto) +
    theme(
      plot.background    = element_rect(fill = bg, colour = NA),
      panel.background   = element_rect(fill = bg, colour = NA),
      panel.grid.major.y = if (grade %in% c("y", "ambas")) linha_grade else element_blank(),
      panel.grid.major.x = if (grade %in% c("x", "ambas")) linha_grade else element_blank(),
      panel.grid.minor   = element_blank(),
      axis.line.x        = element_line(colour = grafite, linewidth = 0.7),
      axis.ticks         = element_blank(),
      axis.text          = element_text(colour = grafite, size = rel(0.95)),
      axis.title         = element_text(colour = grafite, size = rel(0.9)),
      plot.title         = element_text(family = fonte_titulo, face = "bold",
                                        colour = cores_macroliga[["azul_marinho"]],
                                        size = rel(1.45), hjust = 0,
                                        margin = margin(b = 6)),
      plot.subtitle      = element_text(colour = grafite, size = rel(1),
                                        hjust = 0, margin = margin(b = 14)),
      plot.caption       = element_text(colour = grafite, size = rel(0.8),
                                        hjust = 0, margin = margin(t = 14)),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      legend.position    = "top",
      legend.justification = "left",
      legend.title       = element_blank(),
      legend.text        = element_text(colour = grafite, size = rel(0.9)),
      legend.key.width   = unit(1.6, "lines"),
      strip.text         = element_text(colour = grafite, face = "bold",
                                        hjust = 0, size = rel(0.95)),
      plot.margin        = margin(14, 18, 12, 12)
    )
}

# ---- Escalas de cor (2 a 4 séries) -------------------------------------------------
.checar_series <- function(n) {
  if (n > length(paleta_macroliga)) {
    stop("[MacroLiga] Mais de 4 séries. Agrupe as menores em 'Outros' ",
         "ou use facet_wrap() em vez de mais cores.", call. = FALSE)
  }
}
scale_colour_macroliga <- function(...) {
  discrete_scale("colour", "macroliga",
                 function(n) { .checar_series(n); paleta_macroliga[seq_len(n)] }, ...)
}
scale_fill_macroliga <- function(...) {
  discrete_scale("fill", "macroliga",
                 function(n) { .checar_series(n); paleta_macroliga[seq_len(n)] }, ...)
}
scale_color_macroliga <- scale_colour_macroliga

# ---- Rótulo direto no último dado ------------------------------------------------------
# Série única: ponto vermelho + valor.
# Várias séries: ponto na cor da série + "Nome  valor" em grafite.
# Aumente a margem direita do eixo x para caber o texto, ex.:
#   scale_x_date(expand = expansion(mult = c(0.01, 0.14)))
# tamanho: 5.2 para redes (base_size 16); 3.4 para a publicação (base_size 10)
rotulos_finais <- function(dados, x, y, grupo = NULL,
                           formato = num_br(accuracy = 0.1),
                           tamanho = 5.2) {
  tam_ponto <- tamanho * 0.75
  if (is.null(grupo)) {
    ult <- dados[which.max(dados[[x]]), , drop = FALSE]
    ult$.rotulo <- formato(ult[[y]])
    ponto <- geom_point(data = ult, aes(x = .data[[x]], y = .data[[y]]),
                        colour = cores_macroliga[["vermelho"]], size = tam_ponto,
                        inherit.aes = FALSE)
  } else {
    partes <- split(dados, dados[[grupo]], drop = TRUE)
    ult <- do.call(rbind, lapply(partes, function(d) d[which.max(d[[x]]), , drop = FALSE]))
    ult$.rotulo <- paste0(ult[[grupo]], "  ", formato(ult[[y]]))
    ponto <- geom_point(data = ult,
                        aes(x = .data[[x]], y = .data[[y]], colour = .data[[grupo]]),
                        size = tam_ponto, inherit.aes = FALSE, show.legend = FALSE)
  }
  # Afasta rótulos que ficariam sobrepostos (o ponto continua no valor real)
  ult <- ult[order(ult[[y]]), , drop = FALSE]
  folga <- diff(range(dados[[y]], na.rm = TRUE)) * 0.05
  ult$.y_rotulo <- ult[[y]]
  if (nrow(ult) > 1) for (i in 2:nrow(ult)) {
    ult$.y_rotulo[i] <- max(ult$.y_rotulo[i], ult$.y_rotulo[i - 1] + folga)
  }
  desloc <- diff(range(as.numeric(dados[[x]]), na.rm = TRUE)) * 0.015
  list(
    ponto,
    geom_text(data = ult,
              aes(x = .data[[x]], y = .y_rotulo, label = .rotulo),
              inherit.aes = FALSE, hjust = 0, nudge_x = desloc,
              family = fonte_texto, fontface = "bold",
              colour = cores_macroliga[["grafite"]], size = tamanho),
    coord_cartesian(clip = "off")
  )
}

# ---- Exportação ---------------------------------------------------------------------------
# Tamanhos em pixels, já no dobro da área do template (nitidez em telas retina):
#   grafico_comentado : área do gráfico no template "Gráfico Comentado" (888 x 690)
#   carrossel         : área cinza da lâmina de gráfico do carrossel   (888 x 800)
#   linkedin          : post horizontal do LinkedIn                     (1200 x 627)
#   publicacao        : figura para o fascículo (16 x 10 cm, 300 dpi) — use base_size = 10
salvar_macroliga <- function(grafico, arquivo,
                             formato = c("grafico_comentado", "carrossel",
                                         "linkedin", "publicacao"),
                             transparente = FALSE) {
  formato <- match.arg(formato)
  spec <- switch(formato,
    grafico_comentado = list(w = 1776, h = 1380, units = "px", dpi = 192),
    carrossel         = list(w = 1776, h = 1600, units = "px", dpi = 192),
    linkedin          = list(w = 2400, h = 1254, units = "px", dpi = 192),
    publicacao        = list(w = 16,   h = 10,   units = "cm", dpi = 300)
  )
  dispositivo <- if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else "png"
  ggsave(arquivo, grafico, width = spec$w, height = spec$h, units = spec$units,
         dpi = spec$dpi, device = dispositivo,
         bg = if (transparente) "transparent" else cores_macroliga[["offwhite"]])
  invisible(arquivo)
}

# ---- Dados do Banco Central (SGS) ------------------------------------------------------
# sgs(432, "01/01/2015")  -> data.frame(data, valor)
# Códigos úteis (confira em https://www3.bcb.gov.br/sgspub):
#   432   Meta Selic definida pelo Copom (% a.a.)
#   433   IPCA - variação mensal (%)
#   13522 IPCA - acumulado em 12 meses (%)
# Séries diárias: a API limita cada consulta a 10 anos.
sgs <- function(codigo, inicio = NULL, fim = NULL) {
  url <- paste0("https://api.bcb.gov.br/dados/serie/bcdata.sgs.", codigo,
                "/dados?formato=json")
  if (!is.null(inicio)) url <- paste0(url, "&dataInicial=", inicio)
  if (!is.null(fim))    url <- paste0(url, "&dataFinal=", fim)
  bruto <- jsonlite::fromJSON(url)
  data.frame(data  = as.Date(bruto$data, format = "%d/%m/%Y"),
             valor = as.numeric(bruto$valor))
}
