// "Copiar citação" (spec T7): copia a citação e anuncia "Citação copiada." a leitores de tela.
// Sem JavaScript, o botão fica oculto e a citação continua selecionável.
(function () {
  function pronto(fn) {
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", fn);
    else fn();
  }
  function copiarAntigo(texto) {
    var area = document.createElement("textarea");
    area.value = texto;
    area.setAttribute("readonly", "");
    area.style.position = "absolute";
    area.style.left = "-9999px";
    document.body.appendChild(area);
    area.select();
    document.execCommand("copy");
    document.body.removeChild(area);
  }
  pronto(function () {
    document.querySelectorAll("[data-copiar]").forEach(function (botao) {
      var alvo = document.getElementById(botao.getAttribute("data-copiar"));
      var aviso = botao.parentNode.querySelector(".citacao__aviso");
      if (!alvo || !aviso) return;
      botao.hidden = false;
      botao.addEventListener("click", function () {
        var texto = alvo.innerText.trim();
        function avisar() {
          aviso.textContent = "";
          setTimeout(function () { aviso.textContent = "Citação copiada."; }, 50);
        }
        if (navigator.clipboard && window.isSecureContext) {
          navigator.clipboard.writeText(texto).then(avisar, function () { copiarAntigo(texto); avisar(); });
        } else {
          copiarAntigo(texto);
          avisar();
        }
      });
    });
  });
})();
