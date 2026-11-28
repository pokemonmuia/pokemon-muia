/* Pokémon Muia — sfondi animati per la schermata di caricamento.
 * Scene in loop costruite sulle illustrazioni di Muggia:
 *   0 Muia de matina      (luce rosata, foschia, pescherecci, scia misteriosa nel golfo)
 *   1 Muia de dopopranzo  (nuvole con ombra, barca a vela, ombra di un leggendario)
 *   2 Muia de note        (luci della città, riflessi di luna, creatura nel golfo)
 *   3 Porto · tramonto    (fuori dal giro automatico, da rifare)
 *   4 Muia, da la matina a la note: la stessa vista che passa dalla mattina alla
 *     notte seguendo il caricamento (api.progresso(0..1)); senza progresso va a tempo.
 * Uso:  MuiaSfondi.avvia(elemento, { base: "sfondi/", scena: "giro" | "casuale" | 0..3, durata: 12000 })
 *       → restituisce una Promise con { ferma(), vai(n), progresso(f), scena }.
 */
(function (glob) {
  "use strict";
  const DATI = {"porto":{"w":1195,"h":896,"nuvole":[{"sx":0,"sy":0,"w":132,"h":53,"x":173,"y":13},{"sx":0,"sy":55,"w":31,"h":16,"x":300,"y":25},{"sx":0,"sy":73,"w":38,"h":18,"x":314,"y":45},{"sx":0,"sy":93,"w":76,"h":34,"x":934,"y":56},{"sx":0,"sy":129,"w":33,"h":17,"x":331,"y":62},{"sx":0,"sy":148,"w":31,"h":23,"x":1000,"y":65},{"sx":0,"sy":173,"w":140,"h":53,"x":694,"y":74},{"sx":0,"sy":228,"w":25,"h":21,"x":830,"y":99},{"sx":0,"sy":251,"w":97,"h":34,"x":73,"y":116},{"sx":0,"sy":287,"w":23,"h":73,"x":816,"y":184},{"sx":0,"sy":362,"w":80,"h":38,"x":263,"y":185},{"sx":0,"sy":402,"w":32,"h":40,"x":880,"y":185},{"sx":0,"sy":444,"w":24,"h":37,"x":866,"y":204}]},"alto":{"w":1264,"h":842,"nuvole":[{"sx":0,"sy":0,"w":163,"h":61,"x":655,"y":36},{"sx":0,"sy":63,"w":229,"h":86,"x":83,"y":45},{"sx":0,"sy":151,"w":144,"h":73,"x":1062,"y":48},{"sx":0,"sy":226,"w":58,"h":28,"x":336,"y":86}]}};
  const SCENE = [
    { nome: "Muia de matina", img: "alto", ora: 3 },
    { nome: "Muia de dopopranzo", img: "alto", ora: 0 },
    { nome: "Muia de note", img: "alto", ora: 2 },
    { nome: "Porto · tramonto", img: "porto", ora: 1 }, // in pausa: da rifare
    { nome: "Muia, da la matina a la note", img: "alto", ora: 4 }, // sfuma col caricamento
  ];
  const GIRO = [0, 1, 2]; // scene che ruotano in automatico
  const LAMPIONI = [[40, 46, 1.6], [212, 392, 1], [253, 455, 0.9], [365, 487, 0.6], [464, 478, 0.8],
    [652, 485, 0.8], [783, 483, 0.8], [816, 480, 0.8], [1016, 440, 0.9]];
  const PX = 3; // un pixel "grosso" = 3 pixel dell'illustrazione

  // ---------------------------------------------------------------- sprite
  const GAB = [ // gabbiano di lato, verso destra (3 pose d'ala)
    ["..KK........", "...KWK......", "....KWK.....", ".KK..KWWWK..", "..KWWWWWWWKO", "...KKGGGKK..", "............"],
    ["............", "............", "KKKKK.......", ".KWWWKWWWK..", "..KWWWWWWWKO", "...KKGGGKK..", "............"],
    ["............", "............", ".....KWWWK..", "..KWWWWWWWKO", "...KWWGGKK..", "....KWK.....", ".....KK....."],
  ];
  const GAB_ALTO = [ // gabbiano visto dall'alto, verso destra
    ["....O....", "KWWWGWWWK", ".K..G..K.", "....K...."],
    ["....O....", "..KWGWK..", "....G....", "....K...."],
  ];
  const PAL_GIORNO = { K: "#3a4252", W: "#ffffff", G: "#a9b6c6", O: "#f2b84b" };
  const PAL_SERA = { K: "#2a1a2e", W: "#3b2840", G: "#4a3350", O: "#2a1a2e" };

  function spr(g, rows, pal, x, y, s, flip) {
    s = s || 1;
    const w = rows[0].length;
    for (let j = 0; j < rows.length; j++) {
      const r = rows[j];
      for (let i = 0; i < w; i++) {
        const c = r[i];
        if (c === ".") continue;
        g.fillStyle = pal[c];
        g.fillRect(Math.round(x + (flip ? w - 1 - i : i) * s), Math.round(y + j * s), s, s);
      }
    }
  }
  const h1 = (n) => { const x = Math.sin(n * 127.1 + 311.7) * 43758.5453; return x - Math.floor(x); };

  // ---------------------------------------------------------------- WebGL
  const VS = "attribute vec2 p;varying vec2 v;void main(){v=vec2(p.x*.5+.5,.5-p.y*.5);gl_Position=vec4(p,0.,1.);}";
  const FS = [
    "precision mediump float;varying vec2 v;uniform sampler2D T,M;uniform vec2 S;uniform float t,ora,bob,rip,nott;",
    "float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}",
    "vec3 matina(vec3 col,float lum,float sp,vec2 v){",
    " float sole=smoothstep(1.4,0.,length(v-vec2(1.05,-.1)));",
    " col=mix(col,vec3(lum),.28);",
    " col=col*vec3(1.02,.88,.90)+vec3(.12,.06,.10);",
    " col=mix(col,vec3(1.,.82,.66),sole*.45);",
    " col=mix(col,col*vec3(.80,.84,1.08),smoothstep(.35,1.,v.y)*.45);",
    " return col+sp*vec3(1.,.85,.6);}",
    "vec3 note(vec3 col,float lum,float sp,float b,float t){",
    " col=vec3(.05,.08,.18)+col*vec3(.26,.33,.52)+lum*vec3(.0,.04,.10);",
    " float tw=.72+.28*sin(t*2.6+b*53.);",
    " col+=b*tw*vec3(1.,.68,.30)*1.15;",
    " return col+sp*vec3(.55,.7,1.)*.7;}",
    "void main(){",
    " vec2 px=v*S;vec4 m=texture2D(M,v);vec2 d=vec2(0.);",
    " d.y+=m.g*bob*sin(px.x*.011-t*1.5);",
    " d.x+=m.g*bob*.35*sin(px.x*.006+t*1.1+1.);",
    " d.x+=m.r*rip*sin(px.y*.30+t*2.2+sin(px.x*.015+t*.7)*2.);",
    " d.y+=m.r*rip*.4*sin(px.x*.04-t*1.6);",
    " vec4 c=texture2D(T,(px+d)/S);",
    " vec2 cell=floor((px+vec2(t*6.,0.))/vec2(6.,3.));",
    " vec2 fc=fract((px+vec2(t*6.,0.))/vec2(6.,3.));",
    " float sp=step(.986,h(cell+floor(t*2.5)))*step(.5,m.r)*step(fc.x,.55)*step(fc.y,.4);",
    " float lum=dot(c.rgb,vec3(.299,.587,.114));vec3 col=c.rgb;",
    " if(ora<.5){col=col*vec3(1.05,1.,.92)+vec3(.02,.01,0.);col+=sp*vec3(.75,.7,.5);}",
    " else if(ora>3.5){col=mix(matina(col,lum,sp,v),note(col,lum,sp,m.b*nott,t),nott);col+=vec3(.16,.05,-.03)*4.*nott*(1.-nott)*(1.-v.y*.5);}",
    " else if(ora>2.5){col=matina(col,lum,sp,v);}",
    " else if(ora<1.5){",
    "  col=col*vec3(1.10,.80,.64)+vec3(.05,.0,.03);",
    "  col=mix(col,col*vec3(.72,.58,.74),smoothstep(.45,1.,v.y)*.55);",
    "  col+=sp*vec3(1.,.72,.35);",
    "  float on=step(.3,fract(m.b*7.3+floor(t*.12+m.b*3.)*.37));",
    "  col+=step(.05,m.b)*on*vec3(1.,.72,.32)*.85;",
    " } else {col=note(col,lum,sp,m.b,t);}",
    " gl_FragColor=vec4(col,c.a);",
    "}",
  ].join("\n");

  function creaGL(cv) {
    let gl = null;
    try { gl = cv.getContext("webgl", { premultipliedAlpha: false, alpha: true, antialias: false }); } catch (e) {}
    if (!gl) return null;
    const sh = (tipo, src) => { const s = gl.createShader(tipo); gl.shaderSource(s, src); gl.compileShader(s); return s; };
    const pr = gl.createProgram();
    gl.attachShader(pr, sh(gl.VERTEX_SHADER, VS));
    gl.attachShader(pr, sh(gl.FRAGMENT_SHADER, FS));
    gl.linkProgram(pr);
    if (!gl.getProgramParameter(pr, gl.LINK_STATUS)) return null;
    gl.useProgram(pr);
    const buf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
    const loc = gl.getAttribLocation(pr, "p");
    gl.enableVertexAttribArray(loc);
    gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
    const U = {};
    ["T", "M", "S", "t", "ora", "bob", "rip", "nott"].forEach((n) => (U[n] = gl.getUniformLocation(pr, n)));
    gl.uniform1i(U.T, 0); gl.uniform1i(U.M, 1);
    const tex = (img) => {
      const tx = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, tx);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      return tx;
    };
    return {
      tex,
      disegna(tImg, tMask, w, h, t, ora, bob, rip, nott) {
        gl.viewport(0, 0, w, h);
        gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
        gl.activeTexture(gl.TEXTURE0); gl.bindTexture(gl.TEXTURE_2D, tImg);
        gl.activeTexture(gl.TEXTURE1); gl.bindTexture(gl.TEXTURE_2D, tMask);
        gl.uniform2f(U.S, w, h); gl.uniform1f(U.t, t); gl.uniform1f(U.ora, ora);
        gl.uniform1f(U.bob, bob); gl.uniform1f(U.rip, rip); gl.uniform1f(U.nott, nott || 0);
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
      },
    };
  }

  const carica = (src) => new Promise((ok, ko) => {
    const i = new Image(); i.decoding = "async"; i.onload = () => ok(i); i.onerror = ko; i.src = src;
  });
  const tela = (w, h) => { const c = document.createElement("canvas"); c.width = w; c.height = h; return c; };

  function tinta(img, colore, modo, alfa) { // copia colorata di un atlante di nuvole
    const c = tela(img.width, img.height), g = c.getContext("2d");
    g.drawImage(img, 0, 0);
    g.globalCompositeOperation = modo; g.globalAlpha = alfa; g.fillStyle = colore;
    g.fillRect(0, 0, c.width, c.height);
    g.globalCompositeOperation = "destination-in"; g.globalAlpha = 1; g.drawImage(img, 0, 0);
    return c;
  }

  // ---------------------------------------------------------------- avvio
  async function avvia(el, opz) {
    opz = opz || {};
    const base = opz.base == null ? "sfondi/" : opz.base;
    const durata = opz.durata || 12000;
    const calma = glob.matchMedia && matchMedia("(prefers-reduced-motion: reduce)").matches;
    // le immagini del porto si scaricano solo se serve la scena del porto
    const serveP = opz.scena === 3;
    const [iAlto, iAltoNuv, iAltoM, iPortoFg, iCielo, iPortoNuv, iPortoM] = await Promise.all(
      ["alto.webp", "alto-nuvole.png", "alto-maschere.png"].concat(serveP
        ? ["porto-primopiano.webp", "porto-cielo.webp", "porto-nuvole.png", "porto-maschere.png"] : [])
        .map((f) => carica(base + f)));
    const iPorto = iPortoFg;

    // struttura: quadro (copre lo schermo) con 3 tele sovrapposte
    const quadro = document.createElement("div");
    quadro.className = "muia-sfondi";
    quadro.style.cssText = "position:absolute;left:0;top:0;opacity:0;transition:opacity .7s ease;will-change:transform,opacity;";
    const mk = (z, pix) => {
      const c = document.createElement("canvas");
      c.style.cssText = "position:absolute;inset:0;width:100%;height:100%;" + (pix ? "image-rendering:pixelated;" : "");
      c.style.zIndex = z; quadro.appendChild(c); return c;
    };
    const cvDietro = mk(1), cvGL = mk(2), cvDavanti = mk(3);
    if (getComputedStyle(el).position === "static") el.style.position = "relative";
    el.style.overflow = "hidden";
    el.appendChild(quadro);

    const gl = creaGL(cvGL);
    const g2 = gl ? null : cvGL.getContext("2d");
    const T = gl ? {
      porto: serveP ? gl.tex(iPorto) : null, portoM: serveP ? gl.tex(iPortoM) : null, alto: gl.tex(iAlto), altoM: gl.tex(iAltoM),
    } : null;

    // nuvole colorate per tramonto e notte
    const nuvPorto = serveP ? [iPortoNuv, tinta(iPortoNuv, "#ff9a6a", "multiply", 0.85)] : [];
    const nuvAlto = [iAltoNuv, tinta(iAltoNuv, "#2a3a66", "multiply", 0.9), tinta(iAltoNuv, "#ffc2a8", "multiply", 0.7)];
    const ombraAlto = tinta(iAltoNuv, "#0b3a3a", "source-in", 1);

    // maschera del mare (bassa risoluzione) per ritagliare la creatura notturna
    const mareMask = (() => {
      const w = Math.round(DATI.alto.w / PX), h = Math.round(DATI.alto.h / PX);
      const c = tela(w, h), g = c.getContext("2d");
      try {
        g.drawImage(iAltoM, 0, 0, w, h);
        const d = g.getImageData(0, 0, w, h), p = d.data;
        for (let i = 0; i < p.length; i += 4) { p[i + 3] = p[i]; p[i] = p[i + 1] = p[i + 2] = 255; }
        g.putImageData(d, 0, 0);
        return c;
      } catch (e) { return null; }
    })();

    let idx = typeof opz.scena === "number" ? opz.scena % SCENE.length : (opz.scena === "casuale" ? GIRO[(Math.random() * GIRO.length) | 0] : 0);
    const giro = opz.scena === "giro" || opz.scena === undefined;
    let W = 0, H = 0, pix = null, pg = null, pixD = null, pgD = null;

    function imposta(n) {
      idx = n;
      const s = SCENE[n], d = DATI[s.img];
      W = d.w; H = d.h;
      [cvDietro, cvGL, cvDavanti].forEach((c) => { c.width = W; c.height = H; });
      pix = tela(Math.ceil(W / PX), Math.ceil(H / PX)); pg = pix.getContext("2d");
      pixD = tela(Math.ceil(W / PX), Math.ceil(H / PX)); pgD = pixD.getContext("2d");
      adatta();
      if (api) api.scena = SCENE[n].nome;
    }

    function adatta() {
      const box = el.getBoundingClientRect();
      const vw = box.width || innerWidth, vh = box.height || innerHeight;
      const r = Math.max(vw / W, vh / H) * 1.06; // un filo di margine per la panoramica
      quadro.style.width = W * r + "px"; quadro.style.height = H * r + "px";
      quadro._ox = vw - W * r; quadro._oy = vh - H * r;
    }
    addEventListener("resize", adatta);

    // ------------------------------------------------ disegno per scena
    const gDietro = cvDietro.getContext("2d"), gDavanti = cvDavanti.getContext("2d");

    let alfaBase = 1;
    function nuvole(g, atl, meta, t, ombra, alfa) {
      const a0 = alfaBase * (alfa == null ? 1 : alfa);
      meta.forEach((n, i) => {
        const v = (5 + (i % 4) * 2.2) * (calma ? 0.3 : 1);
        const giroX = W + n.w + 160;
        const x = ((n.x + n.w + 80 + v * t) % giroX) - n.w - 80;
        if (ombra) { g.globalAlpha = 0.33 * a0; g.drawImage(ombra, n.sx, n.sy, n.w, n.h, x + 18, n.y + 62, n.w, n.h); }
        g.globalAlpha = a0;
        g.drawImage(atl, n.sx, n.sy, n.w, n.h, x, n.y, n.w, n.h);
        g.globalAlpha = 1;
      });
    }

    function bagliore(g, x, y, r, col, a) {
      const gr = g.createRadialGradient(x, y, 0, x, y, r);
      gr.addColorStop(0, col.replace("A", a)); gr.addColorStop(1, col.replace("A", 0));
      g.fillStyle = gr; g.fillRect(x - r, y - r, r * 2, r * 2);
    }

    function gabbiani(g, t, pal, n0) {
      const pw = pix.width;
      for (let k = 0; k < 4; k++) {
        const v = 11 + k * 4, fase = h1(k + n0) * 300;
        const giroL = pw + 40;
        let x = ((t * v + fase) % giroL) - 20;
        const dir = k % 2 === 0;
        if (!dir) x = pw - x;
        const y = 14 + k * 11 + Math.sin(t * 0.9 + k) * 4;
        const f = Math.floor(t * (5 + k) + k) % 4;
        spr(g, GAB[[0, 1, 2, 1][f]], pal, x, y, 1, !dir);
      }
      // gabbiano vicino che plana davanti, ogni 20 s
      const c = (t + 6) % 20;
      if (c < 8) {
        const x = -30 + c * (pw + 60) / 8, y = 95 + Math.sin(c * 0.8) * 8;
        spr(g, GAB[c % 1.2 < 0.6 ? 1 : 0], pal, x, y, 2, false);
      }
    }

    function scenaPortoTramonto(t) {
      const gr = gDietro.createLinearGradient(0, 0, 0, 320);
      gr.addColorStop(0, "#2b2a5e"); gr.addColorStop(0.45, "#a04a6e"); gr.addColorStop(0.8, "#f08a52"); gr.addColorStop(1, "#ffc46b");
      gDietro.fillStyle = gr; gDietro.fillRect(0, 0, W, H);
      bagliore(gDietro, 760, 262, 210, "rgba(255,200,110,A)", 0.55);
      gDietro.fillStyle = "#ffe7a3"; gDietro.beginPath(); gDietro.arc(760, 262, 38, 0, 7); gDietro.fill();
      nuvole(gDietro, nuvPorto[1], DATI.porto.nuvole, t);
      // uccello di luce (leggendario) che attraversa il cielo dietro al castello
      const c = t % 18;
      if (c < 9) {
        const pw = pixD.width, p = c / 9;
        const x = pw + 30 - p * (pw + 90), y = 22 + Math.sin(p * 6.3) * 6;
        for (let i = 1; i < 26; i++) { // scia di scintille
          const a = (1 - i / 26) * (0.5 + 0.5 * h1(i + Math.floor(t * 12)));
          pgD.fillStyle = "rgba(255,226,140," + a + ")";
          pgD.fillRect(Math.round(x + i * 2.2), Math.round(y + Math.sin(i * 0.5 + t * 3) * 1.5), 1 + (i < 8), 1);
        }
        const ala = Math.sin(t * 5) * 4;
        pgD.fillStyle = "rgba(255,236,170,0.95)";
        pgD.fillRect(Math.round(x), Math.round(y), 7, 2); // corpo
        pgD.fillRect(Math.round(x - 1), Math.round(y - 1), 2, 1); // testa
        pgD.fillStyle = "rgba(255,210,120,0.9)";
        for (let i = 0; i < 5; i++) { // ali
          pgD.fillRect(Math.round(x + 2 + i), Math.round(y - 1 - (ala * (i + 1)) / 5), 1, 1);
          pgD.fillRect(Math.round(x + 2 + i), Math.round(y + 2 + (ala * (i + 1)) / 5), 1, 1);
        }
        pgD.fillStyle = "rgba(255,190,90,0.8)";
        pgD.fillRect(Math.round(x + 7), Math.round(y), 5, 1); pgD.fillRect(Math.round(x + 11), Math.round(y + 1), 4, 1); // coda
        gDietro.globalCompositeOperation = "lighter";
        bagliore(gDietro, x * PX, y * PX, 60, "rgba(255,200,120,A)", 0.35);
        gDietro.globalCompositeOperation = "source-over";
      }
      // lampioni
      gDavanti.globalCompositeOperation = "lighter";
      LAMPIONI.forEach(([x, y, s], i) => {
        const f = 0.85 + 0.15 * Math.sin(t * 7 + i * 2.1) * Math.sin(t * 3.3 + i);
        bagliore(gDavanti, x, y, 46 * s, "rgba(255,190,90,A)", 0.55 * f);
        bagliore(gDavanti, x, y, 10 * s, "rgba(255,240,190,A)", 0.9);
      });
      gDavanti.globalCompositeOperation = "source-over";
      gabbiani(pg, t * 0.8, PAL_SERA, 3);
    }

    function barca(g, bx, by, dir, vela) {
      for (let i = 1; i < 14; i++) { g.fillStyle = "rgba(220,240,255," + (0.6 - i * 0.04) + ")"; g.fillRect(Math.round(bx - dir * i * 1.6 + (dir < 0 ? 5 : 0)), Math.round(by - dir * i * 0.27 + ((i % 2) ? 1 : -1)), 1, 1); }
      g.fillStyle = vela ? "#1d3450" : "#f4f1e8"; g.fillRect(Math.round(bx), Math.round(by), 6, 2);
      if (vela) {
        g.fillStyle = "#ffffff"; g.fillRect(Math.round(bx + 1), Math.round(by - 1), 4, 1);
        g.fillRect(Math.round(bx + 2), Math.round(by - 4), 1, 3); g.fillRect(Math.round(bx + 3), Math.round(by - 3), 1, 2);
        g.fillStyle = "#e3350d"; g.fillRect(Math.round(bx + 2), Math.round(by - 5), 1, 1);
      } else { // peschereccio
        g.fillStyle = "#2b5f8a"; g.fillRect(Math.round(bx + (dir > 0 ? 1 : 3)), Math.round(by - 1), 2, 1);
        g.fillStyle = "#e3350d"; g.fillRect(Math.round(bx), Math.round(by + 1), 6, 1);
      }
    }

    function nebbia(g, t) { // banchi di foschia che scivolano sulle colline e sul mare
      const banchi = [[0.1, 60, 280, 0.45], [0.55, 120, 320, 0.38], [0.3, 200, 240, 0.28], [0.8, 40, 260, 0.42], [0.2, 720, 340, 0.30], [0.65, 640, 300, 0.24]];
      banchi.forEach(([fx, y, r, a], i) => {
        const x = ((fx * (W + 600) + t * (6 + i * 1.5)) % (W + 600)) - 300;
        g.save(); g.translate(x, y + Math.sin(t * 0.2 + i) * 6); g.scale(1, 0.32);
        bagliore(g, 0, 0, r, "rgba(255,240,236,A)", a);
        bagliore(g, r * 0.6, 20, r * 0.7, "rgba(255,240,236,A)", a * 0.8);
        g.restore();
      });
    }

    function scenaAltoMattina(t) {
      const pw = pix.width, ph = pix.height;
      // pescherecci che escono dal porticciolo verso il largo
      for (let j = 0; j < 2; j++) {
        const c = ((t + j * 17) % 34) / 34;
        barca(pgD, 205 - c * 210, 228 + j * 14 + c * 24 + Math.sin(t * 1.5 + j) * 0.5, -1, false);
      }
      // qualcosa sfreccia sotto il pelo dell'acqua: si vede solo la scia (ogni 19 s)
      const k = t % 19;
      if (k < 6) {
        const p = k / 6, hx = 165 - p * 190, hy = 262 + Math.sin(p * 5) * 4;
        for (let i = 0; i < 30; i++) {
          const d = i * 1.4, a = (1 - i / 30) * 0.9;
          pgD.fillStyle = "rgba(255,255,255," + a + ")";
          pgD.fillRect(Math.round(hx + d), Math.round(hy - d * 0.45), 1, 1);
          pgD.fillRect(Math.round(hx + d), Math.round(hy + d * 0.45), 1, 1);
          if (i % 4 === 0 && h1(i + Math.floor(t * 10)) > 0.4) pgD.fillRect(Math.round(hx + d + 1), Math.round(hy + (h1(i * 7 + Math.floor(t * 10)) - 0.5) * 3), 1, 1);
        }
        pgD.fillStyle = "rgba(120,200,255,0.9)"; pgD.fillRect(Math.round(hx - 1), Math.round(hy), 2, 1);
      }
      if (mareMask) { pgD.globalCompositeOperation = "destination-in"; pgD.drawImage(mareMask, 0, 0); pgD.globalCompositeOperation = "source-over"; }
      // gabbiani che vanno verso il mare
      for (let i = 0; i < 6; i++) {
        const v = 6 + (i % 3) * 2, giroY = ph + 20;
        const y = ((t * v + i * 53) % giroY) - 10;
        const x = 20 + i * 45 + Math.sin(t * 0.5 + i) * 6 - y * 0.1;
        spr(pg, GAB_ALTO[Math.floor(t * 5 + i * 1.3) % 2].slice().reverse(), PAL_GIORNO, x, y, 1, false);
      }
      return () => {
        nuvole(gDavanti, nuvAlto[2], DATI.alto.nuvole, t * 0.8, ombraAlto);
        gDavanti.globalAlpha = alfaBase; nebbia(gDavanti, t); gDavanti.globalAlpha = 1;
      };
    }

    function scenaAltoGiorno(t) {
      const pw = pix.width, ph = pix.height;
      // barca a vela che attraversa il golfo
      const c = (t % 30) / 30;
      barca(pg, -12 + c * 175, 245 + c * 30 + Math.sin(t * 1.3) * 0.6, 1, true);
      // ombra del leggendario che passa sopra Muia (ogni 22 s)
      const k = t % 22;
      if (k < 7) {
        const p = k / 7;
        const x = -60 + p * (pw + 120), y = ph * 0.85 - p * ph * 0.8;
        const ang = Math.atan2(-ph * 0.8, pw + 120);
        const ap = 1 - 0.3 * Math.sin(t * 3.2);
        pg.save(); pg.translate(x, y); pg.rotate(ang);
        pg.fillStyle = "rgba(4,28,30,0.34)";
        pg.beginPath();
        pg.ellipse(0, 0, 22, 5, 0, 0, 7); // corpo
        pg.moveTo(-22, 0); pg.lineTo(-44, -5); pg.lineTo(-40, 0); pg.lineTo(-44, 5); pg.closePath(); // coda
        pg.moveTo(8, -3); pg.lineTo(-4, -46 * ap); pg.lineTo(-9, -36 * ap); pg.lineTo(-13, -40 * ap); pg.lineTo(-16, -28 * ap); pg.lineTo(-20, -30 * ap); pg.lineTo(-14, -3); pg.closePath(); // ala sx
        pg.moveTo(8, 3); pg.lineTo(-4, 46 * ap); pg.lineTo(-9, 36 * ap); pg.lineTo(-13, 40 * ap); pg.lineTo(-16, 28 * ap); pg.lineTo(-20, 30 * ap); pg.lineTo(-14, 3); pg.closePath(); // ala dx
        pg.moveTo(20, -2); pg.lineTo(30, 0); pg.lineTo(20, 2); pg.closePath(); // muso
        pg.fill(); pg.restore();
      }
      // stormo di gabbiani visti dall'alto
      for (let i = 0; i < 5; i++) { // volano verso le colline
        const v = 7 + (i % 3) * 2.5, giroY = ph + 20;
        const y = ph + 5 - ((t * v + i * 61) % giroY);
        const x = 30 + i * 52 + Math.sin(t * 0.6 + i) * 6 + (ph - y) * 0.15;
        spr(pg, GAB_ALTO[Math.floor(t * 5 + i * 1.7) % 2], PAL_GIORNO, x, y, 1, false);
      }
      return () => nuvole(gDavanti, nuvAlto[0], DATI.alto.nuvole, t, ombraAlto);
    }

    function scenaAltoNotte(t) {
      const pw = pix.width;
      // luna riflessa nel golfo
      for (let i = 0; i < 26; i++) {
        const y = 232 + i * 1.8, larg = 2 + h1(i * 3 + Math.floor(t * 4)) * 7;
        const x = 95 + Math.sin(t * 1.4 + i * 0.7) * 3 - larg / 2 + (i * 0.6);
        pgD.fillStyle = "rgba(255,244,200," + (0.25 + 0.5 * h1(i + Math.floor(t * 6))) + ")";
        pgD.fillRect(Math.round(x), Math.round(y), Math.round(larg), 1);
      }
      // creatura leggendaria che nuota sotto la superficie (ogni 24 s)
      const k = t % 24;
      if (k < 16) {
        const a = Math.min(1, k / 3, (16 - k) / 3);
        const hx = 10 + k * 8.5, hy = 262 - k * 1.1;
        for (let i = 22; i >= 0; i--) {
          const sx = hx - i * 3.2, sy = hy + Math.sin(t * 2 - i * 0.45) * 3 + i * 0.4;
          const r = 6.5 - i * 0.22;
          pgD.fillStyle = "rgba(8,24,58," + 0.55 * a + ")";
          pgD.beginPath(); pgD.arc(sx, sy, Math.max(r, 1.5), 0, 7); pgD.fill();
          if (i % 3 === 1) { pgD.fillStyle = "rgba(90,230,255," + a * (0.55 + 0.45 * Math.sin(t * 3 + i)) + ")"; pgD.fillRect(Math.round(sx), Math.round(sy - r * 0.4), 1, 1); }
        }
        pgD.fillStyle = "rgba(160,255,255," + a + ")";
        pgD.fillRect(Math.round(hx + 3), Math.round(hy - 2), 1, 1); pgD.fillRect(Math.round(hx + 3), Math.round(hy + 2), 1, 1);
        for (let j = 0; j < 2; j++) { // cerchi sull'acqua
          const rr = ((t * 6 + j * 6) % 12);
          pgD.strokeStyle = "rgba(200,230,255," + a * (1 - rr / 12) * 0.5 + ")";
          pgD.beginPath(); pgD.ellipse(hx + 2, hy, rr + 3, (rr + 3) * 0.5, 0, 0, 7); pgD.stroke();
        }
      }
      if (mareMask) { pgD.globalCompositeOperation = "destination-in"; pgD.drawImage(mareMask, 0, 0); pgD.globalCompositeOperation = "source-over"; }
      // fanali del molo
      const lamp = (x, y, col, ph) => {
        const on = Math.sin(t * 2.2 + ph) > -0.2;
        if (!on) return;
        gDavanti.globalCompositeOperation = "lighter";
        bagliore(gDavanti, x, y, 26, col, 0.8); gDavanti.globalCompositeOperation = "source-over";
      };
      lamp(70, 792, "rgba(255,70,60,A)", 0); lamp(456, 782, "rgba(80,255,120,A)", 1.6);
      // lucciole/scintille sopra il verde
      for (let i = 0; i < 18; i++) {
        const x = (h1(i) * pw + Math.sin(t * 0.5 + i) * 6), y = 20 + h1(i + 40) * 120 + Math.cos(t * 0.6 + i) * 4;
        pg.fillStyle = "rgba(220,255,150," + Math.max(0, Math.sin(t * 1.7 + i * 2.3)) * 0.9 + ")";
        pg.fillRect(Math.round(x), Math.round(y), 1, 1);
      }
      return () => nuvole(gDavanti, nuvAlto[1], DATI.alto.nuvole, t * 0.7, null, 0.45);
    }

    // mattina e notte sovrapposte: i due livelli si incrociano con l'avanzamento
    let notte = 0, notteMeta = null, tPrec = 0;
    function componi(a) {
      gDavanti.imageSmoothingEnabled = false;
      gDavanti.globalAlpha = a;
      gDavanti.drawImage(pixD, 0, 0, pixD.width * PX, pixD.height * PX);
      gDavanti.drawImage(pix, 0, 0, pix.width * PX, pix.height * PX);
      gDavanti.globalAlpha = 1;
      pg.clearRect(0, 0, pix.width, pix.height); pgD.clearRect(0, 0, pixD.width, pixD.height);
    }
    function scenaGiornata(t) {
      const n = notte;
      let dM = null, dN = null;
      if (n < 0.995) { dM = scenaAltoMattina(t); componi(1 - n); }
      if (n > 0.005) { gDavanti.globalAlpha = n; dN = scenaAltoNotte(t); gDavanti.globalAlpha = 1; componi(n); }
      return () => {
        if (dM) { alfaBase = 1 - n; dM(); }
        if (dN) { alfaBase = n; dN(); }
        alfaBase = 1;
      };
    }

    const DISEGNI = [scenaAltoMattina, scenaAltoGiorno, scenaAltoNotte, scenaPortoTramonto, scenaGiornata];

    // ------------------------------------------------ ciclo
    let vivo = true, t0 = performance.now(), cambio = 0, inizioScena = t0;
    function frame(now) {
      if (!vivo) return;
      // sicurezza: se el sfondo xe sta nascosto (el zogo xe partì), se ferma
      if (el.style.display === "none") { api.ferma(); return; }
      const t = Math.max(0, now - t0) / 1000 + 3;
      const s = SCENE[idx];
      // la notte arriva verso metà caricamento (o, senza progresso, dopo ~20 s), sfumando piano
      const dt = Math.min(0.1, Math.max(0, t - tPrec)); tPrec = t;
      const meta = notteMeta != null ? notteMeta : Math.min(1, Math.max(0, (t - 3 - 14) / 10));
      notte += Math.max(-0.22 * dt, Math.min(0.22 * dt, meta - notte));
      gDietro.clearRect(0, 0, W, H); gDavanti.clearRect(0, 0, W, H);
      pg.clearRect(0, 0, pix.width, pix.height); pgD.clearRect(0, 0, pixD.width, pixD.height);
      if (gl) {
        const porto = s.img === "porto";
        gl.disegna(porto ? T.porto : T.alto, porto ? T.portoM : T.altoM, W, H, t, s.ora,
          calma ? 0 : (porto ? 2.2 : 0), calma ? 0 : (porto ? 1.6 : 1.1), notte);
      } else {
        g2.clearRect(0, 0, W, H);
        g2.drawImage(s.img === "porto" ? iPortoFg : iAlto, 0, 0, W, H);
        if (s.ora) { g2.fillStyle = s.ora === 1 ? "rgba(255,120,60,.25)" : s.ora === 3 ? "rgba(255,190,170,.2)" : s.ora === 4 ? "rgba(10,20,60," + (0.6 * notte).toFixed(3) + ")" : "rgba(10,20,60,.6)"; g2.fillRect(0, 0, W, H); }
      }
      const dopo = DISEGNI[idx](calma ? t * 0.4 : t);
      gDietro.imageSmoothingEnabled = false; gDavanti.imageSmoothingEnabled = false;
      // porto: il livello "dietro" sta nel cielo, dietro le case; alto: sta sul mare, quindi davanti
      (s.img === "porto" ? gDietro : gDavanti).drawImage(pixD, 0, 0, pixD.width * PX, pixD.height * PX);
      gDavanti.drawImage(pix, 0, 0, pix.width * PX, pix.height * PX);
      if (dopo) dopo();
      // panoramica lenta (utile soprattutto col telefono in verticale)
      const p = 0.5 + 0.5 * Math.sin(((now - inizioScena) / 1000) * 0.09 - 1.57);
      quadro.style.transform = "translate(" + (quadro._ox * (calma ? 0.5 : p)).toFixed(1) + "px," + (quadro._oy * 0.5).toFixed(1) + "px)";
      if (giro && now - cambio > durata) {
        cambio = now;
        quadro.style.opacity = 0;
        setTimeout(() => { if (vivo) { imposta(GIRO[(GIRO.indexOf(idx) + 1) % GIRO.length]); inizioScena = performance.now(); quadro.style.opacity = 1; } }, 750);
      }
      requestAnimationFrame(frame);
    }

    const api = {
      scena: SCENE[idx].nome,
      ferma() { vivo = false; removeEventListener("resize", adatta); quadro.remove(); },
      vai(n) { imposta(((n % SCENE.length) + SCENE.length) % SCENE.length); inizioScena = cambio = performance.now(); },
      // avanzamento del caricamento 0..1: la notte entra tra il 40% e il 70%
      progresso(f) { const x = Math.min(1, Math.max(0, (f - 0.4) / 0.3)); notteMeta = x * x * (3 - 2 * x); },
    };
    imposta(idx);
    cambio = performance.now();
    requestAnimationFrame((n) => { quadro.style.opacity = 1; frame(n); });
    return api;
  }

  glob.MuiaSfondi = { avvia, SCENE };
})(window);
