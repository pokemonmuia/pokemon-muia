# Pokémon Muia: piano di lavoro

Stato al 4 novembre 2026, ricavato leggendo mappe, eventi e dati del branch `sviluppo-claude`, prima dell'unione in `main`: le modifiche fatte dopo non sono considerate. Il gioco non è stato avviato: ciò che riguarda il comportamento in partita va confermato con un playtest.

## Fasi

Il primo traguardo è una **demo giocabile fino alla seconda palestra**: serve a provare tutto il giro di gioco prima di disegnare decine di interni.

| Fase | Cosa si fa | Pronta quando |
| --- | --- | --- |
| 0. Ordine nel repo | Fatto in parte: `sviluppo-claude` è stato unito in `main` (PR #9). Resta da decidere chi lavora su quali mappe. | Tutti e due partite dalla stessa versione |
| 1. Basi di gioco | Primo Centro Pokémon e primo Market, copiando le mappe della demo. Pokémon selvatici nelle prime mappe. Pulizia dei residui della demo. | Si cattura, si compra, ci si cura senza trucchi |
| 2. Demo Atto 1 | Rivale, scelta tra Cinghio e Harry, allenatori in strada, palestre 1 e 2, primo conto al bar, contatore del debito, primo incontro con il Team Recupero Crediti. | Un amico gioca dal molo alla seconda medaglia senza aiuti |
| 3. Mondo fuori dal centro | Santa Barbara, Rio Ospo, Muggia Vecchia, Porto San Rocco, Lazzaretto. Mappa della regione e Svolo. | L'Autista porta a mappe vere |
| 4. Atti 2, 3 e 4 | Palestre 3-8 con interni diversi e allenatori, catena dei debiti, ufficio del Ragionier. | Si arriva alla fine della trama |
| 5. Finale | Super 4, sindaco, Sala d'Onore, titoli di coda. | Il gioco si può finire |
| 6. Post-partita e rifinitura | Trieste, Muidex, grafica definitiva, musiche, versioni per altri sistemi. | Si può pubblicare |

**Gli interni vanno scelti, non fatti tutti.** Nel centro storico serve un livello base di circa 20-25 stanze, il resto delle porte può restare chiuso con una battuta. Il numero è una mia stima, non un conteggio delle porte.

1. Subito: Centro Pokémon e Market del centro, Comun rifatto, casa del giocatore ripulita.
2. Poi: 8 palestre ognuna con un aspetto proprio, 3-4 bar della guerra tra Cinghio e Harry.
3. Poi: Duomo, Museo Carà, 6-8 case con un personaggio o una missione.
4. Infine: Centro e Market di Santa Barbara, ufficio del Ragionier, grotte e dungeon.

Bar come Centro Pokémon: è una trovata che sta già nel gioco, perché il bar di Cinghio cura la squadra. Può diventare la regola: si cura nei bar e il Centro vero resta uno solo.

## Stato del progetto

Il check è fatto leggendo tutti i file di mappe, eventi e dati del branch `sviluppo-claude`. Non ho avviato il gioco, quindi quello che riguarda il comportamento in partita va confermato con un playtest.

| Area | Cosa c'è | Cosa manca |
| --- | --- | --- |
| Mappe esterne | 41 mappe di Muia collegate tra loro: dal Molo si raggiungono tutte | Frazioni e colline: Muggia Vecchia, Santa Barbara, Rio Ospo, Porto San Rocco, Lazzaretto |
| Interni | 12 mappe: casa, Comun, Bar de Zuppo, 8 palestre e `cdn` (vuota e scollegata) | Tutto il resto. Le 8 palestre sono copie identiche: guida e capopalestra, senza allenatori o enigmi |
| Centro Pokémon e Market | Nessuno a Muia. Le uniche mappe sono quelle della demo | 1 Centro e 1 Market nel centro, poi quelli delle frazioni |
| Pokémon selvatici | Solo Caliterna, con dati provvisori: Bulbasaur, Charmander, Ivysaur e Lugia | Tabelle per le 26 mappe con erba e per le 9 mappe con acqua |
| Pokémon e strumenti | Dati completi di 898 specie. 3 starter: Froakie, Torchic, Chikorita | Muidex: l'elenco di quali Pokémon si trovano a Muia. Quello attuale viene dalla demo |
| Allenatori | 8 capipalestra con squadra, Tubo, una nuotatrice al Mandracchio | Sindaco, Super 4, rivale, Cinghio, Harry, squadra nemica, allenatori di strada |
| Trama | Scene 1, 2 e 2b. Scelta tra Cinghio e Harry abbozzata | Tutto il resto. Le 8 palestre sono già agganciate tra loro con l'ordine delle medaglie |
| Finale | Interruttore "Lega sbloccada" dopo l'ottava palestra. Castello come possibile sede | Mappe della Lega, battaglie, Sala d'Onore, titoli di coda |
| Mappa della regione | Ancora quella di Essen, con Lappet Town | Mappa di Muia, posizioni, punti di cura per Svolo. Nessuna mappa di Muia ha una posizione |
| Grafica | Tileset personalizzato, ritratti e sprite di sindaco, Cinghio, Henry, Gianna e Sandra Omo | Capipalestra: sono le grafiche provvisorie rinominate. Gianna e Sandra Omo non compaiono in nessun evento |
| Testi | Tante battute in dialetto, menu in italiano | Alcuni eventi sono in italiano standard, altri in inglese |
| Mosse di esplorazione | Tajo, Svolo, Sburton, Onda Granda con nomi in dialetto, ostacoli già piazzati | Decidere dove si ottiene ciascuna |

Le vostre battute, come Mauretto senza barca, la Vecia dela Cesa e il cartello del gin tonic, sono la parte più riuscita: la trama qui sotto le riusa.

## Bug e residui della demo

I primi quattro bloccano la partita, gli altri sono pulizia.

| Priorità | Problema | Dove | Soluzione |
| --- | --- | --- | --- |
| Bloccante | Nessun evento dà Pokémon Ball e non c'è un negozio, quindi non si può catturare | Tutte le mappe di Muia | Market più 5 Ball regalate da Dejan |
| Bloccante | Lugia può uscire nell'erba di Caliterna, al livello 35-55, con peso 30 | `PBS/encounters.txt`, sezione 081 | Nuova tabella con Pokémon comuni |
| Bloccante | Curarsi è possibile solo perdendo o stando nel Team Cinghio | Bar del Mandracchio, evento 12 | Primo Centro Pokémon. Vantaggio simile per il Team Harry |
| Bloccante | Finita l'ottava palestra non succede nulla | Interruttore 64 | Fase 5 del piano |
| Alta | L'Autista dice Santa Barbara, Molo T e Rio Ospo, ma porta alle mappe della demo. Due risposte sono ancora in inglese | Mandracchio, evento 11 | Tenerlo chiuso fino alla fase 3 |
| Alta | In casa ci sono NPC della demo in inglese, teletrasporti verso le mappe di prova e un Celebi regalato | Mappa 3, eventi 6-15 | Rimuovere prima di dare il gioco ad altri |
| Media | Si chiama Harry nei dialoghi e Henry negli sprite. La variabile 50 non ha nome | Mandracchio, Piazza Marconi | Scegliere un nome e nominare la variabile |
| Media | A reclutare per il Team Harry è il Mato dela Risorta, non Harry | Mandracchio, evento 5 | Spostare l'evento o spiegarlo nella storia |
| Media | Le scarpe costano 20 ma il codice controlla e toglie 0. Altri due NPC e la mamma della demo le regalano gratis | Mappe 76, 92, 106 e 3 | Tenere un solo evento |
| Media | Il sindaco ha ancora una riga in inglese: "Please let me know how you get on!" | Comun, evento 1 | Tradurre o togliere |
| Bassa | La finestra del gioco si chiama ancora "Pokémon Essentials v21.1" | `mkxp.json` | Mettere "Pokémon Muia" |
| Bassa | Mappa `cdn` isolata con un testo provvisorio | Mappa 33 | Cancellarla o collegarla |
| Bassa | Tubo usa ancora il tipo allenatore Team Rocket | Via della Torre | Nuovo tipo allenatore |
| Bassa | Le mappe della demo sono 69 e restano nel gioco | Cartella DEMO ESSENTIALS | Togliere le ultime dipendenze, poi cancellarle prima dell'uscita |

## Decisioni che spettano a voi

La prima va presa prima di far girare il gioco fuori dalla vostra cerchia.

- [ ] **Nome del sindaco.** Polidori è il cognome del [sindaco vero di Muggia](https://www.tuttitalia.it/friuli-venezia-giulia/67-muggia/26-amministrazione/), e nel gioco si presenta con quel nome, bestemmia e fa il boss finale. Consiglio un nome inventato, o solo "el Sindaco". La bozza usa "el Sindaco".
- [ ] **Altre persone vere.** Non so chi siano davvero Dejan, Cinghio, Harry, Zuppo, Walter, Mauretto e gli altri. Se esistono, conviene chiedere loro il permesso prima di pubblicare, soprattutto per le battute più pesanti. Nella bozza nessuno di loro è cattivo.
- [ ] **Compagnie del Carneval.** Sono associazioni vere: nella bozza restano simpatiche e dalla parte del giocatore.
- [ ] **Quanto rendere pubblico il gioco.** Un fan game Pokémon pubblico può ricevere richieste di rimozione da Nintendo. Un conto è girarlo tra amici, un altro metterlo online con il nome Pokémon.
- [ ] **Rivale.** Serve sapere chi sono Gianna e Sandra Omo: una delle due potrebbe prendere il posto di Tea, la rivale che propongo.
- [ ] **Centrale di Grignan con Zapdos.** Se intendete Grignano, sta dall'altra parte del golfo e starebbe bene nel post-partita a Trieste.
