#===============================================================================
# Muia - Storia: Tubo, el pulotto de Muia (el rivale)
#
# Tubo xe dela Polizia Locale e el ga deciso che un foresto a Muia no ghe
# piasi. El te ferma in piazza, al posto de bloco, al Squero, al Castel, in
# Via Roma e alla fine el xe un dei Super 4.
# El ga sempre el so can poliziotto (Growlithe) e el starter che bati el tuo.
#===============================================================================
module MuiaStoria
  TUBO_TIPO    = :TUBO
  TUBO_GRAFICA = "trainer_TUBO"
  TUBO_NOME    = "Tubo"

  # Starter scelto (var 7): 1 Froakie, 2 Torchic, 3 Chikorita.
  # Tubo ciol quel che lo bati: [base, prima evoluzion, ultima]
  TUBO_STARTER = {
    1 => [:CHIKORITA, :BAYLEEF, :MEGANIUM],
    2 => [:FROAKIE, :FROGADIER, :GRENINJA],
    3 => [:TORCHIC, :COMBUSKEN, :BLAZIKEN]
  }

  # Le squadre: [specie, livel rispeto al to più forte (o livel fisso se > 0 e :fisso)]
  # n = numero dela lota (0 piazza, 1 posto de bloco, 2 Squero, 3 Castel, 4 Via Roma)
  def self.squadra_tubo(n)
    st = TUBO_STARTER[$game_variables[VAR_STARTER]] || TUBO_STARTER[2]
    case n
    # Prima lota in piazza: un contro un, QUASI impossibile (vedi el
    # Campari in 011_Campari.rb): un solo pokemon, el starter che bati el tuo.
    # Livei calcolai con 1,5 milioni de lote simulade (el tuo starter liv. 5):
    #  Froakie vs Chikorita liv.6 ~1/60000 (al liv.5 no la ga ancora Foia Taiente: 1/4)
    #  Torchic vs Froakie liv.5  ~1/25000
    #  Chikorita vs Torchic liv.5 ~1/4000
    # In zogo xe un fià più facile (l'IA no xe perfeta): circa una su qualche mila.
    when 0 then [[st[0], ($game_variables[VAR_STARTER] == 1) ? 6 : 5]]
    # Dopo: come un rival vero, la squadra cressi e la xe 1-2 livei sora el tuo più forte
    when 1 then [[:GROWLITHE, 1], [st[0], 2]]
    when 2 then [[:GROWLITHE, 1], [:MAGNEMITE, 1], [:MURKROW, 1], [st[1], 2]]
    when 3 then [[:GROWLITHE, 1], [:MAGNETON, 1], [:MURKROW, 1], [:MACHOKE, 1], [st[1], 2]]
    when 4 then [[:ARCANINE, 2], [:MAGNETON, 1], [:HONCHKROW, 1], [:MACHOKE, 1], [:SNEASEL, 1], [st[2], 2]]
    else        [[:ARCANINE, 56], [:MAGNEZONE, 56], [:HONCHKROW, 56], [:LUCARIO, 57], [:MACHAMP, 57], [st[2], 58]]
    end
  end

  # Livel de Tubo: el to più forte + qualcossa, mai sotto un minimo per tapa
  TUBO_MINIMO = [5, 8, 20, 33, 44]

  def self.alenador_tubo(n)
    tipo = GameData::TrainerType.exists?(TUBO_TIPO) ? TUBO_TIPO : :TEAMROCKET_M
    alenador = NPCTrainer.new(TUBO_NOME, tipo)
    base = [livel_max, TUBO_MINIMO[[n, 4].min]].max
    squadra_tubo(n).each do |specie, delta|
      livel = (n == 0 || n >= 5) ? delta : base + delta
      alenador.party.push(fa_pokemon(specie, livel, alenador))
    end
    alenador.lose_text = [
      _INTL("Fortuna del principiante!"),
      _INTL("Va ben, va ben... ma te tegno d'ocio."),
      _INTL("Me ga scampà la multa..."),
      _INTL("No xe finida qua, foresto!"),
      _INTL("Ma come xe possibile?!"),
      _INTL("...Va ben. Va' dal sindaco.")
    ][[n, 5].min]
    return alenador
  end

  # Lota con Tubo. Ritorna true se te vinci.
  def self.lota_tubo(n, pol_perder = false)
    setBattleRule("canLose") if pol_perder
    vinto = TrainerBattle.start(alenador_tubo(n))
    $game_variables[VAR_TUBO] = [lote_tubo, n + 1].max
    return vinto
  end

  # Tubo nei Super 4 (Castel, dopo l'otava medaja)
  def self.lega_tubo(id, nome, prima, dopo)
    if MuiaMondo.batù?(id)
      dì(nome, _INTL(dopo))
      return
    end
    dì(nome, _INTL(prima))
    dì(nome, _INTL("Sie lote, sie volte che te me ga batù. Ma qua, al Castel, xe la setima. E la setima xe quela bona!")) if lote_tubo >= 5
    return if !pbConfirmMessage(_INTL("Te vol lotar con {1}?", nome))
    alenador = alenador_tubo(5)
    alenador.lose_text = _INTL(dopo)
    if TrainerBattle.start(alenador)
      MuiaMondo.segna_batù(id)
      $game_variables[VAR_TUBO] = [lote_tubo, 6].max
    end
  end

  #-----------------------------------------------------------------------------
  # Imboscade: Tubo te salta fora apena te entri in una mapa
  # [mapa, medaje minime, numero dela lota, frasi prima, frasi dopo]
  #-----------------------------------------------------------------------------
  IMBOSCADE = [
    [83, 2, 2,
     ["Fermo là, foresto! Questo xe un cantier soto sequestro.",
      "Marieta dela Lampo ga fato saltar la corente de mezo Muia, e mi go de far el verbal.",
      "Ti te volessi parlarghe? Prima te passi soto el mio verbal!"],
     ["Bon... fa quel che te vol. Tanto el verbal lo fazo istesso.",
      "Ma ricordite: a Muia comando mi! Dopo el sindaco. E dopo la mia mama."]],
    [114, 4, 3,
     ["Alt! Le scale del Castel xe zona rossa: qua ghe xe i fantasmi dei Mandrioi.",
      "E mi, de note, son el fantasma più tremendo de tuti. Documenti!"],
     ["No ghe credo... Bon, va su, che Gigi te speta. Mi intanto fazo un giro de ronda... lontan."]],
    [86, 6, 4,
     ["Tuti fermi! Controlo stradal in Via Roma.",
      "Sie bolli, ah? I me ga dito che te vol diventar sindaco. Un foresto sindaco de Muia!",
      "Prima de rivarghe, te ga de passar sul mio corpo. E su quel del mio can."],
     ["Te son forte, mulo. Lo ammeto. Ma i Super 4 no xe come mi...",
      "...anzi, xe pezo. Ghe xe anca uno che te conossi ben. Ahahah!"]]
  ]

  def self.imboscada_da_far(map_id)
    return nil if trama < 7
    IMBOSCADE.each do |dati|
      m, med, n = dati
      next if m != map_id
      next if medaje < med || lote_tubo > n
      return dati
    end
    return nil
  end

  def self.imboscada
    dati = imboscada_da_far($game_map.map_id)
    evento = ev(1090)
    if !dati || !evento
      evento&.erase
      return
    end
    _m, _med, n, prima, dopo = dati
    x, y = casela_vizin
    evento.moveto(x, y)
    grafica(evento, TUBO_GRAFICA, 2)
    gira_verso_zogador(evento)
    gira_zogador_verso(evento)
    pbSEPlay("Exclaim") rescue nil
    pbExclaim(evento)
    prima.each { |t| dì("TUBO", _INTL(t)) }
    if lota_tubo(n)
      dopo.each { |t| dì("TUBO", _INTL(t)) }
      pbFadeOutIn { evento.erase }
    else
      $game_variables[VAR_TUBO] = n   # la rivincita la prossima volta
      evento.erase
    end
    aggiorna
  end
end
