/*
 * Pokémon Muia: programma in background (service worker) della pagina /gioca/.
 *
 * Fa due cose:
 *  1. Aggiunge le intestazioni COOP/COEP a ogni risposta, come faceva
 *     coi-serviceworker: il motore del gioco ne ha bisogno per funzionare.
 *  2. Tiene una copia della pagina e dei suoi file piccoli, così l'app si
 *     apre anche senza connessione. La rete ha sempre la precedenza: con la
 *     connessione si prende la versione più nuova, la copia serve solo se la
 *     rete manca o risponde troppo piano.
 *
 * Il gioco vero (.mkxpz) e il motore (.wasm) NON stanno qui: la pagina li
 * tiene già per conto suo in IndexedDB, con il controllo della versione.
 *
 * Regola d'oro: questo file non deve mai far fallire il caricamento della
 * pagina. Ogni parte che riguarda la copia è in try/catch e, se qualcosa va
 * storto, si passa alla rete come se il programma non ci fosse.
 */
const CACHE = "muia-app-v1";
const ATTESA_RETE_MS = 5000; // oltre, se c'è una copia, si usa quella
const MAX_BYTE_COPIA = 8 * 1024 * 1024; // niente copie di file più grandi
const NON_COPIARE = /\.(mkxpz|wasm)$|mkxp-z_libretro\.js$/;
const SCOPE = new URL(self.registration.scope);
const PRECARICA = [
  "manifest.webmanifest",
  "icon-192.png",
  "icon-512.png",
  "icon-maskable-512.png",
  "apple-touch-icon.png",
];

// Firefox e Chrome vanno con "require-corp"; gli altri (Safari) con "credentialless"
let coepCredentialless = !/Chrome\/|Firefox\//.test(self.navigator.userAgent);

self.addEventListener("install", (event) => {
  event.waitUntil(precarica().catch(() => {}));
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      try {
        for (const nome of await caches.keys()) {
          if (nome !== CACHE && nome.startsWith("muia-app-")) {
            await caches.delete(nome);
          }
        }
      } catch (err) {
        // pazienza: restano copie vecchie
      }
      await self.clients.claim();
    })(),
  );
});

self.addEventListener("message", (ev) => {
  if (!ev.data) {
    return;
  }
  if (ev.data.type === "coepCredentialless") {
    coepCredentialless = !!ev.data.value;
  } else if (ev.data.type === "deregister") {
    self.registration
      .unregister()
      .then(() => self.clients.matchAll())
      .then((clients) => clients.forEach((c) => c.navigate(c.url)));
  }
  // "heartbeat" non fa niente: serve solo a tenere sveglio il programma
});

self.addEventListener("fetch", (event) => {
  const r = event.request;
  if (r.cache === "only-if-cached" && r.mode !== "same-origin") {
    return;
  }
  event.respondWith(gestisci(event, r));
});

const conIntestazioni = (risposta) => {
  if (risposta.status === 0) {
    return risposta; // risposta opaca (redirect manuale o no-cors)
  }
  const h = new Headers(risposta.headers);
  h.set("Cross-Origin-Embedder-Policy", coepCredentialless ? "credentialless" : "require-corp");
  if (!coepCredentialless) {
    h.set("Cross-Origin-Resource-Policy", "cross-origin");
  }
  h.set("Cross-Origin-Opener-Policy", "same-origin");
  return new Response(risposta.body, {
    status: risposta.status,
    statusText: risposta.statusText,
    headers: h,
  });
};

const chiaveCopia = (url, navigazione) => {
  const u = new URL(url);
  u.hash = "";
  if (navigazione) {
    // /gioca/, /gioca/index.html, /gioca/?debug: tutte la stessa pagina
    u.search = "";
    if (u.pathname === SCOPE.pathname + "index.html") {
      u.pathname = SCOPE.pathname;
    }
  }
  return u.href;
};

const dellaPagina = (r, url) =>
  r.method === "GET" &&
  url.origin === SCOPE.origin &&
  url.pathname.startsWith(SCOPE.pathname) &&
  !r.headers.has("range") &&
  !NON_COPIARE.test(url.pathname);

async function gestisci(event, r) {
  const richiesta =
    coepCredentialless && r.mode === "no-cors" ? new Request(r, { credentials: "omit" }) : r;
  const url = new URL(r.url);
  if (!dellaPagina(r, url)) {
    return conIntestazioni(await fetch(richiesta));
  }
  return conIntestazioni(await reteConRipiego(event, richiesta, url, r.mode === "navigate"));
}

async function reteConRipiego(event, richiesta, url, navigazione) {
  let cache = null;
  let copia;
  const chiave = chiaveCopia(url.href, navigazione);
  try {
    cache = await caches.open(CACHE);
    copia = await cache.match(chiave);
  } catch (err) {
    cache = null; // niente copie: si va solo di rete
  }

  // GitHub Pages dice al browser di tenere i file 10 minuti: per la pagina
  // e il manifest si chiede sempre conferma (di solito basta un "non cambiato"),
  // mentre i file in /assets/ hanno il nome legato al contenuto e restano come sono.
  const modo = url.pathname.includes("/assets/") ? "default" : "no-cache";
  const rete = fetch(richiesta, { cache: modo }).then((risposta) => {
    if (cache !== null && risposta.status === 200 && risposta.type === "basic") {
      const lunghezza = Number(risposta.headers.get("content-length") || 0);
      if (lunghezza <= MAX_BYTE_COPIA) {
        const daSalvare = risposta.clone();
        event.waitUntil(
          cache.put(chiave, daSalvare).catch(() => {}),
        );
      }
    }
    return risposta;
  });

  if (!copia) {
    return rete; // prima volta: si aspetta la rete
  }
  const esito = await Promise.race([
    rete.then(
      (risposta) => ({ risposta }),
      () => ({ fallita: true }),
    ),
    new Promise((resolve) => setTimeout(() => resolve({ lenta: true }), ATTESA_RETE_MS)),
  ]);
  if (esito.risposta && esito.risposta.status < 500) {
    return esito.risposta;
  }
  // Rete assente, lenta o con errore del server: si usa la copia, e se la rete
  // sta ancora lavorando la si lascia finire per aggiornare la copia.
  event.waitUntil(rete.catch(() => {}));
  return copia;
}

// Scarica subito pagina, file collegati, icone e manifest, così l'app è
// pronta per l'offline anche prima della seconda apertura.
async function precarica() {
  const cache = await caches.open(CACHE);
  const salva = async (percorso) => {
    try {
      const risposta = await fetch(new Request(percorso, { cache: "reload" }));
      if (risposta.status === 200) {
        await cache.put(chiaveCopia(risposta.url, false), risposta.clone());
      }
      return risposta;
    } catch (err) {
      return null;
    }
  };
  const pagina = await salva(SCOPE.href);
  if (pagina !== null && pagina.status === 200) {
    try {
      const html = await pagina.text();
      const trovati = new Set();
      for (const m of html.matchAll(/(?:src|href)="(\.\/[^"#?]+)"/g)) {
        trovati.add(m[1]);
      }
      for (const p of trovati) {
        if (!NON_COPIARE.test(p)) {
          await salva(new URL(p, SCOPE).href);
        }
      }
    } catch (err) {
      // la pagina verrà copiata alla prima apertura
    }
  }
  for (const p of PRECARICA) {
    await salva(new URL(p, SCOPE).href);
  }
}
