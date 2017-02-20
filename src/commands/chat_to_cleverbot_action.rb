# Send a message to cleverbot
#
# @info
#   !cb "you are a bot" results in
#   message = ["you", "are", "a", "bot"]
# @param message [Array<String>] user message, word by word.
class ChatToCleverbotAction < WithArgumentsAction
  def run(message)
    msg = message.join(" ")
    answer = ChatbotFactory.cleverbot.tell(msg)
    Bot.say_as_private(Command.sender, answer)
  end
end
