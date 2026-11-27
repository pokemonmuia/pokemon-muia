#===============================================================================
# Muia - Storia: "El Foresto"
#
# Te son un foresto rivà da Trieste col Delfin Verde. El sindaco Pochibori ga
# firmà un'ordinanza: nissun foresto torna a casa se no el ga i oto bolli dele
# compagnie del Carneval e no el bati i Super 4 e el sindaco in persona.
#
# Come Muia Mondo, i personaggi de 'sto plugin NO i xe dentro i file
# Data/MapXXX.rxdata: i vien zontadi quando la mapa se carica. ID dal 1001 in su.
# Trama completa e tabele in PLOT.md.
#
# Variabile 27 "Trama":
#   0 inizio, 1 rivà in piazza, 2 la guida xe andada, 3 parlà col sindaco,
#   4 folla e Dei ian in piazza, 5 prima lota con Tubo, 6 Libreto dela Siora
#   Ornella, 7 passà el posto de bloco de Tubo in cima a Calle Parini.
#===============================================================================
module MuiaStoria
  VAR_TRAMA    = 27
  VAR_MEDAJE   = 28
  VAR_TUBO     = 29   # quante lote con Tubo xe za stade fate (finide)
  VAR_PORTA    = 30   # [mapa, x, y] dela porta de dove se xe entrai in casa
  VAR_BAR      = 31   # roba in vendita nei bar (Hash)
  VAR_STARTER  = 7

  SW_SFILATA   = 81   # transenne del Carneval (fin che no te passi Tubo)
  SW_MOLO      = 82   # molo C. Colombo serà (prima dela 3a medaja)
  SW_CASTEL    = 83   # scale del Castel serade (prima dela 4a medaja)
  SW_DELFIN    = 84   # Delfin Verde fermo (fin che no te bati el sindaco)
  SW_RIONE     = 85   # muli de Santa Lucia in cale
  SW_RIONE_OK  = 86   # muli de Santa Lucia batui
  SW_MAPA      = 87   # la mama te ga dà la mapa
  SW_FINAL     = 88   # finale visto (Delfin Verde ciapà)

  MAPA_PIAZZA  = 42
  MAPA_MOLO    = 22
  MAPA_CASA    = 3
  MAPA_ZUPPO   = 80
  MAPA_BLOCO   = 92   # Via Roma_2: el posto de bloco xe in fondo a Calle Parini
  MAPA_CASTEL  = 114

  #-----------------------------------------------------------------------------
  # Stato
  #-----------------------------------------------------------------------------
  def self.trama;   return $game_variables[VAR_TRAMA] || 0; end
  def self.medaje;  return $player ? $player.badge_count : 0; end
  def self.lote_tubo; return $game_variables[VAR_TUBO].is_a?(Integer) ? $game_variables[VAR_TUBO] : 0; end

  def self.sindaco_batù?
    return false if !defined?(MuiaMondo)
    return MuiaMondo.batù?(MuiaMondo::SINDACO[0], MuiaMondo::LEGA_MAPA)
  end

  # Ricalcola i interuttori che dipendi dala storia (transenne, molo, ecc.)
  def self.aggiorna(refresh = true)
    return if !$game_switches || !$game_variables
    $game_switches[SW_SFILATA] = trama < 7
    $game_switches[SW_MOLO]    = medaje < 3
    $game_switches[SW_CASTEL]  = medaje < 4
    $game_switches[SW_DELFIN]  = !sindaco_batù?
    $game_switches[SW_RIONE]   = !$game_switches[SW_RIONE_OK]
    $game_switches[89]         = medaje < 2   # SW_COLINA: strada per Muggia Vecia
    # scarpe da corsa: chi xe za dopo la scena in piazza le ga (anca i salvataggi vechi)
    $player.has_running_shoes = true if $player && trama >= 5
    if refresh
      $game_map.need_refresh = true if $game_map
      $map_factory&.maps&.each { |m| m.need_refresh = true }
    end
  end

  #-----------------------------------------------------------------------------
  # Costruzion dei eventi
  # pagine: lista de Hash, la prima pagina vien prima (in RPG Maker vinci
  # l'ultima pagina che ga le condizion giuste).
  #   gfx: grafica (Characters), tile: ID del tile (per transenne e coni)
  #   dir: 2 zo, 4 sinistra, 6 destra, 8 su    trig: 0 parla, 1 tocca, 3 auto
  #   sw: interutor (deve esser ON)   var: [id, valor minimo]   self: "A"
  #   cmd: codice Ruby da far partir   through: se se passa attraverso
  #   move: 0 fermo, 1 a caso    vista: true = el se gira verso de ti
  #-----------------------------------------------------------------------------
  def self.evento(id, x, y, pagine, nome = nil)
    ev = RPG::Event.new(x, y)
    ev.id   = id
    ev.name = nome || "Muia Storia #{id}"
    ev.pages = pagine.map { |p| pagina(p) }
    return ev
  end

  def self.pagina(p)
    pg = RPG::Event::Page.new
    c = pg.condition
    if p[:sw]
      c.switch1_valid = true
      c.switch1_id    = p[:sw]
    end
    if p[:sw2]
      c.switch2_valid = true
      c.switch2_id    = p[:sw2]
    end
    if p[:var]
      c.variable_valid = true
      c.variable_id    = p[:var][0]
      c.variable_value = p[:var][1]
    end
    if p[:self]
      c.self_switch_valid = true
      c.self_switch_ch    = p[:self]
    end
    pg.graphic.character_name = p[:gfx] || ""
    pg.graphic.tile_id        = p[:tile] || 0
    pg.graphic.direction      = p[:dir] || 2
    pg.trigger      = p[:trig] || 0
    pg.move_type    = p[:move] || 0
    pg.move_frequency = 3
    pg.through      = p[:through] || false
    pg.step_anime   = p[:step] || false
    pg.direction_fix = p[:fix] || false
    pg.always_on_top = false
    lista = []
    lista.push(RPG::EventCommand.new(355, 0, [p[:cmd]])) if p[:cmd]
    lista.push(RPG::EventCommand.new(0, 0, []))
    pg.list = lista
    return pg
  end

  def self.metti(map, ev)
    return if map.events[ev.id]   # un evento fato in RPG Maker vinci sempre
    map.events[ev.id] = ev
  end

  #-----------------------------------------------------------------------------
  # Robe utili per le scene
  #-----------------------------------------------------------------------------
  def self.ev(id)
    return $game_map.events[id]
  end

  # Speta che i personagi gabi finì de caminar (massimo 8 secondi)
  def self.aspetta(*eventi)
    eventi = eventi.flatten.compact
    inizio = System.uptime
    loop do
      break if eventi.none? { |e| e.move_route_forcing || e.moving? }
      break if System.uptime - inizio > 15
      pbWait(0.05)
    end
  end

  def self.passi(evento, *comandi)
    return if !evento
    pbMoveRoute(evento, comandi.flatten)
  end

  # Strada (BFS sule caselle passabili dela mapa) da (x0,y0) a (x1,y1):
  # torna la lista dei comandi PBMoveRoute, o nil se no ghe xe strada.
  def self.strada(x0, y0, x1, y1, max = 400)
    pasi = { 2 => [0, 1, PBMoveRoute::DOWN], 4 => [-1, 0, PBMoveRoute::LEFT],
             6 => [1, 0, PBMoveRoute::RIGHT], 8 => [0, -1, PBMoveRoute::UP] }
    prima = { [x0, y0] => nil }
    coda = [[x0, y0]]
    until coda.empty?
      c = coda.shift
      break if c == [x1, y1]
      pasi.each do |d, (dx, dy, _m)|
        n = [c[0] + dx, c[1] + dy]
        next if prima.key?(n) || !$game_map.valid?(n[0], n[1])
        next if !$game_map.passable?(c[0], c[1], d) || !$game_map.passable?(n[0], n[1], 10 - d)
        next if ocupada?(n[0], n[1]) && n != [x1, y1]
        prima[n] = [c, pasi[d][2]]
        coda.push(n)
      end
      return nil if prima.length > max
    end
    return nil if !prima.key?([x1, y1])
    comandi = []
    c = [x1, y1]
    while prima[c]
      comandi.unshift(prima[c][1])
      c = prima[c][0]
    end
    comandi
  end

  # Casela dove ghe xe el zogador o un personagio visibile (per no pestarli)
  def self.ocupada?(x, y)
    return true if $game_player.x == x && $game_player.y == y
    $game_map.events.values.any? do |e|
      e.x == x && e.y == y && !e.through && e.character_name.to_s != ""
    end
  end

  # Fa caminar un evento fin a (x,y) passando per le strade (through, cussì
  # no el se pianta su altri personagi). Se no ghe xe strada, el se teletrasporta.
  # corri: true = de corsa (velocità 4, come el zogador con le scarpe da corsa),
  # e sempre con l'animazion dei passi (senza, el personagio "svola").
  def self.camina(evento, x, y, corri: false)
    return if !evento
    cmd = strada(evento.x, evento.y, x, y)
    if cmd.nil?
      evento.moveto(x, y)
      return
    end
    prima = [PBMoveRoute::THROUGH_ON]
    if corri
      prima += [PBMoveRoute::WALK_ANIME_ON, PBMoveRoute::STEP_ANIME_OFF,
                PBMoveRoute::DIRECTION_FIX_OFF, PBMoveRoute::CHANGE_SPEED, 4]
    end
    pbMoveRoute(evento, prima + cmd + [PBMoveRoute::THROUGH_OFF])
    aspetta(evento)
  end

  def self.gira_verso_zogador(evento)
    pbTurnTowardEvent(evento, $game_player) if evento
  end

  def self.gira_zogador_verso(evento)
    pbTurnTowardEvent($game_player, evento) if evento
  end

  # Mostra (o sconde) un evento cambiandoghe la grafica
  def self.grafica(evento, nome, dir = 2)
    return if !evento
    pbMoveRoute(evento, [PBMoveRoute::GRAPHIC, nome, 0, dir, 0])
    aspetta(evento)
  end

  # Casela libera vizin al zogador (per far comparir qualchedun)
  def self.casela_vizin
    px = $game_player.x
    py = $game_player.y
    dir = $game_player.direction
    davanti = { 2 => [0, 1], 4 => [-1, 0], 6 => [1, 0], 8 => [0, -1] }[dir] || [0, 1]
    prove = [davanti, [0, 1], [0, -1], [-1, 0], [1, 0]].uniq
    prove.each do |dx, dy|
      x = px + dx
      y = py + dy
      next if !$game_map.valid?(x, y)
      next if !$game_map.passable?(x, y, 0)
      next if $game_map.events.values.any? { |e| e.x == x && e.y == y && !e.through && e.character_name != "" }
      return [x, y]
    end
    return [px, py + 1]
  end

  # Trasferimento come el comando "Trasferisci" de RPG Maker, con dissolvenza
  def self.trasferisci(map_id, x, y, dir = 2, suono = true)
    pbSEPlay("Door exit") if suono
    $game_temp.player_transferring  = true
    $game_temp.player_new_map_id    = map_id
    $game_temp.player_new_x         = x
    $game_temp.player_new_y         = y
    $game_temp.player_new_direction = dir
    Graphics.freeze
    $game_temp.transition_processing = true
    $game_temp.transition_name       = ""
  end

  def self.dì(nome, testo)
    pbMessage(_INTL("{1}: {2}", nome, testo))
  end

  #-----------------------------------------------------------------------------
  # Livei: alenadori de strada e Tubo vien dietro al pokemon più forte
  #-----------------------------------------------------------------------------
  def self.livel_max
    livei = ($player ? $player.party : []).reject { |pk| pk.egg? }.map { |pk| pk.level }
    return livei.empty? ? 5 : livei.max
  end

  # Fa evolver una specie se el livel xe giusto (anca per pietre e scambi,
  # oltre un certo livel), cussì un alenador de livel 40 no ga un Caterpie.
  def self.specie_per_livel(specie, livel)
    sp = specie
    6.times do
      dati = GameData::Species.try_get(sp)
      break if !dati
      evo = dati.get_evolutions(true).find do |s, metodo, param|
        nome = metodo.to_s
        if nome.start_with?("Level") || nome.start_with?("AttackGreater") ||
           nome.start_with?("DefenseGreater") || nome.start_with?("AtkDefEqual") ||
           nome == "Ninjask" || nome == "Shedinja" || nome == "Silcoon" || nome == "Cascoon"
          param.is_a?(Integer) && livel >= param
        elsif nome.start_with?("Happiness")
          livel >= 28
        else   # pietre, scambi e robe strane
          livel >= 36
        end
      end
      break if !evo
      sp = evo[0]
    end
    return sp
  end

  def self.fa_pokemon(specie, livel, alenador = nil)
    livel = livel.clamp(2, GameData::GrowthRate.max_level)
    sp = specie_per_livel(specie, livel)
    sp = specie if !GameData::Species.exists?(sp)
    return Pokemon.new(sp, livel, alenador)
  end
end
