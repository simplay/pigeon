# Poke Sir Pigeon.
# This will result in Sir Pigeon poking the sender.
# Can be used to ping the bot and test, whether the bot has crashed.
class PokeAction < SimpleAction
  def run
    let_bot_say(Command.sender, "Hey, stop poking me!")
  end
end
