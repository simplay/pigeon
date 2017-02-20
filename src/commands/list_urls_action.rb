# List all stored (shared) links
class ListUrlAction < WithArgumentsAction
  def run(nicks)
    sorted_links = if nicks.empty?
                     UrlStore.all
                   else
                     users = nicks.map { |nick| User.find_by_nick(nick) }
                     users.flat_map { |u| UrlStore.urls(u.id) }
                   end.sort
    return if sorted_links.empty?
    message = "Links: \n" + sorted_links.map(&:escaped).join("\n")
    Bot.say_as_private(Command.sender, message)
  end
end
