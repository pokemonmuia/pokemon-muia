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
- **11112026** Repository rinominà da pokemon_muia.v1 a pokemon-muia; el vecio repository pokemon_muia xe sta cancelà. Zontà die-lab come collaboradori.

# IDEE
- **02032026** La centrale elettrica de Grignan con Zapdos dentro.ù
