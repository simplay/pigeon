# Subscribes the command caller to pigeon's ot list.
# When a user on that list enters the server, it will
# receive a private message sent trough a private channel to Sir Pigeon.
# This channel can be used for sending commands to the bot.
class SubscribeAction < SimpleAction
  def run
    OtList.append(Command.sender)
    Bot.say_as_private(Command.sender, "Successfully subscribed - yay, friends forever.")
  end
end
