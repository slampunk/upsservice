require 'socket'
require_relative 'slack_service'

class UPSDevice
  attr_reader :name, :server
  attr_accessor :infoHash, :stop_server_msg

  SOCKET_PATH='/tmp/ups.sock'

  def initialize(upsName = 'eaton')
    @name = upsName
    @infoHash = {}
    @stop_server_msg = false

    File.delete SOCKET_PATH if File.exists?(SOCKET_PATH) && !is_in_use?(SOCKET_PATH)
    @server = UNIXServer.open(SOCKET_PATH)

    @slack_service = SlackService.new
    listen_unix_socket
  end

  def listen_unix_socket
    puts "listening on socket #{SOCKET_PATH}"
    while !@stop_server_msg do
      client = @server.accept

      case client.readline.chomp
        when "PING"
          client.puts "PONG"
        when "ONBATTERY"
          ups_info = get_ups_info
          msg = "Power is OUT!!! battery level: #{ups_info['battery.charge']}%"
          @slack_service.send_msg(msg)
          # send message that power is out
          # optionally send battery levels
          # optionally shut down Sonos? TV? (TV assuming that the power outlets on the UPS itself can be switched off)
        when "ONLINE"
          msg = "Power is restored! Keep on being your awesome selves"
          @slack_service.send_msg(msg)
          # send message that power is restored
        when "BATTERYLEVEL"
          # perhaps there's a way to intercept events for batt levels?
        when "LOWBATTERY"
          msg = "UPS is low on battery and will be shutting down soon. Its a good idea to save/push all your work now"
          @slack_service.send_msg(msg)
          # send message that battery will run out soon
        when "REPLACEBATTERY"
          msg = "*UPS battery is in need of replacement.* Here are a few contact details:```Eaton Wadeville head office\ntel: 011 824-7400\nemail: infosouthafrica@eaton.com\n\nEaton Epping\ntel:021 531 5852\nemail: capetown@eaton.com```"
          @slack_service.send_msg(msg)
          # send message that battery needs to be replaced
        when "SHUTDOWN"
          # do we need to shutdown the ups service?
          @stop_server_msg = true
      end
      # Uncomment below to see messages live
      #puts "socket message: #{client.readline}"
    end

    File.delete(SOCKET_PATH)
  end

  def is_in_use?(path)
    # an exception is raised if a socket connection cannot be opened to a given path
    # i.e. an exception implies that the given unix socket is stale/not in use
    begin
      UNIXSocket.open(path)
      return true
    rescue
      return false
    end
  end

  def get_ups_info
    `upsc eaton`
      .split("\n")
      .map { |line| line.split(": ") }.to_h
  end
end

upsDevice = UPSDevice.new
