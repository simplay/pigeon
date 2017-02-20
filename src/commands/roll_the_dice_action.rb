# Create/Modify/List/Delete a roll to dice (rtd) link (node).
#
# @info:
#   formats:
#     <ID, URL, FROM, TO>
#       add a url with a given id having a certain from to range
#     <ID, URL, FROM>
#       add a url with a given id starting at second FROM
#     <ID, URL>
#       add a url with a given id without having a temporal limit
#     <ID>
#       Delete the node with a given ID
#     NONE
#       List all nodes
class RollTheDiceAction < WithArgumentsAction
  def run(msg)
    case msg.count
    when 4
      TauntLinkStore.write(msg[0], msg[1], msg[2], msg[3])
    when 3
      TauntLinkStore.write(msg[0], msg[1], msg[2])
    when 2
      TauntLinkStore.write(msg[0], msg[1])
    when 1
      TauntLinkStore.delete(msg[0])
    when 0
      links = TauntLinkStore.all_links
      links.each do |link|
        Bot.say_as_private(Command.sender, link)
      end
    end
  end
end
