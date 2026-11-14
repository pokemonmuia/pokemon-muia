# Alleggerisce la versione web: trova le specie di Pokémon che il gioco usa
# davvero e stampa i file di sprite, icone, impronte e versi delle ALTRE
# specie, che la build web lascia fuori dal pacchetto.
#
# Se nel gioco compare una specie esclusa per errore non si blocca nulla:
# Essentials mostra lo sprite "?" (000) e non riproduce il verso.
#
# Uso (dalla cartella del gioco):  ruby web/gioca/specie_usate.rb
#   stampa su stdout i percorsi da escludere, su stderr un riepilogo.
require "zlib"
require "set"

# Tutte le specie definite in PBS/pokemon.txt
all_species = Set.new
evolutions = Hash.new { |h, k| h[k] = Set.new }
current = nil
File.foreach("PBS/pokemon.txt", encoding: "bom|utf-8") do |line|
  if line =~ /^\[([A-Z0-9]+)\]/
    current = $1
    all_species << current
  elsif current && line =~ /^\s*Evolutions\s*=\s*(.+)$/
    $1.split(",").map(&:strip).each_slice(3) do |target, _method, _param|
      next if target.nil? || target.empty?
      evolutions[current] << target
      evolutions[target] << current
    end
  end
end

used = Set.new
scan = lambda do |text|
  text.scan(/[A-Z][A-Za-z0-9]+/) { |tok| used << tok if all_species.include?(tok) }
end

# PBS che piazzano davvero Pokémon nel gioco
%w[encounters.txt trainers.txt].each do |f|
  path = "PBS/#{f}"
  scan.call(File.read(path, encoding: "bom|utf-8")) if File.exist?(path)
end

# Mappe ed eventi comuni (pbAddPokemon, lotte con selvatici, regali...)
collect_strings = lambda do |obj, out|
  case obj
  when String then out << obj
  when Array then obj.each { |o| collect_strings.call(o, out) }
  when Hash then obj.each { |k, v| collect_strings.call(k, out); collect_strings.call(v, out) }
  else
    obj.instance_variables.each { |iv| collect_strings.call(obj.instance_variable_get(iv), out) } rescue nil
  end
end
Dir.glob("Data/{Map[0-9]*,CommonEvents,Troops}.rxdata").each do |f|
  # Le classi di RPG Maker non esistono qui: leggo i byte grezzi, le stringhe
  # degli script degli eventi sono salvate in chiaro.
  scan.call(File.binread(f).force_encoding("BINARY").encode("UTF-8", invalid: :replace, undef: :replace))
end

# Plugin (codice aggiunto da voi): stringhe compresse dentro PluginScripts
if File.exist?("Data/PluginScripts.rxdata")
  strings = []
  collect_strings.call(Marshal.load(File.binread("Data/PluginScripts.rxdata")), strings) rescue nil
  strings.each do |s|
    text = (Zlib::Inflate.inflate(s) rescue s)
    scan.call(text.force_encoding("UTF-8").scrub)
  end
end
Dir.glob("Plugins/**/*.rb").each { |f| scan.call(File.read(f).scrub) }

# Famiglie evolutive complete (se evolve, deve vedersi bene anche dopo)
queue = used.to_a
until queue.empty?
  sp = queue.pop
  evolutions[sp].each do |o|
    next if used.include?(o) || !all_species.include?(o)
    used << o
    queue << o
  end
end

dirs = Dir.glob("Graphics/Pokemon/*/") + ["Audio/SE/Cries/"]
excluded = []
dirs.each do |dir|
  next if dir.include?("Eggs") || dir.include?("Shadow")
  Dir.children(dir).each do |name|
    base = name.sub(/\.[^.]+\z/, "").split("_").first
    next unless all_species.include?(base)   # 000 e file non di specie: si tengono
    next if used.include?(base)
    excluded << File.join(dir, name)
  end
end

warn "Specie definite: #{all_species.size}, usate dal gioco: #{used.size}, file esclusi: #{excluded.size}"
warn "Specie tenute: #{used.to_a.sort.join(', ')}"
puts excluded
