// Monta cada wireframe: navegação entre telas, as duas molduras (celular e
// desktop) a partir do <template id="tela">, e os blocos comuns G1 e G2.
// G1 e G2 ficam escritos só aqui, para valer igual em todas as telas.

const TELAS = [
  ["inicio-a.html", "Início A (fascículo)"],
  ["inicio-b.html", "Início B (grade de pontos)"],
  ["inicio-c.html", "Início C (gráfico comentado)"],
  ["publicacoes.html", "Publicações"],
  ["fasciculo.html", "Fascículo nº 1"],
  ["texto.html", "Texto"],
  ["eventos.html", "Eventos"],
  ["sobre.html", "Sobre"],
  ["equipe.html", "Equipe"],
  ["participe.html", "Participe"],
];

const MENU = ["Início", "Publicações", "Gráficos comentados", "Eventos", "Sobre", "Equipe", "Participe"];

function g1(ativo) {
  const itens = MENU.map(m => `<a href="#"${m === ativo ? ' aria-current="page"' : ""}>${m}</a>`).join("");
  return `
  <section class="b cheio">
    <p class="nota"><b>G1</b> cabeçalho (igual em todas as páginas): logo horizontal + menu. No celular, o menu abre por botão. "Gráficos comentados" depende da decisão 4.</p>
    <div class="lim">
      <a class="pular" href="#">Pular para o conteúdo</a>
      <div class="g1-barra">
        <span class="logo">logo horizontal</span>
        <span class="btn so-c">Abrir menu</span>
        <nav class="menu so-d">${itens}</nav>
      </div>
    </div>
  </section>`;
}

const G2 = `
  <section class="b cheio escuro">
    <p class="nota"><b>G2</b> rodapé (igual em todas as páginas): identidade, contato e créditos. Faz o papel da página Contato.</p>
    <div class="lim g3">
      <div>
        <span class="logo">logo horizontal (branca)</span>
        <p class="t3" style="margin-top:10px">MacroLiga UFRGS, Liga Acadêmica de Macroeconomia.</p>
        <p class="peq">Projeto de extensão da Faculdade de Ciências Econômicas da UFRGS, coordenado pelo prof. Leonardo Xavier da Silva.</p>
      </div>
      <div>
        <p class="t3">Contato</p>
        <p class="peq">E-mail: macroliga.ufrgs@gmail.com<br>Instagram: @macroliga.ufrgs<br>LinkedIn: MacroLiga UFRGS</p>
        <span class="btn">Escrever para a liga</span>
      </div>
      <div class="peq">
        <p>Textos publicados sob a licença CC BY 4.0.</p>
        <p>Site feito pela equipe de Comunicação da liga, com Quarto, e publicado no GitHub Pages.</p>
        <p>© 2026 MacroLiga UFRGS</p>
      </div>
    </div>
  </section>`;

(function montar() {
  const corpo = document.body;
  const params = new URLSearchParams(location.search);
  if (params.get("so")) corpo.dataset.so = params.get("so");

  // Navegação entre telas
  const topo = document.querySelector(".wf-topo");
  const atual = location.pathname.split("/").pop();
  const nav = document.createElement("nav");
  nav.className = "wf-nav";
  nav.innerHTML = `<a href="index.html">Índice</a>` + TELAS.map(([arq, nome]) =>
    `<a href="${arq}"${arq === atual ? ' aria-current="page"' : ""}>${nome}</a>`).join("");
  topo.prepend(nav);
  const ctrl = document.createElement("p");
  ctrl.className = "wf-ctrl";
  ctrl.innerHTML = `<label><input type="checkbox" id="reduzir"> Mostrar o desktop pela metade (para caber em telas menores)</label>`;
  topo.append(ctrl);

  // Molduras
  const modelo = document.getElementById("tela");
  const palco = document.createElement("main");
  palco.className = "wf-palco";
  palco.innerHTML = `
    <figure class="wf-quadro wf-celular"><figcaption>Celular, 390 px</figcaption><div class="tela"></div></figure>
    <figure class="wf-quadro wf-desktop"><figcaption>Desktop, 1280 px</figcaption><div class="tela"></div></figure>`;
  palco.querySelectorAll(".tela").forEach(t => {
    t.append(modelo.content.cloneNode(true));
    t.querySelectorAll("[data-g1]").forEach(el => { el.outerHTML = g1(corpo.dataset.menu); });
    t.querySelectorAll("[data-g2]").forEach(el => { el.outerHTML = G2; });
  });
  topo.after(palco);
})();
