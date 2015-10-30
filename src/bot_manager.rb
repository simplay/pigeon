require_relative 'bot'
require_relative 'server_config'

class BotManager
  def initialize
    config = ServerConfig.new
    bot = Bot.new(config, "Pigeon")
    bot.start
  end
end
