#===============================================================================
# Muia - Prova de rete (TEMPORANEA)
#
# Serve solo a capir se el motor del browser (versione web e telefono) riesce
# a verzer i "socket" che el multiplayer dopra. Compare nel menu de pausa come
# "Prova rete". Dopo el test se toia via.
#
# I risultati i vien mostrai a schermo e scrivui anca in "Prova_rete.txt"
# (nella cartela dei salvataggi se se pol).
#===============================================================================
module MuiaProvaRete
  def self.prova(nome)
    t0 = Time.now
    esito = begin
      "OK " + yield.to_s
    rescue Exception => e
      "ERORE #{e.class}: #{e.message}"
    end
    riga = "#{nome}: #{esito} (#{((Time.now - t0) * 1000).round} ms)"
    echoln riga
    return riga
  end

  def self.mostra(righe)
    righe.each_slice(3) { |gruppo| pbMessage(gruppo.join("\n")) }
  end

  def self.salva(righe)
    File.open("Prova_rete.txt", "w") { |f| f.puts(righe) }
  rescue Exception
    nil
  end

  def self.esegui
    righe = []
    righe << "Piataforma: #{(System.platform rescue '?')}"
    righe << prova("require socket") { require 'socket'; "caricà" }
    righe << prova("TCPSocket definì") { defined?(TCPSocket).inspect }
    righe << prova("UDPSocket definì") { defined?(UDPSocket).inspect }
    righe << prova("UDPSocket.new") { s = UDPSocket.new; s.close; "creà" }
    righe << prova("UDP connect+send") do
      s = UDPSocket.new
      s.connect(VMS::EXTERNALHOST, VMS::EXTERNALPORT)
      n = s.send("prova", 0)
      s.close
      "mandai #{n} byte"
    end
    mostra(righe)
    if pbConfirmMessage("Provo anca el TCP. Se el zogo se bloca, ricarica la pagina. Vao avanti?")
      righe << prova("TCP a 127.0.0.1:9") { TCPSocket.new("127.0.0.1", 9).close; "conetù" }
      righe << prova("TCP a #{VMS::EXTERNALHOST}") { TCPSocket.new(VMS::EXTERNALHOST, VMS::EXTERNALPORT).close; "conetù" }
      mostra(righe.last(2))
    end
    salva(righe)
    pbMessage("Test finì. Scrivi a Claude cossa te vedi.")
  end
end

MenuHandlers.add(:pause_menu, :muia_prova_rete, {
  "name"      => "Prova rete",
  "order"     => 99,
  "condition" => proc { true },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    MuiaProvaRete.esegui
    menu.pbShowMenu
    menu.pbRefresh
    next false
  }
})
