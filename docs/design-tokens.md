# Tokens e direção visual

- **Status:** prancha aprovada em 03/10/2026, com dois ajustes (sem frase sobre Porto Alegre; licença CC BY-NC 4.0). Plano de implementação em docs/plano-implementacao.md.
- **Arquivos:** `design/macroliga.css` (tokens e componentes), `design/prancha.html` (amostras), `design/abertura.html` (abertura da Início), `design/gerar-mapa.py` (gera `design/mapa-pontos.svg`) e `design/fontes.html` (comparação de fontes que levou à decisão D-F).
- **Uso na fase do Quarto:** as cores e as fontes vão para o `_brand.yml`; o resto de `macroliga.css` vira `estilos/macroliga.scss`, com os mesmos nomes de variáveis.

## Decisões aprovadas

| # | Decisão |
|---|---|
| D-A | **Ideia-assinatura:** o mapa de pontos se acende na abertura da Início. Usa as posições exatas dos 175 pontos do logo, em off-white sobre azul, sobre uma grade de fundo com o mesmo passo. Porto Alegre aparece por último, em vermelho. |
| D-B | **Sem legenda na abertura:** o ponto vermelho de Porto Alegre aparece sem frase explicativa. |
| D-C | **Cabeçalho azul-marinho em todas as páginas.** Na Início, ele se funde à abertura. |
| D-F | **Fontes:** Libre Baskerville + Inter, como antes. A Libre Baskerville agora é variável no Google Fonts (400 a 700), e os pesos intermediários fazem parte do sistema. |

## Tokens

Os valores estão em `design/macroliga.css`. Tamanhos em px, celular / desktop; o desktop começa em 992 px, o mesmo ponto em que o menu do Quarto deixa de ser recolhido.

| Token | Valor | Uso |
|---|---|---|
| `--fs-display` | 46–52 / 72–84, peso 400 | Só a frase da abertura |
| `--fs-h1` | 52 / 72, peso 400 | Título de página |
| `--fs-titulo-longo` | 32 / 44, peso 450 | Título de texto, gráfico e fascículo |
| `--fs-h2` | 28 / 36, peso 500 | Seções |
| `--fs-h3` | 21 / 24, peso 560 | Títulos em listas |
| `--fs-sintese` | 21, peso 400, entrelinha 1,65 | Síntese (serifa) |
| `--fs-corpo` | 17 / 18, entrelinha 1,6 | Texto (Inter) |
| `--fs-meta` | 15 | Tipo, autor, datas, rótulos |
| `--fs-pequeno` | 14 | Fonte de gráfico, créditos |

- **Pesos da Libre Baskerville:** o peso sobe quando o tamanho desce (400 grande; 450, 500 e 560 nos menores). O 700 é o peso do nome no logo e fica fora do site.
- **Espaçamento:** `--esp-1` a `--esp-10` = 4, 8, 12, 16, 24, 32, 48, 64, 96, 128. Gutter de 16 px no celular e 32 px no desktop; largura máxima de 1200 px; medida de 68ch.
- **Formas:** `--raio-0` em tudo e `--raio-ponto` (50%) só nos pontos. O ponto é a única forma redonda do site.
- **Linhas:** `--linha-grade` (1 px `grade`) entre os itens de lista e `--linha-eixo` (2 px `grafite`) no fim de cada lista, como a grade e o eixo de um gráfico.

## Regras que a prancha revelou

- **"nº" e o número nunca se separam:** os templates escrevem `nº&nbsp;{n}`.
- **Algarismos tabulares só em dados** (tabelas, metadados, gráficos). No corpo do texto, o `tabular-nums` da Inter também alarga o hífen ("azul - marinho").
- **Títulos em listas sem sublinhado**, que aparece só ao passar o mouse. Links no meio do texto continuam sublinhados.
- **O vermelho tem três usos:** Porto Alegre no mapa, o último dado de cada gráfico e a etapa "Publicação". Nunca texto, nunca estado de interface.

## Gráficos no site (formato `site` do tema em R)

- **Arquivo:** `assets/graficos/tema_macroliga.R` (cópia do site). O original em `../Materiais/Graficos/` não foi alterado.
- **Duas imagens por gráfico:** `salvar_macroliga(g, "grafico.png", "site")` gera `grafico.png` (1792 × 1120, exibida até 896 px no desktop) e `grafico-celular.png` (720 × 900, formato 4:5). Com `theme_macroliga(base_size = 12)` e `rotulos_finais(..., tamanho = 3.9)`, o texto do gráfico fica com cerca de 15 px nas duas telas. O PNG das redes ficaria com cerca de 7 px no celular.
- **Sem título na imagem:** título, subtítulo e fonte ficam no texto da página (GC3 e GC5).
- **No Quarto:** `grafico_site(g, alt = "...")` salva as duas versões e escreve um `<picture>`. O celular baixa só a versão 4:5; a partir de 768 px, o navegador baixa só a horizontal. O `alt` é obrigatório: sem ele, a renderização para com uma mensagem em português.
- **Rótulo do último dado:** a distância entre o ponto e o valor agora é um espaço tipográfico, e não um deslocamento no eixo x. Assim ela não encolhe no gráfico estreito do celular. Isso vale para todos os formatos.
- **`.fonte_ok()`** também aceita fontes registradas com `systemfonts::register_font()`, além das instaladas.

## Pontos resolvidos na etapa do plano (03/10/2026)

1. **`grafico_site()` dentro do Quarto:** testado no Quarto 1.10.18. O freeze guarda as duas imagens em `_freeze/<página>/figure-html/`, e o render as copia para `_site/`. Se um dia falhar, a saída aprovada é salvar as imagens na pasta da página e declará-las em `resources:`.
2. **Link na lista de Publicações (P4) e no sumário (F3):** o título é o link; não há botão "Ler o texto".
3. **Abertura em 360 px:** 46 px aceitos (2,7× o corpo), só em telas de 360–375 px.
4. **Fontes no `_brand.yml`:** ele só aceita pesos múltiplos de 100. A Inter (400 e 700) vem por ele; a Libre Baskerville vem por `<link>` com `wght@400..560`.
