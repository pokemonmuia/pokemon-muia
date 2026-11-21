#===============================================================================
# Pokémon Muia: misure del multiplayer (TEMPORANEO, par capir cossa xe lento)
#
# Ogni 5 secondi scrive nella console del browser (verta el zogo con ?debug in
# fondo all'indirizzo, poi F12 → Console, e cerca "VMS perf") una riga con:
#   fps           fotogrammi al secondo del zogo
#   update        ms medi che ghe vol par ogni VMS.update
#   invio/poll    ms medi par mandar un messagio / controlar la cartela (solo browser)
#   dati          ms medi par preparar i dati del zogador
#   msg_in        messagi ricevui dal server al secondo
#   ping          ms tra quando el zogo manda la so posizion e quando el server
#                 ghe la rimanda indrio (andata e ritorno, tuto compreso)
# e ogni volta che el "stato" de un zogador cambia (par vedér dove se ferma
# l'interazion tra do zogadori): "VMS stato: ...".
# Se PERF_LOG xe false no fa gnente.
#===============================================================================
module VMS
  PERF_LOG = true unless const_defined?(:PERF_LOG)

  module Perf
    @somme = Hash.new(0.0)
    @conti = Hash.new(0)
    @inizio = nil
    @frame0 = 0
    @stati = {}
    @t_inizio = Time.now

    def self.misura(chiave)
      return yield unless VMS::PERF_LOG
      t0 = Time.now
      risultato = yield
      @somme[chiave] += (Time.now - t0)
      @conti[chiave] += 1
      return risultato
    end

    def self.conta(chiave, n = 1)
      @conti[chiave] += n if VMS::PERF_LOG
    end

    def self.media_ms(chiave)
      return "-" if @conti[chiave] == 0
      return (@somme[chiave] / @conti[chiave] * 1000).round(1)
    end

    def self.stati
      return unless VMS.is_connected?
      adesso = "%.1f" % (Time.now - @t_inizio)
      mio = $game_temp.vms[:state]
      if @stati[:io] != mio
        @stati[:io] = mio
        echoln "VMS stato [#{adesso}s]: IO → #{mio.inspect}"
      end
      VMS.get_players.each do |p|
        next if p.id == $player.id
        if @stati[p.id] != p.state
          @stati[p.id] = p.state
          echoln "VMS stato [#{adesso}s]: #{p.name} → #{p.state.inspect}"
        end
      end
    rescue Exception
      nil
    end

    def self.riepilogo
      adesso = Time.now
      @inizio ||= adesso
      @frame0 = Graphics.frame_count if @frame0 == 0
      return if adesso - @inizio < 5
      secondi = adesso - @inizio
      fps = ((Graphics.frame_count - @frame0) / secondi).round(1)
      ping = (VMS.ping * 1000).round rescue -1
      echoln "VMS perf: fps=#{fps} update=#{media_ms(:update)}ms invio=#{media_ms(:invio)}ms " \
             "poll=#{media_ms(:poll)}ms dati=#{media_ms(:dati)}ms " \
             "msg_in=#{(@conti[:msg_in] / secondi).round(1)}/s ping=#{ping}ms (#{VMS.web? ? 'browser' : 'pc'})"
      @somme.clear
      @conti.clear
      @inizio = adesso
      @frame0 = Graphics.frame_count
    end
  end

  class << self
    unless method_defined?(:muia_update_originale)
      alias_method :muia_update_originale, :update
      def update
        return muia_update_originale unless VMS::PERF_LOG
        Perf.misura(:update) { muia_update_originale }
        Perf.stati
        Perf.riepilogo
      end

      alias_method :muia_generate_player_data_originale, :generate_player_data
      def generate_player_data
        return muia_generate_player_data_originale unless VMS::PERF_LOG
        return Perf.misura(:dati) { muia_generate_player_data_originale }
      end
    end
  end
end
