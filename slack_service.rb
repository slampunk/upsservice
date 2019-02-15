require 'net/http'
require 'uri'
require 'json'
require 'dotenv'
require 'pry'

Dotenv.load('.env')

class SlackService
  VARS = {
    url: "https://hooks.slack.com/services/#{ENV['APP_ID']}/#{ENV['CHANNEL_ID']}/#{ENV['TOKEN']}",
    content_type: "application/json"
  }

  def send_msg(msg)
    uri = URI.parse(VARS[:url])
    request = Net::HTTP::Post.new(uri)
    request.content_type = VARS[:content_type]

    request.body = JSON.dump({
      "text" => msg
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end

SlackService.new.send_msg("HEY, I'M THE UPS SLACK BOT")
