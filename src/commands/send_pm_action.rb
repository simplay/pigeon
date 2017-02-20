# Fuzzy matching private message sending via pigeon
class SendPmAction < WithArgumentsAction
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
