#===============================================================================
# Muia - Storia: porte, case e interni
#
# Ogni porta disegnada sule mape de Muia (tile 1993, 2026, 2014, 2065) diventa
# un evento: la maggior parte xe serade (con una frase a caso), qualcheduna
# porta dentro una casa. Le case dopra 5 interni (mape 123-127, copiade dale
# case dela demo): chi che te trovi dentro dipendi dala porta de dove te son
# entrà. Quando te esci, te torni davanti ala stessa porta (variabile 30).
#===============================================================================
module MuiaStoria
  TILE_PORTE = [1993, 2026, 2014, 2065]
  MAPE_FORA  = (22..113).to_a + [114, 128, 129]

  # Interni: [mapa, x de entrada, y de entrada, x porta de uscida, y porta de uscida]
  INTERNI = {
    123 => [3, 8, 3, 9],
    124 => [6, 7, 6, 8],
    125 => [4, 7, 4, 8],
    126 => [5, 10, 5, 11],
    127 => [6, 9, 6, 10]
  }

  # Personagi dentro le case: chiave => [interno, [[x, y, grafica, dir, [frasi], regalo], ...]]
  # regalo: :OGETO, [:OGETO, quantità], o [:OGETO, quantità, medaje minime]
  CASE = {
    piazza_sindacheto: [123, [[8, 6, "NPC 13", 2, [
      "Mi son el vice-sindaco. Cioè, el vice del vice. Insoma, fazo le fotocopie.",
      "Pochibori xe un bon omo, ma el ga una passion per le ordinanze. L'ultima: proibì fis-ciar dopo le diese.",
      "Ciol 'sta roba, me la ga lassada un triestin l'ano passà. Anca lu el xe ancora qua."], [:POTION, 3]]]],
    piazza_nona: [124, [[7, 6, "NPC 11", 4, [
      "Ah, el foresto! Vien, vien, sentite. Te vol un toco de presnitz?",
      "Mio marì el iera de Trieste. Sessanta ani a Muia e i lo ciamava ancora 'el foresto'.",
      "Ma no sta preocuparte: dopo i primi cinquanta ani i te ciapa in simpatia."], :SITRUSBERRY]]],
    cale_bortolo: [123, [[2, 6, "NPC 17", 6, [
      "Son el nono Bortolo, giardinier de Muia da quando che Tito iera ancora in fasse.",
      "Te vedi quei alberi che sbara le cali? Con un pokemon che sa TAJAR te li tiri zo in un fià.",
      "Ciol, xe la MN del Tajo. Ma ocio: el Tajo funziona fora dela bataia solo se te ga almeno un bollo."], [:HM01, 1]]]],
    cale_gemelle: [125, [[2, 6, "NPC 23", 6, [
      "Mi e mia sorela gavemo fato una scomessa: chi trova prima un Pokémon raro nel'erba.",
      "Ela xe andada in Caliterna. Mi son restada a casa. Vinzo mi: el raro xe el divan."]],
      [8, 6, "NPC 22", 4, ["...Ela ga bara. Go visto un Hoothoot de note in Calle Parini, e lu xe rarissimo."]]]],
    cale_pescador: [124, [[2, 3, "trainer_FISHERMAN", 2, [
      "Se te vol pescar a Muia te ga de gaver pazienza. E una canna.",
      "Ciol, xe la mia canna vecia. In mar ghe xe sempre qualcossa che abbocca... de solito un Magikarp."], :OLDROD]]],
    cale_studente: [126, [[4, 3, "NPC 18", 2, [
      "Studio a Trieste, al Politecnico. Ogni matina el Delfin Verde, ogni sera el Delfin Verde.",
      "Te disi che el sindaco no te lassa partir? Ah, ma xe per quel che el Delfin xe sempre in ritardo!",
      "Ciol, me avanza dele Poké Ball dela gita al Carso."], [:POKEBALL, 5]]]],
    cale_balon: [123, [[10, 3, "NPC 05", 2, [
      "Ti te zoghi a balon? Mi son el bomber dela Muiesana. Cioè, iero. Desso son el bomber del divan.",
      "Un consilio: i pokemon de tipo Lota xe come i difensori dela Muiesana: no i passa nissun."]]]],
    cale_televisor: [125, [[9, 3, "NPC 19", 4, [
      "SSST! Xe el meteo de Tele Quattro: bora a cento all'ora. Normale.",
      "Quando tira bora i pokemon volanti xe più rabiosi. Anca mia suocera."]]]],
    cale_cuoca: [124, [[5, 6, "NPC 26", 8, [
      "Sto fazendo la jota. Fasoi, crauti, patate e... el segreto dela nona: pazienza.",
      "Te son magro come un fil de ferro! Ciol, almeno 'sta pozion, che xe istesso nutriente."], [:SUPERPOTION, 2]]]],
    cale_artista: [126, [[8, 3, "trainer_PAINTER", 2, [
      "Pituro solo el Mandracchio. Da trent'ani. Sempre el stesso.",
      "Ogni tanto ghe meto un Wingull diverso, per non annoiarme."]]]],
    cale_mama_muli: [125, [[2, 6, "NPC 24", 6, [
      "I mii fioi xe in Ricreatorio, mi finalmente go un fià de pase.",
      "Ti te son el foresto? Brava gente quei de Trieste... basta che i resti de là."]]]],
    cale_marinaio: [123, [[8, 6, "trainer_SAILOR", 4, [
      "Go navigà per tuti i mari del mondo. El più bel? Quel de Muia. Anca perché el xe vizin a casa.",
      "Se te vol andar in fondo al molo C. Colombo, te serve rispeto dei pescadori: tre bolli almeno.",
      "Ciol, 'ste corde le ga sempre in scarsela un bon marinaio."], [:ESCAPEROPE, 2]]]],
    cale_vecio_carneval: [124, [[2, 3, "NPC 17", 2, [
      "Go sfilà con la Bora nel '72. Gavevimo un caro con un mulin de vento vero!",
      "El vento lo ga portà fin a Capodistria. El caro, no mi."]]]],
    dante_professor: [126, [[2, 9, "trainer_SCIENTIST", 6, [
      "Studio i pokemon de Muia. Teoria: i Rattata de Muia xe più grandi de quei de Trieste.",
      "Conferma: xe vero. Magna meio."], [:REPEL, 3]]]],
    dante_coppia: [125, [[2, 6, "trainer_YOUNGCOUPLE", 6, [
      "Semo sposai da poco. Gavemo fato el viagio de nozze a Porto San Rocco.",
      "Iera tanto bel che no semo più tornai. Cioè, semo a cinquecento metri."]]]],
    mandracchio_cinese: [123, [[2, 6, "NPC 15", 6, [
      "Benvignù! Qua vendo de tuto: ombrele, lampadine, cover del telefono, e... lanterne cinesi.",
      "Una me ga scampà in Mandracchio. Se te la vedi in fondo al mar, lassila là: xe arte."]]]],
    mandracchio_nuotador: [124, [[7, 6, "trainer_SWIMMER_M", 4, [
      "Fazo el clanfo dal molo ogni giorno, anca a genaio.",
      "El segreto? No pensarghe. E un bicer de grappa dopo."], :FRESHWATER]]],
    vela_skipper: [126, [[9, 9, "trainer_SAILOR", 4, [
      "Al Circolo dela Vela semo tuti skipper. Barche no ghe ne gavemo, ma skipper sì.",
      "La Barcolana? Ghe go partecipà vinti volte. Rivà ultimo vinti volte. Record!"]]]],
    vela_mula: [125, [[8, 6, "trainer_SWIMMER_F", 4, [
      "Tuti me disi che son la più brava a nodar de Muia.",
      "Ciol 'sta perla, la go trovada soto el Circolo."], :PEARL]]],
    slucia_capo_casa: [124, [[5, 6, "trainer_ROCKER", 8, [
      "Te ga batù i muli del rion? Alora te son de Santa Lucia anche ti, onorario.",
      "Qua in rion ghe xe el bar più rifornì de Muia. Ocio ai prezi."], [:GREATBALL, 3]]]],
    slucia_vecia_gati: [123, [[8, 6, "NPC 14", 2, [
      "Go tredici gati e un Meowth. El Meowth xe el più educà.",
      "Lu me porta anca i schei, de note. No so de dove. Meio no domandar."], [:NUGGET, 1]]]],
    slucia_studioso: [126, [[4, 3, "trainer_RUINMANIAC", 2, [
      "Santa Lucia, Muia Vecia, el Castel... qua ogni sasso ga sete secoli.",
      "Dicono che soto el Castel ghe sia un passagio segreto fin al mar. Mi no lo go mai trovà. Ancora."]]]],
    slucia_ragazzo: [125, [[9, 3, "trainer_YOUNGSTER", 4, [
      "Te sa che a Trieste i ga el tram de Opicina? Noi gavemo el Delfin Verde. Vincemo noi.",
      "Cioè, gavevimo. Desso el xe fermo per l'ordinanza. Pareggio."]]]],
    nord_infermiera: [123, [[8, 6, "NPC 24", 2, [
      "Lavoro al Distretto. Te ga i pokemon strachi? Mi curo solo i umani, ma te dago 'sta roba.",
      "E ricordite: le vecie de Muia cura meio de mi. E gratis."], [:FULLHEAL, 2]]]],
    nord_bambin: [124, [[2, 3, "trainer_TUBER_M", 2, [
      "Da grande voio far el capopalestra. O el gelatier. O tuti e do: la palestra del gelato!"]]]],
    nord_nono_guera: [125, [[2, 6, "NPC 17", 6, [
      "Mi go visto Muia cambiar tante volte. Prima Austria, pò Italia, pò la zona B...",
      "Ma el caffè in Piazza Marconi xe sempre stado el stesso. Bon e caro."]]]],
    nord_ciclista: [126, [[2, 9, "NPC_ciclista", 6, [
      "Fazo Muia-Lazzareto in bici ogni matina. Andata in salita, ritorno in salita. No so come.",
      "Ciol, xe energia pura. Per i pokemon, eh. No sta magnarla ti."], [:PROTEIN, 1, 3]]]],
    nord_fan_tubo: [123, [[10, 3, "NPC 05", 2, [
      "Tubo? El xe mio cugin. In fameia lo ciamemo 'el Tubetto'.",
      "Da picio el voleva far el sindaco. Pò el ga fato el concorso per vigile. Pò el ga fato el vigile e basta.",
      "No sta dirghe che te lo go dito. Ciol, per el silenzio."], [:XATTACK, 2]]]],
    nord_osmiza: [124, [[7, 6, "NPC 17", 4, [
      "Sabo verzo l'osmiza su in colina. Vin, ovi duri e persuto.",
      "Te vedi la frasca su la strada? Alora xe verto. No te la vedi? Alora la ga portada via la bora."], :LEFTOVERS]]],
    nord_sposa: [125, [[8, 6, "trainer_LADY", 4, [
      "Me sposo in Duomo sabo. El sposo xe de Trieste. Mia mama ancora no la ga digerida."]]]],
    nord_gamer: [126, [[9, 9, "trainer_SUPERNERD", 4, [
      "Te zoghi anche ti al 'Pokémon Muia' sul telefono? Dicono che ghe xe un fan game ambientà qua.",
      "Sì, va ben, ma chi xe che fa un zogo su Muia? Ahahah."]]]],
    psr_yacht: [126, [[4, 3, "trainer_GENTLEMAN", 2, [
      "Benvignù al Yacht Club de Porto San Rocco. Qua le barche costa più dele case.",
      "Un foresto che vien a piedi? Che roba esotica! Ciol, xe una cana bona: in marina ghe xe pessi de lusso."], :GOODROD]]],
    psr_turista: [125, [[2, 6, "trainer_LADY", 6, [
      "Son vignuda in vacanza a Porto San Rocco. Me ga dito che xe 'Muia ma più elegante'.",
      "Go magnà sardoni impanai per tre giorni. Son felice."]]]],
    castel_custode: [123, [[8, 6, "NPC 13", 2, [
      "Son el custode del Castel. Le ciavi? Le ga i Mandrioi. I fantasmi? Anca quei xe dei Mandrioi."]]]]
  }

  # Porte che verzi: [mapa, x, y] => chiave in CASE (o :bar_* in 006_Bar.rb)
  PORTE_VERTE = {
    [42, 26, 2] => :bar_tendarossa, [42, 18, 2] => :bar_jimmy,
    [42, 49, 5] => :piazza_sindacheto, [42, 55, 18] => :piazza_nona,
    [89, 2, 9] => :cale_bortolo, [89, 11, 9] => :cale_gemelle, [89, 17, 9] => :cale_pescador,
    [89, 26, 9] => :cale_studente, [89, 5, 13] => :cale_balon, [89, 16, 13] => :cale_televisor,
    [89, 25, 13] => :cale_cuoca, [89, 9, 18] => :cale_artista, [89, 22, 18] => :cale_mama_muli,
    [87, 11, 9] => :cale_marinaio, [87, 8, 18] => :cale_vecio_carneval,
    [90, 24, 11] => :cale_balon, [93, 18, 10] => :cale_televisor,
    [32, 6, 11] => :dante_professor, [84, 7, 11] => :dante_coppia,
    [76, 10, 1] => :mandracchio_cinese, [76, 23, 1] => :mandracchio_nuotador,
    [79, 11, 6] => :vela_skipper, [79, 28, 18] => :vela_mula,
    [113, 11, 11] => :bar_slucia, [113, 2, 11] => :slucia_capo_casa, [113, 14, 11] => :slucia_vecia_gati,
    [113, 29, 21] => :slucia_studioso, [113, 9, 33] => :slucia_ragazzo,
    [97, 7, 40] => :nord_infermiera, [98, 41, 8] => :nord_bambin, [104, 24, 21] => :nord_nono_guera,
    [106, 17, 8] => :nord_ciclista, [109, 17, 8] => :nord_fan_tubo, [107, 15, 5] => :nord_osmiza,
    [105, 9, 8] => :nord_sposa, [128, 8, 20] => :psr_yacht, [128, 28, 20] => :psr_turista, [107, 16, 17] => :nord_gamer, [114, 2, 10] => :castel_custode
  }

  FRASI_PORTE = [
    "Xe serà. Dentro se senti la television a tuto volume: i varda Tele Quattro.",
    "Xe serà. Sul campanel xe scrito: \"NO SE VENDI GNENTE, NO SE COMPRA GNENTE\".",
    "Te bati. \"CHI XE?!\" \"Un foresto!\" \"NO GAVEMO BISOGNO!\"",
    "Xe serà. Da dentro riva un profumo de jota. Te vien una fame...",
    "Xe serà. Sula porta: \"Torno subito\". El cartel xe del 1987.",
    "La porta xe serada a ciave. Anche la finestra. Anche el balcon. A Muia no se fida de nissun.",
    "Te soni el campanel. Un can taca a bauar. Pò do. Pò tre. Meio andar.",
    "Xe serà. Una vose da dentro: \"Mama, xe quel foresto! Sera le scuri!\"",
    "Xe serà. Sul zerbin xe scrito BENVIGNUDI, ma la porta no la xe d'acordo.",
    "Xe serà. Un bigliet: \"Semo al mar a Porto San Rocco, tornemo dopo le sie\".",
    "Te bati. \"Se te xe del Comun, no son in casa!\"",
    "Xe serà. Qualchedun dentro zoga a briscola e el bestemia in tre lingue.",
    "Xe serà. Un bigliet: \"Ciave soto el vaso\". Soto el vaso ghe xe un altro bigliet: \"Ciapà!\"",
    "Xe serà. Se senti odor de pesse fritto. Deve esser venerdì.",
    "Xe serà. Dentro i varda la partida dela Triestina. Meio no disturbar.",
    "Xe serà. Se senti un nono che canta in dialeto, stonà come una campana.",
    "Xe serà. Sula cassetta dela posta: \"NO PUBBLICITÀ. E NO FORESTI.\" Ahia.",
    "Te bati. Te verzi un Meowth, el te varda, el te sera la porta in muso."
  ]

  #-----------------------------------------------------------------------------
  def self.porte_dela_mapa(map_id, map)
    ret = []
    return ret if !MAPE_FORA.include?(map_id) || map.tileset_id != 1
    map.height.times do |y|
      map.width.times do |x|
        t1 = map.data[x, y, 1]
        t2 = map.data[x, y, 2]
        ret.push([x, y]) if TILE_PORTE.include?(t1) || TILE_PORTE.include?(t2)
      end
    end
    return ret
  end

  def self.zonta_porte(map_id, map)
    # Porte sule mape de fora
    occupade = {}
    map.events.each_value { |e| occupade[[e.x, e.y]] = true }
    porte_dela_mapa(map_id, map).each_with_index do |(x, y), i|
      next if occupade[[x, y]]
      chiave = PORTE_VERTE[[map_id, x, y]]
      cmd = chiave ? "MuiaStoria.entra(:#{chiave}, #{map_id}, #{x}, #{y})" : "MuiaStoria.porta_serada(#{map_id}, #{x}, #{y})"
      metti(map, evento(1301 + i, x, y, [{ trig: 1, through: true, cmd: cmd }], "Porta"))
    end
    # Interni: porta de uscida e personagi
    dati = INTERNI[map_id]
    return if !dati
    _ex, _ey, ux, uy = dati
    metti(map, evento(1290, ux, uy, [{ trig: 1, through: true, cmd: "MuiaStoria.esci" }], "Uscida"))
    chiave = casa_atual
    persone = (CASE[chiave] && CASE[chiave][0] == map_id) ? CASE[chiave][1] : []
    persone.each_with_index do |p, i|
      x, y, gfx, dir = p
      metti(map, evento(1291 + i, x, y, [{ gfx: gfx, dir: dir, cmd: "MuiaStoria.parla_casa(:#{chiave}, #{i})" }]))
    end
    zonta_bar_interno(map_id, map, chiave) if respond_to?(:zonta_bar_interno)
  end

  def self.casa_atual
    v = $game_variables[VAR_PORTA]
    return v.is_a?(Array) ? v[3] : nil
  end

  def self.porta_serada(map_id, x, y)
    n = (map_id * 31 + x * 7 + y * 13) % FRASI_PORTE.length
    pbMessage(_INTL("{1}", _INTL(FRASI_PORTE[n])))
    $game_player.turn_down rescue nil
    $game_player.move_down rescue nil
  end

  def self.entra(chiave, map_id, x, y)
    interno = chiave.to_s.start_with?("bar_") ? (BAR[chiave] ? BAR[chiave][0] : nil) : (CASE[chiave] ? CASE[chiave][0] : nil)
    if !interno || !INTERNI[interno]
      porta_serada(map_id, x, y)
      return
    end
    if chiave == :bar_slucia && !$game_switches[SW_RIONE_OK]
      pbMessage(_INTL("Xe el Bar Santa Lucia. Sula porta: \"SOLO PER CHI XE DEL RION\"."))
      $game_player.move_down rescue nil
      return
    end
    $game_variables[VAR_PORTA] = [map_id, x, y, chiave]
    ex, ey = INTERNI[interno]
    pbSEPlay("Door enter") rescue nil
    trasferisci(interno, ex, ey, 8, false)
  end

  def self.esci
    v = $game_variables[VAR_PORTA]
    if !v.is_a?(Array)
      trasferisci(MAPA_PIAZZA, 26, 10, 2)   # no dovessi mai suceder
      return
    end
    trasferisci(v[0], v[1], v[2] + 1, 2)
  end

  def self.parla_casa(chiave, i)
    dati = CASE[chiave]
    return if !dati || !dati[1][i]
    _x, _y, _g, _d, frasi, regalo = dati[1][i]
    evento = pbMapInterpreter&.get_self
    gira_verso_zogador(evento) if evento
    chiave_regalo = [chiave, i]
    dato = ($game_variables[VAR_BAR].is_a?(Hash) ? $game_variables[VAR_BAR] : ($game_variables[VAR_BAR] = {}))
    dato[:regali] ||= {}
    if regalo && dato[:regali][chiave_regalo]
      pbMessage(_INTL("{1}", _INTL(frasi[0])))
      pbMessage(_INTL("Come va col Libreto? Te ga {1} bolli, vedo. Bravo!", medaje)) if trama >= 6
      return
    end
    frasi.each { |f| pbMessage(_INTL("{1}", _INTL(f))) }
    return if !regalo
    ogeto, quanti, min_medaje = regalo.is_a?(Array) ? regalo : [regalo, 1, 0]
    if medaje < (min_medaje || 0)
      pbMessage(_INTL("...Ma no, no te lo dago ancora. Torna quando te ga {1} bolli.", min_medaje))
      return
    end
    return if !GameData::Item.exists?(ogeto)
    if pbReceiveItem(ogeto, quanti || 1)
      dato[:regali][chiave_regalo] = true
    end
  end
end
