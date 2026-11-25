#===============================================================================
# Muia - Versione del zogo e salvataggi che passa da una versione a l'altra
#
# 1. La versione la xe scrita SOLO in version.txt (in cima al repo), tipo 1.01.
#    Ogni push su main la cressi de 0.01 (vedi CLAUDE.md). Qua se la lezi a
#    l'avvio e la diventa Settings::GAME_VERSION, che Essentials scrivi in
#    ogni salvataggio.
# 2. Quando se verzi un salvataggio fato con una versione diversa, prima de
#    tocarlo se ghe fa una copia: Game.rxdata.v<versione vecia>.bak
# 3. Se un salvataggio vecio ga bisogno de esser sistemà (mapa rifata, ID
#    cambiai...), se zonta una "conversione" in fondo a sto file. Essentials
#    la fa partir da solo, una volta sola, sui salvataggi più veci de quela
#    versione. Esempio in fondo.
#
# I numeri va sempre con do cifre dopo el punto (1.01, 1.02 ... 1.09, 1.10):
# Essentials confronta le versioni cifra per cifra.
#===============================================================================
module MuiaAggiornamenti
  FILE_VERSIONE = "version.txt"
  # Se version.txt no se trova, se resta su questa (quela dei primi salvataggi)
  VERSIONE_DE_RISERVA = "1.0.0"

  def self.lezi_versione
    testo = nil
    begin
      testo = File.read(FILE_VERSIONE) if FileTest.exist?(FILE_VERSIONE)
    rescue StandardError
      testo = nil
    end
    if testo.nil?
      # Versione web e zoghi impachetai: el file xe dentro l'archivio
      begin
        testo = load_data(FILE_VERSIONE, true)
      rescue StandardError, RGSSError, MKXPError
        testo = nil
      end
    end
    versione = testo.to_s.strip.sub(/\Av/i, "")
    return versione if versione[/\A\d+\.\d\d\z/]
    echoln("Muia Aggiornamenti: #{FILE_VERSIONE} no trovà o sbaglià, uso #{VERSIONE_DE_RISERVA}") rescue nil
    return VERSIONE_DE_RISERVA
  end

  def self.versione
    return Settings::GAME_VERSION
  end

  # Copia del salvataggio prima che una versione diversa lo cambi
  def self.copia_de_sicurezza(file)
    return if !File.file?(file)
    dati = SaveData.get_data_from_file(file)
    vecia = dati.is_a?(Hash) ? dati[:game_version] : nil
    return if vecia.nil? || vecia == versione
    copia = "#{file}.v#{vecia}.bak"
    return if File.file?(copia)
    File.binwrite(copia, File.binread(file))
    echoln("Muia Aggiornamenti: salvataggio v#{vecia} copià in #{copia}") rescue nil
  rescue StandardError
    # la copia xe solo una sicurezza in più: se no la riessi, se va avanti
  end
end

# La versione de version.txt diventa quela del zogo
module Settings
  remove_const(:GAME_VERSION) if const_defined?(:GAME_VERSION, false)
  GAME_VERSION = MuiaAggiornamenti.lezi_versione
end

module SaveData
  class << self
    unless method_defined?(:muia_read_from_file)
      alias_method :muia_read_from_file, :read_from_file
      def read_from_file(file_path)
        MuiaAggiornamenti.copia_de_sicurezza(file_path)
        return muia_read_from_file(file_path)
      end
    end
  end
end

# Versione picia in basso a destra nella schermata del titolo
class IntroEventScene
  [:open_title_screen, :open_title_after_movie].each do |metodo|
    originale = :"muia_versione_#{metodo}"
    next if method_defined?(originale) || !method_defined?(metodo)
    alias_method originale, metodo
    define_method(metodo) do |*args|
      send(originale, *args)
      muia_mostra_versione
    end
  end

  def muia_mostra_versione
    return if @muia_versione
    @muia_versione = Sprite.new(@viewport)
    @muia_versione.bitmap = Bitmap.new(Graphics.width, 24)
    @muia_versione.y = Graphics.height - 24
    @muia_versione.z = 99_999
    pbSetSmallFont(@muia_versione.bitmap)
    pbDrawTextPositions(@muia_versione.bitmap,
                        [["v#{MuiaAggiornamenti.versione}", Graphics.width - 6, 4, :right,
                          Color.new(248, 248, 248), Color.new(40, 40, 40)]])
    addUserSprite(@muia_versione)
  rescue StandardError
    # se qualcosa no va, el titolo resta come prima
  end
end

#===============================================================================
# CONVERSIONI DEI SALVATAGGI
# Una per ogni versione che cambia qualcosa che xe za nei salvataggi.
# "game_version" = la versione che porta la modifica: la conversione la parti
# solo sui salvataggi fati PRIMA de quela.
#
# Esempio (no ativo):
#
# SaveData.register_conversion(:muia_1_05_mapa_12_rifata) do
#   game_version "1.05"
#   display_title "1.05: mapa 12 rifata"
#   to_value :game_player do |player|
#     # ...
#   end
#   to_all do |save_data|
#     # save_data[:variables], save_data[:switches], save_data[:player] ...
#   end
# end
#
# Per adesso nissuna: i salvataggi de la 1.0.0 va ben cussì come i xe.
#===============================================================================

# 1.29: storia nova (folla in piazza, Libreto, posto de bloco de Tubo).
# Chi che ga za parlà con Fulvio (ex Dejan) salta el novo prologo, cussì no
# el resta bloccà de là dele transenne de Via Roma.
SaveData.register_conversion(:muia_1_29_storia_nova) do
  game_version "1.29"
  display_title "1.29: storia nova"
  to_all do |save_data|
    variabili = save_data[:variables]
    if variabili && variabili[27].is_a?(Integer) && variabili[27] >= 4
      variabili[27] = 7
    end
  end
end
