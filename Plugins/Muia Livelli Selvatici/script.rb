#===============================================================================
# Muia - Livelli dei Pokémon selvatici legati alla squadra
#
# I Pokémon selvatici presi dalle tabelle di PBS/encounters.txt (erba, acqua,
# pesca, ecc.) escono a un livello compreso tra SOTTO livelli in meno e SOPRA
# livelli in più rispetto al Pokémon di livello più alto in squadra.
# I livelli scritti in encounters.txt vengono quindi ignorati.
#
# Non tocca i Pokémon degli eventi (regali, leggendari, lotte fisse).
# Per avere livelli fissi in una mappa, aggiungere "Flags = LivelliFissi" alla
# mappa in PBS/map_metadata.txt.
#===============================================================================
module MuiaLivelliSelvatici
  SOTTO          = 2   # quanti livelli sotto il più forte della squadra
  SOPRA          = 1   # quanti livelli sopra il più forte della squadra
  LIVELLO_MINIMO = 2

  def self.livello
    livelli = $player.party.reject { |pkmn| pkmn.egg? }.map { |pkmn| pkmn.level }
    return nil if livelli.empty?
    nuovo = livelli.max - SOTTO + rand(SOTTO + SOPRA + 1)
    return nuovo.clamp(LIVELLO_MINIMO, GameData::GrowthRate.max_level)
  end
end

EventHandlers.add(:on_wild_species_chosen, :muia_livelli_selvatici,
  proc { |encounter|
    next if !encounter
    next if $game_map.metadata&.has_flag?("LivelliFissi")
    nuovo = MuiaLivelliSelvatici.livello
    encounter[1] = nuovo if nuovo
  }
)
