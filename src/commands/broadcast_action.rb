# Send a message a poke notification to every user currently online.
class BroadcastAction < WithArgumentsAction
  def run(message)
    msg = message.join(" ")
    User.all.each do |user|
      let_bot_say(user, msg)
    end
  end
end
