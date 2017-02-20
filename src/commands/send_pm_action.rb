# Send a private message to a user by its nickname.
# The nickname has only to match partially.
class SendPmAction < WithArgumentsAction

  # @param args [Array] containing the target user's nick
  # (1st argument) and message (2nd argument)
  def run(args)
    fuzzy_nick = args[0]
    msg = args[1]
    matched_users = User.try_find_all_by_nick(fuzzy_nick)
    sender = Command.sender
    header = "#{sender.nick} sent you: "
    matched_users.each do |user|
      Bot.say_as_private(user, header+msg)
    end
  end
end
