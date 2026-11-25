#===============================================================================
# Muia - Storia: schei
#
# Anca i pokemon selvadeghi, quando te li bati, te lassa qualche moneda
# (i se la gaveva tacada sul pel). Quanto: livel x 3 + un poco a caso.
#   livel 5  -> circa 15-20 Poké$      livel 30 -> circa 90-120 Poké$
#   livel 50 -> circa 150-200 Poké$
# Se te lo ciapi inveze, te trovi la metà (el resto lo ga el pokemon).
# Per confronto: Poké Ball 200, Pozion 300, alenador de strada 200-1500.
#===============================================================================
module MuiaStoria
  FRASI_SCHEI = [
    "Soto el pel del pokemon ghe iera {1} Poké$!",
    "El pokemon ga perso el portafoi: dentro ghe iera {1} Poké$.",
    "Te trovi {1} Poké$ par tera. Muia xe generosa!",
    "Tra l'erba lusi qualcossa: {1} Poké$!"
  ]

  def self.schei_selvadego(livel, ciapà)
    soldi = livel * 3 + rand(livel + 1)
    soldi /= 2 if ciapà
    return [soldi, 1].max
  end
end

EventHandlers.add(:on_wild_battle_end, :muia_schei_selvadeghi,
  proc { |_species, level, decision|
    next if ![1, 4].include?(decision)   # 1 = batù, 4 = ciapà
    next if !$player
    soldi = MuiaStoria.schei_selvadego(level, decision == 4)
    prima = $player.money
    $player.money += soldi
    guadagno = $player.money - prima
    next if guadagno <= 0
    $stats.battle_money_gained += guadagno rescue nil
    frase = MuiaStoria::FRASI_SCHEI[rand(MuiaStoria::FRASI_SCHEI.length)]
    pbMessage(_INTL(frase, guadagno.to_s_formatted))
  }
)
