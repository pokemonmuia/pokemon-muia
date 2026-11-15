#===============================================================================
# Muia - Stessi tasti da tastiera su Windows, Mac e versione web
#
#   Z / Spazio / Invio  = A del gioco (conferma)        -> Input::USE
#   X                   = B del gioco (indrio e corer)  -> Input::BACK
#   Esc                 = verzi e sera el menu          -> Input::ACTION
#   D                   = menu rapido                   -> Input::SPECIAL
#   Frecie              = caminar
#
# mkxp-z de base el meteria Z = menu e Esc = indrio: qua se cambia solo questo.
# I gamepad e i tasti a schermo del telefono no i cambia.
# Nella version web la tastiera la tradusi la pagina (web/gioca/main.ts) e
# sti metodi "ex" no i vedi gnente, quindi qua no se fa danni.
#===============================================================================
module Input
  # tasti da zontar a un boton del zogo
  MUIA_TASTI_PIU   = { C => [:Z], A => [:ESCAPE] }
  # tasti che mkxp-z ghe meteria de base ma che no volemo
  MUIA_TASTI_MENO  = { A => [:Z], B => [:ESCAPE] }

  class << self
    [[:press?, :pressex?], [:trigger?, :triggerex?],
     [:repeat?, :repeatex?], [:release?, :releaseex?]].each do |metodo, ex|
      originale = :"muia_tasti_#{metodo.to_s.chomp('?')}"
      next if method_defined?(originale) || !method_defined?(metodo)
      alias_method originale, metodo
      define_method(metodo) do |boton|
        risultato = send(originale, boton)
        next risultato unless respond_to?(ex)
        begin
          meno = MUIA_TASTI_MENO[boton]
          risultato = false if risultato && meno && meno.any? { |k| send(ex, k) }
          piu = MUIA_TASTI_PIU[boton]
          risultato ||= piu.any? { |k| send(ex, k) } if piu
        rescue StandardError
          # se el motor no conossi un tasto, se tien el comportamento de base
        end
        risultato
      end
    end
  end
end
