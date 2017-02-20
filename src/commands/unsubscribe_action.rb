# Unsubscribes command caller from the ot list.
class UnsubscribeAction < SimpleAction
  def run
    OtList.remove(Command.sender)
    Bot.say_as_private(Command.sender, "Unsubscribed: Hope, I'm gonna see you soon again. QQ")
  end
end
