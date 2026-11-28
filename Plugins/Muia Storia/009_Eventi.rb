#===============================================================================
# Muia - Storia: quali personaggi va in quala mapa
#===============================================================================
module MuiaStoria
  def self.zonta(map_id, map)
    aggiorna(false)
    case map_id
    when MAPA_PIAZZA
      # Regista dela scena (invisibile, parti da solo quando te esci dal Comun)
      metti(map, evento(1001, 0, 0, [{}, { var: [VAR_TRAMA, 3], trig: 3, cmd: "MuiaStoria.scena_piazza" },
                                     { var: [VAR_TRAMA, 4] }]))
      FOLLA.each do |id, x, y, gfx, dir|
        metti(map, evento(id, x, y, [{}, { var: [VAR_TRAMA, 3], gfx: gfx, dir: dir, through: true },
                                     { var: [VAR_TRAMA, 4] }]))
      end
      # Tubo (compar solo durante la scena)
      metti(map, evento(1010, 34, 9, [{}, { var: [VAR_TRAMA, 3], through: true }, { var: [VAR_TRAMA, 5] }]))
      # La mama coi scarponcini (compar solo durante la scena)
      metti(map, evento(1011, 20, 12, [{}, { var: [VAR_TRAMA, 3], through: true }, { var: [VAR_TRAMA, 5] }]))
    when MAPA_ZUPPO
      metti(map, evento(1020, 7, 4, [{ gfx: "NPC 24", dir: 2, cmd: "MuiaStoria.ornella" }], "Siora Ornella"))
    when MAPA_BLOCO
      # Una casela dentro Via Roma_2 (riga 13): ala riga 14 el zogador riva da
      # Calle Parini Alta, che xe n'altra mapa, e no se podeva parlarghe (1.53)
      metti(map, evento(1080, 53, 13, [{}, { sw: SW_SFILATA, gfx: TUBO_GRAFICA, dir: 2,
                                             cmd: "MuiaStoria.posto_de_bloco" }], "Tubo (posto de bloco)"))
      metti(map, evento(1081, 54, 13, [{}, { sw: SW_SFILATA, tile: 559, cmd: "MuiaStoria.posto_de_bloco" }]))
    when MAPA_MOLO
      metti(map, evento(1085, 64, 13, [{ gfx: "trainer_SAILOR", dir: 8, cmd: "MuiaStoria.controlor" }],
                        "Controlor del Delfin Verde"))
    when MAPA_CASA
      if mapa_da_dar?
        metti(map, evento(1095, 0, 0, [{ trig: 3, cmd: "MuiaStoria.mama_mapa" }]))
      end
    end
    if imboscada_da_far(map_id)
      metti(map, evento(1090, 0, 0, [{ trig: 3, through: true, cmd: "MuiaStoria.imboscada" }], "Tubo (imboscada)"))
    end
    zonta_blochi(map_id, map)
    zonta_porte(map_id, map) if respond_to?(:zonta_porte)
    zonta_bar(map_id, map) if respond_to?(:zonta_bar)
    zonta_frazioni(map_id, map) if respond_to?(:zonta_frazioni)
  end
end

EventHandlers.add(:on_game_map_setup, :muia_storia,
  proc { |map_id, map, _tileset|
    MuiaStoria.zonta(map_id, map)
  }
)
