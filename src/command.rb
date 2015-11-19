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

  def self.open_terminal
    @bot.say_as_private(Command.sender, "How can I serve you?")
  end

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
      @bot.say_as_private(user, header+msg) if user.human?
    end
  end

  # list all available help commands
  def self.help
    sender = Command.sender
    header = "Available commands: \n"
    help_msgs = @all.keys.map do |cmd|
      description = CommandDescription.parse(cmd)
      "!#{cmd.to_s} - #{description} \n"
    end
    @bot.say_as_private(sender, header+help_msgs.join)
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

