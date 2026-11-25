#===============================================================================
# Muia - Mondo: vecie che cura, market, alenadori de strada e Lega del Castel
#
# I personaggi de 'sto plugin NO i xe dentro i file Data/MapXXX.rxdata: i vien
# zontadi alla mapa quando la se carica (EventHandler :on_game_map_setup).
# Cussì no se toca i file binari dele mape (che no se pol unir con git) e chi
# che lavora in RPG Maker sule mape no ga conflitti.
#
# Come zontar un personaggio: una riga nela lista giusta qua soto.
#   - ID: numeri dal 901 in su, MAI riusar o rinumerar un ID (i salvataggi
#     ricorda chi te ga batù tramite l'interuttor locale "A" de [mapa, ID]).
#   - Se una casela xe sbagliada (personaggio dentro un muro), basta cambiar
#     x e y.
#   - Se in RPG Maker se zonta un evento con lo stesso ID, vinci quel de RPG
#     Maker e questo no vien zontà.
#===============================================================================
module MuiaMondo
  GRAFICA_VECIA = "NPC 14"   # signora coi cavei grisi, uguale per tute

  # [ID, mapa, x, y, nome per i messagi]
  VECIE = [
    [901,  96,  8, 10, "Siora Nives dei Giardinetti"],
    [902,  42, 46,  6, "Siora Pina dela Piazza"],
    [903,  81, 30,  9, "Siora Gema de Caliterna"],
    [904, 109, 13, 17, "Siora Bruna de Borgolauro"],
    [905, 106, 10, 30, "Siora Maria del Viale"],
    [906,  98, 15,  9, "Siora Rosa de San Giovanni"]
  ]

  # [ID, mapa, x, y, tipo, grafica, direzion]
  MARKET = [
    [921,  42, 27,  5, :tabachin, "NPC 15", 2],   # Tabachin de fronte al Comun
    [922, 105, 10, 20, :botega,   "NPC 15", 2],   # Botega de Via Mazzarei
    [923, 100, 16,  9, :grande,   "NPC 15", 2]    # Magazin Grande de Via Singolo
  ]

  # Alenadori de strada, piazzai secondo la storia.
  # [ID, mapa, x, y, tipo, nome, specie, frase prima, frase dopo, [trama minima, medaje minime]]
  # I livei NO i xe fissi: ogni pokemon xe tra 4 soto e 2 sora el to più forte
  # (vedi LIVEL_SOTO/LIVEL_SORA), e se el livel xe alto el vien za evolù.
  # Un alenador compar solo quando la storia xe rivada al punto giusto.
  LIVEL_SOTO = 4
  LIVEL_SORA = 2
  ALENADORI = [
    # --- Centro storico, dopo la prima lota con Tubo ---
    [957, 76, 10, 7, :YOUNGSTER, "Mulo Kevin", [:RATTATA, :ZIGZAGOON],
     "Ti te son el foresto? Mi son el mulo più forte del Mandracchio! ...Dopo Pina. E dopo mio fradel.",
     "Bon, bon. Ma no sta dirghe a mio fradel.", [5, 0]],
    [941, 81, 20,  8, :YOUNGSTER,  "Mattia", [:PIDGEY, :SPEAROW],
     "I mii uccei vola sora Caliterna da quando i xe nati. Ti, inveze, te son pena sbarcà!",
     "Va ben, va ben... te son più bravo de mi.", [5, 0]],
    [942, 81, 45, 10, :LASS,       "Giulia",  [:WINGULL, :PIKIPEK],
     "In Caliterna tira sempre vento: i mii uccei xe abituadi. E ti, foresto, te xe abituà ala bora?",
     "Mona mi a sfidarte...", [5, 0]],
    [943, 89, 10, 14, :BUGCATCHER, "Nicolò",  [:CATERPIE, :WEEDLE, :VENIPEDE],
     "Nele cali se trova le bestiole più bele! Anca i foresti, ogni tanto.",
     "Le mie bestiole ga bisogno de riposar.", [5, 0]],
    [944, 89, 24, 14, :PICNICKER,  "Elisa",   [:BUNEARY, :SKITTY],
     "Te passi per la mia cale? Qua i foresti paga el pedagio: una lota!",
     "Bon, passa pur. Gratis, per stavolta.", [5, 0]],
    [958, 87, 10, 13, :CAMPER,     "Ivan",    [:POOCHYENA, :HOOTHOOT],
     "Cul de Nave xe el posto più bel de Muia. Per forza: ghe abito mi!",
     "Te pol abitarghe anche ti, va ben. Ma solo de giorno.", [5, 0]],
    # --- Dopo el posto de bloco de Tubo ---
    [945, 90, 12, 12, :CAMPER,     "Luca",    [:GEODUDE, :ROLYCOLY],
     "Calle Parini xe tuta sassi, come i mii pokemon! E come la testa de Tubo.",
     "Me son sgretolà...", [7, 0]],
    [946, 90, 21, 12, :HIKER,      "Franco",  [:ROGGENROLA, :ONIX],
     "Su e zo per 'ste cale go le gambe de fero! Ti, foresto, te ga za el fià grosso?",
     "Mejo che torno in osmiza.", [7, 0]],
    [947, 93, 15,  7, :BLACKBELT,  "Stefano", [:MACHOP, :MAKUHITA],
     "La Salita dele Mure me la fazo tuti i giorni de corsa! Desso che Tubo ga tolto el bloco, xe tuta mia.",
     "Ahia... oggi no xe giornada.", [7, 0]],
    [959, 92, 30,  8, :BIKER,      "Rico",    [:GRIMER, :KOFFING, :GROWLITHE],
     "Via Roma xe verta! Finalmente posso tornar a far rumor col motorin!",
     "Me se ga spento el motor.", [7, 0]],
    [960, 97, 20, 35, :COOLTRAINER_M, "Davide", [:SNORUNT, :SPHEAL, :MANKEY],
     "Te va al Pacco a sfidar le compagnie? Prima fa' un fià de alenamento con mi!",
     "Bel, te me ga fato sudar. Va', che Bepi te speta.", [7, 0]],
    # --- Porto San Rocco (dopo el posto de bloco) ---
    [969, 128, 10, 22, :SAILOR,    "Marinaio Dario", [:WINGULL, :TENTACOOL, :KRABBY],
     "In marina se lavora, mulo, no se fa turismo! Ma una lota la fazo volentieri.",
     "Torno a lustrar el yacht del paron.", [7, 0]],
    [970, 128, 30, 3, :PICNICKER,  "Chiara",  [:HOPPIP, :SUNKERN, :SKITTY],
     "Su la colina sora Porto San Rocco se vedi tuto el golfo. E anca i foresti che riva!",
     "Bela lota. Ciapa el sol, che te son palido.", [7, 0]],
    # --- Dopo el primo bollo: Giardinetti (Nives) ---
    [948, 96,  6, 22, :AROMALADY,  "Sara",    [:ODDISH, :BELLSPROUT, :FOMANTIS],
     "Nives xe vignuda a bagnar le rose. Mi inveze bagno i foresti!",
     "Che pecà, i fiori se ga sfiorì.", [7, 1]],
    [949, 96, 20,  6, :BUGCATCHER, "Tommaso", [:BUTTERFREE, :COMBEE, :NINCADA],
     "I Giardinetti xe pieni de bestie: le go ciapade tute! Manca solo un foresto.",
     "Torno a cercarghe nel'erba.", [7, 1]],
    # --- Muggia Vecia (dopo el secondo bollo) ---
    [971, 129,  5, 11, :HIKER,      "Escursionista Bruno", [:GEODUDE, :NIDORAN_M, :SANDSHREW],
     "Son vignù su a piedi da Muia. Tre ore. Ma vuto meter la vista? E la lota dopo?",
     "Desso me toca tornar zo. A piedi. Altre tre ore.", [7, 2]],
    [972, 129, 24, 11, :BIRDKEEPER, "Ornitologa Lia", [:PIDGEOTTO, :STARLY, :HOOTHOOT],
     "Qua su i uccei vola sora la basilica da mile ani. I mii, da tre settimane.",
     "I mii uccei va a riposarse sul campanil.", [7, 2]],
    # --- Dopo el secondo: Vecio Squero (Marieta) ---
    [950, 83, 10,  6, :SAILOR,     "Bruno",   [:TENTACOOL, :KRABBY, :WINGULL],
     "Al Squero se riparava le barche. Mi riparo i foresti dopo che li bato!",
     "Me toca riparar la mia barca, desso.", [7, 2]],
    # --- Dopo el terzo: Molo C. Colombo (Nane) ---
    [967, 78, 20,  3, :FISHERMAN,  "Pescador Gino", [:MAGIKARP, :TENTACOOL, :HORSEA],
     "Te ga passà i pescadori in cima al molo? Alora te ga i bolli giusti. Vedemo se te ga anche la cana!",
     "Oggi no ciapa gnente. Gnanca le lote.", [7, 3]],
    [968, 78, 40,  4, :SWIMMER_F,  "Ariana",  [:STARYU, :GOLDEEN, :WINGULL],
     "Nodo dal molo C. Colombo fin a Trieste ogni estate. Per tornar ciapo el Delfin, come ti. Ah, no, ti no te pol!",
     "Me ga vignù un crampo...", [7, 3]],
    # --- Dopo el quarto: Castel (Gigi) ---
    [952, 114, 25, 19, :CHANNELER, "Ondina",  [:MISDREAVUS, :SHUPPET, :GASTLY],
     "Dopo mezanote al Castel se senti robe strane... Anche de giorno, a dir la verità.",
     "I spiriti se ga calmà.", [7, 4]],
    # --- Dopo el quinto e el sesto: Piazza dela Repubblica, Ricreatorio, Via Roma ---
    [953, 85, 10,  8, :BIKER,      "Rico Senior", [:GROWLITHE, :PONYTA, :SANDSHREW],
     "Rombo rombo! Toni dela Ongia el xe mio amigo de spritz. Prima de lu, te bevi mi!",
     "Me se ga spento el motor.", [7, 5]],
    [951, 94, 11,  8, :COOLTRAINER_F, "Martina", [:SNOVER, :SWINUB, :MANKEY],
     "Al Ricreatorio se zoga, ma mi zogo sul serio! Anca coi foresti.",
     "Bel, te me ga fato sudar.", [7, 5]],
    [954, 86, 10,  8, :PSYCHIC_F,  "Licia Jr.", [:ABRA, :GIRAFARIG, :MEDITITE],
     "Go za visto come che finirà... o forsi no. Ti te diventi sindaco? Le carte disi: 'mah'.",
     "No lo gavevo previsto!", [7, 6]],
    # --- Dopo el setimo: Mandracchio (Pina) ---
    [955, 76, 30,  7, :FISHERMAN,  "Bepi Pescador", [:MAGIKARP, :SEAKING, :SHELLDER],
     "Qua al Mandracchio pesco solo pokemon grossi! E stasera, un foresto.",
     "Oggi no ciapa gnente.", [7, 7]],
    [956, 76, 45, 10, :BLACKBELT,  "Nino",    [:MACHOP, :TYROGUE, :MANKEY],
     "Pina me ga alenà: prima de ela te ga de passar de mi! Cento flessioni e una lota.",
     "Va', che Pina te speta.", [7, 7]]
  ]

  # Lega del Castel: [ID, x, y, tipo, nome, squadra, frase prima, frase dopo]
  LEGA_MAPA = 114
  LEGA = [
    [961, 21, 13, :ELITEFOUR_Lorelei, "Nerina dei Super 4",
     [[:LAPRAS, 52], [:DEWGONG, 52], [:SLOWBRO, 53], [:CLOYSTER, 53], [:JYNX, 54]],
     "Son la prima dei Super 4. El mar de Muja xe con mi!", "Te son forte. Va' avanti."],
    [962, 24, 13, :ELITEFOUR_Lance, "Capitan Ugo dei Super 4",
     [[:GYARADOS, 53], [:DRAGONAIR, 53], [:AERODACTYL, 54], [:KINGDRA, 54], [:SALAMENCE, 55]],
     "Go navigà sete mari e go visto sete draghi. Ti te sarà l'otavo?", "Te ga el cuor de un vero muiesan."],
    [963, 27, 13, :ELITEFOUR_Agatha, "Nona Gigia dei Super 4",
     [[:GENGAR, 54], [:MISMAGIUS, 54], [:DUSKNOIR, 55], [:CHANDELURE, 55], [:GENGAR, 56]],
     "Go visto passar sete sindaci, mulo. Desso vedemo ti.", "Ah, i zoveni de oggi..."],
    [964, 31, 13, :TUBO, "Tubo dei Super 4", :tubo,
     "Te lo gavevo dito che ghe iera uno che te conossevi ben! Ultimo dei Super 4: TUBO, Polizia Locale!",
     "...Va ben. Te ga vinto. Va' dal sindaco. Ma prima... fame un autografo. Per mio cugin."]
  ]
  SINDACO = [965, 22, 11, :CHAMPION, "el Sindaco Pochibori",
    [[:PIDGEOT, 58], [:ALAKAZAM, 58], [:RHYPERIOR, 58], [:ARCANINE, 59], [:STARMIE, 59], [:CHARIZARD, 60]],
    "Te ricordi? 'Te pensi de esser meio de mi?' Desso vedemo se te ga fato esperienza!",
    "No ghe credo... Muja ga un novo sindaco!"]

  # Banditor in Piazza Marconi: el te disi dove andar in base ale medaje
  BANDITOR = [966, 42, 29, 10, "NPC 01"]
  CONSIGLI = [
    "La prima sfida xe nela Palestra Pacco, in Via Gabriele D'annunzio. Bepi dela Bora te speta dentro.",
    "Nives dele Bellezze Naturali la xe ai Giardinetti D'Europa: trovila e la tornerà in palestra.",
    "Marieta dela Lampo la xe al Vecio Squero, a cercar dove che ga saltà la corente.",
    "Nane del Brivido el pesca in Punta Molo C. Colombo: i pescadori desso te lassa passar.",
    "Gigi dei Mandrioi el se sconde al Castel de Muia, su per le scale tra Mandracchio e Circolo dela Vela.",
    "Toni dela Ongia el bevi el spritz in Piazza dela Repubblica.",
    "Licia dela Trottola la xe in Via Roma, vizin al museo Carà.",
    "Pina dei Bulli e Pupe la se alena al Mandracchio.",
    "Te ga tuti e oto i bolli! Va' al Castel de Muia: là te speta i Super 4 e el sindaco Pochibori."
  ]

  def self.banditor
    pbMessage(_INTL("BANDITOR: Sentì, sentì! Novità de Muja!"))
    if $game_variables[27] < 4
      pbMessage(_INTL("BANDITOR: Ti te son quel novo? Prima va' parlar col sindaco in Comun e con Fulvio."))
    elsif $game_variables[27] < 7
      pbMessage(_INTL("BANDITOR: Per via dela sfilata Via Roma xe transennada. Siora Ornella del Comun xe in Bar de Zuppo, e Tubo fa el posto de bloco in cima a Calle Parini."))
    elsif batù?(SINDACO[0], LEGA_MAPA)
      pbMessage(_INTL("BANDITOR: Viva el novo sindaco de Muja! Viva! E el Delfin Verde xe pronto in Molo dei Bersaglieri!"))
    else
      pbMessage(_INTL("BANDITOR: {1}", CONSIGLI[[$player.badge_count, 8].min]))
      pbMessage(_INTL("BANDITOR: Se te ga i pokemon strachi, le vecie de Muja te li cura. Per comprar roba ghe xe el tabachin qua de fronte."))
    end
  end

  #-----------------------------------------------------------------------------
  # Creazion dei eventi
  #-----------------------------------------------------------------------------
  def self.evento(id, x, y, grafica, comando, direzion = 2)
    ev = RPG::Event.new(x, y)
    ev.id   = id
    ev.name = "Muia Mondo #{id}"
    pagina = ev.pages[0]
    pagina.graphic.character_name = grafica
    pagina.graphic.direction      = direzion
    pagina.trigger   = 0    # se parla col tasto de azion: nissun te ferma
    pagina.move_type = 0
    pagina.list = [RPG::EventCommand.new(355, 0, [comando]),
                   RPG::EventCommand.new(0, 0, [])]
    return ev
  end

  def self.metti(map, ev)
    return if map.events[ev.id]   # un evento fato in RPG Maker vinci sempre
    map.events[ev.id] = ev
  end

  def self.zonta(map_id, map)
    VECIE.each do |id, m, x, y, _nome|
      next if m != map_id
      metti(map, evento(id, x, y, GRAFICA_VECIA, "MuiaMondo.vecia(#{id})"))
    end
    MARKET.each do |id, m, x, y, _tipo, grafica, dir|
      next if m != map_id
      metti(map, evento(id, x, y, grafica, "MuiaMondo.market(#{id})", dir))
    end
    ALENADORI.each do |id, m, x, y, tipo, *_resto, cond|
      next if m != map_id
      next if !alenador_visibile?(cond)
      metti(map, evento(id, x, y, grafica_alenador(tipo), "MuiaMondo.alenador(#{id})"))
    end
    if map_id == BANDITOR[1]
      id, _m, x, y, grafica = BANDITOR
      metti(map, evento(id, x, y, grafica, "MuiaMondo.banditor"))
    end
    if map_id == LEGA_MAPA
      LEGA.each do |id, x, y, tipo, *_resto|
        metti(map, evento(id, x, y, grafica_alenador(tipo), "MuiaMondo.lega(#{id})"))
      end
      id, x, y = SINDACO
      metti(map, evento(id, x, y, "trainer_POLIDORI", "MuiaMondo.sindaco"))   # grafica del sindaco Pochibori
    end
  end

  def self.grafica_alenador(tipo)
    nome = "trainer_#{tipo}"
    return nome if pbResolveBitmap("Graphics/Characters/" + nome)
    return "NPC 01"
  end

  #-----------------------------------------------------------------------------
  # Vecie che cura
  #-----------------------------------------------------------------------------
  def self.vecia(id)
    nome = VECIE.find { |v| v[0] == id }&.at(4) || "Siora"
    pbMessage(_INTL("{1}: Oh, povero mulo, i tui pokemon xe tuti strachi!", nome))
    if pbConfirmMessage(_INTL("Te vol che te li meto a posto mi, come al Centro Pokémon?"))
      pbMEPlay("Pkmn healing")
      $player.heal_party
      pbWait(1.5)
      pbMessage(_INTL("Ecco qua, i xe come novi! Un toco de strucolo e via."))
      pbMessage(_INTL("Torna quando te vol, mi son sempre qua."))
    else
      pbMessage(_INTL("Come te vol. Ma no sta strussiarli massa!"))
    end
  end

  #-----------------------------------------------------------------------------
  # Market: la roba in vendita cressi con le medaje
  #-----------------------------------------------------------------------------
  def self.roba(tipo)
    medaje = $player.badge_count
    lista = [:POKEBALL, :POTION, :ANTIDOTE, :PARALYZEHEAL, :AWAKENING, :REPEL]
    lista += [:GREATBALL, :SUPERPOTION, :BURNHEAL, :ICEHEAL, :ESCAPEROPE] if medaje >= 2 || tipo == :grande
    lista += [:HYPERPOTION, :SUPERREPEL, :REVIVE, :FULLHEAL] if medaje >= 4
    lista += [:ULTRABALL, :MAXREPEL] if medaje >= 5
    lista += [:MAXPOTION] if medaje >= 6
    lista += [:FULLRESTORE] if medaje >= 7
    lista += [:NETBALL, :DIVEBALL, :NESTBALL, :REPEATBALL, :TIMERBALL, :XATTACK, :XDEFENSE, :XSPEED] if tipo == :grande
    return lista.uniq.select { |i| GameData::Item.exists?(i) }
  end

  def self.market(id)
    tipo = MARKET.find { |m| m[0] == id }&.at(4) || :botega
    case tipo
    when :tabachin
      pbMessage(_INTL("Benvignù in tabachin! Sigarete no te ne vendo, ma Poké Ball sì."))
    when :grande
      pbMessage(_INTL("Benvignù al Magazin Grande de Via Singolo! Qua ghe xe de tuto."))
    else
      pbMessage(_INTL("Bondì! Cossa te serve?"))
    end
    pbPokemonMart(roba(tipo))
  end

  #-----------------------------------------------------------------------------
  # Alenadori: la lota parti SOLO se te ghe parli ti
  #-----------------------------------------------------------------------------
  def self.batù?(id, map_id = $game_map.map_id)
    return $game_self_switches[[map_id, id, "A"]]
  end

  def self.segna_batù(id, map_id = $game_map.map_id)
    $game_self_switches[[map_id, id, "A"]] = true
    $game_map.need_refresh = true
  end

  def self.fa_alenador(tipo, nome, squadra, frase_dopo)
    alenador = NPCTrainer.new(nome, tipo)
    squadra.each do |specie, livel|
      next if !GameData::Species.exists?(specie)
      alenador.party.push(MuiaStoria.fa_pokemon(specie, livel, alenador))
    end
    alenador.lose_text = frase_dopo
    return alenador
  end

  def self.lota(id, tipo, nome, squadra, prima, dopo)
    if batù?(id)
      pbMessage(_INTL("{1}: {2}", nome, dopo))
      return true
    end
    pbMessage(_INTL("{1}: {2}", nome, prima))
    return false if !pbConfirmMessage(_INTL("Te vol lotar con {1}?", nome))
    alenador = fa_alenador(tipo, nome, squadra, dopo)
    vinto = TrainerBattle.start(alenador)
    segna_batù(id) if vinto
    return vinto
  end

  def self.alenador_visibile?(cond)
    return true if !cond.is_a?(Array)
    trama = $game_variables[27] || 0
    return trama >= cond[0] && $player.badge_count >= cond[1]
  end

  # Squadra de un alenador de strada: livei vizin al to pokemon più forte
  def self.squadra_scalada(specie)
    max = MuiaStoria.livel_max
    return specie.map { |sp| [sp, max - LIVEL_SOTO + rand(LIVEL_SOTO + LIVEL_SORA + 1)] }
  end

  def self.alenador(id)
    dati = ALENADORI.find { |a| a[0] == id }
    return if !dati
    _id, _m, _x, _y, tipo, nome, specie, prima, dopo = dati
    lota(id, tipo, nome, squadra_scalada(specie), prima, dopo)
  end

  #-----------------------------------------------------------------------------
  # Lega: Super 4 e Sindaco al Castel (dopo l'otava medaja, switch 64)
  #-----------------------------------------------------------------------------
  LEGA_SWITCH = 64

  def self.lega_verta?
    return $game_switches[LEGA_SWITCH] || $player.badge_count >= 8
  end

  def self.lega(id)
    dati = LEGA.find { |a| a[0] == id }
    return if !dati
    _id, _x, _y, tipo, nome, squadra, prima, dopo = dati
    if !lega_verta?
      pbMessage(_INTL("{1}: Torna quando te gavarà tuti e oto i bolli dele compagnie del Carneval.", nome))
      return
    end
    indice = LEGA.index(dati)
    if indice > 0 && !batù?(LEGA[indice - 1][0], LEGA_MAPA)
      pbMessage(_INTL("{1}: Prima te ga de bater {2}.", nome, LEGA[indice - 1][4]))
      return
    end
    if squadra == :tubo
      MuiaStoria.lega_tubo(id, nome, prima, dopo)
      return
    end
    lota(id, tipo, nome, squadra, prima, dopo)
  end

  def self.sindaco
    id, _x, _y, tipo, nome, squadra, prima, dopo = SINDACO
    if batù?(id, LEGA_MAPA)
      pbMessage(_INTL("{1}: Desso el sindaco de Muja te son ti. Trieste te speta, se te vol tornar.", nome))
      return
    end
    if !lega_verta? || !LEGA.all? { |a| batù?(a[0], LEGA_MAPA) }
      pbMessage(_INTL("{1}: El porton del Castel xe serà. Prima bati i Super 4, dopo parlemo.", nome))
      return
    end
    pbMessage(_INTL("{1}: {2}", nome, prima))
    return if !pbConfirmMessage(_INTL("Te son pronto per la lota finale?"))
    alenador = fa_alenador(tipo, nome, squadra, dopo)
    if TrainerBattle.start(alenador)
      segna_batù(id)
      pbMessage(_INTL("{1}: Va ben, va ben. Muja xe tua.", nome))
      pbMessage(_INTL("FULVIO: Te ghe la ga fata! Te son el novo sindaco de Muja!"))
      pbMessage(_INTL("SINDACO POCHIBORI: Firma qua... e qua. L'ordinanza xe tua: el Delfin Verde te speta in Molo dei Bersaglieri."))
      MuiaStoria.aggiorna rescue nil
      pbHallOfFameEntry
      pbMessage(_INTL("Desso te pol tornar a Trieste col Delfin Verde... o restar a Muia quanto che te vol."))
    end
  end
end

EventHandlers.add(:on_game_map_setup, :muia_mondo,
  proc { |map_id, map, _tileset|
    MuiaMondo.zonta(map_id, map)
  }
)
