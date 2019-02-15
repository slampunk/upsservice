require "pry"
require_relative "slack_service"

class UpsDevice
  attr_reader :name
  attr_accessor :infoHash
  POLL_TIME = 300

  def initialize(upsName = 'eaton')
    @name = upsName
    @infoHash = {}
    @slackService = SlackService.new
  end

  def get_ups_info
    info = `upsc eaton`
    @infoHash = info.split("\n")
                  .map { |line| line.split(": ") }.to_h
  end

  def main_thing
    loop do
      get_ups_info()
      if is_power_out?
        report_to_slack
      end

      puts "sleeping for 5 minutes"
      sleep POLL_TIME
    end
  end

  def is_power_out?
    infoHash['ups.status'] == 'OB'
  end

  def report_to_slack
    msg = "Power is OUT!!! battery level: #{infoHash['battery.charge']}"
    @slackService.send_msg(msg)
  end
end

upsDevice = UpsDevice.new
upsDevice.main_thing
