class Command

  def self.all
    @all ||= {
      :poke => Command.new { poke },
      :bb => Command.new(ServerGroup.server_admin) { leave_server }, # bybye
      :ll => Command.new(ServerGroup.normal) { |nicks| list_urls(nicks) }, # list links
      :rs => Command.new(ServerGroup.normal) { |keyword| crawl_for(keyword, 1) }, # random shit
      :rsi => Command.new(ServerGroup.normal) { crawl_img },
      :pm => Command.new(ServerGroup.normal) { |args| pm_to(args[0], args[1]) },
      :rsw => Command.new(ServerGroup.normal) { crawl_wtf },
      :ot => Command.new(ServerGroup.normal) { open_terminal},
      :dd => Command.new(ServerGroup.server_admin) { |nick| drag_and_drop(nick.first) },
      :s => Command.new(ServerGroup.normal) { subscribe_to_ot_list },
      :us => Command.new(ServerGroup.normal) { unsubscribe_from_ot_list },
      :cb => Command.new(ServerGroup.normal) { |msg| say_to_cleverbot(msg) },
      :tcbm => Command.new(ServerGroup.normal) { toggle_cleverbot_mode },
      :pb => Command.new(ServerGroup.normal) { |msg| say_to_pandorabot(msg) },
      :adl => Command.new(ServerGroup.server_admin) { |msg| append_description_link(msg) },
      :ddl => Command.new(ServerGroup.server_admin) { |msg| delete_description_link(msg) },
      :bc => Command.new(ServerGroup.server_admin) { |msg| broadcast(msg) },
      :rtd => Command.new(ServerGroup.server_admin) { |msg| roll_the_dice(msg) },
      :h => Command.new { help }
    }
  end

  # @param auth_level [AuthLevel] required authentication level required to
  #   invoke the target command.
  # @param instr [Procedure] lambda defining the invoked command instuction.
  def initialize(auth_level=ServerGroup.lowest, &instr)
    @auth_level = auth_level
    @instr = instr
  end

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
  def self.roll_the_dice(msg)
    case msg.count
    when 4
      TauntLinkStore.write(msg[0], msg[1], msg[2], msg[3])
    when 3
      TauntLinkStore.write(msg[0], msg[1], msg[2])
    when 2
      TauntLinkStore.write(msg[0], msg[1])
    when 1
      TauntLinkStore.delete(msg[0].to_sym)
    when 0
      links = TauntLinkStore.all_links
      links.each do |link|
        @bot.say_as_private(Command.sender, link)
      end
    end
  end

  # Send a message a poke notification to every user currently online.
  def self.broadcast(message)
    msg = message.join(" ")
    User.all.each do |user|
      let_bot_say(user, msg)
    end
  end

  # Toggle talking to clever bot mod.
  # While being in this mode, a user is constantly
  # chatting to cleverbot while writting to pigeon (via pm).
  # However, commands (messages starting with a '!') are still
  # correctly parsed and will get invoked.
  # I.e. they are not send to cleverbot
  # but the corresponding command is executed.
  def self.toggle_cleverbot_mode
    sender = Command.sender
    session_user = Session.find_user_in_userlist(sender.id)
    session_user.toggle_talking_to_cb
  end

  # Delete a discription link by providing a substring of the target identifier.
  #
  # @example
  #   Given the identifier mc_foo, delete it from the description:
  #     !ddl foo
  def self.delete_description_link(msg)
    id = DescriptionLinkStore.find_all_including_key(msg[0], true).first
    DescriptionLinkStore.delete(id.first)
  end

  # passing only one arg should result in listing
  #
  # @example
  #   Add a new link with identifier github, label Github and the given link:
  #     !adl github_home Github https://github.com
  #   List all link identifiers containing mc:
  #     !adl mc
  def self.append_description_link(msg)
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
      @bot.say_as_private(Command.sender, message+identifiers.join("\n"))
    end
  end

  # Subscribes the command caller to pigeon's ot list.
  # When a user on that list enters the server, it will
  # receive a private message sent trough a private channel to Sir Pigeon.
  # This channel can be used for sending commands to the bot.
  def self.subscribe_to_ot_list
    OtList.append(Command.sender)
    @bot.say_as_private(Command.sender, "Successfully subscribed - yay, friends forever.")
  end

  # Unsubscribes command caller from the ot list.
  def self.unsubscribe_from_ot_list
    OtList.remove(Command.sender)
    @bot.say_as_private(Command.sender, "Unsubscribed: Hope, I'm gonna see you soon again. QQ")
  end

  # Send a message to cleverbot
  #
  # @info
  #   !cb "you are a bot" results in
  #   message = ["you", "are", "a", "bot"]
  # @param message [Array<String>] user message, word by word.
  def self.say_to_cleverbot(message)
    msg = message.join(" ")
    answer = ChatbotFactory.cleverbot.tell(msg)
    @bot.say_as_private(Command.sender, answer)
  end

  # Send a message to pandorabot
  #
  # @info
  #   !pb "you are a bot" results in
  #   message = ["you", "are", "a", "bot"]
  # @param message [Array<String>] user message, word by word.
  def self.say_to_pandorabot(message)
    msg = message.join(" ")
    answer = ChatbotFactory.pandorabot.tell(msg)
    @bot.say_as_private(Command.sender, answer)
  end

  # Try to invoke a given command by a user.
  #
  # @info: Invoking commands is guarded. A particular command
  #   can only be invoked if the invoking user has enough priviliges
  #   to invoe that command.
  # @param user [User] sender of command
  # @param args [Array] command name and its arguments
  def invoke_by(user, args)
    Command.sender = user
    if user.level? @auth_level
      @instr.call(args)
    else
      msg = "You do not have permission to use this command!"
      Command.let_bot_say(Command.sender, msg)
    end
  end

  # drags a client by its nick (fuzzy) to the channel
  # where the command sender is currently in.
  #
  # @info: Only partial match is required. Movement is applied to
  #   every user retrieved by fuzzy finder.
  # @param fuzzy_nick [String] name of user to be dragged
  def self.drag_and_drop(fuzzy_nick)
    matches = User.try_find_all_by_nick(fuzzy_nick)
    unless matches.empty?
      sender = Command.sender
      matches.each do |user|
        @bot.move_target(user, sender.channel_id)
      end
    end
  end

  # Forces the bot to send a private message (pm)
  # to the sender.
  #
  # @info: The bot can only receive messages by users via:
  #     + the global server chat.
  #     + the channel the bot is located at (the lobby).
  #     + private messages.
  #
  #   Since users are barely in the server lobby or
  #   are chatting via the global server chat, the only appropriate
  #   variant to communicate with pigeon is through sending a pm.
  def self.open_terminal
    @bot.say_as_private(Command.sender, "How may I serve you?")
  end

  # Poking pigeon will result in pigeon poking the sender.
  def self.poke
    let_bot_say(Command.sender, "Hey, stop poking me!")
  end

  def self.let_bot_say(sender, msg)
    @bot.say_as_poke(sender, msg)
  end

  # Fuzzy matching private message sending via pigeon
  def self.pm_to(fuzzy_nick, msg)
    matched_users = User.try_find_all_by_nick(fuzzy_nick)
    sender = Command.sender
    header = "#{sender.nick} sent you: "
    matched_users.each do |user|
      @bot.say_as_private(user, header+msg)
    end
  end

  # list all available help commands
  def self.help
    sender = Command.sender
    header = "Available commands: \n"
    help_msgs = @all.keys.map do |cmd|
      description = CommandDescription.parse(cmd)
      "!#{cmd.to_s} #{description} \n"
    end

    splits = help_msgs.each_slice(5).to_a
    linked_splits = splits.map do |split|
      LinedText.new(split)
    end
    msg_count = linked_splits.count
    linked_splits.each_with_index do |split, idx|
      @bot.say_as_private(sender, "[#{idx+1}/#{msg_count}] " + header + split.to_s + "\n")
    end
  end

  def self.leave_server
    @bot.say_in_current_channel("I'm leaving now - cu <3")
    @bot.shut_down
  end

  def self.list_urls(nicks)
    sorted_links = if nicks.empty?
      UrlStore.all
    else
      users = nicks.map { |nick| User.find_by_nick(nick) }
      users.flat_map { |u| UrlStore.urls(u.id) }
    end.sort

    return if sorted_links.empty?
    message = "Links: \n" + sorted_links.map(&:escaped).join("\n")
    @bot.say_as_private(Command.sender, message)
  end

  def self.crawl_for(keyword, amount)
    @bot.say_in_current_channel "Searching for wtf stuff..."
    crawler = keyword.empty? ? Crawler.new : Crawler.new(keyword.first)
    unless crawler.ok?
      @bot.say_as_private(Command.sender, "Sorry, nothing found...")
      return
    end
    crawler.links.first(amount).each do |result|
      @bot.say_as_private(Command.sender, "https://reddit.com"+result.last, true)
    end
  end

  def self.crawl_img
    @bot.say_as_private(Command.sender, "Searching for random stuff...")
    crawler = RedditImgCrawler.new
    results = crawler.links
    random_idx = rand(0..results.count-1)
    @bot.say_as_private(Command.sender, results.values[random_idx], true)
  end

  def self.crawl_wtf
    @bot.say_as_private(Command.sender, "Searching for random stuff...")
    crawler = WtfCrawler.new
    results = crawler.links
    random_idx = rand(0..results.count-1)
    @bot.say_as_private(Command.sender, results.values[random_idx], true)
  end

  # Remember running pigeon bot instance.
  #
  # @param bot [Bot] running Pigeon instance listening to clients on server.
  def self.prepare(bot)
    @bot ||= bot
  end

  # Return sender of current command
  #
  # @return [User] user who sent last message to Bot.
  def self.sender
    @sender
  end

  # Remember sender of last message
  #
  # @param sender [User] user who sent last message to Bot.
  def self.sender=(sender)
    @sender = sender
  end

end
