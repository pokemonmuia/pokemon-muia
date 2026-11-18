// Pokémon Muia: ponte tra el zogo e el server del multiplayer.
//
// Nel browser el motor del zogo no gà socket, quindi el zogo scrive file nella
// cartela dei salvataggi (OPFS) e questa pagina li inoltra al server via
// WebSocket, e fa el contrario con le risposte. El protocolo dei file xe
// descrito in Plugins/Voltseon's Multiplayer Solution/001_Base/004_VMS_Web_Bridge.rb
//
//   muia_ctl_<sigla>_<n>.bin    zogo -> pagina : "open" o "close"
//   muia_out_<sigla>_<n>.bin    zogo -> pagina : un messagio par el server
//   muia_in_<sigla>_<n>.bin     pagina -> zogo : un messagio dal server
//   muia_stato_<sigla>_<n>.bin  pagina -> zogo : svejo / conetendo / connesso /
//                                                 chiuso / erore: ...
// Ogni file finisse con "MUIA". Se el zogo no scrive, qua no se fa gnente.
//
// Anca (plugin "Muia Web"):
//   muia_txt_<sigla>_<n>.bin    zogo -> pagina : el zogo vol un testo (nome...):
//                                                 min \n max \n iniziale \n domanda
//   muia_txtris_<sigla>_<n>.bin pagina -> zogo : "ok\n<testo>" o "anula"
//   muia_esci_<sigla>_<n>.bin   zogo -> pagina : el zogador xe uscì dal zogo

type CartellaOpfs = any; // FileSystemDirectoryHandle (tipi non sempre presenti)

export interface OpzioniPonte {
  /** Dà la cartela dove el zogo scrive i salvataggi */
  trovaCartella: () => Promise<CartellaOpfs>;
  /** Indirizzo del WebSocket (wss://.../ws) */
  urlWebSocket: string;
  /** Indirizzo HTTP del server, par "svejarlo" se el dorme */
  urlSveglia: string;
  /** Ogni quanti ms controlar i file (default 25) */
  intervalloMs?: number;
  /** Secondi massimi par conetarse (default 150) */
  attesaMaxS?: number;
  log?: (...args: unknown[]) => void;
}

const FINE = new TextEncoder().encode("MUIA");
const PREFISSO = "muia_";
const IN_MAX_CODA = 40; // messagi dal server in attesa de scritura: oltre, i vecchi se perde
const VITA_FILE_IN_MS = 6000; // dopo, el file ricevù dal zogo xe tolto

const finisceConFine = (dati: Uint8Array): boolean => {
  if (dati.length < FINE.length) {
    return false;
  }
  for (let i = 0; i < FINE.length; i++) {
    if (dati[dati.length - FINE.length + i] !== FINE[i]) {
      return false;
    }
  }
  return true;
};

const numero8 = (n: number) => n.toString().padStart(8, "0");

interface Sessione {
  sigla: string;
  ws: WebSocket | null;
  connesso: boolean;
  chiusa: boolean;
  nStato: number;
  nIn: number;
  codaIn: Uint8Array[];
  scrivendo: boolean;
}

// ---- casela de testo vera (tastiera del PC o del telefono) -------------
interface RichiestaTesto {
  minimo: number;
  massimo: number;
  iniziale: string;
  domanda: string;
}

let casellaAperta = false;

const mostraCasella = (r: RichiestaTesto): Promise<string | null> =>
  new Promise((resolve) => {
    casellaAperta = true;
    const fondo = document.createElement("div");
    fondo.style.cssText =
      "position:fixed;inset:0;z-index:100000;background:rgba(0,0,0,.55);" +
      "display:flex;align-items:center;justify-content:center;padding:16px;" +
      "touch-action:manipulation;";
    const box = document.createElement("form");
    box.style.cssText =
      "background:#fff;color:#111;border-radius:12px;padding:16px;width:100%;" +
      "max-width:360px;font:16px system-ui,sans-serif;box-shadow:0 8px 30px rgba(0,0,0,.4);";
    const titolo = document.createElement("label");
    titolo.textContent = r.domanda || "Scrivi";
    titolo.style.cssText = "display:block;margin-bottom:10px;font-weight:600;";
    const input = document.createElement("input");
    input.type = "text";
    input.value = r.iniziale;
    if (r.massimo > 0) {
      input.maxLength = r.massimo;
    }
    input.autocomplete = "off";
    input.setAttribute("autocapitalize", "words");
    input.setAttribute("enterkeyhint", "done");
    input.spellcheck = false;
    // 16px: cussì el telefono no ingrandisse la pagina
    input.style.cssText =
      "width:100%;box-sizing:border-box;font-size:16px;padding:10px;" +
      "border:2px solid #888;border-radius:8px;" +
      // la pagina blocca la selezion del testo dapertuto: qua serve (iPhone)
      "-webkit-user-select:text;user-select:text;touch-action:manipulation;";
    const righe = document.createElement("div");
    righe.style.cssText = "display:flex;gap:8px;margin-top:12px;justify-content:flex-end;";
    const ok = document.createElement("button");
    ok.type = "submit";
    ok.textContent = "Va ben";
    ok.style.cssText =
      "font-size:16px;padding:8px 16px;border-radius:8px;border:0;background:#2a7;color:#fff;";
    const anula = document.createElement("button");
    anula.type = "button";
    anula.textContent = "Anula";
    anula.style.cssText =
      "font-size:16px;padding:8px 16px;border-radius:8px;border:0;background:#ccc;color:#111;";
    if (r.minimo <= 0) {
      righe.appendChild(anula);
    }
    righe.appendChild(ok);
    box.append(titolo, input, righe);
    fondo.appendChild(box);
    document.body.appendChild(fondo);

    const valido = () => {
      const n = input.value.trim().length;
      return n >= Math.max(r.minimo, 0) && (r.massimo <= 0 || n <= r.massimo);
    };
    const aggiornaOk = () => {
      ok.disabled = !valido();
      ok.style.opacity = ok.disabled ? "0.5" : "1";
    };
    aggiornaOk();
    input.addEventListener("input", aggiornaOk);

    // Mentre la casela xe verta, i tasti va solo a ela (no al zogo):
    // se ferma i eventi prima che li veda la pagina o el motore.
    const tasto = (ev: KeyboardEvent) => {
      ev.stopImmediatePropagation();
      if (ev.type !== "keydown") {
        return;
      }
      if (document.activeElement !== input) {
        input.focus();
      }
      if (ev.key === "Enter") {
        ev.preventDefault();
        conferma();
      } else if (ev.key === "Escape" && r.minimo <= 0) {
        ev.preventDefault();
        fine(null);
      }
    };
    window.addEventListener("keydown", tasto, true);
    window.addEventListener("keypress", tasto, true);

    const fine = (testo: string | null) => {
      window.removeEventListener("keydown", tasto, true);
      window.removeEventListener("keypress", tasto, true);
      input.blur();
      fondo.remove();
      casellaAperta = false;
      resolve(testo);
    };
    const conferma = () => {
      if (valido()) {
        fine(input.value.trim());
      }
    };
    box.addEventListener("submit", (ev) => {
      ev.preventDefault();
      conferma();
    });
    anula.addEventListener("click", () => fine(null));
    // Sul PC el cursor xe subito drento; sul telefono (iPhone) la tastiera
    // vien fora quando se toca la casela.
    setTimeout(() => {
      input.focus();
      input.select();
    }, 50);
  });

// El zogador xe uscì dal zogo: se prova a serar la pagina, se no (el browser
// no lo permette se la pagina no xe stada verta da un script) se torna al sito.
const esciDalGioco = () => {
  try {
    window.close();
  } catch (err) {
    // gnente
  }
  setTimeout(() => {
    location.href = new URL("../", location.href).href;
  }, 300);
};

export const avviaPonte = (opz: OpzioniPonte) => {
  const log = opz.log ?? (() => {});
  const intervallo = opz.intervalloMs ?? 25;
  const attesaMax = (opz.attesaMaxS ?? 150) * 1000;
  let cartella: CartellaOpfs | null = null;
  let sessione: Sessione | null = null;
  let occupato = false;
  const creati = new Map<string, number>(); // file scriti da noi → quando
  const ricordaCreato = (nome: string) => creati.set(nome, Date.now());

  const scrivi = async (nome: string, dati: Uint8Array) => {
    const fh = await cartella.getFileHandle(nome, { create: true });
    const w = await fh.createWritable();
    const tutto = new Uint8Array(dati.length + FINE.length);
    tutto.set(dati, 0);
    tutto.set(FINE, dati.length);
    await w.write(tutto);
    await w.close();
    ricordaCreato(nome);
  };

  const scriviStato = async (s: Sessione, testo: string) => {
    s.nStato++;
    try {
      await scrivi(
        `${PREFISSO}stato_${s.sigla}_${numero8(s.nStato)}.bin`,
        new TextEncoder().encode(testo),
      );
    } catch (err) {
      log("ponte: stato non scrito", err);
    }
  };

  // Scrive in ordine i messagi arrivai dal server
  const svodaCodaIn = async (s: Sessione) => {
    if (s.scrivendo) {
      return;
    }
    s.scrivendo = true;
    try {
      while (s.codaIn.length > 0 && !s.chiusa) {
        const dati = s.codaIn.shift() as Uint8Array;
        s.nIn++;
        try {
          await scrivi(`${PREFISSO}in_${s.sigla}_${numero8(s.nIn)}.bin`, dati);
        } catch (err) {
          log("ponte: messagio non scrito", err);
        }
      }
    } finally {
      s.scrivendo = false;
    }
  };

  const chiudi = (s: Sessione, avisa: boolean) => {
    if (s.chiusa) {
      return;
    }
    s.chiusa = true;
    try {
      s.ws?.close();
    } catch (err) {
      // za serà
    }
    if (avisa) {
      void scriviStato(s, "chiuso");
    }
  };

  const apri = async (s: Sessione) => {
    const inizio = Date.now();
    await scriviStato(s, "svejo");
    // Prova a "svejar" el server: se el dorme, la prima richiesta lo fa partir
    const sveglia = () => {
      void fetch(opz.urlSveglia, { mode: "no-cors", cache: "no-store" }).catch(
        () => {},
      );
    };
    sveglia();
    while (!s.chiusa && !s.connesso) {
      if (Date.now() - inizio > attesaMax) {
        await scriviStato(s, "erore: server no risponde");
        chiudi(s, false);
        return;
      }
      await new Promise<void>((resolve) => {
        let finio = false;
        const fine = () => {
          if (!finio) {
            finio = true;
            resolve();
          }
        };
        let ws: WebSocket;
        try {
          ws = new WebSocket(opz.urlWebSocket);
        } catch (err) {
          setTimeout(fine, 3000);
          return;
        }
        ws.binaryType = "arraybuffer";
        s.ws = ws;
        ws.onopen = () => {
          if (s.chiusa) {
            ws.close();
            fine();
            return;
          }
          s.connesso = true;
          void scriviStato(s, "connesso");
          fine();
        };
        ws.onmessage = (ev) => {
          if (!(ev.data instanceof ArrayBuffer) || s.chiusa) {
            return;
          }
          s.codaIn.push(new Uint8Array(ev.data));
          while (s.codaIn.length > IN_MAX_CODA) {
            s.codaIn.shift();
          }
          void svodaCodaIn(s);
        };
        ws.onclose = () => {
          if (s.connesso && !s.chiusa) {
            s.connesso = false;
            chiudi(s, true); // conession cascà: el zogo ga da saverlo
          }
          // se no gaveva ancora verto: se riprova (server che se sta svegliando)
          setTimeout(fine, 3000);
        };
        ws.onerror = () => {
          // el "close" che vien dopo ghe pensa
        };
      });
      if (!s.connesso && !s.chiusa) {
        await scriviStato(s, "svejo");
        sveglia();
      }
    }
  };

  const cercaCartella = async (): Promise<CartellaOpfs | null> => {
    const saves = await opz.trovaCartella();
    const candidate: CartellaOpfs[] = [saves];
    for await (const [, handle] of saves.entries()) {
      if (handle.kind === "directory") {
        candidate.push(handle);
      }
    }
    for (const c of candidate) {
      for await (const [nome] of c.entries()) {
        if (/^muia_(ctl|txt|esci)_/.test(nome)) {
          return c;
        }
      }
    }
    return null;
  };

  const leggi = async (nome: string): Promise<Uint8Array | null> => {
    try {
      const fh = await cartella.getFileHandle(nome);
      const dati = new Uint8Array(await (await fh.getFile()).arrayBuffer());
      return finisceConFine(dati)
        ? dati.subarray(0, dati.length - FINE.length)
        : null;
    } catch (err) {
      return null;
    }
  };

  const giro = async () => {
    if (cartella === null) {
      cartella = await cercaCartella();
      if (cartella === null) {
        return;
      }
    }
    const nomi: string[] = [];
    for await (const [nome] of cartella.entries()) {
      if (nome.startsWith(PREFISSO)) {
        nomi.push(nome);
      }
    }
    nomi.sort();
    const adesso = Date.now();
    for (const nome of nomi) {
      const m = /^muia_(ctl|out|in|stato|txt|txtris|esci)_([^_]+)_(\d+)\.bin$/.exec(nome);
      if (m === null) {
        continue;
      }
      const [, tipo, sigla, numero] = m;
      if (tipo === "esci") {
        await cartella.removeEntry(nome).catch(() => {});
        log("ponte: el zogador xe uscì");
        esciDalGioco();
        continue;
      }
      if (tipo === "txt") {
        if (casellaAperta) {
          continue;
        }
        const dati = await leggi(nome);
        if (dati === null) {
          continue;
        }
        await cartella.removeEntry(nome).catch(() => {});
        const [minimo, massimo, iniziale, ...domanda] = new TextDecoder()
          .decode(dati)
          .split("\n");
        const dir = cartella;
        void mostraCasella({
          minimo: Number(minimo) || 0,
          massimo: Number(massimo) || 0,
          iniziale: iniziale ?? "",
          domanda: domanda.join(" "),
        }).then(async (testo) => {
          const risposta = testo === null ? "anula" : "ok\n" + testo;
          const nomeRis = `${PREFISSO}txtris_${sigla}_${numero}.bin`;
          try {
            const fh = await dir.getFileHandle(nomeRis, { create: true });
            const w = await fh.createWritable();
            const corpo = new TextEncoder().encode(risposta);
            const tutto = new Uint8Array(corpo.length + FINE.length);
            tutto.set(corpo, 0);
            tutto.set(FINE, corpo.length);
            await w.write(tutto);
            await w.close();
            ricordaCreato(nomeRis);
          } catch (err) {
            log("ponte: risposta del testo non scrita", err);
          }
        });
        continue;
      }
      if (tipo === "ctl") {
        const dati = await leggi(nome);
        if (dati === null) {
          continue;
        }
        await cartella.removeEntry(nome).catch(() => {});
        const comando = new TextDecoder().decode(dati);
        if (comando === "open") {
          if (sessione !== null) {
            chiudi(sessione, false);
          }
          sessione = {
            sigla,
            ws: null,
            connesso: false,
            chiusa: false,
            nStato: 0,
            nIn: 0,
            codaIn: [],
            scrivendo: false,
          };
          log("ponte: apro la sessione", sigla);
          void apri(sessione);
        } else if (comando === "close" && sessione?.sigla === sigla) {
          log("ponte: chiudo la sessione", sigla);
          // Prima manda i messagi che el zogo ga lassà (el "disconnect" par el
          // server), poi serra: i nomi dei file "ctl" i vien prima dei "out".
          for (const altro of nomi) {
            if (altro.startsWith(`${PREFISSO}out_${sigla}_`)) {
              const resto = await leggi(altro);
              if (resto !== null) {
                await cartella.removeEntry(altro).catch(() => {});
                if (sessione.ws !== null && sessione.connesso) {
                  sessione.ws.send(resto as BufferSource);
                }
              }
            }
          }
          const daSerar = sessione;
          sessione = null;
          setTimeout(() => chiudi(daSerar, false), 400);
        }
      } else if (tipo === "out") {
        if (sessione === null || sessione.sigla !== sigla || sessione.chiusa) {
          await cartella.removeEntry(nome).catch(() => {}); // vecio, de un'altra sessione
          continue;
        }
        const dati = await leggi(nome);
        if (dati === null) {
          continue;
        }
        await cartella.removeEntry(nome).catch(() => {});
        if (sessione.ws !== null && sessione.connesso) {
          sessione.ws.send(dati as BufferSource);
        }
      } else {
        // "in" e "stato" xe i nostri: se toe dopo un poco, tegnendo i ultimi stati
        const nato = creati.get(nome);
        if (nato === undefined) {
          // de una sessione precedente (pagina ricaricà): subito via
          await cartella.removeEntry(nome).catch(() => {});
        } else if (adesso - nato > VITA_FILE_IN_MS) {
          await cartella.removeEntry(nome).catch(() => {});
          creati.delete(nome);
        }
      }
    }
  };

  // A riposo (nissuna partìa online) se controla ogni mezo secondo, par no
  // consumar batteria; durante la partìa ogni "intervallo" (25 ms).
  const RIPOSO_MS = 500;
  let ultimoGiro = 0;
  const timer = setInterval(async () => {
    if (occupato) {
      return;
    }
    if (sessione === null && Date.now() - ultimoGiro < RIPOSO_MS) {
      return;
    }
    occupato = true;
    ultimoGiro = Date.now();
    try {
      await giro();
    } catch (err) {
      log("ponte:", err);
    } finally {
      occupato = false;
    }
  }, intervallo);

  return () => {
    clearInterval(timer);
    if (sessione !== null) {
      chiudi(sessione, false);
    }
  };
};
