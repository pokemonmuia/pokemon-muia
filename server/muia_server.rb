#!/usr/bin/env ruby
# Pokémon Muia: server del multiplayer (senza el zogo).
#
# Dopra el STESSO server del plugin (Plugins/Voltseon's Multiplayer Solution),
# cussì gnente se duplica: qua se prepara solo quel che serve a farlo girar da
# solo, fora da Essentials. Ascolta in UDP su 127.0.0.1:PORT; davanti ghe sta
# ponte.js, che ghe passa i messaggi dei zogadori dal browser.
require "socket"
require "zlib"
require "time"

RADICE = File.expand_path("..", __dir__)
PLUGIN = File.join(RADICE, "Plugins", "Voltseon's Multiplayer Solution")

# Piccole cose de Essentials che el plugin dopra solo per scriver nella console
def echoln(testo)
  puts "#{Time.now.strftime('%H:%M:%S')} #{testo}"
  $stdout.flush
end

module Console
  def self.markup_style(testo, **)
    testo
  end
end

load File.join(PLUGIN, "001_Base", "001_VMS_Config.rb")
module VMS
  remove_const(:LOG_TO_CONSOLE)
  LOG_TO_CONSOLE = true
end
load File.join(PLUGIN, "006_Integrated_Server", "001_VMS_Integrated_Server.rb")

# Porta e indirizzo possono vegnir dal ambiente (Docker/Render)
port = (ENV["VMS_PORT"] || VMS::PORT).to_i
VMS::IntegratedServer::Server.class_eval do
  define_method(:initialize) do
    @port = port
    @host = ENV["VMS_HOST"] || "127.0.0.1"
    @clusters = {}
    @clients = {}
    @tick_rate = VMS::TICK_RATE
    @heartbeat_timeout = VMS::HEARTBEAT_TIMEOUT
    @use_tcp = false
    @socket = UDPSocket.new
    @socket.bind(@host, @port)
  end
end

VMS::IntegratedServer.running = true
echoln "Server Muia in ascolto su #{ENV['VMS_HOST'] || '127.0.0.1'}:#{port} (UDP)"
trap("TERM") { VMS::IntegratedServer.running = false }
trap("INT")  { VMS::IntegratedServer.running = false }
VMS::IntegratedServer::Server.new.start
echoln "Server fermà"
