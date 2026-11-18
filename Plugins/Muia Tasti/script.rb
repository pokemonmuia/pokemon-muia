#===============================================================================
# Muia - Tasti da tastiera, uguali su Windows, Mac e versione web, e
#        personalizzabili da "Conza el zogo" → "Tasti" (do tasti par azion)
#
#   Azion                 Tasti de base        Boton del zogo
#   Conferma (A)          Z, Spazio (+ Invio)  Input::USE
#   Indrio / Corer (B)    X, Back              Input::BACK
#   Menu / Esci           Esc                  sulla mapa verzi el menu (ACTION);
#                                              nei menu torna indrio (BACK)
#   Funzion               Shift                Input::ACTION (nei menu: scambia,
#                                              ordina, verso, cerca...)
#   Menu rapido (SELECT)  D                    Input::SPECIAL
#   Frecie                caminar (fisse)
#
# Game.exe: qua se lexe la tastiera vera (metodi "ex" de mkxp-z) e se toe i
# tasti che mkxp-z ghe meteria de base. I gamepad no i cambia.
# Browser: la tastiera la tradusi la pagina (web/gioca/main.ts e ponte.ts) e
# i tasti se cambia in una finestra della pagina; qua el zogo ghe dise solo se
# el zogador xe "libero sulla mapa" (par Esc) e ghe domanda de verzer la finestra.
# Sul telefono: solo i tasti a schermo.
#===============================================================================
module MuiaTasti
  AZIONI = [
    [:conferma, "Conferma (A)"],
    [:indietro, "Indrio / Corer (B)"],
    [:menu,     "Menu / Esci"],
    [:funzione, "Funzion"],
    [:rapido,   "Menu rapido"]
  ]
  PREDEFINITI = {
    conferma: [:Z, :SPACE],
    indietro: [:X, :BACKSPACE],
    menu:     [:ESCAPE, nil],
    funzione: [:LSHIFT, nil],
    rapido:   [:D, nil]
  }
  # Tasti che se pol sceglier
  CATTURABILI = (("A".."Z").map(&:to_sym) +
                 [:SPACE, :RETURN, :ESCAPE, :BACKSPACE, :TAB, :LSHIFT, :RSHIFT,
                  :LCTRL, :RCTRL, :LALT, :RALT])
  NOMI = {
    SPACE: "Spazio", RETURN: "Invio", ESCAPE: "Esc", BACKSPACE: "Back",
    TAB: "Tab", LSHIFT: "Shift", RSHIFT: "Shift dx", LCTRL: "Ctrl",
    RCTRL: "Ctrl dx", LALT: "Alt", RALT: "Alt dx"
  }
  # Quel che mkxp-z mete de base sulla tastiera par ogni boton (vien tolto)
  BASE_MKXP = {
    Input::C => [:SPACE, :RETURN, :C, :KP_ENTER],
    Input::B => [:ESCAPE, :X, :KP_0],
    Input::A => [:LSHIFT, :RSHIFT, :Z],
    Input::Z => [:D],
    Input::X => [:A],
    Input::Y => [:S],
    Input::L => [:Q],
    Input::R => [:W]
  }
  FILE = "muia_tasti.txt"

  def self.nome_tasto(k)
    return "-" if k.nil?
    return NOMI[k] || k.to_s
  end

  def self.web?
    return defined?(MuiaWeb) && MuiaWeb.web?
  end

  # Solo con Game.exe: nel browser i metodi "ex" no vedi la tastiera
  def self.attivo?
    return @attivo unless @attivo.nil?
    @attivo = !web? && Input.respond_to?(:pressex?)
    return @attivo
  end

  def self.config
    carica if @config.nil?
    return @config
  end

  def self.percorso
    return File.join(System.data_directory, FILE)
  rescue StandardError
    return FILE
  end

  def self.carica
    @config = {}
    PREDEFINITI.each { |a, t| @config[a] = t.dup }
    return unless File.exist?(percorso)
    File.readlines(percorso).each do |riga|
      azion, tasti = riga.strip.split("=", 2)
      next if tasti.nil? || !PREDEFINITI.key?(azion.to_sym)
      lista = tasti.split(",").map { |t| (t == "-" || t.empty?) ? nil : t.to_sym }
      lista = lista.map { |t| CATTURABILI.include?(t) ? t : nil }
      @config[azion.to_sym] = [lista[0], lista[1]]
    end
  rescue StandardError
    @config = nil
    @config = {}
    PREDEFINITI.each { |a, t| @config[a] = t.dup }
  end

  def self.salva
    File.open(percorso, "wb") do |f|
      config.each { |a, t| f.write("#{a}=#{t.map { |k| k || '-' }.join(',')}\n") }
    end
    @usati = nil
  rescue StandardError
    nil
  end

  def self.ripristina
    @config = {}
    PREDEFINITI.each { |a, t| @config[a] = t.dup }
    salva
  end

  def self.usati
    @usati ||= config.values.flatten.compact + [:RETURN]
    return @usati
  end

  # Libero sulla mapa: Esc verzi el menu. Altrimenti (menu, lote, messagi,
  # schermata iniziale) Esc torna indrio.
  def self.mappa_libera?
    return false unless $scene.is_a?(Scene_Map)
    return false if $game_temp.nil? || $game_temp.in_menu || $game_temp.in_battle
    return false if $game_temp.message_window_showing
    return false if pbMapInterpreterRunning?
    return true
  rescue StandardError
    return false
  end

  # Tasti che fa scatar un boton del zogo, adesso
  def self.tasti_per(boton)
    c = config
    case boton
    when Input::USE    then return c[:conferma] + [:RETURN]
    when Input::BACK   then return mappa_libera? ? c[:indietro] : c[:indietro] + c[:menu]
    when Input::ACTION then return mappa_libera? ? c[:funzione] + c[:menu] : c[:funzione]
    when Input::SPECIAL then return c[:rapido]
    end
    return []
  end
end

module Input
  class << self
    [[:press?, :pressex?], [:trigger?, :triggerex?],
     [:repeat?, :repeatex?], [:release?, :releaseex?]].each do |metodo, ex|
      originale = :"muia_tasti_#{metodo.to_s.chomp('?')}"
      next if method_defined?(originale) || !method_defined?(metodo)
      alias_method originale, metodo
      define_method(metodo) do |boton|
        risultato = send(originale, boton)
        next risultato unless MuiaTasti.attivo?
        begin
          base = MuiaTasti::BASE_MKXP[boton]
          gestito = [Input::USE, Input::BACK, Input::ACTION, Input::SPECIAL].include?(boton)
          if risultato && base
            # Se el boton xe scatà par un tasto de base de mkxp-z, no conta
            # (i tasti giusti xe quei scelti); par i altri boton se toe solo
            # i tasti che xe usai par qualcos'altro.
            da_togliere = gestito ? base : base.select { |k| MuiaTasti.usati.include?(k) }
            risultato = false if da_togliere.any? { |k| send(ex, k) }
          end
          if !risultato && gestito
            risultato = MuiaTasti.tasti_per(boton).compact.any? { |k| send(ex, k) }
          end
        rescue StandardError
          # se el motor no conossi un tasto, se tien quel che gavevimo
        end
        risultato
      end
    end
  end
end

#===============================================================================
# Schermata par cambiar i tasti (Game.exe)
#===============================================================================
module MuiaTasti
  def self.schermata
    if web?
      return MuiaWeb.apri_tasti if defined?(MuiaWeb) && MuiaWeb.respond_to?(:apri_tasti)
      return
    end
    unless attivo?
      pbMessage(_INTL("Qua no se pol cambiar i tasti."))
      return
    end
    indice = 0
    loop do
      comandi = AZIONI.map do |a, nome|
        t = config[a]
        "#{nome}:  #{nome_tasto(t[0])} / #{nome_tasto(t[1])}"
      end
      comandi.push(_INTL("Rimeti come prima"), _INTL("Fato"))
      scelta = pbMessage(_INTL("Che tasto te vol cambiar? (Invio conferma sempre)"),
                         comandi, comandi.length, nil, indice)
      break if scelta < 0 || scelta == comandi.length - 1
      indice = scelta
      if scelta == AZIONI.length
        if pbConfirmMessage(_INTL("Rimeter tuti i tasti come prima?"))
          ripristina
        end
        next
      end
      azion, nome = AZIONI[scelta]
      t = config[azion]
      posto = pbMessage(_INTL("{1}: quale te vol cambiar?", nome),
                        [_INTL("Primo ({1})", nome_tasto(t[0])),
                         _INTL("Secondo ({1})", nome_tasto(t[1])),
                         _INTL("Togli el secondo"), _INTL("Anula")], 4)
      next if posto < 0 || posto == 3
      if posto == 2
        config[azion][1] = nil
        salva
        next
      end
      tasto = cattura(nome)
      next if tasto.nil?
      # el stesso tasto no pol far do robe: se toe da dove el iera
      config.each_value { |lista| lista.map! { |k| k == tasto ? nil : k } }
      config[azion][posto] = tasto
      config[:conferma][0] ||= :Z   # Conferma ga sempre almeno un tasto
      salva
    end
  end

  # Speta un tasto (10 secondi), mostrando un messagio
  def self.cattura(nome)
    finestra = pbCreateMessageWindow
    finestra.letterbyletter = false
    finestra.text = _INTL("Schicia el tasto novo par \"{1}\"...", nome)
    # se speta che i tasti sia molai, cussì no se ciapa el Invio de prima
    20.times { Graphics.update; Input.update; finestra.update }
    t0 = System.uptime
    trovato = nil
    loop do
      Graphics.update
      Input.update
      finestra.update
      trovato = CATTURABILI.find { |k| Input.triggerex?(k) rescue false }
      break if trovato || System.uptime - t0 > 10
    end
    pbDisposeMessageWindow(finestra)
    Input.update
    return trovato
  end
end

#===============================================================================
# Voce "Tasti" in "Conza el zogo"
#===============================================================================
class MuiaBotonOption < EnumOption
  def etichetta
    return values[0]
  end
end

class Window_PokemonOption
  alias muia_tasti_drawItem drawItem unless method_defined?(:muia_tasti_drawItem)

  def drawItem(index, count, rect)
    opzion = @options[index]
    return muia_tasti_drawItem(index, count, rect) unless opzion.is_a?(MuiaBotonOption)
    rect = drawCursor(index, rect)
    sel = (index == self.index)
    larghezza = rect.width * 9 / 20
    pbDrawShadowText(self.contents, rect.x, rect.y, larghezza, rect.height, opzion.name,
                     sel ? SEL_NAME_BASE_COLOR : self.baseColor,
                     sel ? SEL_NAME_SHADOW_COLOR : self.shadowColor)
    pbDrawShadowText(self.contents, rect.x + larghezza, rect.y, larghezza, rect.height,
                     opzion.etichetta, self.baseColor, self.shadowColor)
  end
end

class PokemonOption_Scene
  def pbOptions
    pbActivateWindow(@sprites, "option") do
      index = -1
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].index != index
          pbChangeSelection
          index = @sprites["option"].index
        end
        @options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE)
          break if @sprites["option"].index == @options.length
          if @options[index].is_a?(MuiaBotonOption)
            pbPlayDecisionSE
            @hashes[index]["muia_azione"]&.call(self)
            pbChangeSelection
          end
        end
      end
    end
  end
end

MenuHandlers.add(:options_menu, :muia_tasti, {
  "name"        => _INTL("Tasti"),
  "order"       => 115,
  "type"        => MuiaBotonOption,
  "parameters"  => [_INTL("Schicia A")],
  "description" => _INTL("Cambia i tasti della tastiera (do par azion)."),
  "get_proc"    => proc { next 0 },
  "set_proc"    => proc { |_value, _scene| },
  "muia_azione" => proc { |_scene| MuiaTasti.schermata }
})

#===============================================================================
# Testo veloce de base (par chi verzi el zogo la prima volta)
#===============================================================================
class PokemonSystem
  alias muia_tasti_initialize initialize unless private_method_defined?(:muia_tasti_initialize)

  def initialize
    muia_tasti_initialize
    @textspeed = 2   # 0 lento, 1 medio, 2 veloce, 3 subito
  end
end
