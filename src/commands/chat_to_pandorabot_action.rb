# Send a message to pandorabot
#
# @example
#   !pb "you are a bot" results in
#   message = ["you", "are", "a", "bot"]
class ChatToPandorabotAction < WithArgumentsAction

  # @param message [Array<String>] message that should be sent to pandorabot 
  def run(message)
    msg = message.join(" ")
    answer = ChatbotFactory.pandorabot.tell(msg)
    Bot.say_as_private(Command.sender, answer)
  end
end
