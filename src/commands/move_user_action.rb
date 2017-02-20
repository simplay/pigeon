# Drags a client by its nick (fuzzy) to the channel
# where the command sender is currently in.
#
# @info: Only partial match is required. Movement is applied to
#   every user retrieved by fuzzy finder.
# @param fuzzy_nick [String] name of user to be dragged
class MoveUserAction < WithArgumentsAction

  # @param fuzzy_nick [String] partial matching nick name
  def run(fuzzy_nick)
    matches = User.try_find_all_by_nick(fuzzy_nick)
    unless matches.empty?
      sender = Command.sender
      matches.each do |user|
        Bot.move_target(user, sender.channel_id)
      end
    end
  end
end
