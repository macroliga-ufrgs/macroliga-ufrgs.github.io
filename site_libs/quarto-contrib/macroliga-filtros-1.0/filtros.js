// Filtros de Publicações (spec 3.5): mostram os textos que atendem ao eixo E ao tipo
// escolhidos, com o estado no endereço (?eixo=…&tipo=…). Sem JavaScript, os controles
// ficam ocultos e a lista aparece inteira. Valor desconhecido no endereço = "todos".
(function () {
  function pronto(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }
  pronto(function () {
    var raiz = document.querySelector("[data-filtros]");
    if (!raiz) return;
    var lista = document.querySelector(".lista-textos--filtravel");
    var itens = Array.prototype.slice.call(lista.querySelectorAll(".item-texto"));
    var vazio = document.getElementById("filtros-vazio");
    var resultado = document.getElementById("filtros-resultado");
    var campos = ["eixo", "tipo"];
    var validos = {};
    campos.forEach(function (c) {
      validos[c] = Array.prototype.map.call(raiz.querySelectorAll('select[data-filtro="' + c + '"] option'),
        function (o) { return o.value; });
    });

    function lerEndereco() {
      var p = new URLSearchParams(location.search);
      var e = {};
      campos.forEach(function (c) {
        var v = p.get(c) || "";
        e[c] = validos[c].indexOf(v) === -1 ? "" : v;
      });
      return e;
    }
    function gravarEndereco(e) {
      var p = new URLSearchParams(location.search);
      campos.forEach(function (c) { if (e[c]) p.set(c, e[c]); else p.delete(c); });
      var q = p.toString();
      history.replaceState(null, "", location.pathname + (q ? "?" + q : "") + location.hash);
    }
    function sincronizar(e) {
      campos.forEach(function (c) {
        raiz.querySelector('select[data-filtro="' + c + '"]').value = e[c];
        var r = raiz.querySelector('input[name="filtro-' + c + '"][value="' + e[c] + '"]');
        if (r) r.checked = true;
      });
    }
    function aplicar(e, gravar) {
      var n = 0;
      itens.forEach(function (li) {
        var mostra = (!e.eixo || li.getAttribute("data-eixo") === e.eixo) &&
                     (!e.tipo || li.getAttribute("data-tipo") === e.tipo);
        li.hidden = !mostra;
        if (mostra) n++;
      });
      vazio.hidden = n > 0;
      lista.hidden = n === 0;
      resultado.textContent = n === 1 ? "1 texto encontrado." : n + " textos encontrados.";
      sincronizar(e);
      if (gravar) gravarEndereco(e);
    }

    var estado = lerEndereco();
    raiz.hidden = false;
    raiz.addEventListener("change", function (ev) {
      var alvo = ev.target;
      var c = alvo.getAttribute("data-filtro") || (alvo.name || "").replace("filtro-", "");
      if (campos.indexOf(c) === -1) return;
      estado[c] = alvo.value;
      aplicar(estado, true);
    });
    document.querySelectorAll("[data-limpar]").forEach(function (b) {
      b.addEventListener("click", function () {
        estado = { eixo: "", tipo: "" };
        aplicar(estado, true);
        // O botão do estado vazio some ao limpar: o foco vai para o primeiro controle visível.
        var controles = raiz.querySelectorAll("select, input");
        for (var i = 0; i < controles.length; i++) {
          if (controles[i].offsetParent !== null) { controles[i].focus(); break; }
        }
      });
    });
    aplicar(estado, false);
  });
})();
