#===============================================================================
# Muia - Storia: condivision esperienza automatica e rivincite dopo 24 ore (1.53)
#
# - Dopo ogni lota (selvadeghi e alenadori) i pokemon dela squadra che no ga
#   lotà ciapa la metà dela esperienza (come el Condividi Esp. dala 6a gen.).
# - Se un alenador te ga batù, per 24 ore la rivincita con lu no da la
#   condivision: l'esperienza la ciapa solo chi lota (no se fa i furbi).
# - Le lote online con altri zogadori no da MAI esperienza (e no conta qua).
# - I alenadori de strada batui torna a lotar dopo 24 ore (ore vere). No
#   capipalestra, Super 4, sindaco e Tubo: quei resta batui per sempre.
#===============================================================================
module MuiaStoria
  RIVINCITA_SECONDI = 24 * 60 * 60
  # Tipi de alenador che no torna mai (capipalestra, lega, rival)
  ALENADORI_FISSI = /\A(LEADER|ELITEFOUR|CHAMPION|TUBO)/

  def self.adesso
    return pbGetTimeNow.to_i rescue Time.now.to_i
  end

  def self.chiave_alenador(tr)
    return "#{tr.trainer_type}|#{tr.name}"
  end

  # Alenadori che te ga batù (chiave => quando)
  def self.sconfite
    return $PokemonGlobal.muia_sconfite
  end

  # Alenadori batui da ti che pol tornar (mapa, evento => quando)
  def self.vitorie
    return $PokemonGlobal.muia_vitorie
  end

  # La condivision vale in sta lota? No se un dei avversari te ga batù da poco.
  # Lota online contro un altro zogador (Voltseon's Multiplayer)?
  def self.lota_online?(battle)
    return true if !battle.internalBattle
    ai = battle.battleAI rescue nil
    return true if defined?(Battle::VMS_AI) && ai.is_a?(Battle::VMS_AI)
    return true if defined?(Battle::VMS_Multibattle_AI) && ai.is_a?(Battle::VMS_Multibattle_AI)
    return false
  end

  def self.condivision?(battle)
    return true if !battle.trainerBattle?
    avversari = battle.opponent || []
    recenti = avversari.select do |tr|
      quando = sconfite[chiave_alenador(tr)]
      quando && adesso - quando < RIVINCITA_SECONDI
    end
    return recenti.empty?
  end

  # Dopo una lota con alenadori: segna sconfite e vitorie
  def self.dopo_lota_alenador(alenadori, vinto)
    alenadori = alenadori.flatten.select { |a| a.is_a?(NPCTrainer) }
    return if alenadori.empty?
    if !vinto
      alenadori.each { |tr| sconfite[chiave_alenador(tr)] = adesso }
      return
    end
    return if alenadori.any? { |tr| tr.trainer_type.to_s =~ ALENADORI_FISSI }
    # Evento che ga fato partir la lota (alenadori dele mape e de strada)
    interp = pbMapInterpreter rescue nil
    id = interp&.get_self&.id rescue nil
    return if !id || !$game_map
    return if id >= 1000                      # personagi dela storia: mai
    # Muia Mondo: solo i alenadori de strada (no la Lega)
    return if id >= 900 && !(defined?(MuiaMondo::ALENADORI) && MuiaMondo::ALENADORI.any? { |a| a[0] == id })
    vitorie[[$game_map.map_id, id]] = adesso
  end

  # Ogni volta che se riva in una mapa: i alenadori batui da più de 24 ore torna
  def self.rivincite(map_id = $game_map&.map_id)
    return if !map_id || !$PokemonGlobal
    cambià = false
    vitorie.each do |(m, id), quando|
      next if m != map_id || adesso - quando < RIVINCITA_SECONDI
      $game_self_switches[[m, id, "A"]] = false
      vitorie.delete([m, id])
      cambià = true
    end
    $game_map.need_refresh = true if cambià && $game_map
  end
end

class PokemonGlobalMetadata
  def muia_sconfite
    @muia_sconfite ||= {}
    return @muia_sconfite
  end

  def muia_vitorie
    @muia_vitorie ||= {}
    return @muia_vitorie
  end
end

class Battle
  alias muia_esp_pbGainExp pbGainExp unless method_defined?(:muia_esp_pbGainExp)
  def pbGainExp
    return if MuiaStoria.lota_online?(self)   # online: mai esperienza
    prima = $player.has_exp_all
    $player.has_exp_all = MuiaStoria.condivision?(self)
    begin
      muia_esp_pbGainExp
    ensure
      $player.has_exp_all = prima
    end
  end

  alias muia_esp_pbDisplayPaused pbDisplayPaused unless method_defined?(:muia_esp_pbDisplayPaused)
  def pbDisplayPaused(msg, &block)
    msg = _INTL("Anca i altri pokemon dela squadra ga ciapà esperienza!") if msg == _INTL("Your other Pokémon also gained Exp. Points!")
    muia_esp_pbDisplayPaused(msg, &block)
  end
end

class Battle
  alias muia_esp_pbEndOfBattle pbEndOfBattle unless method_defined?(:muia_esp_pbEndOfBattle)
  def pbEndOfBattle
    decision = @decision
    ret = muia_esp_pbEndOfBattle
    if trainerBattle? && [1, 2].include?(decision) && !MuiaStoria.lota_online?(self)
      begin
        MuiaStoria.dopo_lota_alenador(@opponent || [], decision == 1)
      rescue StandardError
        nil
      end
    end
    return ret
  end
end

EventHandlers.add(:on_enter_map, :muia_rivincite,
  proc { |_old_map_id|
    MuiaStoria.rivincite
  }
)
