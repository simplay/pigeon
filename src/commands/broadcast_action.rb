# Send a poke-like message to every user on the server.
# 
# @example !bc fancyMessage
class BroadcastAction < WithArgumentsAction

  # @param message [String] global message that should be sent to all users.
  def run(message)
    msg = message.join(" ")
    User.all.each do |user|
      let_bot_say(user, msg)
    end
  end
end
