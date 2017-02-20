# Send a message to pandorabot
#
# @info
#   !pb "you are a bot" results in
#   message = ["you", "are", "a", "bot"]
# @param message [Array<String>] user message, word by word.
class ChatToPandorabotAction < WithArgumentsAction
  def run(message)
    msg = message.join(" ")
    answer = ChatbotFactory.pandorabot.tell(msg)
    Bot.say_as_private(Command.sender, answer)
  end
end
