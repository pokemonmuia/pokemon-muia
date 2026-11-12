# pokemon_muia
Fan game Pokémon ambientà a Muia, fatto con Pokémon Essentials v21.1 e RPG Maker XP.

- [Te spiego](#te-spiego)
  - [La prima volta](#la-prima-volta)
  - [Ogni volta che te lavori](#ogni-volta-che-te-lavori)
  - [Come provar el zogo](#come-provar-el-zogo)
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

> **Ocio:** se lavoremo tuti e due sulla **stessa mapa** nello stesso momento, una delle due modifiche se perdi (i file delle mape no se pol unir). Disemose prima chi lavora su cosa, anca quando se crea mape nove.

### Come provar el zogo
- Per zogar basta verzer `Game.exe`, no serve instalar gnente.
- Per modificar mape ed eventi se verzi `Game.rxproj` (RPG Maker XP).
- Se se ga cambià qualcossa nella cartela `PBS` (Pokémon, allenatori, strumenti...), bisogna far partir el zogo da RPG Maker con **F12** (Playtest): cussì el zogo ricompila i dati. Dopo far commit e push anca dei file `.dat` cambiai nella cartela `Data`.

---

## Cosa ghe xe in sta cartela
| Cartela / file | Cosa xe |
|---|---|
| `Data/` | Mape, eventi e dati compilai del zogo (no se verzi a man) |
| `PBS/` | Dati de testo: Pokémon, mosse, strumenti, allenatori, incontri |
| `Graphics/`, `Audio/`, `Fonts/` | Grafica, musiche e caratteri |
| `Plugins/` | Plugin (multiplayer, rainefallUtils) |
| `Text_italiano_core/` | Traduzion italiana dei menu e dei messaggi del motor |
| `Strumenti/` | Script de aiuto (per esempio per compilar la traduzion) |
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

# IDEE
- **02032026** La centrale elettrica de Grignan con Zapdos dentro.ù
