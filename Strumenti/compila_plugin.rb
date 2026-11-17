# Aggiorna Data/PluginScripts.rxdata dai file in Plugins/ senza aprire il gioco.
#
# Game.exe e la versione web leggono i plugin SOLO da Data/PluginScripts.rxdata:
# i file .rb in Plugins/ vengono ricompilati da Essentials solo quando si prova
# il gioco da RPG Maker (modalità debug). Dopo aver cambiato o aggiunto un
# plugin senza provarlo da RPG Maker, lancia:
#
#   ruby Strumenti/compila_plugin.rb
#
# I plugin già presenti tengono il loro posto nell'ordine di caricamento; quelli
# nuovi vanno in fondo. Un plugin la cui cartella non c'è più viene tolto.
require "zlib"

RADICE = File.expand_path("..", __dir__)
FILE   = File.join(RADICE, "Data", "PluginScripts.rxdata")

def leggi_meta(dir)
  meta = {}
  script = []
  File.readlines(File.join(dir, "meta.txt"), encoding: "bom|utf-8").each do |riga|
    next if riga.strip.empty? || riga.strip.start_with?("#")
    chiave, valore = riga.split("=", 2).map(&:strip)
    next if valore.nil?
    valori = valore.split(",").map(&:strip)
    case chiave.upcase
    when "NAME"         then meta[:name] = valore
    when "VERSION"      then meta[:version] = valore
    when "ESSENTIALS"   then meta[:essentials] = valori
    when "CREDITS"      then meta[:credits] = valori
    when "REQUIRES"     then (meta[:dependencies] ||= []).push(*valori)
    when "SCRIPTS"      then script.push(*valori)
    when "LINK", "WEBSITE" then meta[:link] = valori[0]
    else meta[chiave.downcase.to_sym] = valori[0]
    end
  end
  tutti = Dir.glob("**/*.rb", base: dir).sort
  [meta, (script + tutti).uniq]
end

vecchio = File.file?(FILE) ? Marshal.load(File.binread(FILE)) : []
cartelle = Dir.glob(File.join(RADICE, "Plugins", "*", "meta.txt")).map { |f| File.dirname(f) }
nuovi = {}
cartelle.each do |dir|
  meta, script = leggi_meta(dir)
  abort "Manca Name in #{dir}/meta.txt" unless meta[:name]
  # tiene i metadati già compilati per i plugin esterni (es. Requires con versione)
  prima = vecchio.find { |n, _, _| n == meta[:name] }
  meta = prima[1] if prima && prima[1][:version] == meta[:version]
  codice = script.map { |f| [f, Zlib::Deflate.deflate(File.binread(File.join(dir, f)))] }
  nuovi[meta[:name]] = [meta[:name], meta, codice]
end

risultato = vecchio.map { |n, _, _| nuovi.delete(n) }.compact + nuovi.values
File.binwrite(FILE, Marshal.dump(risultato))
risultato.each { |n, m, s| puts "#{n} #{m[:version]} (#{s.size} file)" }
