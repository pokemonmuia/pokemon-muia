#===============================================================================
# Muia - Intro: alla domanda "Ma te son un omo o una baba?" se vedi subito
# chi te scieglierà, mentre te move el cursor:
#   Omo    -> introBoy      Baba -> introGirl      Fluido -> Abra (introMarill)
# No se toca la mapa (Map001): l'evento resta uguale, qua se mostra solo
# l'immagine 3 (e la pedana, immagine 2) intanto che la scelta xe verta.
#===============================================================================
module MuiaIntro
  MAPPA  = 1
  SCELTE = { "Omo" => "introBoy", "Baba" => "introGirl", "Fluido" => "introMarill" }

  def self.anteprima(finestra)
    return unless $game_map && $game_map.map_id == MAPPA && $game_screen
    comandi = finestra.commands rescue nil
    return unless comandi.is_a?(Array) && comandi.map(&:to_s) == SCELTE.keys
    nome = SCELTE[comandi[finestra.index].to_s]
    return if nome.nil?
    immagine = $game_screen.pictures[3]
    if immagine.name != nome || immagine.opacity < 255
      immagine.show(nome, 1, 256, 178, 100, 100, 255, 0)
    end
    pedana = $game_screen.pictures[2]
    if pedana.name != "introbase" || pedana.opacity < 255
      pedana.show("introbase", 1, 256, 256, 100, 100, 255, 0)
    end
  rescue StandardError
    nil
  end
end

class Window_CommandPokemonEx
  alias muia_intro_update update unless method_defined?(:muia_intro_update)

  def update
    muia_intro_update
    MuiaIntro.anteprima(self)
  end
end
