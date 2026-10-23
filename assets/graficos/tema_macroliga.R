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
  contexto     = "#9AA5B1"   # séries de contexto (em segundo plano) e "Outros"
)

# Paleta para comparar 2 a 4 séries: ordem FIXA (nunca reordene nem cicle).
# Aqui o vermelho é a 2ª série (azul x vermelho, como no logo); em gráficos
# de uma série ele fica reservado ao destaque (rotulos_finais()).
# Validada para daltonismo sobre o fundo off-white. O âmbar tem contraste
# < 3:1 com o fundo, por isso séries múltiplas sempre levam rótulo direto
# (use rotulos_finais()).
# A categoria "Outros" (soma das séries menores) é sempre cinza `contexto`,
# fora dessa ordem: é a 5ª cor, e só existe com esse nome.
paleta_macroliga <- c("#1F5FA8", "#D51E23", "#C98A0B", "#2E9C78")

# ---- Fontes -------------------------------------------------------------------
.fonte_ok <- function(familia) {
  if (!requireNamespace("systemfonts", quietly = TRUE)) return(FALSE)
  familia %in% c(systemfonts::system_fonts()$family,
                 systemfonts::registry_fonts()$family)
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
# mes_br()(datas)       -> "jan/25"  (não depende do idioma do sistema)
num_br <- function(accuracy = NULL, ...) {
  label_number(accuracy = accuracy, big.mark = ".", decimal.mark = ",", ...)
}
pct_br <- function(accuracy = NULL, ...) {
  label_number(accuracy = accuracy, big.mark = ".", decimal.mark = ",",
               suffix = "%", ...)
}
mes_br <- function() {
  meses <- c("jan", "fev", "mar", "abr", "mai", "jun",
             "jul", "ago", "set", "out", "nov", "dez")
  function(x) {
    rotulo <- paste0(meses[as.integer(format(x, "%m"))], "/", format(x, "%y"))
    rotulo[is.na(x)] <- NA
    rotulo
  }
}
# anos_br()(c(1, 2.5))  -> "1 ano", "2,5 anos"  (prazos, ex.: curva de juros)
anos_br <- function(accuracy = NULL) {
  numero <- num_br(accuracy = accuracy)
  function(x) {
    rotulo <- paste(numero(x), ifelse(abs(x) == 1, "ano", "anos"))
    rotulo[is.na(x)] <- NA
    rotulo
  }
}

# Legenda de fonte no padrão da liga (use em labs(caption = ...) quando o
# gráfico for sair SEM o template do Canva, ex.: site ou publicação).
fonte_macroliga <- function(fonte) {
  paste0("Fonte: ", fonte, ". Elaboração: MacroLiga UFRGS.")
}

# ---- Tema ------------------------------------------------------------------------
# base_size: 16 para redes (exportação 2x); 12 para o site; 10 para a publicação
#            (16 cm, 300 dpi)
# fundo:    "offwhite" (padrão, combina com o Canva), "transparente" ou "branco"
# grade:     linhas de grade "y" (padrão), "x", "ambas" ou "nenhuma"
# eixo:      linha de eixo em "x" (padrão), "y" ou "nenhum". Em colunas e barras
#            use "nenhum" + linha_zero(), para a linha de base ficar no zero.
theme_macroliga <- function(base_size = 16,
                            fundo = c("offwhite", "transparente", "branco"),
                            grade = c("y", "x", "ambas", "nenhuma"),
                            eixo = c("x", "y", "nenhum")) {
  fundo <- match.arg(fundo)
  grade <- match.arg(grade)
  eixo  <- match.arg(eixo)
  bg <- switch(fundo,
               offwhite     = cores_macroliga[["offwhite"]],
               transparente = NA,
               branco       = "#FFFFFF")
  linha_grade <- element_line(colour = cores_macroliga[["grade"]], linewidth = 0.5)
  grafite <- cores_macroliga[["grafite"]]
  linha_eixo <- element_line(colour = grafite, linewidth = 0.7)

  theme_minimal(base_size = base_size, base_family = fonte_texto) +
    theme(
      plot.background    = element_rect(fill = bg, colour = NA),
      panel.background   = element_rect(fill = bg, colour = NA),
      panel.grid.major.y = if (grade %in% c("y", "ambas")) linha_grade else element_blank(),
      panel.grid.major.x = if (grade %in% c("x", "ambas")) linha_grade else element_blank(),
      panel.grid.minor   = element_blank(),
      axis.line.x        = if (eixo == "x") linha_eixo else element_blank(),
      axis.line.y        = if (eixo == "y") linha_eixo else element_blank(),
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
      legend.box         = "vertical",   # 2+ legendas (ex.: contribuicoes()) empilhadas
      legend.box.just    = "left",
      legend.spacing.y   = unit(0.2, "lines"),
      legend.title       = element_blank(),
      legend.text        = element_text(colour = grafite, size = rel(0.9)),
      legend.key.width   = unit(1.6, "lines"),
      strip.text         = element_text(colour = grafite, face = "bold",
                                        hjust = 0, size = rel(0.95)),
      panel.spacing      = unit(1.4, "lines"),   # respiro entre os painéis (facetas)
      plot.margin        = margin(14, 18, 12, 12)
    )
}

# ---- Escalas de cor (2 a 4 séries + "Outros") ----------------------------------------
# As séries recebem a paleta na ordem dos níveis do fator; o nível chamado
# "Outros" (argumento `outros`) fica sempre cinza, em qualquer posição.
.checar_series <- function(n) {
  if (n > length(paleta_macroliga)) {
    stop("[MacroLiga] Mais de 4 séries (fora 'Outros'). Agrupe as menores em ",
         "'Outros' ou use facet_wrap() em vez de mais cores.", call. = FALSE)
  }
}
.cores_series <- function(niveis, outros) {
  e_outros <- niveis %in% outros
  .checar_series(sum(!e_outros))
  cores <- rep(cores_macroliga[["contexto"]], length(niveis))
  cores[!e_outros] <- paleta_macroliga[seq_len(sum(!e_outros))]
  stats::setNames(cores, niveis)
}
.escala_macroliga <- function(aesthetic, outros, ...) {
  pal <- function(n) { .checar_series(n); paleta_macroliga[seq_len(n)] }
  base <- if (utils::packageVersion("ggplot2") >= "3.5.0") {
    discrete_scale(aesthetic, palette = pal, ...)
  } else {
    discrete_scale(aesthetic, "macroliga", pal, ...)
  }
  # A paleta depende dos NOMES dos níveis (por causa do "Outros"), e não só
  # da quantidade; por isso ela é montada aqui, quando os níveis são conhecidos.
  ggproto(NULL, base,
    map = function(self, x, limits = self$get_limits()) {
      niveis <- as.character(limits[!is.na(limits)])
      self$palette.cache <- .cores_series(niveis, outros)
      self$n.breaks.cache <- length(niveis)
      ggproto_parent(base, self)$map(x, limits)
    })
}
scale_colour_macroliga <- function(..., outros = "Outros") {
  .escala_macroliga("colour", outros, ...)
}
scale_fill_macroliga <- function(..., outros = "Outros") {
  .escala_macroliga("fill", outros, ...)
}
scale_color_macroliga <- scale_colour_macroliga

# ---- Rótulo direto no último dado ------------------------------------------------------
# Série única: ponto vermelho + valor.
# Várias séries: ponto na cor da série + "Nome  valor" em grafite.
# Aumente a margem direita do eixo x para caber o texto, ex.:
#   scale_x_date(expand = expansion(mult = c(0.01, 0.14)))
# tamanho: 5.2 para redes (base_size 16); 3.9 para o site (base_size 12);
#          3.4 para a publicação (base_size 10)
# faceta:  nome da coluna usada em facet_wrap(); marca o último dado de cada
#          painel (com uma série por painel, deixe `grupo` vazio)
rotulos_finais <- function(dados, x, y, grupo = NULL, faceta = NULL,
                           formato = num_br(accuracy = 0.1),
                           tamanho = 5.2) {
  tam_ponto <- tamanho * 0.75
  chaves <- c(grupo, faceta)
  ult <- if (length(chaves) == 0) {
    dados[which.max(dados[[x]]), , drop = FALSE]
  } else {
    partes <- split(dados, dados[chaves], drop = TRUE)
    do.call(rbind, lapply(partes, function(d) d[which.max(d[[x]]), , drop = FALSE]))
  }
  if (is.null(grupo)) {
    ult$.rotulo <- formato(ult[[y]])
    ponto <- geom_point(data = ult, aes(x = .data[[x]], y = .data[[y]]),
                        colour = cores_macroliga[["vermelho"]], size = tam_ponto,
                        inherit.aes = FALSE)
  } else {
    ult$.rotulo <- paste0(ult[[grupo]], "  ", formato(ult[[y]]))
    ponto <- geom_point(data = ult,
                        aes(x = .data[[x]], y = .data[[y]], colour = .data[[grupo]]),
                        size = tam_ponto, inherit.aes = FALSE, show.legend = FALSE)
  }
  # Afasta rótulos que ficariam sobrepostos (o ponto continua no valor real),
  # painel a painel
  folga <- diff(range(dados[[y]], na.rm = TRUE)) * 0.05
  afastar <- function(u) {
    u <- u[order(u[[y]]), , drop = FALSE]
    u$.y_rotulo <- u[[y]]
    if (nrow(u) > 1) for (i in 2:nrow(u)) {
      u$.y_rotulo[i] <- max(u$.y_rotulo[i], u$.y_rotulo[i - 1] + folga)
    }
    u
  }
  ult <- if (is.null(faceta)) afastar(ult) else
    do.call(rbind, lapply(split(ult, ult[[faceta]], drop = TRUE), afastar))
  # Espaços à esquerda afastam o texto do ponto por uma distância fixa,
  # igual em gráficos largos e em painéis estreitos
  ult$.rotulo <- paste0("   ", ult$.rotulo)
  list(
    ponto,
    geom_text(data = ult,
              aes(x = .data[[x]], y = .y_rotulo, label = .rotulo),
              inherit.aes = FALSE, hjust = 0,
              family = fonte_texto, fontface = "bold",
              colour = cores_macroliga[["grafite"]], size = tamanho),
    coord_cartesian(clip = "off")
  )
}

# ---- Colunas e barras -------------------------------------------------------------------
# Colunas (uma série no tempo): azul-marinho para valores positivos e
# vermelho para negativos. Aqui o vermelho marca o sinal, não o destaque.
#   ggplot(d, aes(data, valor, fill = sinal(valor))) +
#     geom_col() + linha_zero() + scale_fill_sinal() +
#     theme_macroliga(eixo = "nenhum")
sinal <- function(x) {
  factor(ifelse(x < 0, "negativo", "positivo"), levels = c("positivo", "negativo"))
}
scale_fill_sinal <- function(...) {
  scale_fill_manual(values = c(positivo = cores_macroliga[["azul_marinho"]],
                               negativo = cores_macroliga[["vermelho"]]),
                    guide = "none", drop = FALSE, ...)
}

# Barras horizontais (ranking): azul-marinho, com a categoria discutida no
# comentário em vermelho (mesma regra do gráfico de uma série).
#   d$uf <- ordenar(d$uf, d$valor)       # maior no topo
#   ggplot(d, aes(valor, uf, fill = destacar(uf, "Rio Grande do Sul"))) +
#     geom_col() + linha_zero(horizontal = TRUE) + scale_fill_destaque() +
#     theme_macroliga(grade = "x", eixo = "nenhum")
# Ordene no próprio data.frame (antes do ggplot), para os rótulos seguirem
# a mesma ordem das barras. Com várias linhas por categoria (ex.: haltere),
# ordena pela média; para ordenar por um só momento, passe NA nos outros:
#   d$uf <- ordenar(d$uf, ifelse(d$momento == "2026", d$valor, NA))
ordenar <- function(categoria, valor, decrescente = TRUE) {
  stats::reorder(factor(categoria), if (decrescente) valor else -valor,
                 FUN = function(v) mean(v, na.rm = TRUE))
}
destacar <- function(x, quais) {
  factor(ifelse(x %in% quais, "destaque", "demais"), levels = c("demais", "destaque"))
}
scale_fill_destaque <- function(...) {
  scale_fill_manual(values = c(demais   = cores_macroliga[["azul_marinho"]],
                               destaque = cores_macroliga[["vermelho"]]),
                    guide = "none", drop = FALSE, ...)
}

# Linha de base no zero, por cima das barras (adicione depois de geom_col()).
linha_zero <- function(horizontal = FALSE) {
  if (horizontal) {
    geom_vline(xintercept = 0, colour = cores_macroliga[["grafite"]], linewidth = 0.7)
  } else {
    geom_hline(yintercept = 0, colour = cores_macroliga[["grafite"]], linewidth = 0.7)
  }
}

# Valor na ponta de cada barra: por fora, acima/à direita se positivo e
# abaixo/à esquerda se negativo.
# horizontal: TRUE quando a categoria está no eixo y (ranking)
# quais:      "todos" (rankings, poucas colunas) ou "ultimo" (séries longas:
#             rotule só o dado discutido no comentário)
rotulos_barras <- function(dados, categoria, valor, horizontal = FALSE,
                           formato = num_br(accuracy = 0.1),
                           quais = c("todos", "ultimo"),
                           tamanho = 5.2) {
  quais <- match.arg(quais)
  d <- dados
  if (quais == "ultimo") {
    d <- d[which.max(as.numeric(d[[categoria]])), , drop = FALSE]
  }
  d$.rotulo <- formato(d[[valor]])
  negativo <- d[[valor]] < 0
  folga <- diff(range(c(0, dados[[valor]]), na.rm = TRUE)) * 0.015
  d$.pos <- d[[valor]] + ifelse(negativo, -folga, folga)
  d$.just <- ifelse(negativo, 1, 0)
  texto <- if (horizontal) {
    geom_text(data = d, aes(x = .pos, y = .data[[categoria]],
                            label = .rotulo, hjust = .just),
              inherit.aes = FALSE, family = fonte_texto, fontface = "bold",
              colour = cores_macroliga[["grafite"]], size = tamanho)
  } else {
    geom_text(data = d, aes(x = .data[[categoria]], y = .pos,
                            label = .rotulo, vjust = .just),
              inherit.aes = FALSE, family = fonte_texto, fontface = "bold",
              colour = cores_macroliga[["grafite"]], size = tamanho)
  }
  list(texto, coord_cartesian(clip = "off"))
}

# ---- Contribuições empilhadas + total ----------------------------------------------------
# Decomposição de uma variação (ex.: contribuição dos grupos do IPCA, PIB pela
# ótica da demanda). Colunas empilhadas por componente — positivos acima e
# negativos abaixo do zero — e o total como linha com pontos em grafite.
# dados: formato longo, uma linha por x e componente. Até 4 componentes +
#        "Outros"; ponha "Outros" como último nível do fator.
# total: NULL soma os componentes; ou um data.frame com as colunas `x` e `y`
#        (mesmos nomes) com o total oficial.
# Já inclui linha_zero(), scale_fill_macroliga() e a escala do total; use
# theme_macroliga(eixo = "nenhum").
contribuicoes <- function(dados, x, y, grupo, total = NULL,
                          nome_total = "Total", largura = 0.75) {
  if (is.null(total)) {
    total <- stats::aggregate(dados[[y]], list(dados[[x]]), sum)
    names(total) <- c(x, y)
  }
  total$.serie <- nome_total
  valores_x <- dados[[x]]
  largura_col <- if (is.numeric(valores_x) || inherits(valores_x, "Date")) {
    largura * resolution(as.numeric(valores_x), zero = FALSE)
  } else {
    largura
  }
  grafite <- cores_macroliga[["grafite"]]
  list(
    geom_col(data = dados, aes(x = .data[[x]], y = .data[[y]], fill = .data[[grupo]]),
             inherit.aes = FALSE, width = largura_col,
             colour = cores_macroliga[["offwhite"]], linewidth = 0.3),
    linha_zero(),
    geom_line(data = total, aes(x = .data[[x]], y = .data[[y]], colour = .serie),
              inherit.aes = FALSE, linewidth = 0.9),
    geom_point(data = total, aes(x = .data[[x]], y = .data[[y]], colour = .serie),
               inherit.aes = FALSE, size = 2.8),
    scale_fill_macroliga(),
    scale_colour_manual(values = stats::setNames(grafite, nome_total)),
    guides(fill = guide_legend(order = 1), colour = guide_legend(order = 2))
  )
}

# ---- Faixas e períodos ---------------------------------------------------------------------
# Adicione ANTES de geom_line(), para a série ficar por cima.

# banda(): faixa sombreada entre dois limites (ex.: intervalo de tolerância
# da meta), com linha tracejada opcional no centro e rótulo opcional.
banda <- function(dados, x, inferior, superior, centro = NULL,
                  rotulo = NULL, tamanho = 5.2) {
  camadas <- list(
    geom_ribbon(data = dados,
                aes(x = .data[[x]], ymin = .data[[inferior]], ymax = .data[[superior]]),
                inherit.aes = FALSE, fill = cores_macroliga[["azul_marinho"]],
                alpha = 0.10)
  )
  if (!is.null(centro)) {
    camadas <- c(camadas, list(
      geom_line(data = dados, aes(x = .data[[x]], y = .data[[centro]]),
                inherit.aes = FALSE, colour = cores_macroliga[["grafite"]],
                linewidth = 0.4, linetype = "22")
    ))
  }
  if (!is.null(rotulo)) {
    ini <- dados[which.min(dados[[x]]), , drop = FALSE]
    ini$.rotulo <- rotulo
    camadas <- c(camadas, list(
      geom_text(data = ini, aes(x = .data[[x]], y = .data[[superior]], label = .rotulo),
                inherit.aes = FALSE, hjust = 0, vjust = -0.6,
                family = fonte_texto, colour = cores_macroliga[["grafite"]],
                size = tamanho * 0.8)
    ))
  }
  camadas
}

# Metas de inflação definidas pelo CMN (centro e tolerância, em % e p.p.).
# Desde 2025 a meta é contínua: 3,0% ± 1,5 p.p. (anos seguintes repetem 2025).
metas_cmn <- data.frame(
  ano        = 2006:2025,
  centro     = c(rep(4.5, 13), 4.25, 4, 3.75, 3.5, 3.25, 3, 3),
  tolerancia = c(rep(2, 11), rep(1.5, 9))
)

# meta_inflacao(inicio, fim) -> data.frame(data, centro, inferior, superior)
# em degraus anuais, pronto para banda(..., "inferior", "superior", "centro").
meta_inflacao <- function(inicio, fim) {
  inicio <- as.Date(inicio)
  fim <- as.Date(fim)
  anos <- as.integer(format(inicio, "%Y")):as.integer(format(fim, "%Y"))
  m <- metas_cmn[match(pmin(anos, max(metas_cmn$ano)), metas_cmn$ano), ]
  if (anyNA(m$centro)) stop("[MacroLiga] metas_cmn começa em 2006.", call. = FALSE)
  d <- data.frame(
    data       = c(as.Date(paste0(anos, "-01-01")), as.Date(paste0(anos, "-12-31"))),
    centro     = rep(m$centro, 2),
    tolerancia = rep(m$tolerancia, 2)
  )
  d <- d[order(d$data), ]
  d$data <- pmin(pmax(d$data, inicio), fim)
  d$inferior <- d$centro - d$tolerancia
  d$superior <- d$centro + d$tolerancia
  d[, c("data", "centro", "inferior", "superior")]
}

# periodos(): sombreia intervalos de tempo (recessões, mandatos, choques).
#   periodos(recessoes_codace$inicio, recessoes_codace$fim)
#   periodos("2020-03-01", "2020-12-31", rotulo = "Pandemia")
periodos <- function(inicio, fim, rotulo = NULL, tamanho = 4.2) {
  d <- data.frame(inicio = as.Date(inicio), fim = as.Date(fim),
                  ymin = -Inf, ymax = Inf)
  camadas <- list(
    geom_rect(data = d, aes(xmin = inicio, xmax = fim, ymin = ymin, ymax = ymax),
              inherit.aes = FALSE, fill = cores_macroliga[["contexto"]], alpha = 0.25)
  )
  if (!is.null(rotulo)) {
    d$.rotulo <- rotulo
    d$.meio <- d$inicio + (d$fim - d$inicio) / 2
    camadas <- c(camadas, list(
      geom_text(data = d, aes(x = .meio, y = Inf, label = .rotulo),
                inherit.aes = FALSE, vjust = 1.6, family = fonte_texto,
                colour = cores_macroliga[["grafite"]], size = tamanho)
    ))
  }
  camadas
}

# Recessões recentes datadas pelo CODACE/FGV (do trimestre seguinte ao pico
# até o vale). Confira e complete em https://portalibre.fgv.br/codace
recessoes_codace <- data.frame(
  inicio = as.Date(c("2008-10-01", "2014-04-01", "2020-01-01")),
  fim    = as.Date(c("2009-03-31", "2016-12-31", "2020-06-30"))
)

# ---- Dispersão ---------------------------------------------------------------------------
# Pontos azul-marinho com o destaque em vermelho, e um anel na cor do fundo
# que separa pontos sobrepostos. Mapeie `fill` com destacar():
#   ggplot(d, aes(desemprego, inflacao, fill = destacar(data, max(d$data)))) +
#     tendencia() + pontos() + scale_fill_destaque() +
#     theme_macroliga(grade = "ambas")
# Série no tempo: destaque o último dado. Entre países: destaque o Brasil.
# Os pontos são desenhados na ordem das linhas: deixe o destaque por último.
# Sem destaque: pontos(fill = cores_macroliga[["azul_marinho"]]).
# Na dispersão os dois eixos são grandezas: nomeie-os em labs(x, y).
pontos <- function(..., tamanho = 3.4) {
  geom_point(..., shape = 21, colour = cores_macroliga[["offwhite"]],
             stroke = 0.6, size = tamanho)
}

# Reta de tendência (mínimos quadrados) tracejada, por baixo dos pontos.
tendencia <- function() {
  geom_smooth(aes(group = 1, fill = NULL, colour = NULL), method = "lm",
              formula = y ~ x, se = FALSE,
              colour = cores_macroliga[["grafite"]], linewidth = 0.6,
              linetype = "22")
}

# Rótulos de pontos escolhidos (nunca de todos), afastados dos pontos.
# rotulo: coluna com o texto; quais: valores dessa coluna a rotular.
# Usa o pacote ggrepel, se instalado; sem ele, o texto fica acima do ponto.
rotulos_pontos <- function(dados, x, y, rotulo, quais = NULL, tamanho = 4.6) {
  d <- dados
  d$.rotulo <- as.character(d[[rotulo]])
  if (!is.null(quais)) d$.rotulo[!d$.rotulo %in% quais] <- ""
  mapeamento <- aes(x = .data[[x]], y = .data[[y]], label = .rotulo)
  if (requireNamespace("ggrepel", quietly = TRUE)) {
    # Os pontos sem rótulo ("") continuam nos dados para o texto desviar deles
    ggrepel::geom_text_repel(data = d, mapping = mapeamento, inherit.aes = FALSE,
                             family = fonte_texto, fontface = "bold",
                             colour = cores_macroliga[["grafite"]], size = tamanho,
                             box.padding = 0.5, point.padding = 0.3,
                             min.segment.length = 0, max.overlaps = Inf,
                             segment.colour = cores_macroliga[["contexto"]],
                             seed = 1)
  } else {
    d <- d[d$.rotulo != "", , drop = FALSE]
    geom_text(data = d, mapping = mapeamento, inherit.aes = FALSE, vjust = -1.2,
              family = fonte_texto, fontface = "bold",
              colour = cores_macroliga[["grafite"]], size = tamanho)
  }
}

# ---- Haltere (dois momentos por categoria) -----------------------------------------------
# Um traço liga os dois valores de cada categoria; o 1º nível de `momento` é
# azul e o 2º vermelho (paleta da comparação, como no logo).
# dados: formato longo (categoria, valor, momento); `momento` é um fator com
#        2 níveis, na ordem cronológica. Ordene as categorias antes, ex.:
#        d$uf <- ordenar(d$uf, ifelse(d$momento == "2026", d$valor, NA))
# Já inclui scale_colour_macroliga(); use theme_macroliga(grade = "x").
haltere <- function(dados, categoria, valor, momento, tamanho = 4.2) {
  if (length(unique(dados[[momento]])) != 2) {
    stop("[MacroLiga] haltere() compara exatamente 2 momentos.", call. = FALSE)
  }
  cats <- dados[[categoria]]
  faixa <- do.call(rbind, lapply(split(dados[[valor]], cats, drop = TRUE), range))
  seg <- data.frame(.cat = rownames(faixa), .ini = faixa[, 1], .fim = faixa[, 2])
  if (is.factor(cats)) seg$.cat <- factor(seg$.cat, levels = levels(cats))
  list(
    geom_segment(data = seg, aes(x = .ini, xend = .fim, y = .cat, yend = .cat),
                 inherit.aes = FALSE, colour = cores_macroliga[["contexto"]],
                 linewidth = 1.4),
    geom_point(data = dados,
               aes(x = .data[[valor]], y = .data[[categoria]], colour = .data[[momento]]),
               inherit.aes = FALSE, size = tamanho),
    scale_colour_macroliga()
  )
}

# ---- Cascata (waterfall) ---------------------------------------------------------------
# Ponte entre dois níveis, mostrando as parcelas da variação (ex.: fatores da
# variação da dívida/PIB, contribuição dos grupos para o IPCA do mês).
# dados:       uma linha por barra, na ordem de exibição (colunas etapa e valor)
# totais:      etapas que são NÍVEIS (barra do zero até o valor), ex.: o ponto
#              de partida; as demais são variações e flutuam sobre o acumulado
# total_final: nome de uma última barra com o acumulado (NULL para omitir)
# Cores: variação positiva azul-marinho, negativa vermelha (como nas colunas)
# e totais em cinza. Prefira até ~6 barras: some as parcelas pequenas em
# "Outros" (aqui "Outros" é uma variação, com a cor do sinal). Já inclui linha_zero() e a escala x com os nomes das
# etapas; use theme_macroliga(eixo = "nenhum").
cascata <- function(dados, etapa, valor, totais = NULL, total_final = NULL,
                    formato = num_br(accuracy = 0.1), largura = 0.7,
                    quebra = 10, tamanho = 5.2) {
  d <- data.frame(etapa = as.character(dados[[etapa]]), valor = dados[[valor]])
  d$tipo <- ifelse(d$etapa %in% totais, "total",
                   ifelse(d$valor < 0, "negativo", "positivo"))
  d$ini <- d$fim <- NA_real_
  nivel <- 0
  for (i in seq_len(nrow(d))) {
    d$ini[i] <- if (d$tipo[i] == "total") 0 else nivel
    d$fim[i] <- if (d$tipo[i] == "total") d$valor[i] else nivel + d$valor[i]
    nivel <- d$fim[i]
  }
  if (!is.null(total_final)) {
    d <- rbind(d, data.frame(etapa = total_final, valor = nivel, tipo = "total",
                             ini = 0, fim = nivel))
  }
  if (anyDuplicated(d$etapa)) stop("[MacroLiga] Nomes de etapa repetidos.", call. = FALSE)
  d$x <- seq_len(nrow(d))
  sinal_txt <- ifelse(d$tipo != "total" & d$valor > 0, "+", "")
  d$.rotulo <- paste0(sinal_txt, formato(d$valor))
  sobe <- d$fim >= d$ini
  folga <- diff(range(c(0, d$ini, d$fim), na.rm = TRUE)) * 0.015
  d$.y_rotulo <- ifelse(sobe, pmax(d$ini, d$fim) + folga, pmin(d$ini, d$fim) - folga)
  d$.vjust <- ifelse(sobe, 0, 1)
  # Conectores: do fim de cada barra ao início da seguinte, no nível acumulado
  con <- data.frame(x = d$x[-nrow(d)] + largura / 2, xend = d$x[-1] - largura / 2,
                    y = d$fim[-nrow(d)])
  list(
    geom_rect(data = d, aes(xmin = x - largura / 2, xmax = x + largura / 2,
                            ymin = pmin(ini, fim), ymax = pmax(ini, fim), fill = tipo),
              inherit.aes = FALSE),
    geom_segment(data = con, aes(x = x, xend = xend, y = y, yend = y),
                 inherit.aes = FALSE, colour = cores_macroliga[["grafite"]],
                 linewidth = 0.4),
    linha_zero(),
    geom_text(data = d, aes(x = x, y = .y_rotulo, label = .rotulo, vjust = .vjust),
              inherit.aes = FALSE, family = fonte_texto, fontface = "bold",
              colour = cores_macroliga[["grafite"]], size = tamanho),
    scale_fill_manual(values = c(positivo = cores_macroliga[["azul_marinho"]],
                                 negativo = cores_macroliga[["vermelho"]],
                                 total    = cores_macroliga[["contexto"]]),
                      guide = "none"),
    # Com muitas barras, os nomes alternam em duas linhas para não se sobrepor
    scale_x_continuous(breaks = d$x, labels = label_wrap(quebra)(d$etapa),
                       expand = expansion(add = 0.3),
                       guide = guide_axis(n.dodge = if (nrow(d) > 7) 2 else 1)),
    coord_cartesian(clip = "off")
  )
}

# ---- Pequenos múltiplos (facetas) -----------------------------------------------------
# Para mais de 4 séries: um painel por série, com a mesma escala y.
#   ggplot(d, aes(data, valor)) +
#     contexto_facetas(d, "data", "valor", "grupo") +
#     geom_line(colour = cores_macroliga[["azul_marinho"]]) +
#     rotulos_finais(d, "data", "valor", faceta = "grupo") +
#     facet_wrap(~ grupo, ncol = 3) + theme_macroliga()
# contexto_facetas(): repete TODAS as séries em cinza no fundo de cada painel,
# para cada série ser lida contra as demais.
contexto_facetas <- function(dados, x, y, faceta) {
  fundo <- dados
  fundo$.serie <- fundo[[faceta]]
  fundo[[faceta]] <- NULL   # sem a coluna da faceta, a camada vai a todos os painéis
  geom_line(data = fundo, aes(x = .data[[x]], y = .data[[y]], group = .serie),
            inherit.aes = FALSE, colour = cores_macroliga[["contexto"]],
            linewidth = 0.4, alpha = 0.45)
}

# ---- Exportação ---------------------------------------------------------------------------
# Tamanhos em pixels, já no dobro da área do template (nitidez em telas retina):
#   grafico_comentado   : área do gráfico no template "Gráfico Comentado" (888 x 690)
#   carrossel           : área cinza da lâmina de gráfico do carrossel   (888 x 800)
#   linkedin            : post horizontal do LinkedIn                     (1200 x 627)
#   vertical            : post retrato 4:5 do Instagram                   (1080 x 1350)
#   publicacao          : figura para o fascículo (16 x 10 cm, 300 dpi) — use base_size = 10
#   publicacao_vertical : figura alta no fascículo (16 x 20 cm, 300 dpi) — use base_size = 10
#   site                : página de gráfico do site — use base_size = 12, sem título
#                         (título, subtítulo e fonte ficam no texto da página).
#                         Gera DOIS arquivos, um por tamanho de tela:
#                           arquivo.png          desktop (896 x 560 na tela)
#                           arquivo-celular.png  celular (360 x 450 na tela, 4:5)
#                         Assim o texto do gráfico fica com ~15 px nas duas telas.
#                         No Quarto, use grafico_site(), que já monta a imagem certa.
# Os formatos verticais servem para rankings longos (ex.: as 27 UFs). Séries
# no tempo ficam na horizontal: a função avisa quando a escolha não combina.
# transparente: fundo transparente, qualquer que seja o `fundo` do tema.
#   Padrão: sim nos formatos de publicação (para não marcar a página do
#   fascículo) e não nas redes (off-white, igual aos templates do Canva).
salvar_macroliga <- function(grafico, arquivo,
                             formato = c("grafico_comentado", "carrossel",
                                         "linkedin", "vertical", "publicacao",
                                         "publicacao_vertical", "site"),
                             transparente = NULL) {
  formato <- match.arg(formato)
  if (is.null(transparente)) {
    transparente <- formato %in% c("publicacao", "publicacao_vertical")
  }
  if (transparente) {
    sem_fundo <- element_rect(fill = NA, colour = NA)
    grafico <- grafico + theme(plot.background = sem_fundo,
                               panel.background = sem_fundo)
  }
  if (formato == "site") {
    celular <- paste0(tools::file_path_sans_ext(arquivo), "-celular.png")
    .salvar(grafico, arquivo, list(w = 1792, h = 1120, units = "px", dpi = 192), transparente)
    .salvar(grafico, celular, list(w = 720,  h = 900,  units = "px", dpi = 192), transparente)
    return(invisible(c(desktop = arquivo, celular = celular)))
  }
  spec <- switch(formato,
    grafico_comentado   = list(w = 1776, h = 1380, units = "px", dpi = 192),
    carrossel           = list(w = 1776, h = 1600, units = "px", dpi = 192),
    linkedin            = list(w = 2400, h = 1254, units = "px", dpi = 192),
    vertical            = list(w = 2160, h = 2700, units = "px", dpi = 192),
    publicacao          = list(w = 16,   h = 10,   units = "cm", dpi = 300),
    publicacao_vertical = list(w = 16,   h = 20,   units = "cm", dpi = 300)
  )
  .checar_orientacao(grafico, formato)
  .salvar(grafico, arquivo, spec, transparente)
  invisible(arquivo)
}

.salvar <- function(grafico, arquivo, spec, transparente) {
  dispositivo <- if (requireNamespace("ragg", quietly = TRUE)) ragg::agg_png else "png"
  ggsave(arquivo, grafico, width = spec$w, height = spec$h, units = spec$units,
         dpi = spec$dpi, device = dispositivo,
         bg = if (transparente) "transparent" else cores_macroliga[["offwhite"]])
}

# Avisa (sem impedir) quando o formato não combina com o gráfico:
# tempo no eixo x em formato vertical, ou ranking longo em formato horizontal.
.checar_orientacao <- function(grafico, formato) {
  layout <- tryCatch(ggplot_build(grafico)$layout, error = function(e) NULL)
  if (is.null(layout)) return(invisible())
  escala_x <- layout$panel_scales_x[[1]]
  escala_y <- layout$panel_scales_y[[1]]
  vertical <- formato %in% c("vertical", "publicacao_vertical")
  if (vertical && inherits(escala_x, c("ScaleContinuousDate", "ScaleContinuousDatetime"))) {
    message("[MacroLiga] Formato vertical com datas no eixo x: séries no tempo ",
            "ficam melhores na horizontal (grafico_comentado, carrossel, linkedin).")
  }
  if (!vertical && inherits(escala_y, "ScaleDiscrete") &&
      length(escala_y$get_limits()) > 12) {
    message("[MacroLiga] Ranking com mais de 12 categorias: considere o formato ",
            "\"vertical\" (redes) ou \"publicacao_vertical\" (fascículo).")
  }
  invisible()
}

# ---- Gráfico na página do site (Quarto) --------------------------------------------------
# Num bloco de código R da página do gráfico:
#   grafico_site(g, alt = "Gráfico de linha da Selic, de 2016 a 2026. ...")
# Salva as duas versões do formato "site" e escreve a imagem na página: o celular
# baixa só a versão 4:5 e o desktop (a partir de 768 px), só a horizontal. Também
# escreve o link "Abrir o gráfico em tamanho maior".
# alt: obrigatório. Descreva o que o gráfico mostra, em uma ou duas frases.
grafico_site <- function(grafico, alt, nome = "grafico") {
  if (missing(alt) || !nzchar(trimws(alt))) {
    stop("[MacroLiga] Falta o texto alternativo: grafico_site(g, alt = \"...\").",
         call. = FALSE)
  }
  # Dentro do Quarto, as imagens vão para a pasta de figuras da página.
  pasta <- if (isTRUE(getOption("knitr.in.progress"))) dirname(knitr::fig_path()) else "."
  dir.create(pasta, recursive = TRUE, showWarnings = FALSE)
  arquivos <- salvar_macroliga(grafico, file.path(pasta, paste0(nome, ".png")), "site")
  escapar <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    x <- gsub(">", "&gt;", x, fixed = TRUE)
    gsub("\"", "&quot;", x, fixed = TRUE)
  }
  html <- paste0(
    '<figure class="grafico__figura"><picture>',
    '<source media="(min-width: 768px)" srcset="', arquivos[["desktop"]],
    '" width="1792" height="1120">',
    '<img src="', arquivos[["celular"]], '" alt="', escapar(alt),
    '" width="720" height="900">',
    '</picture></figure>',
    '<a class="grafico__ampliar" href="', arquivos[["desktop"]],
    '">Abrir o gráfico em tamanho maior</a>'
  )
  if (isTRUE(getOption("knitr.in.progress"))) {
    knitr::asis_output(html)
  } else {
    cat(html, "\n")
    invisible(html)
  }
}

# ---- Dados do Banco Central (SGS) ------------------------------------------------------
# sgs(432, "01/01/2015")  -> data.frame(data, valor)
# Códigos úteis (confira em https://www3.bcb.gov.br/sgspub):
#   432   Meta Selic definida pelo Copom (% a.a.)
#   433   IPCA - variação mensal (%)
#   13522 IPCA - acumulado em 12 meses (%)
#   24364 IBC-Br com ajuste sazonal (índice)
# Séries diárias: a API exige `inicio` e aceita no máximo 10 anos por
# consulta; com `inicio` informado, o período é dividido em janelas sozinho.
sgs <- function(codigo, inicio = NULL, fim = NULL) {
  baixar <- function(ini, ult) {
    url <- paste0("https://api.bcb.gov.br/dados/serie/bcdata.sgs.", codigo,
                  "/dados?formato=json")
    if (!is.null(ini)) url <- paste0(url, "&dataInicial=", format(ini, "%d/%m/%Y"))
    if (!is.null(ult)) url <- paste0(url, "&dataFinal=", format(ult, "%d/%m/%Y"))
    # A API às vezes falha por instantes: tenta 3 vezes antes de desistir
    for (tentativa in 1:3) {
      resposta <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
      if (!is.null(resposta)) return(resposta)
      Sys.sleep(2)
    }
    stop("[MacroLiga] O SGS não respondeu à consulta da série ", codigo,
         if (!is.null(ini)) paste0(" a partir de ", format(ini, "%d/%m/%Y")),
         ". Confira o código e a conexão; séries diárias exigem `inicio`.",
         call. = FALSE)
  }
  como_data <- function(x) as.Date(x, format = "%d/%m/%Y")
  ult <- if (is.null(fim)) NULL else como_data(fim)
  if (is.null(inicio)) {
    partes <- list(baixar(NULL, ult))
  } else {
    ini <- como_data(inicio)
    if (is.null(ult)) ult <- Sys.Date()
    cortes <- seq(ini, ult, by = "9 years")
    finais <- c(cortes[-1] - 1, ult)
    partes <- Map(baixar, cortes, finais)
  }
  # Janelas sem observação voltam vazias; só descarta essas
  partes <- Filter(function(p) is.data.frame(p) && nrow(p) > 0, partes)
  if (length(partes) == 0) {
    stop("[MacroLiga] A série ", codigo, " não tem dados no período.", call. = FALSE)
  }
  bruto <- do.call(rbind, partes)
  data.frame(data  = como_data(bruto$data),
             valor = as.numeric(bruto$valor))
}

# ---- Dados do IBGE (SIDRA) -------------------------------------------------------------
# sidra("t/4099/n3/all/v/4099/p/last%201")
#   -> data.frame com as colunas do SIDRA (com os nomes legíveis, ex.:
#      "Unidade da Federação", "Mês (Código)") e `valor` numérico.
# Monte o caminho da consulta em https://apisidra.ibge.gov.br
# Tabelas úteis: 7060 (IPCA por grupo: v63 variação mensal, v66 peso,
#                2265 acumulado em 12 meses) e 4099 (desocupação, PNAD Contínua).
sidra <- function(caminho) {
  bruto <- jsonlite::fromJSON(paste0("https://apisidra.ibge.gov.br/values/", caminho))
  nomes <- unlist(bruto[1, ], use.names = FALSE)
  dados <- bruto[-1, , drop = FALSE]
  names(dados) <- nomes
  dados$valor <- suppressWarnings(as.numeric(dados$Valor))  # "..." e "-" viram NA
  rownames(dados) <- NULL
  dados
}

# ---- Dados do Tesouro Direto -------------------------------------------------------------
# tesouro_direto() -> data.frame(tipo, vencimento, data_base, taxa_compra,
#                                taxa_venda, pu_base), taxas em % a.a.
# Todos os títulos desde 2002 (arquivo de ~15 MB; o download leva ~1 min).
# Com `arquivo`, baixa só na primeira vez e depois lê a cópia local
# (apague o arquivo para atualizar):  td <- tesouro_direto("td.csv")
# Para a curva de juros use `taxa_venda`, que existe para todos os títulos em
# estoque (a taxa de compra é zero nos títulos fora de venda).
tesouro_direto <- function(arquivo = NULL) {
  url <- paste0("https://www.tesourotransparente.gov.br/ckan/dataset/",
                "df56aa42-484a-4a59-8184-7676580c81e3/resource/",
                "796d2059-14e9-44e3-80c9-2d9e30b405c1/download/PrecoTaxaTesouroDireto.csv")
  if (is.null(arquivo)) arquivo <- tempfile(fileext = ".csv")
  if (!file.exists(arquivo)) {
    tempo <- getOption("timeout")
    on.exit(options(timeout = tempo), add = TRUE)
    options(timeout = max(300, tempo))
    utils::download.file(url, arquivo, mode = "wb", quiet = TRUE)
  }
  bruto <- utils::read.csv2(arquivo, fileEncoding = "latin1", check.names = FALSE,
                            stringsAsFactors = FALSE)
  como_data <- function(x) as.Date(x, format = "%d/%m/%Y")
  data.frame(tipo        = bruto[["Tipo Titulo"]],
             vencimento  = como_data(bruto[["Data Vencimento"]]),
             data_base   = como_data(bruto[["Data Base"]]),
             taxa_compra = bruto[["Taxa Compra Manha"]],
             taxa_venda  = bruto[["Taxa Venda Manha"]],
             pu_base     = bruto[["PU Base Manha"]])
}
