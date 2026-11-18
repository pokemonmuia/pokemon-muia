#===============================================================================
# Pokémon Muia: multiplayer nel browser (versione web e telefono)
#
# Nel browser el zogo no pol verzer socket (UDP/TCP xe "not supported"), quindi
# el parla con la pagina scrivendo file nella cartela dei salvataggi; la pagina
# (web/gioca/main.ts) li inoltra a un server via WebSocket e fa el contrario con
# le risposte. Questa classe se comporta come un socket: send, read_nonblock,
# close. El resto del plugin no se acorze de la diferensa.
#
# File (tuti i nomi ga la "sigla" de la sessione e un numero progressivo, e no
# i vien mai ricreai col stesso nome: el motore se confonde, l'ò provà):
#   muia_ctl_<sigla>_<n>.bin    zogo -> pagina : "open" o "close"
#   muia_out_<sigla>_<n>.bin    zogo -> pagina : un messagio par el server
#   muia_in_<sigla>_<n>.bin     pagina -> zogo : un messagio dal server
#   muia_stato_<sigla>_<n>.bin  pagina -> zogo : "svejo", "conetendo",
#                                "connesso", "chiuso" o "erore: ..."
# Ogni file finisse con "MUIA", cussì no se lexe mai un file scrito a metà.
# I file i vien tolti dalla pagina; el zogo no ghe tocca.
#===============================================================================
module VMS
  # True se el motore xe quel del browser (dove UDPSocket no se pol crear)
  def self.web?
    return @web unless @web.nil?
    @web = begin
      UDPSocket.new.close
      false
    rescue Errno::ENOTSUP, NotImplementedError
      true
    rescue Exception
      false
    end
    return @web
  end

  class WebBridge
    FINE = "MUIA".b
    CODA_MAX = 4        # messagi in attesa de partir: oltre, i se perde (come in UDP)
    ARRETRATI_MAX = 8   # messagi ricevui in ritardo: oltre, se tien solo i ultimi
    ATTESA_MAX = 150    # secondi par conetarse (el server gratuito se svegia in ~1 minuto)
    POLL_FRAME = 3      # ogni quanti fotogrammi se controla la cartela (leggerla costa)

    def initialize(cartela = nil)
      @dir = cartela || System.data_directory
      @sigla = (Time.now.to_f * 1000).to_i.to_s(36)
      @n_out = 0
      @n_ctl = 0
      @ultimo_in = -1
      @elenco = []
      @generazion = 0
      @pendenti = {}
      @chiuso = false
      @frame = -1
      @coda = []          # messagi ricevui e ancora da consegnar al plugin
    end

    # ---- come un socket ---------------------------------------------------
    def send(messaggio, flags = 0)
      VMS::Perf.misura(:invio) { invia(messaggio, flags) }
    end

    def invia(messaggio, _flags = 0)
      return messaggio.bytesize if @chiuso
      @pendenti.delete_if { |nome, gen| gen < @generazion && !@elenco.include?(nome) }
      return messaggio.bytesize if @pendenti.size >= CODA_MAX
      @n_out += 1
      nome = nome_file("out", @n_out)
      File.binwrite(File.join(@dir, nome), messaggio.b + FINE)
      @pendenti[nome] = @generazion
      return messaggio.bytesize
    end

    def read_nonblock(_massimo = 65536, exception: true)
      # La cartela se controla solo ogni POLL_FRAME fotogrammi: nel browser
      # leggere la cartela e i file xe la roba che pesa de più. Se conta i
      # fotogrammi veri (el plugin adesso ciama più volte par fotogramma).
      frame = Graphics.frame_count
      if frame != @frame && frame % POLL_FRAME == 0
        @frame = frame
        VMS::Perf.misura(:poll) { controlla }
      end
      return :wait_readable if @coda.empty?
      VMS::Perf.conta(:msg_in)
      return @coda.shift
    end

    def controlla
      aggiorna_elenco
      # Se la pagina dise che la conession xe cascà, avisemo el plugin
      # (che se spetta un messagio compresso)
      if !@chiuso && !@avisato && stato =~ /\A(chiuso|erore)/
        @avisato = true
        @coda.unshift(Zlib::Deflate.deflate(Marshal.dump(:disconnect), Zlib::BEST_SPEED))
      end
      ricevui = @elenco.select { |n| n.start_with?("muia_in_#{@sigla}_") }.sort
      ricevui = ricevui.select { |n| numero(n) > @ultimo_in }
      ricevui = ricevui.last(2) if ricevui.size > ARRETRATI_MAX
      ricevui.each do |nome|
        dati = File.binread(File.join(@dir, nome))
        break unless dati.end_with?(FINE)   # ancora in scritura: al prossimo giro
        @ultimo_in = numero(nome)
        @coda << dati[0...-FINE.bytesize]
      end
      @coda = @coda.last(2) if @coda.size > ARRETRATI_MAX
    end

    def close
      return if @chiuso
      scrivi_controllo("close")
      @chiuso = true
    end

    # ---- conession ---------------------------------------------------------
    # Dise alla pagina de verzer la conession e speta che sia pronta, mostrando
    # un messagio. Torna true se tuto ok; false se l'utente anula o se rompe.
    def connetti
      scrivi_controllo("open")
      finestra = pbCreateMessageWindow
      finestra.letterbyletter = false
      testo_prima = nil
      t0 = Time.now
      esito = false
      loop do
        VMS.scene_update
        aggiorna_elenco
        s = stato
        if s == "connesso"
          esito = true
          break
        elsif s =~ /\Aerore/ || s == "chiuso"
          testo_prima = nil
          pbDisposeMessageWindow(finestra)
          finestra = nil
          VMS.message(VMS::CONNECTION_ISSUE_MESSAGE)
          break
        elsif Input.trigger?(Input::BACK)
          break
        elsif Time.now - t0 > ATTESA_MAX
          pbDisposeMessageWindow(finestra)
          finestra = nil
          VMS.message(VMS::SERVER_INACTIVE_MESSAGE)
          break
        end
        testo = if s.nil? && Time.now - t0 > 8
          _INTL("La pagina no risponde: ricarica la pagina del zogo.")
        elsif s == "svejo"
          _INTL("Svejo el server... Pol voler fin a un minuto. (B par anular)")
        else
          _INTL("Me coneto al server... (B par anular)")
        end
        if testo != testo_prima
          finestra.text = testo
          testo_prima = testo
        end
        finestra.update
      end
      pbDisposeMessageWindow(finestra) if finestra
      close if !esito
      return esito
    end

    # Ultimo stato scrito dalla pagina (o nil se ancora gnente)
    def stato
      nomi = @elenco.select { |n| n.start_with?("muia_stato_#{@sigla}_") }
      return nil if nomi.empty?
      dati = File.binread(File.join(@dir, nomi.max_by { |n| numero(n) }))
      return nil unless dati.end_with?(FINE)
      return dati[0...-FINE.bytesize].force_encoding("UTF-8")
    rescue Exception
      return nil
    end

    private

    def nome_file(tipo, n)
      return "muia_#{tipo}_#{@sigla}_#{'%08d' % n}.bin"
    end

    def numero(nome)
      return nome[/_(\d+)\.bin\z/, 1].to_i
    end

    def scrivi_controllo(comando)
      @n_ctl += 1
      File.binwrite(File.join(@dir, nome_file("ctl", @n_ctl)), comando.b + FINE)
    end

    def aggiorna_elenco
      # i file temporanei del browser (.crswap) no i conta: solo i .bin finii
      @elenco = Dir.entries(@dir).select { |n| n.start_with?("muia_") && n.end_with?(".bin") }
      @generazion += 1
    rescue Exception
      @elenco = []
    end
  end
end
