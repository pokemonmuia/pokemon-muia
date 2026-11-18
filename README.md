# pokemon_muia
Fan game Pokémon ambientà a Muia, fatto con Pokémon Essentials v21.1 e RPG Maker XP.

> 🎮 **Zoga online (computer e telefono):** https://pokemonmuia.github.io/pokemon-muia/gioca/
> Se aggiorna da solo a ogni push su `main`. Dettagli in [Zogar online](#zogar-online).

- [Te spiego](#te-spiego)
  - [La prima volta](#la-prima-volta)
  - [Ogni volta che te lavori](#ogni-volta-che-te-lavori)
  - [Come provar el zogo](#come-provar-el-zogo)
  - [Zogar online](#zogar-online)
- [Cosa ghe xe in sta cartela](#cosa-ghe-xe-in-sta-cartela)
- [Traduzion](#traduzion)
- [AGGIORNAMENTI](#aggiornamenti)
- [IDEE](#idee)

La trama e i dettagli del zogo (scene, palestre) xe in [PLOT.md](PLOT.md).

---

## Te spiego
Qua dentro ghe metemo tuta la roba e dovessi sincronizzarse in automatico, oppur te la scarighi ogni volta che tanto pesa poco!

### La prima volta
Solo che te ga de scarigarte la app de githbu che te trovi a sto link [qua](https://desktop.github.com/download/)! 

Dopo te inserissi la mail e la password che te mando per telegram e xe fatta.
Nel senso che te scarigherà la cartella de qualche parte e dopo basta che te verzi el zogo da quella cartella e ghe semo mulon (sul mio la ga messa in C:\Users\die-lab\Documents\GitHub\pokemon_muia\ quindi sul tuo immagino sia una roba simile)!

In curto:
1. Scariga [GitHub Desktop](https://desktop.github.com/download/) e fa el login.
2. *File → Clone repository* e sceglier `pokemonmuia/pokemon_muia.v1`.
3. Verzi el zogo dalla cartella che el te ga creà.

### Ogni volta che te lavori
Ogni volta che te vol far modifiche, prima de iniziar a farle te ga de andar sull'app e far fetch origin, in alto a destra, e dopo **pull origin** (el fetch solo controla se ghe xe novità, el pull le scariga davero), cussi se mi go fatto modifiche dall'ultima volta allora non se le perdemo e te lavori su quelle. 
Quando te le ga finide inveze te ga 1. de far ctrl+s sul zogo, ma questo za te sa. 2. de tornar sull'app de github, riempir el campo "Summary(required)" 3. far "commit to main" e 4. premer "push origin". E XE FATTA!

| Quando | Cosa far su GitHub Desktop |
|---|---|
| Prima de iniziar | **Fetch origin**, dopo **Pull origin** |
| Dopo ver finì | Ctrl+S sul zogo → scriver el **Summary** → **Commit to main** → **Push origin** |

> **Versione del zogo:** el numero xe in `version.txt` (1.01, 1.02, ...) e el compar in basso a destra nel titolo. Ogni push lo alza de 0.01: se te lavori con Claude Code lo fa lu (regola in `CLAUDE.md`), se te fa push da GitHub Desktop lo alza GitHub da solo poco dopo. Per questo, **prima de lavorar fe sempre Pull origin**. No cambiar mai i numeri (ID) de mape, switch, variabili, ogeti o pokemon za esistenti: zontè quei novi in fondo, cussì i salvataggi veci funziona ancora.

> **Ocio:** se lavoremo tuti e due sulla **stessa mapa** nello stesso momento, una delle due modifiche se perdi (i file delle mape no se pol unir). Disemose prima chi lavora su cosa, anca quando se crea mape nove.

### Come provar el zogo
- Per zogar basta verzer `Game.exe`, no serve instalar gnente.
- Senza Windows (Mac, telefono) se zoga online dal link qua sotto.
- Per modificar mape ed eventi se verzi `Game.rxproj` (RPG Maker XP).
- Se se ga cambià qualcossa nella cartela `PBS` (Pokémon, allenatori, strumenti...), bisogna far partir el zogo da RPG Maker con **F12** (Playtest): cussì el zogo ricompila i dati. Dopo far commit e push anca dei file `.dat` cambiai nella cartela `Data`.

### Zogar online
**Link:** https://pokemonmuia.github.io/pokemon-muia/gioca/

- Va su Chrome, Firefox e sul telefono (provà su Android, iPhone ancora de provar). No serve instalar gnente.
- **Se aggiorna da solo:** a ogni push su `main` GitHub rifà el pacchetto e lo ripubblica in 2-3 minuti (se vedi nella scheda *Actions* del repo, "Sito GitHub Pages"). Se el browser mostra ancora la version vecia, ricarica forzando (Cmd/Ctrl+Shift+R) o speta 10 minuti.
- La prima volta el scariga el zogo (circa 70 MB) e lo tien salvà nel browser; dopo se scariga de novo solo quando el zogo cambia. Dopo aver premù **Gioca** ghe vol circa 30 secondi per partir: la bara rossa te disi a che punto el xe.
- **I salvataggi** resta nel browser de quel computer/telefono (no i se passa da un dispositivo all'altro). Se te cancelli i dati del sito, te perdi anca quei. Per questo ghe xe, nella schermata col botón **Gioca** (prima de premerlo), i botoni **Salva una copia dei salvataggi** (scarica un file `.json`) e **Carica una copia** (lo rimeti nel browser, anca su un altro telefono o computer). Se ghe xe za dei salvataggi, quei con lo stesso nome vien sostituii e ghe resta una copia vecia `.prima.bak`. Su iPhone no xe ancora provà.
- **Tasti sul computer** (uguai anca su `Game.exe`, grazie al plugin *Muia Tasti*): frecie per caminar, Z o Spazio (o Invio) = A (conferma), X = B (indrio e corer), Esc verzi e sera el menu, D menu rapido.
- **Sul telefono:** te disi de girarlo in orizontal; a sinistra la crose, a destra A (conferma) e B (indrio/corer), in alto SELECT (menu rapido) e START (menu).
- **Multiplayer nel browser e sul telefono:** dal menù de pausa *Zogo insieme → Zogo online*. Passa da un server su Render (vedi `server/LEGGIMI.md`); se el dorme, ghe vol circa un minuto a svejarse. Su `Game.exe` resta anca el zogo in locale.
- Per la version online i Pokémon che el zogo no dopra (no xe in incontri, allenatori, mape, eventi o plugin, gnanca come evoluzion) resta fora, cussì el se carga prima. La lista se rifà da sola a ogni push; se un Pokémon manca per sbaglio, compar el "?" ma el zogo no se ferma.
- La pagina xe in `web/gioca/` e el lavoro de GitHub in `.github/workflows/pages.yml`. Se se verzi el link con `?debug` in fondo, nella console del browser se vedi tuti i messaggi del motor.

---

## Cosa ghe xe in sta cartela
| Cartela / file | Cosa xe |
|---|---|
| `Data/` | Mape, eventi e dati compilai del zogo (no se verzi a man) |
| `PBS/` | Dati de testo: Pokémon, mosse, strumenti, allenatori, incontri |
| `Graphics/`, `Audio/`, `Fonts/` | Grafica, musiche e caratteri |
| `Plugins/` | Plugin (multiplayer, rainefallUtils, Muia Livelli Selvatici, Muia Tasti) |
| `Text_italiano_core/` | Traduzion italiana dei menu e dei messaggi del motor |
| `Strumenti/` | Script de aiuto (per esempio per compilar la traduzion) |
| `web/gioca/` | La pagina per zogar online (vedi [Zogar online](#zogar-online)) |
| `PLOT.md` | Trama, scene e palestre |

---

## Traduzion
- Nomi de mosse, strumenti e abilità messi a posto coi nomi ufficiai italiani (quei fatti col chatbot gaveva tanti sbagli). Le mosse de esplorazion in dialeto (Tajo, Svolo, Sburton, Onda Granda...) xe restade.
- Pokédex, forme dei Pokémon e porzioni dei strumenti in italian.
- Menu, lote e messaggi del motor in italian: el file xe Text_italiano_core/SCRIPT_TEXTS.txt (riga in inglese, sotto la traduzion). Dopo ver cambià qualcossa, compilar con Debug > Files > "Compile translated text" > Text_italiano_core (o con Strumenti/compila_traduzione.rb).
- Restano in inglese solo i menu del Debug.

---

# AGGIORNAMENTI
Dovemo ricordarse de aggiornar questo file con le robe che femo sul giogo (nove mappe, novi personaggi).
In piu, dovemo metterse nella sezion sotto, delle idee, quel che pensavimo de far.

Formato: data (GGMMAAAA) e cosa xe sta fatto, le robe più nove in fondo.

- **08102026** Novo repository pokemon_muia.v1. Zontà i 8 capipalestra de Muia (Roccia, Erba, Acqua, Elettricità, Veleno, Fuoco, Psico, Ghiaccio) con le squadre in PBS/trainers.txt e grafica provvisoria. Ordine e livei in PLOT.md.
- **08102026** Zogo in italian (dettagli nella sezion [Traduzion](#traduzion)).
- **08102026** Riordinà l'albero delle mape in RPG Maker: tute le vie de Muia sotto la cartela `=== MUIA ===` (Map111), tute le mape demo de Essentials sotto `=== DEMO ESSENTIALS ===` (Map112). No xe sta cancelà gnente e i colegamenti xe uguai a prima. Le mape demo ancora doprade (casa del zogador, Lab, isole dell'Autista) le ga `[IN USO]` nel nome.
- **08102026** Nova mapa **Piazza Santa Lucia** (Map113), a destra de Piazza Marconi: xe el continuo de la via de Calle Parini (Bassa), de la via in alto a destra de Piazza Marconi e de la caleta bassa de Piazza Marconi. Spazio in cemento in mezo, case tuto intorno, do bar co la tenda zala e panchine. Le cali verso nord, est e sud le xe serade coi coni: de là continuerà le prossime mape (anca el castel). No la riva al Circolo de la Vela.
- **19102026** Inizio dela trama nei eventi (dettagli in [PLOT.md](PLOT.md), scene 1, 2 e 2b). Un zogo novo parti dall'intro e te rivi sul Molo dei Bersaglieri col Delfin Verde; un mulo del Comun te compagna in Piazza Marconi; drento el Comun (Map004, ex Lab) el sindaco te disi de far esperienza e el te fa sceglier el starter; fora te speta Dejan che te spiega palestre, Super 4 e sindaco. L'evento de Polidori in piazza (switch 59) no compar più, le sue batude le disi el sindaco drento. El Quick start de debug xe sta fermà (no cancelà).
- **19102026** Intro più curta (solo pokemon, omo/baba e nome) e nel Comun el zogador camina fin dal sindaco (prima restava bloccà soto la barriera).
- **19102026** Le **8 palestre** (Map115-Map122), una per compagnia del Carneval, in ordine dall'ultima alla vincitrice della sfilata 2026, con livei che cressi (12 fin a 50). Porte in Via della Torre, Giardinetti D'Europa, Vecchio Squero, Ricreatorio, Caliterna, Piazza della Repubblica, Via Roma e Mandracchio. Tabela in [PLOT.md](PLOT.md).
- **19102026** **Castel de Muia** (Map114) tornà, ma desso collegà a nord de Piazza Santa Lucia (tolti i coni), come in realtà (Calle Volta → Calle Lauri). Tornade anca le righe de mura in fondo a `Outside_V7.png` e in `Tilesets.rxdata`. PBS e `.dat` za aggiornai.
- **19102026** Novi tipi delle palestre: La Bora Volante, Bellezze Naturali Erba, Lampo Elettro, Brivido Ghiaccio, Mandrioi Spettro, Ongia Fuoco, Trottola Psico, Bulli e Pupe Lotta (stessi livei e posti). Squadre nove in PBS/trainers.txt, capipalestra rinominai per compagnia (LEADER_BORA...) anca nella grafica. **Bisogna far partir el zogo con F12 da RPG Maker** la prima volta, per ricompilar i allenatori.
- **20102026** La palestra 1 (La Bora) xe stada spostada in **Caliterna**: seconda porta seguendo la strada che vien dal Mandracchio (l'edificio zalo e rosso, 57,10), con la porta disegnada e un cartel sulla finestra. Via la porta vecia in Via della Torre. Dejan desso te disi dove xe la prima palestra.
- **20102026** La **casa del zogador** (Map003, punto de rinascita) desso xe in **Cul de Nave**, porta in (7,9). Prima la porta portava ancora a Lappet Town.
- **20102026** **Castel de Muia rifato** come quel vero (foto de Google Maps): mastio quadrato coi merli, mura, scalinata, punto panoramico, vila, parcheggio. Se riva dale **scale tra Mandracchio_2 e Circolo della Vela**; tolto el colegamento con Piazza Santa Lucia (tornai i coni). Zontade 9 righe in fondo a `Outside_V7.png` per el mastio e le mura.
- **20102026** **Sprite dei personaggi**: Polidori (anca versione de Carneval), Sandra Omo, Cinghio, Gianna e Henry. Sprite de lota in `Graphics/Trainers` (SINDACO, SINDACO_CARNEVAL, CINGHIO, HENRY, GIANNA, SANDRA_OMO, con i tipi de allenador in PBS/trainer_types.txt) e ritrati grandi in `Graphics/Pictures/ritratto_*.png`. Nel'intro Polidori xe al posto del professor Oak e el se presenta; el so ritrato compar quando el parla nel Comun, e quel de Cinghio al Mandracchio.
- **11112026** Repository rinominà da pokemon_muia.v1 a pokemon-muia; el vecio repository pokemon_muia xe sta cancelà. Zontà die-lab come collaboradori.
- **12112026** **Video de intro** al posto dela vecia schermata del titolo: dopo le do schermate col stema del Comun parti `Movies/intro.ogv` (dal mondo fin a Muia, col logo) con soto la musica del titolo. Co finissi de comparir el logo vien fora "Daghe, fraca spazio!" che lampeggia; a la fine del video resta l'ultimo fotogramma (`Graphics/Titles/intro_end.png`) col "Daghe, fraca spazio!" vero, e premendo se va nel zogo. Se pol saltar el video con Invio o Esc (se va drito a la fine). El video xe 512x384 con le bande nere sora e soto (l'original xe 3:2); el codice xe in `UI_SplashesAndTitleScreen`. Se el video no parti, resta la schermata del titolo vecia (`title.png`). In Debug (F12 da RPG Maker) no se lo vedi, perché là le schermate de avvio vien saltade.
- **15112026** **Pokédex dal sindaco con la scena**: dopo la scelta del pokemon el sindaco te ciama davanti a lu, el ciol el Pokédex de drio de lu e el te lo dà; desso el Pokédex compar anca nel menu (Pokédex nazional, coi pokemon che te ga za). Lote: **Biava / Saccoccia / Pokémon / Scampa** (Saccoccia anca nel menu). Tradote le ultime frasi in inglese (la batuda de la nona resta in inglese apposta): laboratorio (cartei e balle), telefonada del sindaco (prima "Professor Oak"), meteoriti de Deoxys a Molo T, autista del Mandracchio.
- **15112026** **Casa del zogador pulida** (Map003): via i eventi de la demo (anca quel che ativava el debug e dava tute le medaie), resta solo la mama e de sora el PC, che la prima volta ga dentro 10 Poké Ball. El **Pokédex** desso lo dà el sindaco nel laboratorio (Map004) subito dopo che te ga scelto el pokemon. Plugin novo **Muia Tasti**: stessi tasti sul computer sia online che su `Game.exe`. ⚠️ Prima de verzer RPG Maker fe *Pull origin*, se no se perdi ste modifiche a Map003 e Map004.
- **15112026** **El zogo se zoga online** dal link https://pokemonmuia.github.io/pokemon-muia/gioca/ (computer e telefono, coi tasti a schermo), e el se aggiorna da solo a ogni push su `main`. Tuto spiegà in [Zogar online](#zogar-online).
- **17112026** **Versioni e salvataggi**: el zogo desso ga un numero de versione (`version.txt`, se parti dalla **1.01**) che se vedi nel titolo e che cressi de 0.01 a ogni push. I salvataggi fati con una versione vecia se verzi ancora: prima de cambiarli el zogo ghe fa una copia (`Game.rxdata.v<versione>.bak`) e, se servi, el li sistema con le "conversioni" del plugin novo **Muia Aggiornamenti**. Per ricompilar i plugin senza RPG Maker: `ruby Strumenti/compila_plugin.rb`.
- **17112026** **Copia dei salvataggi nel browser**: nella schermata de **Gioca** (versione web) ghe xe i botoni *Salva una copia dei salvataggi* e *Carica una copia*. Cussì se pol far un backup, o portar i salvataggi su un altro telefono o computer, anca se se cancela i dati del sito. Versione 1.02.
- **17112026** **App sul telefono**: la pagina de **Gioca** desso se pol instalar come app (su Chrome: menù ⋮ → *Installa app* / *Aggiungi a schermata Home*) e se verzi anca senza connession. Co ghe xe la rete se ciapa sempre la versione più nova, senza dover svodar la cache; senza rete se usa l'ultima copia. El zogo e i salvataggi i resta dove i iera. Versione 1.03.
- **17112026** **Zogo insieme (Link Play) in dialeto**: tuti i testi del menù e dei messaggi del multiplayer (zogo in locale/online, scambi, lote, lota a quatro) desso xe in dialeto. Versione 1.04.
- **17112026** **Prova rete (temporanea)**: nel menù de pausa ghe xe "Prova rete", che serve solo a capir se el multiplayer pol andar nel browser. Dopo el test la se toia. Versione 1.05.
- **17112026** **Prova rete 2**: la "Prova rete" desso verifica anca un ponte tra el zogo e la pagina (el browser no gà socket). Versione 1.06.
- **17112026** **Prova rete 3**: la "Prova rete" desso scrive più dettagli su dove el zogo pol scriver file nel browser. Versione 1.07.
- **17112026** **Prova rete 4**: la "Prova rete" desso prova el ponte tra zogo e pagina dentro la cartela dei salvataggi, con messaggi più curti. Versione 1.08.
- **17112026** **Prova rete 5**: el ponte tra zogo e pagina desso dopra un nome novo par ogni messagio e la prova mostra cossa vedi nella cartela. Versione 1.09.
- **17112026** **Multiplayer nel browser**: el zogo online ora funziona anca dal browser e dal telefono, tramite un server (cartela `server/`) e un ponte tra zogo e pagina. Tolta la "Prova rete". Nel menù *Zogo insieme* dal browser ghe xe solo *Zogo online*. Versione 1.10.
- **17112026** **Multiplayer nel browser più leggero**: el zogo online dal browser manda e riceve meno spesso (10 volte al secondo) e legge la cartela dei file con meno fatica, cussì el va meno a scatti. Versione 1.12.
- **17112026** **Misure del multiplayer (temporanee)**: el zogo scrive nella console del browser (con `?debug`) quanto ghe mete ogni fase e come cambia el stato dei zogadori, par capir cossa xe lento. Versione 1.13.
- **18112026** **Multiplayer senza ritardi**: el zogo desso lexe tuti i messagi del server in una volta (prima uno par fotogramma, e dopo un menù o una lota i altri zogadori se vedeva in ritardo), manda i so dati una volta sola par fotogramma, e el server no se confonde più se l'orologio del PC xe indrio o avanti. Versione 1.14.
- **18112026** **Multiplayer più fluido**: i altri zogadori se move liscio a ogni fotogramma (prima i feva mezza strada e i se fermava), el zogo indovina dove i va intanto che riva el prossimo messagio, el server manda solo quel che xe cambià e 15 volte al secondo anca dal browser. Desso se passa *attraverso* i altri zogadori (par parlarghe se ghe sta davanti e se schicia A, come prima). Versione 1.15.
- **18112026** **Messagi tra zogadori più svelti**: inviti, risposte, scambi e lote online parte subito (prima i spetava el giro de invio del zogo e po' quel del server, a ogni passo). Versione 1.16.
- **18112026** **Nome con la tastiera vera**: quando el zogo domanda un nome no ghe xe più la tastiera del zogo: sul PC se scrive con la tastiera del PC, nel browser vien fora una casela (sul telefono con la tastiera del telefono) e se conferma con Invio. **Esci dal gioco** desso domanda se te son sicuro; nel browser la pagina se sera (o torna al sito) invece de finir in un menu strano. Nell'intro el Pokémon del professor xe un **Abra** invece del Marill. Sul sito el boton grando desso xe **Zoga el zogo**. Versione 1.17.
- **18112026** **Intro**: alla domanda "omo o baba" se vedi subito el personagio (Omo = el mulo, Baba = la mula, Fluido = Abra) mentre te move el cursor. **Testo veloce** de base par chi taca una partida nova. **Nome**: la casela par scriver el nome desso xe in stile Pokémon. **Tasti**: in *Conza el zogo* ghe xe *Tasti*, par sceglier do tasti par ogni azion (Conferma, Indrio, Menu/Esci, Funzion, Menu rapido); **Esc** sulla mapa verzi el menu e nei menu torna indrio. Sul telefono resta i tasti a schermo. Versione 1.18.

# IDEE
- **02032026** La centrale elettrica de Grignan con Zapdos dentro.ù
