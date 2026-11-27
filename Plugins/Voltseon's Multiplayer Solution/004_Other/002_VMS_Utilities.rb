class String
  def numeric?
    return true if self =~ /\A\d+\z/
    true if Float(self) rescue false
  end
end

module VMS
  def self.basic_type?(variable)
    [Integer, Float, String, Symbol, TrueClass, FalseClass, NilClass].any? { |type| variable.is_a?(type) }
  end

  def self.encrypt(data)
    ret = {:class => data.class}
    data.instance_variables.each do |var|
      variable = data.instance_variable_get(var)
      if variable.is_a?(Array)
        index = 0
        ret[var] = { :class => variable.class }.merge(variable.each_with_object({}) do |var2, hash2|
          if VMS.basic_type?(var2)
            hash2["#{index}"] = var2
          else
            hash2["#{index}"] = VMS.encrypt(var2)
          end
          index += 1
        end)
      elsif variable.is_a?(Hash)
        ret[var] = { :class => variable.class }.merge(variable.each_with_object({}) do |var2, hash2|
          key = var2[0]
          value = var2[1]
          if VMS.basic_type?(value)
            hash2[key] = value
          else
            hash2[key] = VMS.encrypt(value)
          end
        end)
      elsif VMS.basic_type?(variable)
        ret[var] = variable
      else
        ret[var] = VMS.encrypt(variable)
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Muia 1.47: lettura SICURA del testo dei pokemon che riva dai altri zogadori.
  # Prima se feva eval(testo): el testo vien dala rete, quindi un zogador
  # malintenzionà podeva farghe eseguir qualsiasi codice Ruby al zogo dei altri
  # (sul PC anca comandi del computer). Adesso se lexe solo DATI, nel formato
  # che produce Hash#inspect (vecio "{:a=>1}" e novo "{a: 1}"): numeri, testi,
  # simboli, nil/true/false, {…}, […] e nomi de classe, ma solo quei in
  # CLASSI_SICURE. Tuto el resto = erore (el pokemon no se ricostruisi).
  #-----------------------------------------------------------------------------
  CLASSI_SICURE = %w[Pokemon Pokemon::Move Pokemon::Owner Mail Array Hash Time String Symbol].freeze

  class TestoNonValido < StandardError; end

  def self.muia_leggi_testo(testo)
    raise TestoNonValido, "no xe un testo" unless testo.is_a?(String)
    raise TestoNonValido, "massa lungo" if testo.bytesize > 200_000
    lettore = LettoreDati.new(testo)
    valore = lettore.valore
    lettore.spazi
    raise TestoNonValido, "roba in più in fondo" unless lettore.finio?
    return valore
  end

  # Classe ammessa par nome, o nil (mai const_get su nomi qualsiasi)
  def self.muia_classe_sicura(nome)
    return nil unless CLASSI_SICURE.include?(nome)
    return nome.split("::").inject(Object) { |m, p| m.const_get(p, false) }
  rescue NameError
    return nil
  end

  class LettoreDati
    def initialize(testo)
      @s = testo
      @i = 0
      @prof = 0
    end

    def finio?
      return @i >= @s.length
    end

    def spazi
      @i += 1 while @i < @s.length && @s[@i] =~ /\s/
    end

    def guarda(n = 1)
      return @s[@i, n]
    end

    def aspetta(t)
      spazi
      raise TestoNonValido, "speto #{t} a #{@i}" unless guarda(t.length) == t
      @i += t.length
    end

    def valore
      spazi
      raise TestoNonValido, "massa annidà" if @prof > 40
      c = guarda
      case c
      when "{" then return tabella
      when "[" then return lista
      when "\"" then return testo_fra_virgolette
      when ":" then return simbolo
      when nil then raise TestoNonValido, "finio prima del tempo"
      end
      return numero if c =~ /[-\d]/ || guarda(8) == "Infinity" || guarda(3) == "NaN"
      parola = @s[@i..-1][/\A[A-Za-z_][A-Za-z0-9_]*(::[A-Z][A-Za-z0-9_]*)*/]
      raise TestoNonValido, "carattere strano a #{@i}" if parola.nil?
      @i += parola.length
      case parola
      when "nil" then return nil
      when "true" then return true
      when "false" then return false
      end
      classe = VMS.muia_classe_sicura(parola)
      raise TestoNonValido, "classe non ammessa: #{parola}" if classe.nil?
      return classe
    end

    def tabella
      aspetta("{")
      @prof += 1
      ris = {}
      spazi
      if guarda == "}"
        @i += 1
        @prof -= 1
        return ris
      end
      loop do
        spazi
        chiave = chiave_nova_forma
        if chiave.nil?
          chiave = valore
          aspetta("=>")
        end
        ris[chiave] = valore
        spazi
        if guarda == ","
          @i += 1
        elsif guarda == "}"
          @i += 1
          break
        else
          raise TestoNonValido, "speto , o } a #{@i}"
        end
      end
      @prof -= 1
      return ris
    end

    # Forma nova (Ruby 3.4): "chiave: valor" o "\"chiave\": valor"
    def chiave_nova_forma
      m = @s[@i..-1][/\A[A-Za-z_@][A-Za-z0-9_]*[?!]?:(?!:)/]
      if m && m[-2] != ":"
        @i += m.length
        return m[0...-1].to_sym
      end
      if guarda == "\""
        salva = @i
        t = testo_fra_virgolette
        return t.to_sym if guarda == ":" && guarda(2) != "::"  && (@i += 1)
        @i = salva
      end
      return nil
    end

    def lista
      aspetta("[")
      @prof += 1
      ris = []
      spazi
      if guarda == "]"
        @i += 1
        @prof -= 1
        return ris
      end
      loop do
        ris << valore
        spazi
        if guarda == ","
          @i += 1
        elsif guarda == "]"
          @i += 1
          break
        else
          raise TestoNonValido, "speto , o ] a #{@i}"
        end
      end
      @prof -= 1
      return ris
    end

    def numero
      m = @s[@i..-1][/\A-?(Infinity|NaN|\d+(\.\d+)?(e[-+]?\d+)?)/]
      raise TestoNonValido, "numero strano a #{@i}" if m.nil?
      @i += m.length
      return Float::INFINITY if m == "Infinity"
      return -Float::INFINITY if m == "-Infinity"
      return Float::NAN if m.end_with?("NaN")
      return m =~ /[.e]/ ? m.to_f : m.to_i
    end

    ESCAPE = { "n" => "\n", "t" => "\t", "r" => "\r", "e" => "\e", "a" => "\a", "b" => "\b",
               "f" => "\f", "v" => "\v", "s" => " ", "0" => "\0" }.freeze

    def testo_fra_virgolette
      aspetta("\"")
      ris = +""
      loop do
        c = @s[@i]
        raise TestoNonValido, "testo mai serà" if c.nil?
        @i += 1
        break if c == "\""
        if c != "\\"
          ris << c
          next
        end
        e = @s[@i]
        raise TestoNonValido, "testo mai serà" if e.nil?
        @i += 1
        if ESCAPE.key?(e)
          ris << ESCAPE[e]
        elsif e == "u"
          if @s[@i] == "{"
            fin = @s.index("}", @i)
            raise TestoNonValido, "\\u{ mai serà" if fin.nil?
            @s[(@i + 1)...fin].split(" ").each { |h| ris << h.to_i(16).chr(Encoding::UTF_8) }
            @i = fin + 1
          else
            ris << @s[@i, 4].to_i(16).chr(Encoding::UTF_8)
            @i += 4
          end
        elsif e == "x"
          ris << @s[@i, 2].to_i(16).chr.force_encoding(Encoding::BINARY)
          @i += 2
        else
          ris << e   # \" \\ \# e compagnia
        end
      end
      return ris.force_encoding(Encoding::UTF_8)
    end

    def simbolo
      aspetta(":")
      return testo_fra_virgolette.to_sym if guarda == "\""
      m = @s[@i..-1][/\A(@{0,2}|\$)[A-Za-z_][A-Za-z0-9_]*[?!]?/]
      m ||= @s[@i..-1][/\A(\[\]=?|[+\-*\/%<>=!~^&|]+)/]
      raise TestoNonValido, "simbolo strano a #{@i}" if m.nil?
      @i += m.length
      # :nome= (setter), ma no quando el "=" xe quel de "=>"
      if @s[@i] == "=" && @s[@i + 1] != ">" && m =~ /\A@{0,2}[A-Za-z_]/
        m += "="
        @i += 1
      end
      return m.to_sym
    end
  end

  def self.decrypt(data, instance = nil)
    return data unless data.is_a?(Hash)
    return data unless data[:class] # Safety check
    # Muia 1.47: solo classi ammesse (el testo vien dala rete)
    return nil unless data[:class].is_a?(Class) && CLASSI_SICURE.include?(data[:class].name)

    defaults = VMS::ENCRYPTION_DEFAULTS[data[:class].name]
    case data[:class]
    when Array
      instance ||= []
    when Hash
      instance ||= {}
    else
      if data[:class].is_a?(Class) && data[:class].respond_to?(:new)
        if VMS::ENCRYPTION_DEFAULTS.key?(data[:class].name)
          case data[:class].name
          when "Pokemon" then instance ||= Pokemon.new(defaults[0], defaults[1])
          when "Pokemon::Move" then instance ||= Pokemon::Move.new(defaults[0])
          when "Pokemon::Owner" then instance ||= Pokemon::Owner.new(defaults[0], defaults[1], defaults[2], defaults[3])
          when "Battle::Move" then instance ||= Pokemon::Item.new(defaults[0])
          end
        else
          # Muia 1.47: prima se ciamava new con argomenti sbagliai (un pokemon
          # con una letera in man no se podeva ricostruir: Mail.new voleva 3
          # argomenti). Le classi ammesse xe solo dati: se crea l'oggetto voto
          # (senza eseguir el so initialize) e dopo se ghe meti i campi.
          instance ||= (data[:class] == Time) ? Time.now : data[:class].allocate
        end
      end
    end
    # Sort numeric string keys to ensure correct array order
    sorted_keys = data.keys.sort_by do |k|
      if k.is_a?(String) && k.numeric?
        k.to_i
      else
        # Non-numeric keys stay in original order (use a large number to sort them last)
        k == :class ? -1 : 999999
      end
    end

    sorted_keys.each do |var|
      val = data[var]
      next if var == :class
      if var.is_a?(String) && var.numeric?
        instance[var.to_i] = VMS.decrypt(val)
      elsif data[:class] == Hash
        instance[var] = VMS.decrypt(val)
      else
        instance.instance_variable_set(var, VMS.decrypt(val))
      end
    end
    return instance
  end

  def self.string_to_integer(str)
    prime = 31
    hash = 0
    str.each_char do |char|
      hash = (prime * hash + char.ord) % (2**31)
    end
    return hash
  end

  def self.array_compare(arr1, arr2)
    return false unless arr1.is_a?(Array) && arr2.is_a?(Array) && arr1.length == arr2.length
    return arr1 == arr2
  end
end