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
