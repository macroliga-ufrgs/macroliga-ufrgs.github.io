# Gera o SVG do mapa de pontos da abertura (I1) a partir do símbolo do logo.
# Uso: python design/gerar-mapa.py  (a partir da pasta site/)
# Saída: design/mapa-pontos.svg, para colar no HTML (ou incluir no Quarto).
#
# As posições dos pontos são as do logo aprovado, sem alteração. O script só
# acrescenta a grade de fundo, a ordem da animação (--i) e o ponto de Porto Alegre.
import re
from pathlib import Path

SITE = Path(__file__).resolve().parent.parent
logo = (SITE / "assets/marca/svg/macroliga-simbolo-cor.svg").read_text(encoding="utf-8")

pontos = [
    (float(x), float(y), float(r))
    for x, y, r in re.findall(r'<circle cx="([\d.]+)" cy="([\d.]+)" r="([\d.]+)"', logo)
    if float(r) < 100  # descarta o círculo azul de fundo
]

xs = sorted({p[0] for p in pontos})
ys = sorted({p[1] for p in pontos})
passo_x = (xs[-1] - xs[0]) / (len(xs) - 1)
passo_y = (ys[-1] - ys[0]) / (len(ys) - 1)

# Porto Alegre (51,23° O; 30,03° S), projetada nos limites do mapa
# (74,0° O a 34,8° O; 5,3° N a 33,8° S). Fica com o ponto mais próximo.
px = xs[0] + (-51.23 + 73.99) / 39.20 * (xs[-1] - xs[0])
py = ys[0] + (5.27 + 30.03) / 39.02 * (ys[-1] - ys[0])
poa = min(pontos, key=lambda p: (p[0] - px) ** 2 + (p[1] - py) ** 2)

# Ordem da animação: de norte a sul, com leve inclinação de oeste para leste.
def ordem(p):
    linha = (p[1] - ys[0]) / passo_y
    coluna = (p[0] - xs[0]) / passo_x
    return linha + 0.25 * coluna

maximo = max(ordem(p) for p in pontos)

# Enquadramento: 8 passos de grade à esquerda (onde a grade se dissolve, sem
# encobrir o mapa), 3 à direita e 1 em cima e embaixo.
x0 = xs[0] - 8 * passo_x
y0 = ys[0] - 1 * passo_y
largura = (xs[-1] - xs[0]) + 11 * passo_x
altura = (ys[-1] - ys[0]) + 2 * passo_y

linhas = [
    f'<svg viewBox="{x0:.1f} {y0:.1f} {largura:.1f} {altura:.1f}" preserveAspectRatio="xMaxYMid meet" '
    'role="img" aria-label="Mapa do Brasil formado por pontos, como no logo da liga, com Porto Alegre em vermelho" focusable="false">',
    "<defs>",
    f'<pattern id="grade-pontos" patternUnits="userSpaceOnUse" width="{passo_x:.2f}" height="{passo_y:.2f}" '
    f'x="{xs[0] - passo_x / 2:.2f}" y="{ys[0] - passo_y / 2:.2f}">',
    f'<circle class="mapa-grade-ponto" cx="{passo_x / 2:.2f}" cy="{passo_y / 2:.2f}" r="14.6"/>',
    "</pattern>",
    "</defs>",
    '<rect class="mapa-grade" x="-3000" y="-3000" width="8000" height="8000" fill="url(#grade-pontos)"/>',
]
for p in sorted(pontos, key=ordem):
    linhas.append(
        f'<circle class="mapa-ponto" cx="{p[0]:.2f}" cy="{p[1]:.2f}" r="{p[2]:.1f}" style="--i:{ordem(p) / maximo:.3f}"/>'
    )
linhas.append(f'<circle class="mapa-destaque" cx="{poa[0]:.2f}" cy="{poa[1]:.2f}" r="22"/>')
linhas.append("</svg>")

saida = SITE / "design/mapa-pontos.svg"
saida.write_text("\n".join(linhas) + "\n", encoding="utf-8")
print(f"{len(pontos)} pontos; Porto Alegre em ({poa[0]}, {poa[1]}); {saida.stat().st_size} bytes")
