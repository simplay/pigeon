# Poking pigeon will result in pigeon poking the sender.
class PokeAction < SimpleAction
  
  def run
    let_bot_say(Command.sender, "Hey, stop poking me!")
  end
end
