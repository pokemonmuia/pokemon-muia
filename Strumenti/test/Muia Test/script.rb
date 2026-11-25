#===============================================================================
# Muia Test: prova automatica del zogo (SOLO per il workflow "Test notte").
# NO la va in Plugins/: el workflow la copia là solo nel pacheto de prova.
#
# Parti subito in Piazza Marconi con un zogo novo, risponde da sola ai messagi
# e fa tuta la storia chiamando i metodi dei plugin. Scrivi tuto nella console
# (righe "MUIATEST ...") e el script prova.mjs fa le foto e salva el log.
#===============================================================================
module MuiaTest
  @ok = 0
  @errori = 0
  @fatto = false
  @scelte = []
  @conferme = []
  @messagi = 0
  class << self
    attr_accessor :scelte, :conferme, :vinci, :messagi
  end
  self.vinci = true

  def self.log(s)
    $stdout.puts("MUIATEST #{s}")
    $stdout.flush rescue nil
  end

  def self.passo(nome)
    log("== #{nome}")
    yield
    @ok += 1
    log("OK #{nome}")
  rescue Exception => e
    raise if e.is_a?(SystemExit)
    @errori += 1
    log("ERRORE #{nome}: #{e.class}: #{e.message}")
    (e.backtrace || [])[0, 8].each { |r| log("   #{r}") }
  end

  def self.verifica(cond, testo)
    if cond
      log("  si: #{testo}")
    else
      @errori += 1
      log("  NO: #{testo}")
    end
  end

  def self.foto(nome)
    log("FOTO #{nome}")
    pbWait(2.5)
  end

  def self.frames(n)
    n.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end

  def self.vai(map_id, x, y, dir = 2)
    $game_temp.player_new_map_id    = map_id
    $game_temp.player_new_x         = x
    $game_temp.player_new_y         = y
    $game_temp.player_new_direction = dir
    $game_temp.player_transferring  = true
    $scene.transfer_player(false)
    frames(4)
    log("  mapa #{$game_map.map_id} (#{$game_player.x},#{$game_player.y}) eventi=#{$game_map.events.size}")
  end

  # Fa el trasferimento che un evento ga preparà (porte, uscide)
  def self.fa_trasferimento
    return if !$game_temp.player_transferring
    $game_temp.transition_processing = false
    Graphics.transition(0) rescue nil
    $scene.transfer_player(false)
    frames(4)
    log("  trasferì in mapa #{$game_map.map_id} (#{$game_player.x},#{$game_player.y})")
  end

  def self.ev_muia
    $game_map.events.values.select { |e| e.id >= 900 }
  end

  # Controla che i eventi del plugin no sia dentro i muri
  def self.controla_eventi
    male = []
    ev_muia.each do |e|
      next if e.character_name == "" && e.tile_id == 0
      next if e.x == 0 && e.y == 0
      ok = $game_map.passable?(e.x, e.y, 0) rescue true
      male.push("#{e.id}@#{e.x},#{e.y}") if !ok
    end
    log("  eventi nei muri: #{male.join(' ')}") if !male.empty?
  end

  def self.tutto
    log("INIZIO versione #{Settings::GAME_VERSION}")
    log("plugin: #{PluginManager.plugins.join(', ')}") rescue nil
    $player.party.clear
    pbAddPokemonSilent(:FROAKIE, 5)
    $game_variables[7] = 1
    $player.money = 3000

    passo("tute le mape: creazion eventi") do
      mape = load_data("Data/MapInfos.rxdata")
      mape.keys.sort.each do |id|
        next if !pbRgssExists?(sprintf("Data/Map%03d.rxdata", id))
        next if [1].include?(id)
        begin
          m = Game_Map.new
          m.setup(id)
          n = m.events.values.count { |e| e.id >= 900 }
          log("  mapa #{id}: #{m.events.size} eventi (#{n} dei plugin)") if n > 0
        rescue Exception => e
          @errori += 1
          log("  ERRORE mapa #{id}: #{e.class} #{e.message}")
          log("     #{e.backtrace[0]}")
        end
      end
    end

    passo("scena in piazza (trama 3)") do
      $game_variables[27] = 3
      vai(42, 26, 10, 2)
      controla_eventi
      foto("piazza_folla")
      st = MuiaStoria.strada(31, 0, 26, 9)
      verifica(st, "strada dela mama dala cima dela piazza (#{st ? st.length : 'nil'} passi)")
      MuiaStoria.scena_piazza
      verifica(MuiaStoria.ev(1011).nil? || MuiaStoria.ev(1011).y <= 1 || MuiaStoria.ev(1011).instance_variable_get(:@erased), "mama tornada in cima (verso Cul de Nave)")
      verifica($game_variables[27] == 5, "trama = 5 dopo la scena (xe #{$game_variables[27]})")
      verifica($game_variables[29] >= 1, "prima lota con Tubo fata")
      frames(10)
      foto("piazza_dopo")
    end

    passo("Fulvio a ogni tapa") do
      [3, 5, 6, 7].each do |t|
        $game_variables[27] = t
        MuiaStoria.fulvio
      end
      $game_variables[27] = 5
    end

    passo("Ornella: un pokemon solo, pò do") do
      vai(80, 0, 12, 8)
      controla_eventi
      foto("bar_zuppo")
      MuiaStoria.ornella
      verifica($game_variables[27] == 5, "con un pokemon solo no la dà el libreto")
      pbAddPokemonSilent(:PIDGEY, 4)
      MuiaStoria.ornella
      verifica($game_variables[27] == 6, "con do pokemon trama = 6")
      MuiaStoria.ornella
    end

    passo("transenne e posto de bloco") do
      MuiaStoria.aggiorna
      vai(86, 20, 13, 8)
      verifica($game_switches[81], "transenne su")
      foto("transenne_via_roma")
      vai(91, 1, 0, 8)
      foto("posto_de_bloco")
      MuiaStoria.posto_de_bloco
      verifica($game_variables[27] == 7, "trama = 7 dopo Tubo")
      verifica(!$game_switches[81], "transenne zo")
    end

    passo("muli de Santa Lucia") do
      vai(90, 25, 12, 6)
      MuiaStoria.mulo_rion(false)
      MuiaStoria.mulo_rion(true)
      verifica($game_switches[86], "muli batui")
    end

    passo("porte serade") do
      vai(89, 12, 15, 8)
      MuiaStoria.porta_serada(89, 6, 9)
      MuiaStoria.porta_serada(42, 55, 5)
    end

    passo("tute le case e i bar") do
      $player.money = 500_000
      MuiaStoria::PORTE_VERTE.each do |(m, x, y), chiave|
        begin
          vai(m, x, y + 1, 8)
          MuiaStoria.entra(chiave, m, x, y)
          fa_trasferimento
          dentro = $game_map.map_id
          verifica(MuiaStoria::INTERNI.key?(dentro), "#{chiave}: dentro mapa #{dentro}")
          controla_eventi
          ev_muia.each do |e|
            next if e.id == 1290
            lista = e.instance_variable_get(:@list) || []
            cmd = lista.find { |c| c.code == 355 }
            next if !cmd
            eval(cmd.parameters[0])
          end
          if [:bar_tendarossa, :bar_slucia, :piazza_nona].include?(chiave)
            foto("interno_#{chiave}")
          end
          MuiaStoria.esci
          fa_trasferimento
          verifica($game_map.map_id == m, "#{chiave}: tornà fora in mapa #{m}")
        rescue Exception => e
          @errori += 1
          log("  ERRORE casa #{chiave}: #{e.class} #{e.message} #{e.backtrace[0]}")
        end
      end
      log("  squadra: #{$player.party.map { |p| "#{p.species}#{p.level}" }.join(' ')} schei=#{$player.money}")
    end

    passo("bar: compra 6 volte (le offerte cambia)") do
      $player.money = 900_000
      6.times do
        MuiaStoria.vendi_pokemon("prova_pk", MuiaStoria::PROB_RION)
        MuiaStoria.vendi_mt("prova_mt")
      end
      log("  ultime offerte: #{MuiaStoria.dati_bar['prova_pk'].inspect} #{MuiaStoria.dati_bar['prova_mt'].inspect}")
    end

    passo("schei dai selvadeghi") do
      prima = $player.money
      EventHandlers.trigger(:on_wild_battle_end, :PIDGEY, 10, 1)
      EventHandlers.trigger(:on_wild_battle_end, :PIDGEY, 40, 4)
      log("  guadagnà #{$player.money - prima}")
      verifica($player.money > prima, "schei guadagnai")
    end

    passo("alenadori de strada") do
      MuiaMondo::ALENADORI.each do |dati|
        id, m = dati
        vai(m, 1, 1) if $game_map.map_id != m rescue nil
        MuiaMondo.alenador(id)
      end
    end

    passo("imboscade de Tubo") do
      [[2, 83, 10, 20], [4, 114, 20, 25], [6, 86, 20, 10]].each do |med, m, x, y|
        $player.badges.fill(false)
        med.times { |i| $player.badges[i] = true }
        prima = $game_variables[29]
        vai(m, x, y)
        if $game_map.events[1090]
          MuiaStoria.imboscada
        else
          log("  NO evento imboscada in mapa #{m}")
        end
        verifica($game_variables[29] > prima, "imboscada mapa #{m}: lote Tubo #{prima} -> #{$game_variables[29]}")
      end
    end

    passo("molo e castel") do
      $player.badges.fill(false)
      2.times { |i| $player.badges[i] = true }
      MuiaStoria.aggiorna
      verifica($game_switches[82], "molo serà con 2 bolli")
      MuiaStoria.pescador
      MuiaStoria.corda_castel
      4.times { |i| $player.badges[i] = true }
      MuiaStoria.aggiorna
      verifica(!$game_switches[82] && !$game_switches[83], "molo e castel verti con 4 bolli")
    end

    passo("frazioni e telefonade") do
      MuiaStoria.barriera_colina
      vai(129, 16, 12, 8)
      controla_eventi
      foto("muggia_vecia")
      MuiaStoria.sacrestan
      MuiaStoria.panorama
      vai(128, 20, 9, 6)
      controla_eventi
      foto("porto_san_rocco")
      MuiaStoria.frana
      (1..8).each do |n|
        $player.badges.fill(false)
        n.times { |i| $player.badges[i] = true }
        MuiaStoria.telefonada
      end
      verifica($game_variables[32] == 8, "telefonade fate fin ala 8")
    end

    passo("Lega e sindaco") do
      8.times { |i| $player.badges[i] = true }
      vai(114, 22, 14, 8)
      foto("castel_lega")
      MuiaMondo::LEGA.each { |l| MuiaMondo.lega(l[0]) }
      MuiaMondo.sindaco
      verifica(MuiaStoria.sindaco_batù?, "sindaco batù")
    end

    passo("Delfin Verde e finale") do
      vai(22, 64, 12, 2)
      foto("molo_delfin")
      MuiaStoria.controlor
      verifica($game_switches[88], "finale visto")
    end

    passo("mama e mapa") do
      $stats.blacked_out_count = 1
      vai(3, 7, 5, 8)
      if $game_map.events[1095]
        MuiaStoria.mama_mapa
      else
        log("  NO evento mama")
      end
      verifica($bag.has?(:TOWNMAP), "mapa in borsa")
      begin
        scene = PokemonRegionMap_Scene.new(-1, false)
        log("  regione mapa: #{GameData::TownMap.get(0).name rescue '?'}")
      rescue Exception => e
        log("  mapa: #{e.message}")
      end
    end

    log("messagi mostrai: #{MuiaTest.messagi}")
    log("FINE ok=#{@ok} errori=#{@errori}")
  end
end

#-------------------------------------------------------------------------------
# Risposte automatiche
#-------------------------------------------------------------------------------
def pbMessage(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
  MuiaTest.messagi += 1
  MuiaTest.log("  msg: #{message.to_s.gsub(/\\[a-z]+\[[^\]]*\]|\\[a-zA-Z]/, '')[0, 160]}")
  return nil if !commands
  scelta = MuiaTest.scelte.shift || 0
  MuiaTest.log("  scelta: #{commands[scelta]}")
  return scelta
end

def pbConfirmMessage(message, &block)
  MuiaTest.log("  domanda: #{message}")
  r = MuiaTest.conferme.shift
  return r.nil? ? true : r
end

def pbAddPokemon(pkmn, level = 1, see_form = true)
  pkmn = Pokemon.new(pkmn, level) if !pkmn.is_a?(Pokemon)
  MuiaTest.log("  ricevù pokemon #{pkmn.species} lv#{pkmn.level}")
  return pbAddPokemonSilent(pkmn)
end

def pbPokemonMart(stock, speech = nil, cantsell = false)
  MuiaTest.log("  negozio: #{stock.join(',')}")
end

def pbChoosePokemonForTrade(variableNumber, nameVarNumber, wanted)
  i = $player.party.index { |p| p.species == wanted }
  pbSet(variableNumber, i || -1)
end

def pbStartTrade(pokemonIndex, newpoke, nickname, trainerName, trainerGender = 0)
  MuiaTest.log("  scambio: #{$player.party[pokemonIndex].species} -> #{newpoke}")
  $player.party[pokemonIndex] = Pokemon.new(newpoke, $player.party[pokemonIndex].level)
end

def pbHallOfFameEntry
  MuiaTest.log("  Sala d'Onore")
end

def pbExclaim(*args); end

class TrainerBattle
  def self.start(*args)
    args.each do |a|
      next if !a.is_a?(NPCTrainer)
      MuiaTest.log("  LOTA con #{a.trainer_type} #{a.name}: #{a.party.map { |p| "#{p.species}#{p.level}" }.join(' ')}")
    end
    $game_temp.clear_battle_rules
    return MuiaTest.vinci
  end
end

#-------------------------------------------------------------------------------
# Avvio: zogo novo in Piazza Marconi, i test parti al primo fotogramma
#-------------------------------------------------------------------------------
def pbCallTitle
  return Scene_MuiaTestAvvio.new
end

class Scene_MuiaTestAvvio
  def main
    Graphics.transition(0)
    $data_system.start_map_id = 42
    $data_system.start_x = 26
    $data_system.start_y = 10
    Game.start_new
    $player.name = "Prova"
    $player.has_pokedex = true
    MuiaTest.log("zogo novo avvià")
  end
end

class Scene_Map
  alias muiatest_update update
  def update
    if !$muiatest_fatto
      $muiatest_fatto = true
      begin
        MuiaTest.tutto
      rescue Exception => e
        MuiaTest.log("ERRORE GRAVE #{e.class} #{e.message}")
        (e.backtrace || [])[0, 10].each { |r| MuiaTest.log("   #{r}") }
        MuiaTest.log("FINE ok=0 errori=1")
      end
    end
    muiatest_update
  end
end
