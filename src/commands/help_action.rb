# List all available help commands
class HelpAction < SimpleAction

  def run
    sender = Command.sender
    github_url = LinkText.new("https://github.com/simplay/pigeon")
    version_info = "Sir Pigeon Bot version #{BoldText.new(Bot::VERSION).to_s} (#{github_url.to_s}) \n" 
    header = "Available commands: \n"
    help_msgs = Command.all.keys.map do |cmd|
      description = CommandDescription.parse(cmd)
      "!#{cmd.to_s} #{description} \n"
    end

    splits = help_msgs.each_slice(5).to_a
    linked_splits = splits.map do |split|
      LinedText.new(split)
    end
    msg_count = linked_splits.count
    Bot.say_as_private(sender, "#{version_info}\n")
    linked_splits.each_with_index do |split, idx|
      Bot.say_as_private(sender, "[#{idx+1}/#{msg_count}] " + header + split.to_s + "\n")
    end
  end
end
