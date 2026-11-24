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
  GRAFICA_VECIA = "trainer_VECIA"
  GRAFICA_MARKET = "NPC 16"

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
    [921,  42, 27,  5, :tabachin, "NPC 16", 2],   # Tabachin de fronte al Comun
    [922, 105, 10, 20, :botega,   "NPC 16", 2],   # Botega de Via Mazzarei
    [923, 100, 16,  9, :grande,   "NPC 16", 2]    # Magazin Grande de Via Singolo
  ]

  # [ID, mapa, x, y, tipo, nome, squadra [[specie, livel]...], frase prima, frase dopo]
  ALENADORI = [
    # Caliterna: prima dela palestra 1 (Volante, 12-14)
    [941, 81, 20,  8, :YOUNGSTER,  "Mattia",  [[:PIDGEY, 8], [:RATTATA, 9]],
     "Ocio, mulo! Anche mi go le mie bestie, vara!", "Va ben, va ben... te son più bravo de mi."],
    [942, 81, 45, 10, :LASS,       "Giulia",  [[:WINGULL, 10], [:PIKIPEK, 10]],
     "In Caliterna tira sempre vento: i mii uccei xe abituadi!", "Mona mi a sfidarte..."],
    # Calli: tra palestra 1 e 3
    [943, 89, 10, 14, :BUGCATCHER, "Nicolò",  [[:CATERPIE, 11], [:WEEDLE, 11], [:VENIPEDE, 12]],
     "Nele calli se trova le bestiole più bele!", "Le mie bestiole ga bisogno de riposar."],
    [944, 89, 24, 14, :PICNICKER,  "Elisa",   [[:BUNEARY, 13], [:SKITTY, 13]],
     "Te passi per la mia cale? Prima te ga de bater mi!", "Bon, passa pur."],
    [945, 90, 12, 12, :CAMPER,     "Luca",    [[:GEODUDE, 13], [:ROLYCOLY, 14]],
     "Calle Parini xe tuta sassi, come i mii pokemon!", "Me son sgretolà..."],
    [946, 91, 10, 12, :HIKER,      "Franco",  [[:ROGGENROLA, 14], [:ONIX, 15]],
     "Su e zo per 'ste cale go le gambe de fero!", "Mejo che torno in osmiza."],
    [947, 93, 15,  7, :BLACKBELT,  "Stefano", [[:MACHOP, 15], [:MAKUHITA, 16]],
     "La Salita dele Mura me la fazo tuti i giorni de corsa!", "Ahia... oggi no xe giornada."],
    # Giardinetti: prima dela palestra 2 (Erba, 17-19)
    [948, 96,  6, 22, :AROMALADY,  "Sara",    [[:ODDISH, 15], [:BELLSPROUT, 15], [:FOMANTIS, 16]],
     "Senti che profumo i mii fiori!", "Che pecà, i fiori se ga sfiorì."],
    [949, 96, 20,  6, :BUGCATCHER, "Tommaso", [[:BUTTERFREE, 16], [:COMBEE, 16], [:NINCADA, 17]],
     "I Giardinetti xe pieni de bestie: le go ciapade tute!", "Torno a cercarghe nel'erba."],
    # Vecio Squero: prima dela palestra 3 (Elettro, 22-24)
    [950, 83, 10,  6, :SAILOR,     "Bruno",   [[:TENTACOOL, 19], [:KRABBY, 20], [:WINGULL, 20]],
     "Al Squero se riparava le barche. Mi riparo i pokemon dopo che li bato!", "Me toca riparar la mia barca, desso."],
    # Ricreatorio: prima dela palestra 4 (Ghiaccio, 27-29)
    [951, 94, 11,  8, :COOLTRAINER_M, "Davide", [[:SNORUNT, 24], [:SPHEAL, 25], [:MANKEY, 25]],
     "Al Ricreatorio se zoga, ma mi zogo sul serio!", "Bel, te me ga fato sudar."],
    # Caliterna: prima dela palestra 5 (Spettro, 32-34)
    [952, 81, 72, 15, :CHANNELER,  "Ondina",  [[:MISDREAVUS, 29], [:SHUPPET, 29], [:HAUNTER, 31]],
     "Dopo mezanote in Caliterna se senti robe strane...", "I spiriti se ga calmà."],
    # Piazza dela Repubblica: prima dela palestra 6 (Fogo, 37-39)
    [953, 85, 10,  8, :BIKER,      "Rico",    [[:GROWLITHE, 33], [:PONYTA, 34], [:SANDSLASH, 34]],
     "Rombo rombo! Me piasi el fogo!", "Me se ga spento el motor."],
    # Via Roma: prima dela palestra 7 (Psico, 42-44)
    [954, 86, 10,  8, :PSYCHIC_F,  "Licia Jr.", [[:KADABRA, 38], [:GIRAFARIG, 39], [:MEDITITE, 39]],
     "Go za visto come che finirà... o forsi no.", "No lo gavevo previsto!"],
    # Mandracchio: prima dela palestra 8 (Lota, 47-50)
    [955, 76, 10,  7, :FISHERMAN,  "Bepi Pescador", [[:GYARADOS, 43], [:SEAKING, 44], [:CLOYSTER, 44]],
     "Qua al Mandracchio pesco solo pokemon grossi!", "Oggi no ciapa gnente."],
    [956, 76, 30,  7, :BLACKBELT,  "Nino",    [[:MACHOKE, 45], [:HITMONTOP, 45], [:PRIMEAPE, 46]],
     "Pina me ga alenà: prima de ela te ga de passar de mi!", "Va', che Pina te speta."]
  ]

  # Lega del Castel: [ID, x, y, tipo, nome, squadra, frase prima, frase dopo]
  LEGA_MAPA = 114
  LEGA = [
    [961, 21, 13, :ELITEFOUR_Lorelei, "Nerina dei Super 4",
     [[:LAPRAS, 52], [:DEWGONG, 52], [:SLOWBRO, 53], [:CLOYSTER, 53], [:JYNX, 54]],
     "Son la prima dei Super 4. El mar de Muja xe con mi!", "Te son forte. Va' avanti."],
    [962, 24, 13, :ELITEFOUR_Bruno, "Marco dei Super 4",
     [[:ONIX, 53], [:HITMONCHAN, 53], [:HITMONLEE, 54], [:GOLEM, 54], [:MACHAMP, 55]],
     "Mi son la seconda muraglia del Castel!", "Le mie muscolature se ga arese."],
    [963, 27, 13, :ELITEFOUR_Agatha, "Nona Gigia dei Super 4",
     [[:GENGAR, 54], [:MISMAGIUS, 54], [:DUSKNOIR, 55], [:CHANDELURE, 55], [:GENGAR, 56]],
     "Go visto passar sete sindaci, mulo. Desso vedemo ti.", "Ah, i zoveni de oggi..."],
    [964, 31, 13, :ELITEFOUR_Lance, "Capitan Ugo dei Super 4",
     [[:GYARADOS, 55], [:DRAGONAIR, 55], [:AERODACTYL, 56], [:SALAMENCE, 56], [:DRAGONITE, 57]],
     "Son l'ultimo dei Super 4. Dopo de mi ghe xe solo el Sindaco.", "Te ga el cuor de un vero muiesan."]
  ]
  SINDACO = [965, 22, 11, :CHAMPION, "el Sindaco",
    [[:PIDGEOT, 58], [:ALAKAZAM, 58], [:RHYPERIOR, 58], [:ARCANINE, 59], [:STARMIE, 59], [:CHARIZARD, 60]],
    "Te pensi de esser meio de mi? Vedemo se te ga fato esperienza!",
    "No ghe credo... Muja ga un novo sindaco!"]

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
    ALENADORI.each do |id, m, x, y, tipo, *_resto|
      next if m != map_id
      metti(map, evento(id, x, y, grafica_alenador(tipo), "MuiaMondo.alenador(#{id})"))
    end
    if map_id == LEGA_MAPA
      LEGA.each do |id, x, y, tipo, *_resto|
        metti(map, evento(id, x, y, grafica_alenador(tipo), "MuiaMondo.lega(#{id})"))
      end
      id, x, y = SINDACO
      metti(map, evento(id, x, y, "trainer_POLIDORI", "MuiaMondo.sindaco"))
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
      pkmn = Pokemon.new(specie, livel, alenador)
      alenador.party.push(pkmn)
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

  def self.alenador(id)
    dati = ALENADORI.find { |a| a[0] == id }
    return if !dati
    _id, _m, _x, _y, tipo, nome, squadra, prima, dopo = dati
    lota(id, tipo, nome, squadra, prima, dopo)
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
      pbMessage(_INTL("{1}: Torna quando te gavarà tute e oto le medaje dele compagnie del Carneval.", nome))
      return
    end
    indice = LEGA.index(dati)
    if indice > 0 && !batù?(LEGA[indice - 1][0], LEGA_MAPA)
      pbMessage(_INTL("{1}: Prima te ga de bater {2}.", nome, LEGA[indice - 1][4]))
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
      pbMessage(_INTL("Dejan: Te ghe la ga fata! Te son el novo sindaco de Muja!"))
      pbHallOfFameEntry
      pbMessage(_INTL("FINE... per desso! Grazie de gaver zogà a Pokémon Muia."))
    end
  end
end

EventHandlers.add(:on_game_map_setup, :muia_mondo,
  proc { |map_id, map, _tileset|
    MuiaMondo.zonta(map_id, map)
  }
)
