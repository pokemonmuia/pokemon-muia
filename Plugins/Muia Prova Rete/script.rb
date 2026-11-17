#===============================================================================
# Muia - Prova de rete (TEMPORANEA)
#
# Serve solo a capir se el zogo, nel browser, pol parlar con la pagina
# scrivendo file nella cartela dei salvataggi (el browser no gà socket).
# Compare nel menu de pausa come "Prova rete". Dopo el test se toia via.
#===============================================================================
module MuiaProvaRete
  def self.corto(testo, max = 44)
    testo = testo.to_s.gsub(/\s+/, " ")
    return testo.length > max ? testo[0, max - 1] + "…" : testo
  end

  def self.prova(nome)
    t0 = Time.now
    esito = begin
      "OK " + yield.to_s
    rescue Exception => e
      "ERORE " + e.class.to_s
    end
    return corto("#{nome}: #{esito}") + " " + corto("(#{((Time.now - t0) * 1000).round} ms)")
  end

  def self.vedo(cartela)
    nomi = Dir.entries(cartela).select { |n| n.start_with?("muia_") }
    return corto("vedo: " + (nomi.empty? ? "gnente" : nomi.join(" ")), 60)
  rescue Exception => e
    return corto("vedo: " + e.class.to_s)
  end

  def self.eco(cartela, numero)
    sigla = "#{(Time.now.to_f * 1000).to_i}_#{numero}"
    entra = File.join(cartela, "muia_in_#{sigla}.txt")
    File.write(File.join(cartela, "muia_out_#{sigla}.txt"), "ciao#{numero}")
    t0 = Time.now
    while Time.now - t0 < 3
      Graphics.update
      if Dir.entries(cartela).include?("muia_in_#{sigla}.txt")
        testo = File.read(entra)
        return "risposta" if testo.end_with?("#fine")
      end
    end
    raise "nissuna risposta"
  end

  def self.esegui
    cartela = System.data_directory
    righe = []
    righe << corto("cartela: " + cartela.to_s, 60)
    righe << prova("scrivo in cartela") { File.write(File.join(cartela, "muia_prova.tmp"), "x").to_s }
    3.times do |i|
      riga = prova("ponte eco #{i + 1}") { eco(cartela, i) }
      righe << riga
      righe << vedo(cartela) if riga.include?("ERORE")
    end
    righe.each_slice(2) { |g| pbMessage(g.join("\n")) }
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
