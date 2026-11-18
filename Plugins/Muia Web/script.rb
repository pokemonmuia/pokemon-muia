#===============================================================================
# Muia - Scriver el nome con la tastiera vera, e "Esci dal gioco" che funziona
#
# 1) Scriver testo (nome del zogador, sopranomi, scatole...):
#    - Game.exe sul PC: se dopra sempre la tastiera del PC (mai più la tastiera
#      del zogo con le letere da scieglier).
#    - Browser (PC e telefono): el zogo ghe domanda alla pagina, che mostra una
#      casela de testo vera: sul PC se scrive con la tastiera, sul telefono vien
#      fora la tastiera del telefono. Invio (o "Va ben") e se torna al zogo.
#      Se la pagina no risponde, se dopra la tastiera del zogo come prima.
#
# 2) "Esci dal gioco" (schermata iniziale) e "Torna Caje" (menu de pausa):
#    prima de uscir el zogo domanda se se xe sicuri. Sul PC el se sera; nel
#    browser la pagina se sera (o torna al sito), invece de restar nel menu de
#    RetroArch (quel che pareva un menu de debug).
#
# Protocolo coi file (cartela dei salvataggi, come el multiplayer, vedi
# 004_VMS_Web_Bridge.rb e web/gioca/ponte.ts). Ogni file finisse con "MUIA":
#   muia_txt_<sigla>_1.bin     zogo -> pagina : min \n max \n testo iniziale \n domanda
#   muia_txtris_<sigla>_1.bin  pagina -> zogo : "ok\n<testo>" o "anula"
#   muia_esci_<sigla>_1.bin    zogo -> pagina : "esci"
# La pagina toe el file "txt" appena la mostra la casela: cussì el zogo sa
# che la pagina ghe xe.
#===============================================================================
module MuiaWeb
  FINE = "MUIA".b
  ATTESA_PAGINA = 4   # secondi par veder se la pagina risponde

  def self.web?
    return VMS.web? if defined?(VMS) && VMS.respond_to?(:web?)
    return false
  end

  def self.cartela
    return System.data_directory
  end

  def self.scrivi(tipo, sigla, testo)
    nome = "muia_#{tipo}_#{sigla}_00000001.bin"
    File.binwrite(File.join(cartela, nome), testo.to_s.b + FINE)
    return nome
  end

  def self.leggi(nome)
    percorso = File.join(cartela, nome)
    return nil unless File.exist?(percorso)
    dati = File.binread(percorso)
    return nil unless dati.end_with?(FINE)
    return dati[0...-FINE.bytesize].force_encoding("UTF-8")
  rescue Exception
    return nil
  end

  def self.nova_sigla
    return (Time.now.to_f * 1000).to_i.to_s(36) + rand(36 * 36).to_s(36)
  end

  # Torna el testo scrito, "" se anulà, o nil se la pagina no risponde
  def self.chiedi_testo(domanda, minimo, massimo, iniziale)
    sigla = nova_sigla
    richiesta = scrivi("txt", sigla, [minimo, massimo, iniziale.to_s.gsub("\n", " "),
                                      domanda.to_s.gsub("\n", " ")].join("\n"))
    risposta = "muia_txtris_#{sigla}_00000001.bin"
    t0 = Time.now
    frame = 0
    loop do
      Graphics.update
      Input.update
      frame += 1
      next unless frame % 4 == 0   # leggere la cartela costa
      if File.exist?(File.join(cartela, richiesta))
        # La pagina no la ga ancora vista: se dopo un poco gnente, se lassa perder
        if Time.now - t0 > ATTESA_PAGINA
          File.delete(File.join(cartela, richiesta)) rescue nil
          return nil
        end
        next
      end
      testo = leggi(risposta)
      next if testo.nil?
      return testo.sub(/\Aok\n/, "") if testo.start_with?("ok\n")
      return ""
    end
  end

  # Domanda se uscir; torna false se no. Nel browser, se sì, no torna mai.
  def self.conferma_uscita(gia_chiesto = false)
    unless gia_chiesto
      return false unless pbConfirmMessage(_INTL("Te vol proprio uscir dal zogo?"))
    end
    return true unless web?
    scrivi("esci", nova_sigla, "esci")
    pbBGMFade(0.5) rescue nil
    loop do   # la pagina se sera: intanto se speta
      Graphics.update
      Input.update
    end
  end
end

#-------------------------------------------------------------------------------
# Scriver testo
#-------------------------------------------------------------------------------
unless defined?(muia_web_pbEnterText_originale)
  alias muia_web_pbEnterText_originale pbEnterText
end

def pbEnterText(helptext, minlength, maxlength, initialText = "", mode = 0, pokemon = nil, nofadeout = false)
  if MuiaWeb.web?
    ret = MuiaWeb.chiedi_testo(helptext, minlength, maxlength, initialText)
    unless ret.nil?
      ret = ret[0, maxlength] if maxlength > 0
      Input.update
      return ret
    end
    # la pagina no risponde: tastiera del zogo come prima
    return muia_web_pbEnterText_originale(helptext, minlength, maxlength, initialText, mode, pokemon, nofadeout)
  end
  # Sul PC sempre la tastiera vera
  $PokemonSystem.textinput = 1 if $PokemonSystem
  return muia_web_pbEnterText_originale(helptext, minlength, maxlength, initialText, mode, pokemon, nofadeout)
end

#-------------------------------------------------------------------------------
# "Esci dal gioco" nella schermata iniziale: prima se domanda
#-------------------------------------------------------------------------------
class PokemonLoad_Scene
  alias muia_web_pbChoose pbChoose unless method_defined?(:muia_web_pbChoose)

  def pbChoose(commands)
    loop do
      ret = muia_web_pbChoose(commands)
      return ret unless commands[ret] == _INTL("Quit Game")
      return ret if MuiaWeb.conferma_uscita
      pbPlayCancelSE rescue nil
    end
  end
end

#-------------------------------------------------------------------------------
# "Torna Caje" nel menu de pausa: come prima (domanda e salva), ma nel browser
# la pagina se sera invece de finir nel menu de RetroArch
#-------------------------------------------------------------------------------
MenuHandlers.add(:pause_menu, :quit_game, {
  "name"      => _INTL("Torna Caje"),
  "order"     => 90,
  "effect"    => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Te son proprio sicuro de voler tornar a caje?"))
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      menu.pbEndScene
      MuiaWeb.conferma_uscita(true)
      $scene = nil
      next true
    end
    menu.pbRefresh
    menu.pbShowMenu
    next false
  }
})
