import { primaryInput } from "detect-it";
import { Dexie, type EntityTable } from "dexie";
import fetchProgress from "fetch-progress";
import { toBase64 } from "js-base64";
import { Nostalgist } from "nostalgist";
import ProgressBar from "progressbar.js";
import { Spinner } from "spin.js";

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

const spinner = new Spinner({
  color: "#fff",
});
const spinnerTarget = document.getElementById("spinner-target");
if (spinnerTarget !== null) {
  spinner.spin(spinnerTarget);
}

const progressbarTarget = document.getElementById("progressbar-target");
const bar = new ProgressBar.Circle(progressbarTarget, {
  color: "#fff",
  strokeWidth: 6.0,
  step: (_, bar) => {
    const text = Math.round(bar.value() * 100) + "%";
    // @ts-expect-error The type of `bar` is set incorrectly by @types/progressbar.js
    bar.setText(text);
  },
});
bar.text!.style.fontSize = "20px";

let currentBytes = 0;
let totalBytes = 0;

const updateBar = () => {
  bar.set(
    isNaN(totalBytes) || !isFinite(totalBytes) || totalBytes === 0
      ? 0
      : currentBytes / totalBytes,
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

    // If the blob is not cached, fetch it instead
    if (blob === undefined) {
      let fetchedBytes = 0;

      const response = await fetch(path).then(
        fetchProgress({
          onProgress: (progress) => {
            currentBytes += progress.transferred - fetchedBytes;
            fetchedBytes = progress.transferred;
            updateBar();
            if (progressbarTarget !== null) {
              spinner.stop();
              progressbarTarget.style.display = "initial";
            }
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

bar.destroy();
spinner.stop();

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

// Schermata "Gioca": serve un tocco/clic per l'audio e per lo schermo intero
const startButton = document.getElementById("start-button");
setStatus(null);
if (startButton !== null) {
  startButton.style.display = "flex";
  await new Promise<void>((resolve) => {
    const go = (ev: Event) => {
      ev.preventDefault();
      startButton.removeEventListener("click", go);
      document.removeEventListener("keydown", onKey);
      resolve();
    };
    const onKey = (ev: KeyboardEvent) => {
      if (ev.key === "Enter" || ev.key === " " || ev.key === "c") {
        go(ev);
      }
    };
    startButton.addEventListener("click", go);
    document.addEventListener("keydown", onKey);
  });
  startButton.style.display = "none";
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

setStatus("Avvio del gioco…");

// Nasconde "Avvio del gioco…" quando gli script del gioco partono
let booted = false;
const markBooted = () => {
  if (!booted) {
    booted = true;
    setTimeout(() => setStatus(null), 1500);
  }
};
for (const method of ["log", "info", "warn", "error"] as const) {
  const original = console[method].bind(console);
  console[method] = (...args: unknown[]) => {
    if (!booted) {
      const text = args.map((a) => String(a)).join(" ");
      if (text.includes("[mkxp-z stdout]") && !text.includes("ruby ")) {
        markBooted();
      } else if (text.includes("Game threw an exception")) {
        booted = true;
        setStatus("Il gioco si è fermato per un errore. Ricarica la pagina.");
      }
    }
    original(...args);
  };
}
setTimeout(markBooted, 90000);

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

await nostalgist.start();
