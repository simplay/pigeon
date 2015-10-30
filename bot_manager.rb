require_relative 'bot'
require_relative 'server_config'

class BotManager
  def initialize
    config = ServerConfig.new
    bot = Bot.new(config)
    bot.start
    bot.say_in_current_channel("pew nils pew pew pew ...")
    bot.shut_down
  end
end
