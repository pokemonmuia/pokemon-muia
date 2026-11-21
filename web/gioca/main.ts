import { primaryInput } from "detect-it";
import { Dexie, type EntityTable } from "dexie";
import fetchProgress from "fetch-progress";
import { toBase64 } from "js-base64";
import { Nostalgist } from "nostalgist";
import { avviaPonte, bottonePerTasto, nomeTasto } from "./ponte";

const CORE_NAME = "mkxp-z";

// Log completi del motore solo con ?debug nell'indirizzo
const DEBUG = new URLSearchParams(location.search).has("debug");

// True if RetroArch was built with OPFS support by passing
// `HAVE_THREADS=1 PROXY_TO_PTHREAD=1 HAVE_AUDIOWORKLET=1 HAVE_RWEBAUDIO=0 HAVE_AL=0 HAVE_WASMFS=1 HAVE_EXTRA_WASMFS=1`
// when building RetroArch and building the core with `-pthread`, otherwise false.
// It's highly recommended to build with OPFS support because it allows loading downloaded games/RTPs directly from the disk instead of loading the entire game/RTP into memory.
const HAVE_OPFS =
  typeof import.meta.env.VITE_HAVE_OPFS !== "string" ||
  import.meta.env.VITE_HAVE_OPFS !== "false";

const REQUIRE_OPFS =
  HAVE_OPFS &&
  (typeof import.meta.env.VITE_REQUIRE_OPFS !== "string" ||
    import.meta.env.VITE_REQUIRE_OPFS !== "false");

const CORE_JS_PATH = new URL(
  import.meta.env.VITE_CORE_JS_PATH,
  location.href,
).toString();
const CORE_WASM_PATH = new URL(
  import.meta.env.VITE_CORE_WASM_PATH,
  location.href,
).toString();
const GAME_PATH =
  typeof import.meta.env.VITE_GAME_PATH === "string"
    ? new URL(import.meta.env.VITE_GAME_PATH, location.href).toString()
    : null;
const RTP_PATH =
  typeof import.meta.env.VITE_RTP_PATH === "string"
    ? new URL(import.meta.env.VITE_RTP_PATH, location.href).toString()
    : null;

const CORE_JS_SIZE = parseInt(import.meta.env.VITE_CORE_JS_SIZE);
const CORE_WASM_SIZE = parseInt(import.meta.env.VITE_CORE_WASM_SIZE);
const GAME_SIZE = parseInt(import.meta.env.VITE_GAME_SIZE);
const RTP_SIZE = parseInt(import.meta.env.VITE_RTP_SIZE);

const CORE_JS_HASH =
  typeof import.meta.env.VITE_CORE_JS_HASH === "string"
    ? import.meta.env.VITE_CORE_JS_HASH
    : "";
const CORE_WASM_HASH =
  typeof import.meta.env.VITE_CORE_WASM_HASH === "string"
    ? import.meta.env.VITE_CORE_WASM_HASH
    : "";
const GAME_HASH =
  typeof import.meta.env.VITE_GAME_HASH === "string"
    ? import.meta.env.VITE_GAME_HASH
    : "";
const RTP_HASH =
  typeof import.meta.env.VITE_RTP_HASH === "string"
    ? import.meta.env.VITE_RTP_HASH
    : "";


const GAME_NAME =
  typeof import.meta.env.VITE_GAME_NAME === "string"
    ? import.meta.env.VITE_GAME_NAME
    : null;

// This can be arbitrary but needs to have at least two path elements when using OPFS
const PERSISTENT_DIRECTORY = "/nostalgist/persistent";

// These can be arbitrary subdirectories of the persistent directory
const SAVE_DIRECTORY = PERSISTENT_DIRECTORY + "/saves/" + CORE_NAME;
const STATE_DIRECTORY = PERSISTENT_DIRECTORY + "/states/" + CORE_NAME;
const OPFS_SYSTEM_DIRECTORY = PERSISTENT_DIRECTORY + "/system/" + CORE_NAME;

const RTP_OPFS_PATH =
  RTP_PATH === null
    ? null
    : OPFS_SYSTEM_DIRECTORY.slice(PERSISTENT_DIRECTORY.length) +
      "/mkxp-z/RTP/" +
      RTP_PATH.split("/").slice(-1)[0];

if (GAME_NAME !== null) {
  document.title = GAME_NAME;
}

// Barra di avanzamento (scaricamento e poi avvio del gioco)
const barEl = document.getElementById("bar");
const barFill = document.getElementById("bar-fill");
const barLabel = document.getElementById("bar-label");
const setBar = (fraction: number, label: string) => {
  const f = Math.max(0, Math.min(1, fraction));
  if (barEl !== null) {
    barEl.style.display = "block";
  }
  if (barFill !== null) {
    barFill.style.width = (f * 100).toFixed(1) + "%";
  }
  if (barLabel !== null) {
    barLabel.textContent = label;
  }
};
const hideBar = () => {
  if (barEl !== null) {
    barEl.style.display = "none";
  }
};
setBar(0, "Preparazione…");

let currentBytes = 0;
let totalBytes = 0;

const updateBar = () => {
  const f =
    isNaN(totalBytes) || !isFinite(totalBytes) || totalBytes === 0
      ? 0
      : currentBytes / totalBytes;
  const mb = (n: number) => Math.round(n / 1048576);
  setBar(
    f,
    "Carico il gioco… " +
      Math.round(f * 100) +
      "% (" +
      mb(currentBytes) +
      " / " +
      mb(totalBytes) +
      " MB)",
  );
};

// Disable bfcache because it may undo the loading of the game (e.g. when the user refreshes the page in Chromium after the game successfully loads)
window.addEventListener("pageshow", (ev) => {
  if (ev.persisted) {
    location.reload();
  }
});

// Multithreaded WebAssembly requires a secure context
if (!window.isSecureContext) {
  alert("This site only works if served over HTTPS.");
  throw "Not a secure context";
}

// Wait for coi-serviceworker.js to load
if (!window.crossOriginIsolated) {
  if (!("serviceWorker" in navigator)) {
    alert(
      "Your browser does not support service workers in private browsing mode. Either exit private browsing mode or try private browsing mode in a different browser.",
    );
    throw "Service workers are not available";
  }
  if (navigator.serviceWorker.controller === null) {
    throw "coi-serviceworker.js is not ready yet";
  }
}
const sessionStorageKey =
  "nostalgist status for " + CORE_NAME + " @ " + location.href;
if (window.sessionStorage.getItem(sessionStorageKey) !== "ready") {
  window.sessionStorage.setItem(sessionStorageKey, "ready");
  location.reload();
  throw "Reloading once to make coi-serviceworker.js less flaky";
}
if (!window.crossOriginIsolated) {
  console.error(
    "Cross-origin isolation is not enabled; reloading to enable it",
  );
  location.reload();
  throw "Reloading to enable cross-origin isolation";
}

const opfs = !HAVE_OPFS
  ? null
  : await (async () => {
      try {
        return await navigator.storage.getDirectory();
      } catch (err) {
        if (REQUIRE_OPFS) {
          alert(
            "Your browser does not support OPFS in private browsing mode. Either exit private browsing mode or try private browsing mode in a different browser.",
          );
          throw err;
        } else {
          // Fall back to not using OPFS
          console.error(err);
          return null;
        }
      }
    })();

// Una copia salvata nel browser (IndexedDB/OPFS) può risultare rovinata, per
// esempio sul telefono quando il browser libera spazio: il motore allora dice
// "Failed to initialize the mkxp-z game engine: unsupported". Prima di usarla
// controllo che abbia la dimensione giusta e che inizio e fine si leggano.
const copiaSana = async (blob: Blob, size: number): Promise<boolean> => {
  try {
    if (blob.size !== size || size === 0) {
      return false;
    }
    const inizio = new Uint8Array(await blob.slice(0, 4).arrayBuffer());
    const fine = new Uint8Array(await blob.slice(Math.max(0, size - 4)).arrayBuffer());
    return inizio.length === Math.min(4, size) && fine.length === Math.min(4, size);
  } catch (err) {
    console.error("copia rovinata", err);
    return false;
  }
};

// Cancella le copie del gioco salvate nel browser (non i salvataggi)
const cancellaCopie = async () => {
  try {
    await Dexie.delete("nostalgist cache for " + CORE_NAME);
  } catch (err) {
    console.error(err);
  }
  if (opfs !== null && RTP_OPFS_PATH !== null) {
    try {
      let directory = opfs;
      const elements = RTP_OPFS_PATH.split("/").filter((e) => e.length !== 0);
      for (const element of elements.slice(0, -1)) {
        directory = await directory.getDirectoryHandle(element);
      }
      await directory.removeEntry(elements.slice(-1)[0]);
    } catch (err) {
      // non c'era
    }
  }
};

const fetchWithCache = async (
  size: number,
  hash: string,
  path: string,
  opfsPath?: string,
) => {
  totalBytes += size;
  updateBar();

  let blob: Blob | undefined = undefined;
  let blobSource: "fetch" | "indexeddb" | "opfs" = "fetch";

  const db = new Dexie("nostalgist cache for " + CORE_NAME) as Dexie & {
    cache: EntityTable<
      {
        path: string;
        blob: Blob | null;
        hash: string;
      },
      "path"
    >;
  };
  db.version(2).stores({
    cache: "path",
  });

  try {
    // Try restoring the blob from IndexedDB and OPFS
    try {
      const result = await db.cache.get(path);
      if (result !== undefined && result.hash === hash) {
        if (result.blob !== null) {
          blobSource = "indexeddb";
          blob = result.blob;
        } else if (opfs !== null && opfsPath !== undefined) {
          let directory = opfs;
          const elements = opfsPath
            .split("/")
            .filter((element) => element.length !== 0);
          if (elements.length > 0) {
            for (const element of elements.slice(0, -1)) {
              directory = await directory.getDirectoryHandle(element, {
                create: true,
              });
            }
            const fileHandle = await directory.getFileHandle(
              elements.slice(-1)[0],
            );
            const fileBlob = await fileHandle.getFile();
            if (fileBlob.size === size) {
              blobSource = "opfs";
              blob = fileBlob;
            }
          }
        }
      }
    } catch (err) {
      console.error(err);
    }
    if (blob !== undefined && !(await copiaSana(blob, size))) {
      blob = undefined; // copia rovinata: la riscarico
      blobSource = "fetch";
    }

    // If the blob is not cached, fetch it instead
    if (blob === undefined) {
      let fetchedBytes = 0;

      const response = await fetch(path).then(
        fetchProgress({
          onProgress: (progress) => {
            currentBytes += progress.transferred - fetchedBytes;
            fetchedBytes = progress.transferred;
            updateBar();
          },
        }),
      );

      blob = await response.blob();
    } else {
      currentBytes += size;
      updateBar();
    }

    // Store the blob into IndexedDB and OPFS if needed
    if (
      blobSource !==
      (opfs !== null && opfsPath !== undefined ? "opfs" : "indexeddb")
    ) {
      try {
        await db.cache.put({
          path,
          blob: opfs !== null && opfsPath !== undefined ? null : blob,
          hash,
        });
      } catch (err) {
        console.error(err);
      }

      if (opfs !== null && opfsPath !== undefined) {
        try {
          let directory = opfs;
          const elements = opfsPath
            .split("/")
            .filter((element) => element.length !== 0);
          if (elements.length > 0) {
            for (const element of elements.slice(0, -1)) {
              directory = await directory.getDirectoryHandle(element, {
                create: true,
              });
            }
            const fileHandle = await directory.getFileHandle(
              elements.slice(-1)[0],
              { create: true },
            );
            const fileStream = await fileHandle.createWritable();
            await fileStream.write(blob);
            await fileStream.close();
            blob = await fileHandle.getFile();
          }
        } catch (err) {
          console.error(err);
        }
      }
    }

    return blob;
  } finally {
    db.close();
  }
};

const [coreJsBlob, coreWasmBlob, gameBlob, rtpBlob] = await Promise.all([
  fetchWithCache(CORE_JS_SIZE, CORE_JS_HASH, CORE_JS_PATH),
  fetchWithCache(CORE_WASM_SIZE, CORE_WASM_HASH, CORE_WASM_PATH),
  GAME_PATH === null
    ? null
    : fetchWithCache(
        GAME_SIZE,
        GAME_HASH,
        GAME_PATH,
        undefined, // il gioco resta in memoria, non su OPFS (molto più veloce)
      ),
  RTP_PATH === null
    ? null
    : fetchWithCache(RTP_SIZE, RTP_HASH, RTP_PATH, RTP_OPFS_PATH ?? undefined),
]);

const nostalgist = await Nostalgist.prepare({
  core: {
    name: CORE_NAME,
    js: coreJsBlob,
    wasm: coreWasmBlob,
  },
  rom:
    GAME_PATH === null || gameBlob === null
      ? undefined
      : {
          fileName: toBase64(GAME_PATH, true) + ".mkxpz",
          fileContent: gameBlob,
        },
  bios:
    opfs !== null || rtpBlob === null
      ? undefined
      : {
          fileName: "RTP.mkxpz",
          fileContent: rtpBlob,
        },
  emscriptenModule: {
    preRun: [
      (module) => {
        if (opfs !== null) {
          // Indicate to RetroArch that we want to enable OPFS support if it's supported
          module.ENV.OPFS_MOUNT = PERSISTENT_DIRECTORY;
        }
      },
    ],
  },
  element: "#nostalgist-canvas",
  retroarchConfig: {
    savefile_directory: SAVE_DIRECTORY,
    savestate_directory: STATE_DIRECTORY,
    system_directory:
      opfs !== null
        ? OPFS_SYSTEM_DIRECTORY
        : "/home/web_user/retroarch/userdata/system",
    log_verbosity: true,
    libretro_log_level: DEBUG ? 0 : 1,
    frontend_log_level: DEBUG ? 0 : 2,
    // La tastiera arriva al gioco direttamente (Z/Invio/Spazio, X/Esc,
    // Shift, D, frecce): tolgo le scorciatoie di RetroArch che si
    // sovrapporrebbero (per esempio Spazio = avanti veloce).
    // I tasti a schermo usano K/J/I/U, che il gioco non usa per altro:
    // A = conferma, B = annulla, START = menu, SELECT = menu rapido.
    input_toggle_fast_forward: "nul",
    input_hold_fast_forward: "nul",
    input_toggle_slowmotion: "nul",
    input_hold_slowmotion: "nul",
    input_menu_toggle: "nul",
    input_menu_toggle_gamepad_combo: "0",
    input_save_state: "nul",
    input_load_state: "nul",
    input_state_slot_decrease: "nul",
    input_state_slot_increase: "nul",
    input_screenshot: "nul",
    input_pause_toggle: "nul",
    input_exit_emulator: "nul",
    input_reset: "nul",
    input_toggle_fullscreen: "nul",
    input_fps_toggle: "nul",
    // ATTENZIONE: nostalgist.pressDown() non preme il pulsante direttamente,
    // simula il tasto associato qui. Ogni pulsante usato dalla pagina (a, b,
    // x, r3, frecce) DEVE avere un tasto, altrimenti non fa niente (1.19:
    // frecce a "nul" = frecce e croce del telefono morte). Le frecce restano
    // quelle di base: la pagina le traduce (ponte.ts) e le preme da qui.
    input_player1_up: "up",
    input_player1_down: "down",
    input_player1_left: "left",
    input_player1_right: "right",
    input_player1_a: "k",
    input_player1_b: "j",
    input_player1_x: "i",
    input_player1_y: "nul",
    input_player1_l3: "nul",
    input_player1_r3: "u",
    input_player1_l: "nul",
    input_player1_r: "nul",
    input_player1_l2: "nul",
    input_player1_r2: "nul",
    input_player1_start: "nul",
    input_player1_select: "nul",
  },
  retroarchCoreConfig: {
    "mkxp-z_saveStateSize": "256",
  },
});

if (opfs !== null) {
  // Create the save, state and system directories
  for (const directoryPath of [
    SAVE_DIRECTORY,
    STATE_DIRECTORY,
    OPFS_SYSTEM_DIRECTORY,
  ]) {
    let directory = opfs;
    for (const element of directoryPath
      .slice(PERSISTENT_DIRECTORY.length)
      .split("/")
      .filter((element) => element.length !== 0)) {
      directory = await directory.getDirectoryHandle(element, {
        create: true,
      });
    }
  }

} else {
  const fs: typeof FS & {
    filesystems?: {
      MEMFS: Emscripten.FileSystemType;
      IDBFS?: Emscripten.FileSystemType;
    };
  } = nostalgist.getEmscriptenFS();

  // Move the RTP to the correct path
  if (RTP_PATH !== null) {
    const system_directory = "/home/web_user/retroarch/userdata/system";
    const system_directory_subdirectory = system_directory + "/mkxp-z/RTP";
    fs.mkdirTree(system_directory_subdirectory);
    fs.rename(
      system_directory + "/RTP.mkxpz",
      system_directory_subdirectory + "/" + RTP_PATH.split("/").slice(-1)[0],
    );
  }

  // If RetroArch was not built with OPFS support but was built with IDBFS support,
  // persist saves and save states to IndexedDB so that the user doesn't lose all of their saves and save states whenever the page is reloaded or closed
  if (fs.filesystems?.IDBFS !== undefined) {
    fs.mkdirTree(SAVE_DIRECTORY);
    fs.mkdirTree(STATE_DIRECTORY);
    fs.mount(fs.filesystems.IDBFS, { autoPersist: true }, SAVE_DIRECTORY);
    fs.mount(fs.filesystems.IDBFS, { autoPersist: true }, STATE_DIRECTORY);
    await new Promise<void>((resolve, reject) => {
      fs.syncfs(true, (err: Error | null) => {
        if (err === null) {
          resolve();
        } else {
          reject(err);
        }
      });
    });
  }
}

hideBar();

// ---------------------------------------------------------------------------
// Pokémon Muia: schermata di avvio, controlli touch e orientamento
// ---------------------------------------------------------------------------

const isTouch =
  primaryInput === "touch" ||
  window.matchMedia("(pointer: coarse)").matches ||
  navigator.maxTouchPoints > 0;
if (isTouch) {
  document.body.classList.add("touch");
}

const statusEl = document.getElementById("status");
const setStatus = (text: string | null) => {
  if (statusEl === null) {
    return;
  }
  if (text === null) {
    statusEl.style.display = "none";
  } else {
    statusEl.textContent = text;
    statusEl.style.display = "block";
  }
};

// ---------------------------------------------------------------------------
// Copia dei salvataggi: scarica un file coi salvataggi e li ricarica da quel
// file. Si fa dalla schermata "Gioca", prima che parta il motore, così nessun
// file è in uso. I salvataggi stanno in OPFS: saves/mkxp-z/.../Saves/<gioco>/
// ---------------------------------------------------------------------------
const SALVATAGGI_RADICE = "saves";
// Dove il motore mette i salvataggi (usato solo se la cartella non c'è ancora)
const SALVATAGGI_PERCORSO = ["mkxp-z", "mkxp-z", "mkxp-z", "Saves"];
const COPIA_FORMATO = "pokemon-muia-salvataggi";
const COPIA_MAX_BYTE = 200 * 1024 * 1024;
const COPIA_ESTENSIONE_VECCHIO = ".prima.bak";

type CartellaOpfs = any; // FileSystemDirectoryHandle (tipi non sempre presenti)

const saveToolsEl = document.getElementById("save-tools");
const saveMsgEl = document.getElementById("save-msg");
const saveMsg = (testo: string, errore = false) => {
  if (saveMsgEl !== null) {
    saveMsgEl.textContent = testo;
    saveMsgEl.classList.toggle("error", errore);
  }
};

const bytesInB64 = (bytes: Uint8Array) => {
  let s = "";
  for (let i = 0; i < bytes.length; i += 0x8000) {
    s += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  }
  return btoa(s);
};
const b64InBytes = (b64: string) => Uint8Array.from(atob(b64), (c) => c.charCodeAt(0));

// Tutti i file dentro una cartella "Saves": percorso relativo a "Saves"
const elencaSalvataggi = async () => {
  const trovati: { percorso: string; handle: any }[] = [];
  if (opfs === null) {
    return trovati;
  }
  let radice: CartellaOpfs;
  try {
    radice = await opfs.getDirectoryHandle(SALVATAGGI_RADICE);
  } catch (err) {
    return trovati; // ancora nessun salvataggio
  }
  const visita = async (dir: CartellaOpfs, parti: string[]) => {
    for await (const [nome, handle] of dir.entries()) {
      if (handle.kind === "directory") {
        await visita(handle, [...parti, nome]);
      } else {
        const i = parti.indexOf("Saves");
        if (i >= 0 && !nome.endsWith(COPIA_ESTENSIONE_VECCHIO)) {
          trovati.push({ percorso: [...parti.slice(i + 1), nome].join("/"), handle });
        }
      }
    }
  };
  await visita(radice, []);
  return trovati;
};

const trovaCartellaSaves = async (): Promise<CartellaOpfs> => {
  const radice: CartellaOpfs = await opfs!.getDirectoryHandle(SALVATAGGI_RADICE, {
    create: true,
  });
  const cerca = async (dir: CartellaOpfs, livello: number): Promise<CartellaOpfs | null> => {
    for await (const [nome, handle] of dir.entries()) {
      if (handle.kind !== "directory") {
        continue;
      }
      if (nome === "Saves") {
        return handle;
      }
      if (livello < 6) {
        const trovata = await cerca(handle, livello + 1);
        if (trovata !== null) {
          return trovata;
        }
      }
    }
    return null;
  };
  const esistente = await cerca(radice, 0);
  if (esistente !== null) {
    return esistente;
  }
  let dir = radice;
  for (const nome of SALVATAGGI_PERCORSO) {
    dir = await dir.getDirectoryHandle(nome, { create: true });
  }
  return dir;
};

const scriviFile = async (dir: CartellaOpfs, nome: string, dati: Uint8Array) => {
  const handle = await dir.getFileHandle(nome, { create: true });
  if (typeof handle.createWritable !== "function") {
    throw new Error("Sto browser no lassa scriver i salvataggi");
  }
  const w = await handle.createWritable();
  await w.write(dati);
  await w.close();
};

const esportaSalvataggi = async () => {
  const files = await elencaSalvataggi();
  if (files.length === 0) {
    saveMsg("In sto browser no ghe xe ancora nissun salvataggio.", true);
    return;
  }
  const voci: { percorso: string; dati: string }[] = [];
  for (const f of files) {
    const file: File = await f.handle.getFile();
    voci.push({
      percorso: f.percorso,
      dati: bytesInB64(new Uint8Array(await file.arrayBuffer())),
    });
  }
  const contenuto = JSON.stringify({
    formato: COPIA_FORMATO,
    versione: 1,
    creato: new Date().toISOString(),
    file: voci,
  });
  const link = document.createElement("a");
  link.href = URL.createObjectURL(new Blob([contenuto], { type: "application/json" }));
  link.download = "pokemon-muia-salvataggi-" + new Date().toISOString().slice(0, 10) + ".json";
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(link.href), 60_000);
  saveMsg(
    "Copia fata (" + files.length + (files.length === 1 ? " file" : " file") +
      "). La trovi nei file scaricai.",
  );
};

const percorsoValido = (p: unknown): p is string =>
  typeof p === "string" &&
  p.length > 0 &&
  !p.includes("\\") &&
  !p.includes("\0") &&
  p.split("/").every((x) => x.length > 0 && x !== "." && x !== "..");

const importaSalvataggi = async (file: File) => {
  if (file.size > COPIA_MAX_BYTE) {
    saveMsg("Sto file xe massa grando per esser una copia de salvataggi.", true);
    return;
  }
  let dati: any;
  try {
    dati = JSON.parse(await file.text());
  } catch (err) {
    dati = null;
  }
  if (
    dati === null ||
    dati.formato !== COPIA_FORMATO ||
    !Array.isArray(dati.file) ||
    dati.file.length === 0 ||
    !dati.file.every((v: any) => percorsoValido(v?.percorso) && typeof v?.dati === "string")
  ) {
    saveMsg("Sto file no xe una copia de salvataggi de Pokémon Muia.", true);
    return;
  }
  const esistenti = await elencaSalvataggi();
  if (
    esistenti.length > 0 &&
    !confirm(
      "In sto browser ghe xe za dei salvataggi. Se continuo, quei con lo stesso nome " +
        "vien sostituii (ghe resta una copia vecia con " + COPIA_ESTENSIONE_VECCHIO +
        "). Continuo?",
    )
  ) {
    saveMsg("Gnente cambià.");
    return;
  }
  const saves = await trovaCartellaSaves();
  for (const voce of dati.file as { percorso: string; dati: string }[]) {
    const parti = voce.percorso.split("/");
    let dir = saves;
    for (const parte of parti.slice(0, -1)) {
      dir = await dir.getDirectoryHandle(parte, { create: true });
    }
    const nome = parti[parti.length - 1];
    try {
      const vecchio: File = await (await dir.getFileHandle(nome)).getFile();
      await scriviFile(dir, nome + COPIA_ESTENSIONE_VECCHIO, new Uint8Array(await vecchio.arrayBuffer()));
    } catch (err) {
      if ((err as DOMException)?.name !== "NotFoundError") {
        throw err;
      }
    }
    await scriviFile(dir, nome, b64InBytes(voce.dati));
  }
  saveMsg("Salvataggi caricai (" + dati.file.length + " file). Adesso premi Gioca.");
};

if (saveToolsEl !== null) {
  const btnExport = document.getElementById("save-export") as HTMLButtonElement;
  const btnImport = document.getElementById("save-import") as HTMLButtonElement;
  const inputFile = document.getElementById("save-file") as HTMLInputElement;
  const protetto = async (azione: () => Promise<void>) => {
    btnExport.disabled = btnImport.disabled = true;
    try {
      await azione();
    } catch (err) {
      console.error(err);
      saveMsg("No son riussì: " + ((err as Error)?.message ?? err), true);
    } finally {
      btnExport.disabled = btnImport.disabled = false;
    }
  };
  btnExport.addEventListener("click", () => protetto(esportaSalvataggi));
  btnImport.addEventListener("click", () => inputFile.click());
  inputFile.addEventListener("change", () => {
    const file = inputFile.files?.[0];
    inputFile.value = "";
    if (file !== undefined) {
      void protetto(() => importaSalvataggi(file));
    }
  });
  if (opfs === null) {
    saveToolsEl.querySelector(".row")?.setAttribute("hidden", "");
  }
}

// Schermata "Gioca": serve un tocco/clic per l'audio e per lo schermo intero
const startButton = document.getElementById("start-button");
setStatus(null);
if (startButton !== null) {
  startButton.style.display = "flex";
  if (saveToolsEl !== null) {
    saveToolsEl.style.display = "flex";
  }
  await new Promise<void>((resolve) => {
    const go = (ev: Event) => {
      ev.preventDefault();
      startButton.removeEventListener("click", go);
      document.removeEventListener("keydown", onKey);
      resolve();
    };
    const onKey = (ev: KeyboardEvent) => {
      // Invio/Spazio su un bottone delle copie non deve far partire il gioco
      if ((ev.target as HTMLElement | null)?.closest?.("#save-tools")) {
        return;
      }
      if (ev.key === "Enter" || ev.key === " " || ev.key === "c") {
        go(ev);
      }
    };
    startButton.addEventListener("click", go);
    document.addEventListener("keydown", onKey);
  });
  startButton.style.display = "none";
  if (saveToolsEl !== null) {
    saveToolsEl.style.display = "none";
  }
}

// Sul telefono: schermo intero e, dove si può, blocco in orizzontale
if (isTouch) {
  try {
    const el = document.documentElement;
    if (document.fullscreenElement === null && el.requestFullscreen) {
      await el.requestFullscreen({ navigationUI: "hide" });
    }
  } catch (err) {
    console.warn(err);
  }
  try {
    const orientation = screen.orientation as ScreenOrientation & {
      lock?: (o: string) => Promise<void>;
    };
    if (orientation.lock) {
      await orientation.lock("landscape");
    }
  } catch (err) {
    // iPhone e alcuni browser non lo permettono: resta l'invito a girare
    console.warn(err);
  }
}

// ---------------------------------------------------------------------------
// Barra di avvio: il motore non dice quanto manca, quindi stimo
// l'avanzamento dalle tappe che scrive nel log e dai tempi dell'ultimo avvio
// su questo dispositivo (la prima volta uso tempi prudenti).
// ---------------------------------------------------------------------------
const STAGES = [
  // [testo nel log, frazione della barra raggiunta, nome della fase]
  ["Mounted game save directory", 0.05, "Apro i file del gioco…"],
  ["Loading path cache", 0.08, "Indicizzo i file del gioco…"],
  ["Path cache completed", 0.8, "Avvio il motore…"],
  ["[mkxp-z stdout] ruby", 0.86, "Carico la musica…"],
  ["Using threaded audio driver", 0.9, "Carico gli script del gioco…"],
] as const;
const DEFAULT_DURATIONS = [3, 2, 40, 3, 3, 8]; // secondi, una per fase
let durations = DEFAULT_DURATIONS;
try {
  const saved = JSON.parse(localStorage.getItem("muia-avvio") ?? "null");
  if (Array.isArray(saved) && saved.length === DEFAULT_DURATIONS.length) {
    durations = saved.map((x: number) => Math.max(0.5, x * 1.1));
  }
} catch {
  // localStorage non disponibile: tempi predefiniti
}
let stage = 0; // numero di tappe raggiunte
let stageStart = performance.now();
const measured: number[] = [];
let stageLabel = "Avvio del gioco…";
const fractionAt = (i: number) => (i === 0 ? 0 : STAGES[i - 1][1]);
const nextFraction = (i: number) => (i < STAGES.length ? STAGES[i][1] : 1);

let booted = false;
const bootTimer = setInterval(() => {
  if (booted) {
    return;
  }
  const t = (performance.now() - stageStart) / 1000;
  const d = durations[stage] ?? 5;
  // avanza verso la tappa successiva senza mai raggiungerla da sola
  const progress = 1 - Math.exp((-1.6 * t) / d);
  const f = fractionAt(stage) + (nextFraction(stage) - fractionAt(stage)) * progress * 0.97;
  setBar(f, stageLabel + " " + Math.floor(f * 100) + "%");
}, 200);
setBar(0, stageLabel + " 0%");

const reachStage = (i: number) => {
  if (i < stage) {
    return;
  }
  const now = performance.now();
  // le fasi saltate contano zero
  while (stage <= i) {
    measured[stage] = stage === i ? (now - stageStart) / 1000 : 0;
    stage++;
  }
  stageStart = now;
  stageLabel = STAGES[i][2];
};

const showError = (text: string) => {
  booted = true;
  clearInterval(bootTimer);
  hideBar();
  setStatus("Errore: " + text + " — prova a ricaricare la pagina.");
  if (statusEl !== null) {
    statusEl.classList.add("error");
  }
};

const markBooted = () => {
  if (booted) {
    return;
  }
  booted = true;
  clearInterval(bootTimer);
  measured[stage] = (performance.now() - stageStart) / 1000;
  while (measured.length < DEFAULT_DURATIONS.length) {
    measured.push(0);
  }
  try {
    localStorage.setItem("muia-avvio", JSON.stringify(measured));
    sessionStorage.removeItem("muia-riparo");
  } catch {
    // niente
  }
  setBar(1, "Pronto! 100%");
  setTimeout(hideBar, 1200);
};

for (const method of ["log", "info", "warn", "error"] as const) {
  const original = console[method].bind(console);
  console[method] = (...args: unknown[]) => {
    if (!booted) {
      const text = args.map((a) => String(a)).join(" ");
      STAGES.forEach(([needle], i) => {
        if (text.includes(needle)) {
          reachStage(i);
        }
      });
      if (text.includes("[mkxp-z stdout]") && !text.includes("ruby ")) {
        markBooted();
      } else if (/Failed to initialize the mkxp-z game engine|Failed to load content/i.test(text)) {
        void riparaAvvio(text);
      } else if (/Game threw an exception|RuntimeError|Aborted\(|out of memory/i.test(text)) {
        showError(text.replace(/^.*\] ?/, "").slice(0, 160));
      }
    }
    original(...args);
  };
}
// Il motore non riesce ad aprire il gioco (di solito per una copia salvata
// rovinata): cancello le copie e ricarico la pagina, una volta sola.
let riparando = false;
const riparaAvvio = async (testo: string) => {
  if (riparando) {
    return;
  }
  riparando = true;
  let giaProvato = false;
  try {
    giaProvato = sessionStorage.getItem("muia-riparo") === "1";
    sessionStorage.setItem("muia-riparo", "1");
  } catch {
    // niente
  }
  if (giaProvato) {
    showError("il gioco non si apre (" + testo.replace(/^.*\] ?/, "").slice(0, 80) + ")");
    return;
  }
  setBar(0, "Riparo la copia del gioco e la riscarico…");
  await cancellaCopie();
  location.reload();
};

window.addEventListener("error", (ev) => {
  if (!booted && !String(ev.message).includes("ResizeObserver")) {
    showError(String(ev.message || ev.error));
  }
});
window.addEventListener("unhandledrejection", (ev) => {
  // Il motore chiede di tenere acceso lo schermo (Wake Lock): se il browser
  // dice di no non è un errore del gioco, quindi non lo mostro.
  if (!booted && !/wake ?lock/i.test(String(ev.reason))) {
    showError(String(ev.reason));
  }
});
// Se dopo 4 minuti non è arrivato nulla, lo dico invece di lasciare il nero
setTimeout(() => {
  if (!booted) {
    showError("l'avvio sta impiegando troppo (più di 4 minuti)");
  }
}, 240000);

// ---------------------------------------------------------------------------
// Tasti a schermo: croce direzionale, A, B, START, SELECT
//   A      -> conferma (C)           B      -> annulla / corri (X)
//   START  -> menu (Z)               SELECT -> menu rapido (D)
// ---------------------------------------------------------------------------
type PadButton = "a" | "b" | "x" | "r3" | "up" | "down" | "left" | "right";

const press = (button: PadButton) => nostalgist.pressDown({ button });
const release = (button: PadButton) => nostalgist.pressUp({ button });

if (isTouch) {
  const controls = document.getElementById("controls");
  if (controls !== null) {
    controls.style.display = "block";
  }

  // Pulsanti singoli
  for (const el of document.querySelectorAll<HTMLElement>("[data-button]")) {
    const button = el.dataset.button as PadButton;
    let active = false;
    const down = (ev: PointerEvent) => {
      ev.preventDefault();
      el.setPointerCapture(ev.pointerId);
      if (!active) {
        active = true;
        el.classList.add("pressed");
        press(button);
        navigator.vibrate?.(10);
      }
    };
    const up = (ev: PointerEvent) => {
      ev.preventDefault();
      if (active) {
        active = false;
        el.classList.remove("pressed");
        release(button);
      }
    };
    el.addEventListener("pointerdown", down);
    el.addEventListener("pointerup", up);
    el.addEventListener("pointercancel", up);
    el.addEventListener("lostpointercapture", up);
    el.addEventListener("contextmenu", (ev) => ev.preventDefault());
  }

  // Croce direzionale: si può strisciare il dito da una direzione all'altra
  const dpad = document.getElementById("dpad");
  if (dpad !== null) {
    let current: PadButton | null = null;
    const set = (dir: PadButton | null) => {
      if (dir === current) {
        return;
      }
      if (current !== null) {
        release(current);
        dpad.querySelector(`[data-dir="${current}"]`)?.classList.remove("pressed");
      }
      current = dir;
      if (dir !== null) {
        press(dir);
        dpad.querySelector(`[data-dir="${dir}"]`)?.classList.add("pressed");
        navigator.vibrate?.(5);
      }
    };
    const fromEvent = (ev: PointerEvent): PadButton | null => {
      const rect = dpad.getBoundingClientRect();
      const dx = ev.clientX - (rect.left + rect.width / 2);
      const dy = ev.clientY - (rect.top + rect.height / 2);
      if (Math.hypot(dx, dy) < rect.width * 0.12) {
        return current; // zona morta al centro
      }
      if (Math.abs(dx) > Math.abs(dy)) {
        return dx > 0 ? "right" : "left";
      }
      return dy > 0 ? "down" : "up";
    };
    dpad.addEventListener("pointerdown", (ev) => {
      ev.preventDefault();
      dpad.setPointerCapture(ev.pointerId);
      set(fromEvent(ev));
    });
    dpad.addEventListener("pointermove", (ev) => {
      if (current !== null) {
        ev.preventDefault();
        set(fromEvent(ev));
      }
    });
    const end = (ev: PointerEvent) => {
      ev.preventDefault();
      set(null);
    };
    dpad.addEventListener("pointerup", end);
    dpad.addEventListener("pointercancel", end);
    dpad.addEventListener("lostpointercapture", end);
    dpad.addEventListener("contextmenu", (ev) => ev.preventDefault());
  }
}

// ---------------------------------------------------------------------------
// Tastiera da PC: la tastiera non arriva al gioco direttamente, quindi la
// traduco io negli stessi tasti virtuali usati dai pulsanti a schermo.
// Di base: Z / Spazio / Invio -> A (conferma)   X / Backspace -> B (indietro, corsa)
//   Esc -> menu sulla mappa, indietro nei menu  Shift -> funzione (menu, ordina...)
//   D -> menu rapido (SELECT)                   Frecce -> movimento
// ---------------------------------------------------------------------------
// I tasti se pol cambiar dal zogo ("Conza el zogo" → "Tasti"): la tabella
// la tien ponte.ts (bottonePerTasto). Se ricorda quale boton ga fato partir
// ogni tasto, cussì quando el se mola se mola el boton giusto.
const keyHeld = new Map<string, PadButton>();
document.addEventListener(
  "keydown",
  (ev) => {
    if (!ev.isTrusted || ev.ctrlKey || ev.metaKey || ev.altKey) {
      return;
    }
    const k = nomeTasto(ev);
    const held = keyHeld.get(k);
    const button = held ?? bottonePerTasto(k);
    if (button === undefined) {
      // Una freccia tolta dalla tabella dei tasti non deve muovere lo stesso
      if (k.startsWith("Arrow")) {
        ev.preventDefault();
        ev.stopImmediatePropagation();
      }
      return;
    }
    ev.preventDefault();
    ev.stopImmediatePropagation();
    if (held === undefined) {
      keyHeld.set(k, button);
      press(button);
    }
  },
  true,
);
document.addEventListener(
  "keyup",
  (ev) => {
    if (!ev.isTrusted) {
      return;
    }
    const k = nomeTasto(ev);
    const button = keyHeld.get(k);
    if (button === undefined) {
      return;
    }
    ev.preventDefault();
    ev.stopImmediatePropagation();
    keyHeld.delete(k);
    release(button);
  },
  true,
);
window.addEventListener("blur", () => {
  for (const button of keyHeld.values()) {
    release(button);
  }
  keyHeld.clear();
});

// ---------------------------------------------------------------------------
// Multiplayer online: el zogo (che nel browser no gà socket) parla col server
// tramite file nella cartela dei salvataggi; la pagina li inoltra via WebSocket.
// Vedi ponte.ts. Se la pagina xe verta da localhost se pol dar un server de
// prova con ?server=localhost:8088 (senza https).
// ---------------------------------------------------------------------------
const SERVER_MULTIPLAYER = "pokemon-muia-server-eu.onrender.com";
if (opfs !== null && opfs !== undefined) {
  const locale = ["localhost", "127.0.0.1"].includes(location.hostname);
  const prova = locale ? new URLSearchParams(location.search).get("server") : null;
  const host = prova ?? SERVER_MULTIPLAYER;
  const sicuro = prova === null;
  avviaPonte({
    trovaCartella: trovaCartellaSaves,
    urlWebSocket: (sicuro ? "wss://" : "ws://") + host + "/ws",
    urlSveglia: (sicuro ? "https://" : "http://") + host + "/",
    log: (...args) => console.log(...args),
  });
}

await nostalgist.start();
