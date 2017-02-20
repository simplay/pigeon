# List all users currently online.
class WhoAction < SimpleAction

  def run
    user_nicks = Session.users.map do |user|
      user.nick + "\n"
    end
    Bot.say_as_private(Command.sender, user_nicks.join)
  end
end
