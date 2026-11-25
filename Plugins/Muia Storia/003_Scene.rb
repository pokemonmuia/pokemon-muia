#===============================================================================
# Muia - Storia: le scene
#   - folla in Piazza Marconi apena te esci dal Comun, Fulvio e prima lota con Tubo
#   - la Siora Ornella in Bar de Zuppo (el Libreto del Carneval)
#   - el posto de bloco de Tubo in cima a Calle Parini
#   - el Delfin Verde (finale)
#   - la mama che te dà la mapa dopo el primo KO
#===============================================================================
module MuiaStoria
  FULVIO = 2   # evento de Fulvio in Piazza Marconi (fato in RPG Maker)

  # Folla davanti al Comun: [ID, x, y, grafica, direzion]
  FOLLA = [
    [1002, 24,  9, "NPC 11", 6], [1003, 25,  8, "NPC 07", 2],
    [1004, 27,  8, "NPC 26", 2], [1005, 28,  9, "NPC 13", 4],
    [1006, 24, 11, "NPC 03", 6], [1007, 28, 11, "NPC 19", 4],
    [1008, 23, 10, "NPC 22", 6], [1009, 29, 10, "NPC 09", 4]
  ]
  BISBIGLI = [
    ["SIORA", "Te ga visto? Xe quel novo!"],
    ["VECIO", "El foresto! El vien de Trieste, se vedi dale scarpe."],
    ["MULA", "Dicono che el ga parlà col sindaco Pochibori in persona..."],
    ["SIORA", "Ocio ai portafoi, che quei de Trieste..."],
    ["MULO", "Ma el parla muiesan o triestin?"],
    ["VECIO", "Ai mii tempi i foresti i restava in Piazza Unità!"],
    ["MULA", "El xe rivà col Delfin Verde. El ga ancora el muso verde anca lu!"],
    ["SIORA", "Speremo che no el resti a dormir..."]
  ]

  #-----------------------------------------------------------------------------
  # Scena in piazza (var 27 = 3)
  #-----------------------------------------------------------------------------
  def self.scena_piazza
    return if trama != 3
    folla = FOLLA.map { |f| ev(f[0]) }.compact
    fulvio = ev(FULVIO)
    pbWait(0.4)
    folla.each { |e| gira_verso_zogador(e) }
    pbExclaim(folla[0]) if folla[0]
    BISBIGLI.each_with_index do |(chi, testo), i|
      e = folla[i % [folla.length, 1].max]
      gira_zogador_verso(e) if e
      pbMessage(_INTL("\\c[8]{1} (bisbiglia): {2}", chi, testo))
    end
    pbMessage(_INTL("\\c[8]Bzz bzz... foresto... bzz... Trieste... bzz bzz..."))
    # Riva Fulvio
    if fulvio
      fulvio.moveto(19, 8)
      passi(fulvio, PBMoveRoute::RIGHT, PBMoveRoute::RIGHT, PBMoveRoute::RIGHT,
            PBMoveRoute::RIGHT, PBMoveRoute::RIGHT, PBMoveRoute::DOWN,
            PBMoveRoute::DOWN, PBMoveRoute::RIGHT, PBMoveRoute::TURN_RIGHT)
    end
    dì("FULVIO", _INTL("Oh! OH! Cossa xe 'sto mercà?!"))
    aspetta(fulvio)
    gira_zogador_verso(fulvio)
    dì("FULVIO", _INTL("Lassè respirar el mulo, che el xe pena sbarcà! Fora, fora, a casa vostra!"))
    # La folla se slontana
    FOLLA.each do |id, x, _y, _g, _d|
      e = ev(id)
      next if !e
      verso = (x < 26) ? PBMoveRoute::LEFT : PBMoveRoute::RIGHT
      passi(e, verso, verso, verso, verso, verso, verso)
    end
    aspetta(folla)
    FOLLA.each { |f| ev(f[0])&.erase }
    pbWait(0.3)
    dì("FULVIO", _INTL("Scusili, a Muia no xe che rivi tanti foresti. Mi son Fulvio, piacer."))
    dì("FULVIO", _INTL("Te son quel che el sindaco ga ciamà in Comun, vero? Lassa che te spiego come che funziona qua."))
    dì("FULVIO", _INTL("Te vol tornar a Trieste? Eh, no xe cussì facile, mulon. El sindaco Pochibori ga firmà un'ordinanza."))
    dì("FULVIO", _INTL("Nissun foresto ciapa el Delfin Verde fin che no el ga i OTO BOLLI dele compagnie del Carneval."))
    dì("FULVIO", _INTL("Ogni compagnia ga el so capopalestra: te lo bati, e lu te timbra el bollo sul Libreto del Carneval."))
    dì("FULVIO", _INTL("Dopo i oto bolli te toca i Super 4, su al Castel. E alla fine... el sindaco in persona."))
    dì("FULVIO", _INTL("Se te li bati tuti, l'ordinanza la firmi ti. E el Delfin Verde te riporta a casa."))
    dì("FULVIO", _INTL("Robe pratiche: se i tui pokemon xe strachi, ghe xe le VECIE de Muia che te li cura gratis. Una la xe qua in piazza."))
    dì("FULVIO", _INTL("Per Poké Ball e pozioni ghe xe el TABACHIN, qua de fronte al Comun. I bori te li ciapi lotando: anca i pokemon selvadeghi te molla qualche moneda."))
    dì("FULVIO", _INTL("La palestra xe al Pacco, in Via D'Annunzio, su in alto. Ma ocio: per la sfilata del Carneval Via Roma xe tuta transennada."))
    dì("FULVIO", _INTL("Se passa solo dal posto de bloco in cima a Calle Parini, e là ghe xe..."))
    $game_variables[VAR_TRAMA] = 4
    # Riva Tubo
    tubo = ev(1010)
    if tubo
      tubo.moveto(34, 9)
      grafica(tubo, TUBO_GRAFICA, 4)
    end
    pbSEPlay("Exclaim") rescue nil
    pbMessage(_INTL("???: FERMI TUTI! Polizia Locale!"))
    if tubo
      passi(tubo, PBMoveRoute::LEFT, PBMoveRoute::LEFT, PBMoveRoute::LEFT,
            PBMoveRoute::LEFT, PBMoveRoute::LEFT, PBMoveRoute::DOWN, PBMoveRoute::LEFT)
      aspetta(tubo)
      gira_verso_zogador(tubo)
      gira_zogador_verso(tubo)
    end
    dì("FULVIO", _INTL("...ghe xe lu. Tubo."))
    dì("TUBO", _INTL("Documenti! Fame veder... Ah, ma ti te son el foresto. De TRIESTE."))
    dì("TUBO", _INTL("Mi son Tubo, Polizia Locale de Muia. Qua comando mi. Dopo el sindaco. E dopo mia mama."))
    dì("TUBO", _INTL("Te go za visto: te gavevi la facia de un che no paga el bigliet del Delfin Verde."))
    dì("TUBO", _INTL("Vedemo se te sa almeno tignir un pokemon in man. El mio xe pena uscì dal corso de adestramento!"))
    vinto = lota_tubo(0, true)
    gira_verso_zogador(tubo)
    if vinto
      dì("TUBO", _INTL("Fortuna del principiante! Ma no te monta la testa."))
    else
      dì("TUBO", _INTL("Ahahah! Lo savevo! Torna a Trieste... ah no, no te pol. Ahahah!"))
      $player.heal_party
    end
    dì("TUBO", _INTL("Senza el LIBRETO DEL CARNEVAL timbrà dal Comun, al mio posto de bloco no te passi. Gnanca morto."))
    if tubo
      passi(tubo, PBMoveRoute::UP, PBMoveRoute::RIGHT, PBMoveRoute::RIGHT, PBMoveRoute::RIGHT,
            PBMoveRoute::RIGHT, PBMoveRoute::RIGHT, PBMoveRoute::RIGHT, PBMoveRoute::RIGHT)
      aspetta(tubo)
      tubo.erase
    end
    gira_zogador_verso(fulvio)
    dì("FULVIO", _INTL("Lassilo perder, Tubo xe fato cussì: el ga studià a Trieste e no el lo ga mai digerì."))
    dì("FULVIO", _INTL("El Libreto te lo dà la Siora Ornella del Comun. Ma a 'st'ora la xe sicuro in BAR DE ZUPPO, qua in piazza, a far merenda."))
    dì("FULVIO", _INTL("Mi resto qua in piazza. Se te ga dubi, vien a ciacolar!"))
    $game_variables[VAR_TRAMA] = 5
    aggiorna
  end

  #-----------------------------------------------------------------------------
  # Fulvio in piazza (ex Dejan): consigli in base a dove te son
  #-----------------------------------------------------------------------------
  def self.fulvio
    t = trama
    if t < 3
      dì("FULVIO", _INTL("Ciò, el sindaco te speta in Comun. No sta farlo spetar, che el se rabia."))
      return
    end
    if t < 6
      dì("FULVIO", _INTL("Va' in Bar de Zuppo, qua in piazza: la Siora Ornella te darà el Libreto del Carneval."))
      dì("FULVIO", _INTL("Ah, e la xe pignola: la vol che te gabi almeno DO pokemon. Le Poké Ball le vendi el tabachin.")) if $player.party.length < 2
    elsif t < 7
      dì("FULVIO", _INTL("Col Libreto in scarsela va' al posto de bloco de Tubo, in cima a Calle Parini. Soto la Salita dele Mure."))
    elsif medaje < 8
      dì("FULVIO", _INTL("Te ga {1} bolli su oto. La palestra xe al Pacco, in Via D'Annunzio.", medaje))
      dì("FULVIO", _INTL("Se el capopalestra no xe in palestra, el guardian te disi dove trovarlo. E el Banditor in piazza sa sempre tuto."))
    elsif !sindaco_batù?
      dì("FULVIO", _INTL("Oto bolli! Desso va' su al Castel: i Super 4 e el sindaco te speta. Mi fazo el tifo per ti!"))
    else
      dì("FULVIO", _INTL("Sindaco! Ciò, ma te va via sul serio? El Delfin Verde xe in Molo dei Bersaglieri..."))
      return
    end
    return if $game_switches[SW_FINAL]
    if t >= 7 && !$game_self_switches[[MAPA_PIAZZA, FULVIO, "B"]]
      dì("FULVIO", _INTL("Ah, e un'altra roba: no sta dirme che anche ti te va fin in Piazza Unità con l'auto?"))
      sc = pbMessage(_INTL("Alora?"), [_INTL("Ma cossa te scherzi?"), _INTL("Ovvio ah")], 0)
      if sc == 0
        dì("FULVIO", _INTL("Bravo. Te parchegi in Piazzale Cagni, te ciapi la 9 e in diese minuti te son in Piazza Unità."))
      else
        dì("FULVIO", _INTL("Mama mia. Un vero triestin. Va' pur, va', che te trovi parcheggio in Sacheta per Pasqua."))
      end
      $game_self_switches[[MAPA_PIAZZA, FULVIO, "B"]] = true
    end
  end

  #-----------------------------------------------------------------------------
  # Siora Ornella in Bar de Zuppo: el Libreto del Carneval
  #-----------------------------------------------------------------------------
  def self.ornella
    t = trama
    if t < 4
      dì("SIORA ORNELLA", _INTL("Son in pausa, caro. Torna dopo. Molto dopo."))
      return
    end
    if t >= 6
      dì("SIORA ORNELLA", _INTL("El Libreto te lo go za dà. Te ga {1} bolli su oto. Avanti cussì, mulo!", medaje))
      return
    end
    dì("SIORA ORNELLA", _INTL("Mh? Un foresto in Bar de Zuppo? Ah, te son quel del sindaco."))
    dì("SIORA ORNELLA", _INTL("El Libreto del Carneval? Eh, caro, l'ufficio verzi lunedì, mercoledì e venerdì dale 9 ale 9 e un quarto."))
    dì("SIORA ORNELLA", _INTL("...Ma va ben, go el timbro in borseta. Però el regolamento disi che un alenador ga de gaver ALMENO DO POKEMON."))
    if $player.party.length < 2
      dì("SIORA ORNELLA", _INTL("Ti te ghe ne ga uno solo. Va' a ciaparghene un altro nell'erba e torna. Mi intanto fazo merenda."))
      dì("SIORA ORNELLA", _INTL("Le Poké Ball le vendi el tabachin de fronte al Comun.")) if !$bag.has?(:POKEBALL)
      return
    end
    dì("SIORA ORNELLA", _INTL("Bon, do pokemon. Regolare. Timbro... firma... e controfirma."))
    pbMEPlay("Key item get") rescue nil
    pbMessage(_INTL("\\c[1]{1} ga ricevù el LIBRETO DEL CARNEVAL!\\c[0]", $player.name))
    dì("SIORA ORNELLA", _INTL("Qua dentro i capipalestra te timbra i bolli. Oto bolli, e el Delfin Verde te riporta a Trieste."))
    dì("SIORA ORNELLA", _INTL("Desso va' da Tubo in cima a Calle Parini e mostrighe el Libreto. E salutimelo... anzi no."))
    $game_variables[VAR_TRAMA] = 6
    aggiorna
  end

  #-----------------------------------------------------------------------------
  # Posto de bloco de Tubo in cima a Calle Parini (fin che var 27 < 7)
  #-----------------------------------------------------------------------------
  def self.posto_de_bloco
    tubo = ev(1080)
    gira_verso_zogador(tubo)
    if trama < 6
      dì("TUBO", _INTL("Indrio! Senza el Libreto del Carneval de qua no se passa."))
      dì("TUBO", _INTL("E no sta provar a passar per Via Roma: xe tuto transennà per la sfilata. Ahahah!"))
      return
    end
    dì("TUBO", _INTL("Ah, el Libreto. Fame veder..."))
    dì("TUBO", _INTL("Mmm... el timbro xe storto. E la firma de la Ornella xe tremolante. Sospeto, molto sospeto."))
    dì("TUBO", _INTL("Te fazo una proposta: se te me bati, te lasso passar. Se te perdi, te fazo la multa per... per... per foresteria!"))
    return if !pbConfirmMessage(_INTL("Te lo sfidi?"))
    if lota_tubo(1)
      dì("TUBO", _INTL("Va ben, va ben! Passa. Tanto la sfilata xe finida e i ga tolto le transenne."))
      dì("TUBO", _INTL("Ma te tegno d'ocio, foresto. Dove che te va ti, salto fora mi."))
      $game_variables[VAR_TRAMA] = 7
      pbFadeOutIn do
        tubo&.erase
        ev(1081)&.erase
        aggiorna
      end
      pbMessage(_INTL("\\c[1]La sfilata xe finida: Via Roma xe de novo verta!\\c[0]"))
    else
      aggiorna
    end
  end

  #-----------------------------------------------------------------------------
  # Delfin Verde: el controlor al Molo dei Bersaglieri
  #-----------------------------------------------------------------------------
  def self.controlor
    if !sindaco_batù?
      dì("CONTROLOR", _INTL("Biglieti, prego! ...Ah, un foresto. Gnente da far, mulo."))
      dì("CONTROLOR", _INTL("Ordinanza del sindaco Pochibori: el Delfin Verde no ciol foresti senza i oto bolli del Carneval e senza aver batù i Super 4 e el sindaco."))
      dì("CONTROLOR", _INTL("Te ga {1} bolli su oto. Torna quando te ga finì, che el Delfin no scampa.", medaje)) if trama >= 6
      return
    end
    if $game_switches[SW_FINAL]
      dì("CONTROLOR", _INTL("Siòr sindaco! Ancora qua? El Delfin Verde parti quando el vol Lei."))
      if pbConfirmMessage(_INTL("Te vol rivedar el viagio de ritorno?"))
        finale
      end
      return
    end
    dì("CONTROLOR", _INTL("Siòr... sindaco?! Ma Lei xe el foresto! Cioè, l'ex foresto!"))
    dì("CONTROLOR", _INTL("L'ordinanza la ga firmada Lei: el Delfin Verde xe pronto. Trieste ve speta!"))
    return if !pbConfirmMessage(_INTL("Te monti sul Delfin Verde per tornar a Trieste?"))
    finale
  end

  def self.finale
    pbBGMFade(1.0) rescue nil
    pbMessage(_INTL("\\c[8]Su la passerela, una vose conossuda..."))
    dì("FULVIO", _INTL("Speta! SPETA! Te va via cussì, senza saludar?"))
    dì("FULVIO", _INTL("Te son rivà foresto e te va via sindaco. A Muia no se la desmentegherà più nissun."))
    dì("TUBO", _INTL("...E mi go perso con un triestin. Ma solo perché el mio can gaveva fame."))
    dì("TUBO", _INTL("Ciò... bon viagio, foresto. Cioè... sindaco. Va ben, foresto."))
    dì("SINDACO POCHIBORI", _INTL("Ricordite: el Delfin Verde va e vien. E a Muia un caffè per ti se trova sempre."))
    dì("SINDACO POCHIBORI", _INTL("...Ma paghilo, eh."))
    pbFadeOutIn do
      pbMessage(_INTL("\\c[8]El Delfin Verde se stacca dal molo. Muia se fa picia picia, col Castel in alto e el Duomo in piazza."))
      pbMessage(_INTL("\\c[8]Dopo mezora de onde, el Molo Audace, Piazza Unità, i Topolini..."))
      pbMessage(_INTL("\\c[8]Te son a casa. Ma qualcossa te disi che a Muia te tornerà presto."))
      pbMessage(_INTL("POKÉMON MUIA\nFIN"))
      pbMessage(_INTL("Grazie de gaver zogà! Muia te speta ancora: el Delfin Verde te riporta indrio."))
    end
    $game_switches[SW_FINAL] = true
    aggiorna
  end

  #-----------------------------------------------------------------------------
  # La mama te dà la mapa dopo la prima volta che te va KO
  #-----------------------------------------------------------------------------
  def self.mapa_da_dar?
    return false if $game_switches[SW_MAPA]
    return false if !$stats || $stats.blacked_out_count <= 0
    return true
  end

  def self.mama_mapa
    evento = ev(1095)
    if !mapa_da_dar?
      evento&.erase
      return
    end
    dì("MAMA", _INTL("Oh, povero cocolo, te son tornà a casa tuto pesto!"))
    dì("MAMA", _INTL("Te ga girà per Muia senza saver dove che te ndavi, vero? Te son proprio fio de to pare."))
    dì("MAMA", _INTL("Ciol, questa xe la MAPA DE MUIA. Cussì no te te perdi più tra le cali."))
    pbReceiveItem(:TOWNMAP)
    dì("MAMA", _INTL("La trovi nela borsa, tra le robe importanti. E magna qualcossa, che te son tuto ossi!"))
    $game_switches[SW_MAPA] = true
    evento&.erase
  end

  #-----------------------------------------------------------------------------
  # Guardian dela palestra: no se fa sfide prima del Libreto
  #-----------------------------------------------------------------------------
  def self.palestra_serada?
    return trama < 7
  end
end
