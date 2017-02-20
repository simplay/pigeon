# passing only one arg should result in listing
#
# @example
#   Add a new link with identifier github, label Github and the given link:
#     !adl github_home Github https://github.com
#   List all link identifiers containing mc:
#     !adl mc
class SaveLinkAction < WithArgumentsAction
  def run(msg)
    case msg.count
    when 3
      id = ("mc_"+msg[0]).to_sym
      raw_content = msg[2].gsub(/\[(\/)*URL\]/, "")
      link = LabeledLinkText.new(raw_content, msg[1])
      DescriptionLinkStore.write(link, id)
    when 1
      nodes = DescriptionLinkStore.find_all_including_key(msg[0], true)
      identifiers = nodes.map do |node|
        key = node.first
        ":#{key.to_s}"
      end
      message = "Known #{msg[0]} nodes:\n"
      Bot.say_as_private(Command.sender, message+identifiers.join("\n"))
    end
  end
end
