"""Confere todos os links internos e recursos de um site servido localmente.

Uso: python ferramentas/conferir-links.py http://127.0.0.1:8772/macroliga/index.html
Percorre as páginas a partir do endereço dado, sem sair do prefixo dele, e lista os
links e recursos (href/src) que dão erro ou saem do subcaminho. Sai com código 1 se houver algum.
"""
import sys
from html.parser import HTMLParser
from urllib.error import HTTPError, URLError
from urllib.parse import urldefrag, urljoin, urlparse
from urllib.request import urlopen


class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.encontrados = []

    def handle_starttag(self, tag, attrs):
        for nome, valor in attrs:
            if nome in ("href", "src") and valor:
                self.encontrados.append(valor)


def main():
    inicio = sys.argv[1]
    base = urlparse(inicio)
    prefixo = inicio.rsplit("/", 1)[0] + "/"
    fila, vistos, erros = [inicio], set(), []
    while fila:
        url = fila.pop()
        if url in vistos:
            continue
        vistos.add(url)
        try:
            with urlopen(url) as resposta:
                tipo = resposta.headers.get("Content-Type", "")
                corpo = resposta.read().decode("utf-8", "replace") if "html" in tipo else ""
        except (HTTPError, URLError) as erro:
            erros.append(f"{url}: {erro}")
            continue
        parser = Links()
        parser.feed(corpo)
        for bruto in parser.encontrados:
            alvo = urldefrag(urljoin(url, bruto))[0]
            p = urlparse(alvo)
            if p.scheme not in ("http", "https") or p.netloc != base.netloc:
                continue
            if not alvo.startswith(prefixo):
                erros.append(f"{url}: sai do subcaminho -> {bruto}")
                continue
            fila.append(alvo)
    print(f"{len(vistos)} endereços conferidos.")
    for e in erros:
        print("ERRO", e)
    sys.exit(1 if erros else 0)


if __name__ == "__main__":
    main()
