java_import 'Bots.ChatterBotFactory'
java_import 'Bots.ChatterBotType'

class ChatbotFactory

  def self.instance
    @instance ||= ChatbotFactory.new
  end

  def self.cleverbot
    instance.cleverbot
  end

  def self.pandorabot
    instance.pandorabot
  end

  class ChatBot
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def tell(message)
      @session.tell(message)
    end

  end

  def initialize
    @factory = ChatterBotFactory.new
  end

  # @return [ChatterBotSession]
  def cleverbot
    bot = @factory.create(ChatterBotType::CLEVERBOT)
    ChatBot.new(bot.create_session)
  end

  # @return [ChatterBotSession]
  def pandorabot
    bot = @factory.create(ChatterBotType::PANDORABOTS, "b0dafd24ee35a477")
    ChatBot.new(bot.create_session)
  end

end
