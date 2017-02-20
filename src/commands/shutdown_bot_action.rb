# Shut down the bot
class ShutdownBotAction < SimpleAction
  def run
    Bot.say_in_current_channel("I'm leaving now - cu <3")
    Bot.shut_down
  end
end
