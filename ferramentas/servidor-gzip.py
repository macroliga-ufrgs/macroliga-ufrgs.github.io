"""Servidor local com gzip, como o GitHub Pages, para medir o peso real das páginas.
Uso: python ferramentas/servidor-gzip.py <pasta> <porta>"""
import gzip, sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

TIPOS = (".html", ".css", ".js", ".svg", ".json", ".xml", ".txt")


class Gzip(SimpleHTTPRequestHandler):
    def send_head(self):
        caminho = self.translate_path(self.path)
        if caminho.endswith("/"):
            caminho += "index.html"
        if "gzip" in self.headers.get("Accept-Encoding", "") and caminho.endswith(TIPOS):
            try:
                with open(caminho, "rb") as f:
                    dados = gzip.compress(f.read())
            except OSError:
                return super().send_head()
            self.send_response(200)
            self.send_header("Content-Type", self.guess_type(caminho))
            self.send_header("Content-Encoding", "gzip")
            self.send_header("Content-Length", str(len(dados)))
            self.end_headers()
            from io import BytesIO
            return BytesIO(dados)
        return super().send_head()

    def log_message(self, *args):
        pass


pasta, porta = sys.argv[1], int(sys.argv[2])
ThreadingHTTPServer(("127.0.0.1", porta), partial(Gzip, directory=pasta)).serve_forever()
