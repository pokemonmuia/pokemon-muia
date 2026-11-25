#===============================================================================
# Muia - Storia: la leggenda del Campari
#
# La prima lota con Tubo (in piazza, col solo starter) xe fata per esser quasi
# impossibile. In giro se disi che chi la vinci ga un Campari pagà. Nei bar un
# vecio conta la storia; se te la ga vinta, el te dà un codice da mostrar.
#===============================================================================
module MuiaStoria
  SW_CAMPARI = 90   # Tubo batù ala prima lota

  def self.codice_campari
    id = $player.id & 0xFFFFF
    controlo = (id * 7 + 13) % 97
    return sprintf("CAMPARI-%05d-%02d", id % 100_000, controlo)
  end

  def self.vecio_campari
    if !$game_switches[SW_CAMPARI]
      dì("VECIO DEL BAR", _INTL("Te ga sentì la leggenda? Gira vose che chi bati TUBO ala prima lota, in piazza, col pokemon pena ciapà..."))
      dì("VECIO DEL BAR", _INTL("...ghe ofrimo un CAMPARI. Pagà dala compagnia. Vero, no xe una monada!"))
      dì("VECIO DEL BAR", _INTL("Ma nissun ghe xe mai riussì. El suo pokemon xe alenà in caserma, mulo. I disi che ghe vol gaver fortuna e testa."))
      if trama >= 5
        dì("VECIO DEL BAR", _INTL("Ti? Ah, te ga perso anche ti. No sta preocuparte: ghe ga perso anca el sindaco."))
      end
      return
    end
    dì("VECIO DEL BAR", _INTL("SPETA. Ti te son... quel che ga batù TUBO ala prima lota?! Ma alora la leggenda xe vera!"))
    dì("VECIO DEL BAR", _INTL("Un Campari per el foresto! Anzi, do! Mostra 'sto codice al bar e i te lo ofri:"))
    pbMessage(_INTL("Codice: {1} ({2})", codice_campari, $player.name))
    if !$game_self_switches[[MAPA_ZUPPO, 1203, "A"]] && GameData::Item.exists?(:RARECANDY)
      dì("VECIO DEL BAR", _INTL("E intanto ciol questo, de parte dela compagnia del bar."))
      $game_self_switches[[MAPA_ZUPPO, 1203, "A"]] = true if pbReceiveItem(:RARECANDY, 3)
    end
  end
end
