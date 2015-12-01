java_import 'Bots.ChatterBotFactory'
java_import 'Bots.ChatterBotType'

# ChatbotFactory is a Singleton that creates either a Cleverbot
# or Pandorabot session we can communicate with.
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

  class Chatbot
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
    if @c_bot_session.nil?
      bot = @factory.create(ChatterBotType::CLEVERBOT)
      @c_bot_session = Chatbot.new(bot.create_session)
    end
    @c_bot_session
  end

  # @return [ChatterBotSession]
  def pandorabot
    if @p_bot_session.nil?
      bot = @factory.create(ChatterBotType::PANDORABOTS, "b0dafd24ee35a477")
      @p_bot_session = Chatbot.new(bot.create_session)
    end
    @p_bot_session
  end

end
