#===============================================================================
# Muia - Storia: blochi per la strada (transenne, cordoni, muli in cale)
#
# Le caselle xe state calcolade su la mapa intiera de Muia (tute le mape
# atacade) in modo che no se possa passar de nissuna altra parte:
#   - transenne del Carneval lungo Via Roma: fin che no te passi Tubo
#   - posto de bloco de Tubo in cima a Calle Parini (cale da Calle Parini)
#   - pescadori sul molo C. Colombo: fin ala 3a medaja (Nane xe là in fondo)
#   - corda sule scale del Castel: fin ala 4a medaja (Gigi xe su)
#   - muli de Santa Lucia: te ga de bater el capo
#===============================================================================
module MuiaStoria
  # Transenne: [mapa, x, y, grafica de un spetador (o nil), tile dela transenna]
  TRANSENNE = [
    [86, 2, 14, nil, 573], [86, 3, 14, nil, 565], [86, 4, 14, "NPC 02", nil],
    [86, 5, 14, nil, 565], [86, 6, 14, nil, 573], [86, 7, 14, nil, 565],
    [86, 8, 14, "NPC 04", nil], [86, 9, 14, nil, 565], [86, 12, 14, nil, 573],
    [86, 13, 14, nil, 565], [86, 16, 14, "NPC 06", nil], [86, 17, 14, nil, 565],
    [86, 18, 14, nil, 573], [86, 21, 14, nil, 565], [86, 22, 14, "NPC 08", nil],
    [86, 23, 14, nil, 565], [86, 26, 14, nil, 573], [86, 27, 14, nil, 565],
    [86, 28, 14, "NPC 10", nil], [86, 29, 14, nil, 565], [86, 30, 14, nil, 573],
    [86, 31, 14, nil, 565], [86, 32, 14, "NPC 12", nil], [86, 33, 14, nil, 565],
    [86, 34, 14, nil, 573], [86, 35, 14, nil, 565],
    [88, 10, 19, nil, 573], [88, 11, 19, nil, 565], [88, 12, 19, "NPC 16", nil],
    [88, 13, 19, nil, 565], [88, 14, 19, nil, 573], [88, 15, 19, nil, 565],
    [88, 16, 19, "NPC 18", nil], [88, 17, 19, nil, 565], [88, 18, 19, nil, 573],
    [88, 19, 19, nil, 565], [88, 20, 19, "NPC 20", nil], [88, 21, 19, nil, 565],
    # strada per Porto San Rocco (fin del Circolo dela Vela)
    [79, 44, 7, nil, 573], [79, 44, 8, "NPC 02", nil], [79, 44, 9, nil, 565], [79, 44, 10, nil, 573]
  ]

  FRASI_SPETADORI = [
    "Ssst! Sta per passar el caro dela Bora! Ocio che el ga el ventilator a manetta.",
    "Son qua dale sie de matina per el posto in prima fila. No me movo gnanca per el papa.",
    "Te vol passar? Eh, mulo, xe la sfilata del Carneval: se passa solo dal posto de bloco de Tubo, in cima a Calle Parini.",
    "I Bulli e Pupe ga vinto ancora? Xe sempre lori! Xe tuto combinà!",
    "Mia nona la fazeva i costumi dela Trottola. Mi fazo el tifo... e magno crostoli.",
    "Coriandoli! CORIANDOLI! ...ah, no, xe la forfora del vecio qua davanti.",
    "No sta spinger, foresto! Qua se speta in fila, come in posta.",
    "Ai mii tempi la sfilata durava tre giorni. Desso i se stufa dopo do ore."
  ]

  def self.transenna
    dì("TRANSENNA", _INTL("SFILATA DEL CARNEVAL DE MUIA - STRADA SERADA. Per passar: posto de bloco in cima a Calle Parini."))
  end

  def self.spetador(n)
    pbMessage(_INTL("{1}", _INTL(FRASI_SPETADORI[n % FRASI_SPETADORI.length])))
  end

  #-----------------------------------------------------------------------------
  # Pescadori sul molo C. Colombo (map 78, riga 0) e corda del Castel
  #-----------------------------------------------------------------------------
  MOLO = [[78, 9, 0, "trainer_FISHERMAN", nil], [78, 10, 0, nil, 559],
          [78, 11, 0, nil, 559], [78, 12, 0, "NPC 17", nil]]

  def self.pescador
    dì("PESCADOR", _INTL("Ferma là! Oggi el molo xe nostro: gara de pesca dele compagnie."))
    dì("PESCADOR", _INTL("Te pol passar solo se te ga almeno TRE bolli, come Nane del Brivido. Te ghe ne ga {1}.", medaje))
  end

  # Le scale del Castel: corda in tre tochi sopra i eventi dele scale
  CASTEL = [[43, 44, 4, 568], [79, 0, 4, 569], [79, 1, 4, 570]]

  # Fondo dela strada per Lazzareto (Porto San Rocco, mapa 128): frana
  LAZZARETO = [[128, 39, 7, nil, 559], [128, 39, 8, "trainer_MANOVAL", nil], [128, 39, 9, nil, 559], [128, 39, 10, nil, 559]]

  def self.frana
    dì("MANOVAL", _INTL("FAZO BUSOOO! ...Ah, scusa. La strada per Lazzareto xe serada: xe vignuda zo una frana."))
    dì("MANOVAL", _INTL("I dixi che la verzerà 'presto'. A Muia 'presto' vol dir tra el 2027 e la fine del mondo."))
  end

  def self.corda_castel
    pbMessage(_INTL("Una corda sbara le scale del Castel. Xe tacà un cartel:"))
    pbMessage(_INTL("\"CASTEL SERÀ PER FANTASMI. Firmà: compagnia MANDRIOI. Se passa con QUATRO bolli.\""))
    pbMessage(_INTL("Te ga {1} bolli.", medaje)) if medaje < 4
  end

  #-----------------------------------------------------------------------------
  # Muli de Santa Lucia: tre cali, el capo xe in quela de mezo
  # [ID, x, y, grafica, capo?]
  #-----------------------------------------------------------------------------
  RIONE_MAPA = 113
  RIONE = [
    [1061, 0, 12, "trainer_YOUNGSTER", false], [1062, 0, 13, "trainer_CAMPER", false],
    [1063, 0, 21, "trainer_ROCKER", true],     [1064, 0, 22, "trainer_BIKER", false],
    [1065, 0, 34, "trainer_TWINS", false],     [1066, 0, 35, "trainer_LASS", false]
  ]
  RIONE_SQUADRA = [[:ZIGZAGOON, -3], [:POOCHYENA, -2], [:SCRAGGY, -1]]

  def self.mulo_rion(capo)
    if !capo
      dì("MULO DEL RION", _INTL("Santa Lucia xe roba nostra. I foresti passa solo se i bati el capo, in cale de mezo."))
      return
    end
    dì("CAPO DEL RION", _INTL("Ciò, foresto. In Santa Lucia ghe xe el bar più bon de Muia e i pokemon più rari."))
    dì("CAPO DEL RION", _INTL("Ma i muli del rion no lassa passar chi che no ga fegato. Te ga fegato?"))
    return if !pbConfirmMessage(_INTL("Te sfidi el capo del rion?"))
    alenador = NPCTrainer.new(_INTL("Capo del rion"), :ROCKER)
    base = livel_max
    RIONE_SQUADRA.each { |sp, d| alenador.party.push(fa_pokemon(sp, base + d, alenador)) }
    alenador.lose_text = _INTL("Va ben, te ga fegato. Santa Lucia xe verta!")
    if TrainerBattle.start(alenador)
      dì("CAPO DEL RION", _INTL("Bon. Muli, lassè passar el foresto! El xe dei nostri, desso."))
      pbFadeOutIn do
        $game_switches[SW_RIONE_OK] = true
        aggiorna
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Creazion dei blochi per una mapa
  #-----------------------------------------------------------------------------
  def self.zonta_blochi(map_id, map)
    TRANSENNE.each_with_index do |(m, x, y, gfx, tile), i|
      next if m != map_id
      id = 1101 + i
      cmd = gfx ? "MuiaStoria.spetador(#{i})" : "MuiaStoria.transenna"
      metti(map, evento(id, x, y, [{}, { sw: SW_SFILATA, gfx: gfx, tile: tile, dir: 8, cmd: cmd }]))
    end
    MOLO.each_with_index do |(m, x, y, gfx, tile), i|
      next if m != map_id
      metti(map, evento(1171 + i, x, y, [{}, { sw: SW_MOLO, gfx: gfx, tile: tile, dir: 2,
                                                cmd: "MuiaStoria.pescador" }]))
    end
    CASTEL.each_with_index do |(m, x, y, tile), i|
      next if m != map_id
      metti(map, evento(1181 + i, x, y, [{}, { sw: SW_CASTEL, tile: tile, cmd: "MuiaStoria.corda_castel" }]))
    end
    LAZZARETO.each_with_index do |(m, x, y, gfx, tile), i|
      next if m != map_id
      metti(map, evento(1191 + i, x, y, [{ gfx: gfx, tile: tile, dir: 6, cmd: "MuiaStoria.frana" }]))
    end
    if map_id == RIONE_MAPA
      RIONE.each do |id, x, y, gfx, capo|
        metti(map, evento(id, x, y, [{}, { sw: SW_RIONE, gfx: gfx, dir: 4,
                                           cmd: "MuiaStoria.mulo_rion(#{capo})" }]))
      end
    end
  end
end
