var body = document.querySelector('body')
var menuTrigger = document.querySelector('#toggle-main-menu-mobile');
var menuContainer = document.querySelector('#main-menu-mobile');

menuTrigger.onclick = function() {
    menuContainer.classList.toggle('open');
    menuTrigger.classList.toggle('is-active')
    body.classList.toggle('lock-scroll')
};

// Tema scuro + doppio click sul bottone = pagina "dietro le quinte"
;(function () {
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

// Chiude il menu mobile se la finestra viene allargata, con Esc o dopo un click su una voce
;(function () {
  var menu = document.getElementById('main-menu-mobile');
  var trigger = document.getElementById('toggle-main-menu-mobile');
  if (!menu || !trigger) return;
  function closeMenu() {
    menu.classList.remove('open');
    trigger.classList.remove('is-active');
    document.body.classList.remove('lock-scroll');
  }
  window.matchMedia('(min-width: 768px)').addEventListener('change', function (e) { if (e.matches) closeMenu(); });
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeMenu(); });
  menu.addEventListener('click', closeMenu);
})();
