#===============================================================================
# Muia - Storia: le frazioni
#   - Porto San Rocco (mapa 128): dopo el Circolo dela Vela, lungo la strada
#     per Lazzareto (serada per frana). Vedi 004_Barriere.rb.
#   - Muggia Vecia (mapa 129): su la colina sora Via D'Annunzio, con la basilica.
#     La strada se verzi col secondo bollo.
#===============================================================================
module MuiaStoria
  SW_COLINA   = 89   # strada per Muggia Vecia serada (prima del 2o bollo)
  MAPA_COLINA = 129

  # Barriera in cima a Via D'Annunzio (mapa 110, riga 6)
  BARRIERA_COLINA = [[110, 9, 6, 565], [110, 10, 6, 573], [110, 11, 6, 565], [110, 12, 6, 573]]

  def self.barriera_colina
    pbMessage(_INTL("STRADA PER MUGGIA VECIA - SERADA."))
    pbMessage(_INTL("\"Ordinanza del sindaco Pochibori: i foresti con manco de DO bolli se perdi in colina. Se verzi col secondo bollo.\""))
    pbMessage(_INTL("Te ga {1} bolli.", medaje)) if medaje < 2
  end

  def self.sacrestan
    dì("SACRESTAN", _INTL("Benvignù a Muggia Vecia. Qua ghe iera la Muia vecia, sul monte, prima che i la distrudi nel Medioevo."))
    dì("SACRESTAN", _INTL("De tuto el paese xe restada solo la basilica de Santa Maria Assunta. La ga più de mile ani, mulo."))
    dì("SACRESTAN", _INTL("I muiesani xe andai zo al mar e i ga fato la Muia de desso. Ma el cuor, dicono, el xe restà qua su."))
    if !$game_self_switches[[MAPA_COLINA, 1402, "A"]] && GameData::Item.exists?(:SOOTHEBELL)
      dì("SACRESTAN", _INTL("Ciol, xe una campanela vecia dela basilica. I pokemon che la porta se vol più ben."))
      $game_self_switches[[MAPA_COLINA, 1402, "A"]] = true if pbReceiveItem(:SOOTHEBELL)
    end
  end

  def self.panorama
    pbMessage(_INTL("PUNTO PANORAMICO: de qua se vedi tuto el golfo. Muia soto, el Castel, el Delfin Verde... e in fondo Trieste, picia picia."))
  end

  def self.ogeto(id, item)
    if pbItemBall(item)
      $game_self_switches[[$game_map.map_id, id, "A"]] = true
      $game_map.need_refresh = true
    end
  end

  def self.zonta_frazioni(map_id, map)
    if map_id == MAPA_PACCO_FORA && telefonada_da_far?
      metti(map, evento(1420, 0, 0, [{ trig: 3, through: true, cmd: "MuiaStoria.telefonada" }], "Telefonada"))
    end
    BARRIERA_COLINA.each_with_index do |(m, x, y, tile), i|
      next if m != map_id
      metti(map, evento(1411 + i, x, y, [{}, { sw: SW_COLINA, tile: tile, cmd: "MuiaStoria.barriera_colina" }]))
    end
    return if map_id != MAPA_COLINA
    metti(map, evento(1401, 16, 9, [{ gfx: "NPC 17", dir: 2, cmd: "MuiaStoria.sacrestan" }], "Sacrestan"))
    metti(map, evento(1403, 27, 2, [{ cmd: "MuiaStoria.panorama" }], "Panorama"))
    metti(map, evento(1404, 3, 17, [{ gfx: "Object ball", cmd: "MuiaStoria.ogeto(1404, :RARECANDY)" },
                                    { self: "A" }]))
    metti(map, evento(1405, 28, 25, [{ gfx: "Object ball", cmd: "MuiaStoria.ogeto(1405, :ULTRABALL)" },
                                     { self: "A" }]))
  end
end

#===============================================================================
# Muia - Storia: dopo ogni bollo, apena te esci dala palestra del Pacco,
# te ciama el sindaco Pochibori (o qualchedun altro) per comentar.
#===============================================================================
module MuiaStoria
  VAR_BOLLI_VISTI = 32
  MAPA_PACCO_FORA = 110

  TELEFONADE = [
    nil,
    [["SINDACO POCHIBORI", "Pronto? Xe el sindaco. Go savù che te ga batù Bepi dela Bora. Fortuna, sicuro."],
     ["SINDACO POCHIBORI", "Desso Nives dele Bellezze Naturali la xe ai Giardinetti a bagnar le rose. E ocio: col secondo bollo se verzi anca la strada per Muggia Vecia, su in colina."]],
    [["SINDACO POCHIBORI", "Do bolli? Ciò, no xe che te me diventi simpatico, eh."],
     ["SINDACO POCHIBORI", "Marieta dela Lampo xe al Vecio Squero: ga saltà la corente. E go sentì che Tubo xe in giro col bloco dele multe..."]],
    [["FULVIO", "Pronto, xe Fulvio! Tre bolli! In piazza no se parla d'altro. La siora del tabachin ga anca scomesso su de ti."],
     ["FULVIO", "Nane del Brivido pesca in ponta al molo C. Colombo: i pescadori desso te lassa passar."]],
    [["SINDACO POCHIBORI", "Quatro bolli. Metà strada. A metà strada, de solito, i foresti torna indrio. Ti?"],
     ["SINDACO POCHIBORI", "Gigi dei Mandrioi se sconde al Castel. La corda sule scale i la ga tolta. E... salutime i fantasmi."]],
    [["SIORA ORNELLA", "Xe la Ornella del Comun. Go dovù zontar una pagina al tuo Libreto: i timbri no ghe stava più!"],
     ["SIORA ORNELLA", "Toni dela Ongia el xe in Piazza dela Repubblica a bever spritz. Come sempre. Va' prima che el ghe ne bevi un altro."]],
    [["SINDACO POCHIBORI", "Sie bolli... Go fato rifar la serada dela porta del Comun. Cussì, per sicureza."],
     ["SINDACO POCHIBORI", "Licia dela Trottola la xe in Via Roma. Ela sa za che te rivi: la lo ga visto nele carte. Mi inveze no lo gavevo previsto."]],
    [["FULVIO", "Sete bolli! Mulo, te son una leggenda. Al bar i ga za fato el panin col to nome: el 'Foresto', con persuto e cren."],
     ["FULVIO", "L'ultima xe Pina dei Bulli e Pupe, al Mandracchio. La fa cento flessioni prima de colazion. Ocio."]],
    [["SINDACO POCHIBORI", "...Oto bolli. Va ben. Te speto al Castel. I Super 4 xe pronti. Anca Tubo, che el se ga stirà la divisa."],
     ["SINDACO POCHIBORI", "E se te me bati... l'ordinanza la firmi ti. Ma no te me baterà. Credo. Spero."]]
  ]

  def self.telefonada_da_far?
    visti = $game_variables[VAR_BOLLI_VISTI].is_a?(Integer) ? $game_variables[VAR_BOLLI_VISTI] : 0
    return medaje > visti && medaje <= 8 && TELEFONADE[medaje]
  end

  def self.telefonada
    evento = ev(1420)
    if telefonada_da_far?
      pbWait(0.3)
      pbSEPlay("Battle recall") rescue nil
      pbMessage(_INTL("\\c[8]Drin drin! Drin drin! Te sona el telefonin..."))
      TELEFONADE[medaje].each { |chi, testo| dì(chi, _INTL(testo)) }
      pbMessage(_INTL("\\c[8]Clic."))
      $game_variables[VAR_BOLLI_VISTI] = medaje
    end
    evento&.erase
  end
end
