# Toggle talking to bot mod.
# Currently, there are two bots availble, cleverbot and pandorabot.
# While being in this mode, a user is constantly
# chatting to cleverbot while writting to pigeon (via pm).
# However, commands (messages starting with a '!') are still
# correctly parsed and will get invoked.
# I.e. they are not send to cleverbot
# but the corresponding command is executed.
class ToggleBotChatAction < SimpleAction
  def run
    sender = Command.sender
    session_user = Session.find_user_in_userlist(sender.id)
    session_user.toggle_talking_to_cb
  end
end
