# Forces the bot to send a private message (pm)
# to the sender.
#
# @info: The bot can only receive messages by users via:
#     + the global server chat.
#     + the channel the bot is located at (the lobby).
#     + private messages.
#
#   Since users are barely in the server lobby or
#   are chatting via the global server chat, the only appropriate
#   variant to communicate with pigeon is through sending a pm.
class OpenChatWithBotAction < SimpleAction
  def run
    Bot.say_as_private(Command.sender, "How may I serve you?")
  end
end
