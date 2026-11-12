var body = document.querySelector('body')
var menuTrigger = document.querySelector('#toggle-main-menu-mobile');
var menuContainer = document.querySelector('#main-menu-mobile');

menuTrigger.onclick = function() {
    menuContainer.classList.toggle('open');
    menuTrigger.classList.toggle('is-active')
    body.classList.toggle('lock-scroll')
}

// Tema scuro + doppio click sul bottone = pagina "dietro le quinte"
(function () {
  var btn = document.getElementById('theme-toggle');
  if (!btn) return;
  var root = document.documentElement;
  var lastClick = 0;
  function isDark() { return root.getAttribute('data-theme') === 'dark'; }
  function setTheme(dark) {
    if (dark) root.setAttribute('data-theme', 'dark'); else root.removeAttribute('data-theme');
    try { localStorage.setItem('theme', dark ? 'dark' : 'light'); } catch (e) {}
  }
  btn.addEventListener('click', function () {
    var now = Date.now();
    if (now - lastClick < 400) {
      lastClick = 0;
      setTheme(!isDark()); // annulla il cambio del primo click
      var en = document.documentElement.lang === 'en';
      window.location.href = btn.getAttribute(en ? 'data-secret-en' : 'data-secret-it');
      return;
    }
    lastClick = now;
    setTheme(!isDark());
  });
})();
