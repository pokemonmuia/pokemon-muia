#===============================================================================
# Muia - Storia: i bar de Muia
#
# Nei bar se trova gente che vendi pokemon, MT e MN, o che fa scambi.
# Ogni venditor ga UNA roba in vendita: apena te la compri, el cambia a caso
# (pokemon, MT o MN) e el continua a vender. Qualche volta salta fora anca un
# leggendario... ma el costa un ocio dela testa.
#
# Prezi (in Poké$): pensadi sui premi dele lote. Un alenador de strada dà
# 200-1500, un capopalestra 1200-5000, un selvadego 15-200.
#===============================================================================
module MuiaStoria
  # Pokemon in vendita: [specie, prezo, livel rispeto al to più forte]
  POKEMON_COMUNI = [
    [:EEVEE, 4500, -3], [:PICHU, 2500, -3], [:MARILL, 2000, -3], [:BUNEARY, 1500, -3],
    [:LILLIPUP, 1500, -3], [:RIOLU, 6000, -3], [:SNUBBULL, 1800, -3], [:SLAKOTH, 3000, -3],
    [:MAGNEMITE, 2500, -3], [:GROWLITHE, 3500, -3], [:PONYTA, 2500, -3], [:ABRA, 3000, -3],
    [:MACHOP, 2500, -3], [:SKARMORY, 6500, -3], [:SHUCKLE, 2000, -3], [:CHINCHOU, 2500, -3]
  ]
  POKEMON_RARI = [
    [:DRATINI, 10000, -4], [:LARVITAR, 10000, -4], [:BAGON, 10000, -4], [:GIBLE, 12000, -4],
    [:BELDUM, 10000, -4], [:LAPRAS, 9000, -3], [:SNORLAX, 9000, -3], [:AERODACTYL, 8500, -3],
    [:SCYTHER, 7000, -3], [:PORYGON, 7000, -3], [:TOGEPI, 6000, -3], [:FARFETCHD, 3000, -3],
    [:KANGASKHAN, 7500, -3], [:TAUROS, 6000, -3], [:CHANSEY, 8000, -3], [:ROTOM, 9000, -3]
  ]
  POKEMON_LEGGENDARI = [
    [:ZAPDOS, 25000, 0], [:ARTICUNO, 25000, 0], [:MOLTRES, 25000, 0],
    [:RAIKOU, 30000, 0], [:ENTEI, 30000, 0], [:SUICUNE, 30000, 0],
    [:LATIAS, 35000, 0], [:LATIOS, 35000, 0], [:CELEBI, 40000, 0], [:JIRACHI, 40000, 0],
    [:MEW, 45000, 0], [:LUGIA, 50000, 0], [:HOOH, 50000, 0], [:MEWTWO, 60000, 0]
  ]
  # Probabilità (su 100): [comuni, rari, leggendari]
  PROB_NORMAL = [62, 33, 5]
  PROB_RION   = [35, 47, 18]

  # MN: prezo fisso (le se dopra fora dale lote)
  MN_PREZI = { HM01: 1500, HM02: 6000, HM03: 6000, HM04: 4000, HM05: 4000, HM06: 2000 }

  # Scambi: [cossa i vol, cossa i te dà]
  SCAMBI = [
    [:RATTATA, :SNEASEL], [:PIDGEY, :FARFETCHD], [:WINGULL, :CORPHISH], [:KRABBY, :SHELLOS],
    [:ZUBAT, :NOIBAT], [:SPEAROW, :TAILLOW], [:MEOWTH, :PURRLOIN], [:TENTACOOL, :MANTYKE],
    [:MAGIKARP, :FEEBAS], [:ZIGZAGOON, :SENTRET], [:POOCHYENA, :HOUNDOUR], [:GRIMER, :TRUBBISH],
    [:HOOTHOOT, :NATU], [:MURKROW, :MISDREAVUS], [:GASTLY, :DUSKULL], [:SHELLDER, :CLAMPERL],
    [:HORSEA, :SKRELP], [:ODDISH, :BELLSPROUT]
  ]

  # Bar: chiave => [interno, [[x, y, grafica, dir, ruolo], ...]]
  # ruoli: :pkmn, :pkmn_rion, :mt, :scambi, :barista, o una frase
  BAR = {
    bar_tendarossa: [127, [
      [4, 8, "trainer_HENRY", 2, :barista],
      [9, 3, "trainer_GENTLEMAN", 2, :mt],
      [11, 8, "trainer_GAMBLER", 4, :pkmn],
      [1, 3, "NPC 04", 2, "Henry fa el miglior caffè de Muia. Cinghio disi el contrario. Mi bevo tuti e do, per sicureza."]]],
    bar_jimmy: [126, [
      [4, 3, "trainer_TEAM_CINGHIO_M", 2, :barista],
      [8, 3, "trainer_BURGLAR", 2, :pkmn],
      [9, 9, "NPC 16", 4, :scambi],
      [2, 9, "NPC 20", 6, "Jimmy... cioè Cinghio... cioè el bar xe de Cinghio ma el se ciama Jimmy. Xe complicà. Come Muia."]]],
    bar_slucia: [127, [
      [4, 8, "NPC 14", 2, :barista],
      [9, 3, "trainer_RUINMANIAC", 2, :pkmn_rion],
      [11, 8, "trainer_GENTLEMAN", 4, :mt],
      [1, 3, "trainer_ROCKER", 2, "In rion i pokemon rari riva de note, coi pescadori. No sta domandar de dove."]]]
  }

  # Bar de Zuppo (mapa 80, za fata in RPG Maker): [ID, x, y, grafica, dir, ruolo]
  ZUPPO = [[1201, 2, 9, "NPC 16", 6, :scambi], [1202, 7, 12, "trainer_GAMBLER", 4, :pkmn]]

  #-----------------------------------------------------------------------------
  def self.dati_bar
    $game_variables[VAR_BAR] = {} if !$game_variables[VAR_BAR].is_a?(Hash)
    return $game_variables[VAR_BAR]
  end

  def self.zonta_bar_interno(map_id, map, chiave)
    dati = BAR[chiave]
    return if !dati || dati[0] != map_id
    dati[1].each_with_index do |(x, y, gfx, dir, ruolo), i|
      metti(map, evento(1211 + i, x, y, [{ gfx: gfx, dir: dir, cmd: "MuiaStoria.bar_parla(:#{chiave}, #{i})" }]))
    end
  end

  def self.zonta_bar(map_id, map)
    return if map_id != MAPA_ZUPPO
    ZUPPO.each_with_index do |(id, x, y, gfx, dir, _ruolo), i|
      metti(map, evento(id, x, y, [{ gfx: gfx, dir: dir, cmd: "MuiaStoria.bar_parla(:zuppo, #{i})" }]))
    end
  end

  def self.bar_parla(chiave, i)
    ruolo = (chiave == :zuppo) ? ZUPPO[i][5] : BAR[chiave][1][i][4]
    evento = pbMapInterpreter&.get_self
    gira_verso_zogador(evento) if evento
    banco = "#{chiave}_#{i}"
    case ruolo
    when :pkmn      then vendi_pokemon(banco, PROB_NORMAL)
    when :pkmn_rion then vendi_pokemon(banco, PROB_RION)
    when :mt        then vendi_mt(banco)
    when :scambi    then scambio(banco)
    when :barista   then barista(chiave)
    else pbMessage(_INTL("{1}", _INTL(ruolo.to_s)))
    end
  end

  #-----------------------------------------------------------------------------
  # Barista: bibite (le cura i pokemon in lota)
  #-----------------------------------------------------------------------------
  def self.barista(chiave)
    case chiave
    when :bar_tendarossa then dì("HENRY", _INTL("Benvignù in Tendarossa! Un caffè? Un spritz? Per i pokemon go le bibite."))
    when :bar_jimmy      then dì("BARISTA", _INTL("Da Jimmy se beve ben e se spendi poco. Cioè, se spendi. Cossa te dago?"))
    else                      dì("SIORA DEL BAR", _INTL("Cossa te porto, cocolo? Qua in rion i prezi xe onesti. Quasi."))
    end
    pbPokemonMart([:FRESHWATER, :SODAPOP, :LEMONADE, :MOOMOOMILK].select { |x| GameData::Item.exists?(x) })
  end

  #-----------------------------------------------------------------------------
  # Venditor de pokemon
  #-----------------------------------------------------------------------------
  def self.nova_offerta_pokemon(prob)
    r = rand(100)
    lista = if r < prob[0] then POKEMON_COMUNI
            elsif r < prob[0] + prob[1] then POKEMON_RARI
            else POKEMON_LEGGENDARI
            end
    lista = lista.select { |sp, _p, _l| GameData::Species.exists?(sp) }
    return lista.sample
  end

  def self.vendi_pokemon(banco, prob)
    d = dati_bar
    d[banco] ||= nova_offerta_pokemon(prob)
    sp, prezo, delta = d[banco]
    if !GameData::Species.exists?(sp)
      d[banco] = nil
      return
    end
    livel = [livel_max + delta, 5].max
    nome = GameData::Species.get(sp).name
    leggendario = POKEMON_LEGGENDARI.any? { |x| x[0] == sp }
    if leggendario
      dì("VENDITOR", _INTL("Ssst... vien qua. Go una roba che no te trovi in nissun negozio de Muia."))
      dì("VENDITOR", _INTL("Un {1}. Vero. Leggendario. Non me domandar de dove che el riva.", nome))
    else
      dì("VENDITOR", _INTL("Ciò, foresto! Go un {1} de livel {2}. Bel, sano, mai fato una lota.", nome, livel))
    end
    sc = pbMessage(_INTL("Te lo dago per {1} Poké$. Te ga {2} Poké$.", prezo.to_s_formatted, $player.money.to_s_formatted),
                   [_INTL("Compro"), _INTL("No grazie")], 1)
    if sc != 0
      dì("VENDITOR", _INTL("Pecà. Ma no sta pensarghe tropo: magari doman no lo go più."))
      return
    end
    if $player.money < prezo
      dì("VENDITOR", _INTL("Te manca i schei, mulo. Va' a lotar e torna."))
      return
    end
    if pbBoxesFull?
      dì("VENDITOR", _INTL("No te ga posto nel PC! Libera qualche scatola."))
      return
    end
    $player.money -= prezo
    pbAddPokemon(Pokemon.new(sp, livel.clamp(1, GameData::GrowthRate.max_level)))
    dì("VENDITOR", _INTL("Afar fato! Speta che vado in magazin... eco, desso go un'altra roba."))
    d[banco] = nova_offerta_pokemon(prob)
  end

  #-----------------------------------------------------------------------------
  # Venditor de MT e MN
  #-----------------------------------------------------------------------------
  def self.prezo_mt(item)
    return MN_PREZI[item] if MN_PREZI[item]
    dati = GameData::Item.get(item)
    mossa = GameData::Move.try_get(dati.move)
    return 3000 if !mossa
    return 3000 if mossa.power <= 1
    return ((mossa.power * 70) / 100 * 100).clamp(1500, 10000)
  end

  def self.nova_offerta_mt
    tute = GameData::Item.keys.select do |k|
      it = GameData::Item.get(k)
      (it.is_TM? || it.is_HM?) && it.move
    end
    item = tute.sample
    return item ? [item, prezo_mt(item)] : nil
  end

  def self.vendi_mt(banco)
    d = dati_bar
    d[banco] ||= nova_offerta_mt
    return if !d[banco]
    item, prezo = d[banco]
    dati = GameData::Item.get(item)
    mossa = GameData::Move.get(dati.move).name
    tipo = dati.is_HM? ? _INTL("MN") : _INTL("MT")
    dì("PROFESSOR DELE MACHINE", _INTL("Bondì! Oggi go in vendita una {1}: {2} ({3}).", tipo, dati.name, mossa))
    dì("PROFESSOR DELE MACHINE", _INTL("Le MN te servi anche fora dele lote: tajar alberi, svolar, nodar...")) if dati.is_HM?
    sc = pbMessage(_INTL("Prezo: {1} Poké$. Te ga {2} Poké$.", prezo.to_s_formatted, $player.money.to_s_formatted),
                   [_INTL("Compro"), _INTL("No grazie")], 1)
    return if sc != 0
    if $player.money < prezo
      dì("PROFESSOR DELE MACHINE", _INTL("Te manca qualche schei. Torna."))
      return
    end
    $player.money -= prezo
    pbReceiveItem(item)
    dì("PROFESSOR DELE MACHINE", _INTL("Grazie! Speta che cambio la vetrina..."))
    d[banco] = nova_offerta_mt
  end

  #-----------------------------------------------------------------------------
  # Scambi de pokemon
  #-----------------------------------------------------------------------------
  def self.scambio(banco)
    d = dati_bar
    d[banco] ||= SCAMBI.select { |a, b| GameData::Species.exists?(a) && GameData::Species.exists?(b) }.sample
    vol, dà = d[banco]
    nome_vol = GameData::Species.get(vol).name
    nome_dà  = GameData::Species.get(dà).name
    dì("SCAMBISTA", _INTL("Ciò, mi colecciono pokemon de Muia. Me manca un {1}.", nome_vol))
    dì("SCAMBISTA", _INTL("Se te me lo dà, te dago el mio {1}. Lo go portà da lontan!", nome_dà))
    return if !pbConfirmMessage(_INTL("Te fa el scambio?"))
    pbChoosePokemonForTrade(1, 3, vol)
    indice = $game_variables[1]
    if !indice.is_a?(Integer) || indice < 0
      dì("SCAMBISTA", _INTL("Va ben, la prossima volta."))
      return
    end
    pbStartTrade(indice, dà, nome_dà, _INTL("Scambista"), 0)
    dì("SCAMBISTA", _INTL("Grazie mile! Desso go voia de un altro pokemon..."))
    altri = SCAMBI.reject { |a, _b| a == vol }.select { |a, b| GameData::Species.exists?(a) && GameData::Species.exists?(b) }
    d[banco] = altri.sample
  end
end
