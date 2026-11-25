# PLOT
Femo un bel plot e altre idee del giogo:
## SCENE
### SCENA 1. (FATTA)
Location = Molo dei Bersaglieri (Map022), davanti la passerela del Delfin Verde
Plot = te son pena rivà a Muja col Delfin Verde. Te vien incontro un mulo del Comun che te disi che el sindaco te vol parlar subito, e el te compagna in Piazza Marconi (passagio svelto, con dissolvenza). In piazza el te mostra el Comun e el va via.
### SCENA 2. (FATTA)
Location = Comun de Muja (Map004, la porta xe in Piazza Marconi)
Plot = el sindaco Pochibori te disi "Te pensi de esser meio de mi?" e, qualsiasi roba te rispondi, "prima te ga de far esperienza". El te fa sceglier un pokemon sul tavolo e el te manda fora, dove te speta Dei ian. El te disi anca de l'ordinanza: nissun foresto ciapa el Delfin Verde senza i oto bolli.
### SCENA 2b. (FATTA, rifata 25/11) - La folla e Dei ian
Location = Piazza Marconi (Map042), apena te esci dal Comun (var 27 = 3)
Plot = otto muiesani te circonda e bisbiglia ("Te ga visto? Xe quel novo!", "El foresto! El vien de Trieste, se vedi dale scarpe"...). Riva DEI IAN (ex Dei ian, ex Dejan, evento 2 dela mapa) che li manda via e te spiega: ordinanza del sindaco Pochibori, oto bolli dele compagnie, Super 4 al Castel, sindaco. E le robe pratiche: vecie che cura, tabachin, schei anca dai selvadeghi, palestra al Pacco. Var 27 = 4.

### SCENA 2c. (FATTA) - Tubo
Location = Piazza Marconi
Plot = "FERMI TUTI! Polizia Locale!": TUBO, pulotto, studià a Trieste e mai digerì. Prima lota (se pol perder): Tubo ga el starter che bati el tuo. Dopo el te disi che senza el Libreto del Carneval al so posto de bloco no se passa. Dei ian te manda dala Siora Ornella in Bar de Zuppo. Var 27 = 5.

### SCENA 3. (FATTA) - El Libreto del Carneval
Location = Bar de Zuppo (Map080)
Plot = la SIORA ORNELLA del Comun fa merenda. La te timbra el Libreto solo se te ga almeno do pokemon (te insegna a ciapar e a comprar Poké Ball). Var 27 = 6.

### SCENA 4. (FATTA) - El posto de bloco
Location = Via Roma_2 (Map092, 53-54,14), in cima a Calle Parini, soto la Salita dele Mure
Plot = per la sfilata del Carneval Via Roma xe transennada (spetadori e transenne in Map086 e Map088). L'unico passagio xe el posto de bloco de Tubo: te ghe mostri el Libreto, el disi che el timbro xe storto e te sfida. Se te vinci la sfilata finissi e le transenne sparissi. Var 27 = 7.

### SCENA 5. (FATTA) - I bolli
Le 8 sfide xe sempre nela Palestra del Pacco (Map115). Ogni capopalestra xe in giro e te ga de andarlo a ciamar (vedi tabela soto). Lungo la strada:
- dopo 2 bolli Tubo te ferma al Vecio Squero (cantier soto sequestro)
- con 3 bolli i pescadori te lassa passar sul molo C. Colombo (Nane)
- con 4 bolli se toia la corda sule scale del Castel (Gigi) e Tubo te ferma su al Castel
- dopo 6 bolli Tubo te ferma in Via Roma
- facoltativo: i MULI DEL RION in Santa Lucia (Map113, 3 cali) no lassa passar fin che no te bati el capo; dentro ghe xe el Bar Santa Lucia (pokemon più rari)

### SCENA 6. (FATTA) - Super 4 e sindaco
Location = Castel de Muia (Map114). In ordine: Nerina, Capitan Ugo, Nona Gigia e TUBO (el più forte, livei 56-58). Dopo, el sindaco Pochibori.

### FINALE (FATTA)
Location = Molo dei Bersaglieri (Map022): el CONTROLOR del Delfin Verde. Prima el te ricorda l'ordinanza; dopo el sindaco te pol partir: saludi de Dei ian, Tubo e Pochibori, el viagio verso Trieste, "FIN". Se pol continuar a zogar e rivedar el finale.

### ROBE DE CONTORNO
- Mapa de Muia: la mama la dà la prima volta che te va KO (Map003).
- Case: 34 porte se verzi (interni Map123-127, chi che te trovi dipendi dala porta), le altre xe serade con frasi a caso. Lista in `Plugins/Muia Storia/005_Porte.rb`.
- Bar: Tendarossa (42: 26,2), Jimmy (42: 18,2), Santa Lucia (113: 11,11), Bar de Zuppo. Venditori de pokemon (anca leggendari), MT/MN, scambi. `006_Bar.rb`.
- Variabili e interuttori dela storia: var 27 trama, 29 lote con Tubo, 30 porta de casa, 31 bar; switch 81-88 (vedi `001_Base.rb`).

## DETTAGLI
### PALESTRE
In ordine de come che le se affronta: dall'ultima classificada alla vincitrice della sfilata 2026 del 72° Carneval. Ogni capopalestra no te sfida se no te ga el bollo de prima (el primo vol che te gabi passà el posto de bloco de Tubo). Squadre in PBS/trainers.txt, nomi provvisori.

| N. | Compagnia (posto 2026) | Tipo | Capopalestra | Livei | Dove (mapa) | Premio |
|---|---|---|---|---|---|---|
| 1 | La Bora (8°) | Volante | Bepi | 12-14 | Caliterna, edificio zalo/rosso: seconda porta venendo dal Mandracchio (Map081, 57,10) | MT40 Aeroassalto |
| 2 | Bellezze Naturali (7°) | Erba | Nives | 17-19 | Giardinetti D'Europa (Map096) | MT09 Semitraglia |
| 3 | Lampo (6°) | Elettro | Marieta | 22-24 | Vecchio Squero (Map083) | MT34 Ondashock |
| 4 | Brivido (5°) | Ghiaccio | Nane | 27-29 | Ricreatorio F. Penso (Map094) | MT72 Slavina |
| 5 | Mandrioi (4°) | Spettro | Gigi | 32-34 | Caliterna (Map081) | MT30 Palla Ombra |
| 6 | Ongia (3°) | Fuoco | Toni | 37-39 | Piazza della Repubblica (Map085) | MT35 Lanciafiamme |
| 7 | Trottola (2°) | Psico | Licia | 42-44 | Via Roma, vizin al museo Carà (Map086) | MT29 Psichico |
| 8 | Bulli e Pupe (1°) | Lotta | Pina | 47-50 | Mandracchio (Map076) | MT52 Focalcolpo |

Mape de dentro: Map115-Map122 (copia della palestra de esempio, con guida e capopalestra). Dopo l'ottava se impiza el switch 64 "Lega sbloccada".
I tipi xe sta sceglidi per compagnia (19/10). Nei PBS i capipalestra se ciama col nome della compagnia: LEADER_BORA, LEADER_BELLEZZE, LEADER_LAMPO, LEADER_BRIVIDO, LEADER_MANDRIOI, LEADER_ONGIA, LEADER_TROTTOLA, LEADER_BULLI.

### CASTEL
Castel de Muia (Map114), rifato sula foto de Google Maps: mastio quadrato coi merli (portòn ad arco, finestre ad arco), mura che vien su dala Porta medievale, scalinata tra le mura e la vila alta, punto panoramico coi pini e le panchine, parcheggio a destra e verde sula colina.
Se riva dale scale tra Mandracchio_2 (Map043, 44,4) e Circolo della Vela (Map079, 0-1,4); tornando zo se riva in Circolo della Vela (0,6). El portòn xe serà: bon posto per i Super 4 e el sindaco.
La grafica del mastio e dele mura xe in fondo a `Outside_V7.png` (9 righe nove, tile 4528-4599).

### CASA DEL ZOGADOR
La casa (Map003, dove se torna quando i pokemon va KO) xe in Cul de Nave (Map087), porta in (7,9).

### LEGA E FINAL (plugin Muia Mondo)
Dopo l'otavo bollo (switch 64) al Castel de Muia (Map114) davanti al portòn ghe xe i Super 4 (Nerina, Capitan Ugo, Nona Gigia, Tubo, livei 52-58) e el sindaco Pochibori (58-60). Se bati uno ala volta, in ordine; se te perdi no se ricomincia da capo. Batù el Sindaco: Sala d'Onore e fine.
Vecie che cura, market, alenadori de strada e Banditor no xe nele mape .rxdata: i xe in `Plugins/Muia Mondo/script.rb` (liste con ID, mapa, x, y).
