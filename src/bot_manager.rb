class BotManager
  def initialize
    config = ServerConfig.new
    bot = Bot.new(config, "Sir Pigeon")
    bot.start
  end
end
