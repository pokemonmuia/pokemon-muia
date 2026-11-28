// Prova automatica del zogo nel browser (usada dal workflow "Test notte").
// Verzi la pagina /gioca/ con ?debug, preme "Gioca", raccoglie la console e
// fa una foto ogni volta che el plugin Muia Test scrivi "MUIATEST FOTO nome".
import { chromium } from "playwright";
import fs from "node:fs";

const URL = process.env.URL_GIOCO || "http://localhost:4173/?debug";
const OUT = process.env.OUT || "risultati";
const LIMITE_MS = Number(process.env.LIMITE_MS || 18 * 60 * 1000);
fs.mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({
  channel: process.env.CANALE || undefined,
  headless: process.env.HEADLESS !== "0",
  args: [
    "--autoplay-policy=no-user-gesture-required",
    "--ignore-gpu-blocklist",
    "--enable-unsafe-swiftshader",
    "--enable-features=SharedArrayBuffer",
  ],
});
// TELEFONO=1: schermo verticale col touch e CPU rallentada (TELEFONO_CPU volte)
const TEL = process.env.TELEFONO === "1";
const page = await browser.newPage(TEL
  ? { viewport: { width: 390, height: 844 }, deviceScaleFactor: 3, isMobile: true, hasTouch: true }
  : { viewport: { width: 1024, height: 700 } });
if (TEL) {
  const cdp = await page.context().newCDPSession(page);
  await cdp.send("Emulation.setCPUThrottlingRate", { rate: Number(process.env.TELEFONO_CPU || 4) });
}
const righe = [];
let fine = false;
let perfFatte = 0;
let ricaricà = false;
const foto = [];
page.on("console", (msg) => {
  const t = msg.text();
  righe.push(t);
  const m = t.match(/MUIATEST FOTO (\S+)/);
  if (m) foto.push(m[1]);
  if (TEL && t.includes("MUIATEST OK prestazioni")) perfFatte += 1;
  if (t.includes("MUIATEST FINE") || t.includes("MUIATEST ERRORE GRAVE")) fine = fine || t.includes("FINE");
});
page.on("pageerror", (e) => righe.push("PAGEERROR " + e.message));

const salva = () => fs.writeFileSync(`${OUT}/console.txt`, righe.join("\n"));
const inizio = Date.now();
try {
  await page.goto(URL, { waitUntil: "load" });
  await page.waitForTimeout(5000);
  // coi-serviceworker ricarica la pagina una volta
  await page.waitForSelector("#start-button", { state: "visible", timeout: 180000 });
  await page.screenshot({ path: `${OUT}/00_pagina.png` });
  await page.click("#start-button");
  righe.push("ISOLATA " + (await page.evaluate(() => String(self.crossOriginIsolated))));
  // Dopo un po': el sfondo del caricamento xe ancora vivo? (el dovaria esser fermà)
  setTimeout(async () => {
    try {
      righe.push("SFONDO dopo 90s: " + (await page.evaluate(() => JSON.stringify({
        canvas: document.querySelectorAll("#sfondi canvas").length,
        display: (document.getElementById("sfondi") || {}).style?.display,
      }))));
    } catch {}
  }, 90000);
  let fatte = 0;
  let ultimaFoto = Date.now();
  const SOLO_PERF = process.env.SOLO_PERF === "1";
  while (!fine && !(SOLO_PERF && perfFatte > 0) && Date.now() - inizio < LIMITE_MS) {
    await page.waitForTimeout(500);
    while (fatte < foto.length) {
      await page.waitForTimeout(600);
      fatte += 1;
      await page.screenshot({ path: `${OUT}/${String(fatte).padStart(2, "0")}_${foto[fatte - 1]}.png` });
    }
    // El primo avvio in un browser novo a volte se pianta al 4% (anca in CI):
    // dopo 6 minuti senza el zogo, se ricarica la pagina una volta.
    if (!ricaricà && Date.now() - inizio > 360000 && !righe.some((r) => r.includes("MUIATEST"))) {
      ricaricà = true;
      righe.push("=== AVVIO PIANTÀ: ricarico la pagina ===");
      await page.reload({ waitUntil: "load" });
      await page.waitForSelector("#start-button", { state: "visible", timeout: 180000 });
      await page.click("#start-button");
    }
    if (Date.now() - ultimaFoto > 60000) {
      try {
        righe.push("BARRA " + (await page.evaluate(() => document.getElementById("bar-label")?.textContent || "")));
      } catch {}
      ultimaFoto = Date.now();
      await page.screenshot({ path: `${OUT}/zz_${Math.round((Date.now() - inizio) / 1000)}s.png` });
      salva();
    }
  }
  await page.screenshot({ path: `${OUT}/99_fine.png` });
  // Telefono: seconda volta (zogo za nel browser, el parti svelto), come quando
  // un zogador torna. Qua el sfondo del caricamento podeva restar acceso.
  if (TEL && SOLO_PERF) {
    righe.push("=== SECONDO AVVIO (ricarica la pagina) ===");
    const t0 = Date.now();
    await page.reload({ waitUntil: "load" });
    await page.waitForSelector("#start-button", { state: "visible", timeout: 180000 });
    await page.click("#start-button");
    const prima = perfFatte;
    while (perfFatte === prima && Date.now() - t0 < 300000) await page.waitForTimeout(1000);
    righe.push("SECONDO AVVIO durà " + Math.round((Date.now() - t0) / 1000) + "s");
    righe.push("SFONDO al secondo avvio: " + (await page.evaluate(() => JSON.stringify({
      canvas: document.querySelectorAll("#sfondi canvas").length,
      display: (document.getElementById("sfondi") || {}).style?.display,
    }))));
    await page.screenshot({ path: `${OUT}/99_secondo.png` });
  }
} catch (e) {
  righe.push("ERRORE PROVA " + e.message);
  try { await page.screenshot({ path: `${OUT}/99_errore.png` }); } catch {}
}
salva();
const muia = righe.filter((r) => r.includes("MUIATEST"));
fs.writeFileSync(`${OUT}/muiatest.txt`, muia.join("\n"));
console.log(muia.slice(-40).join("\n"));
await browser.close();
