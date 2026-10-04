// Menu principal (maquinaria: não mexa).
// 1. Marca a seção da página atual: fascículo e texto marcam Publicações; evento marca
//    Eventos; gráfico marca Gráficos comentados. (O Quarto só marca a página exata.)
// 2. Dá ao botão do menu do celular um rótulo visível e acessível: "Abrir menu" / "Fechar menu".
(function () {
  function pronto(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }
  pronto(function () {
    // A raiz do site vem do link do logo, que sempre aponta para a Início.
    var logo = document.querySelector(".navbar-brand");
    var raiz = new URL(logo ? logo.getAttribute("href") : "./", location.href).pathname.replace(/index\.html$/, "");
    var aqui = location.pathname;
    document.querySelectorAll("#navbarCollapse .nav-link").forEach(function (a) {
      var secao = new URL(a.getAttribute("href"), location.href).pathname.replace(/index\.html$/, "");
      if (secao === raiz) return;
      if (aqui.indexOf(secao) === 0) {
        a.classList.add("active");
        a.setAttribute("aria-current", "page");
      }
    });

    var botao = document.querySelector(".navbar-toggler");
    var menu = document.getElementById("navbarCollapse");
    if (!botao || !menu) return;
    botao.removeAttribute("role");
    function rotular(aberto) {
      var t = aberto ? "Fechar menu" : "Abrir menu";
      botao.textContent = t;
      botao.setAttribute("aria-label", t);
    }
    rotular(false);
    menu.addEventListener("show.bs.collapse", function () { rotular(true); });
    menu.addEventListener("hide.bs.collapse", function () { rotular(false); });
  });
})();
