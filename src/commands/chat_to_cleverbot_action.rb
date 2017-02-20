# Send a message to cleverbot
#
# @example
#   !cb "you are a bot" results in
#   message = ["you", "are", "a", "bot"]
class ChatToCleverbotAction < WithArgumentsAction

  # @param message [Array<String>] message that should be sent to cleverbot 
  def run(message)
    msg = message.join(" ")
    answer = ChatbotFactory.cleverbot.tell(msg)
    Bot.say_as_private(Command.sender, answer)
  end
end
