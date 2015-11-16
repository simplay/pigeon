class Command

  def self.all
    @all ||= {
      :poke => Command.new { poke },
      :bb => Command.new { leave_server }, # bybye
      :ll => Command.new { |nicks| list_urls(nicks) }, # list links
      :rs => Command.new { |keyword| crawl_for(keyword, 1) }, # random shit
      :rsi => Command.new { crawl_img },
      :rsw => Command.new { crawl_wtf },
      :h => Command.new { help }
    }
  end

  # @param auth_level [AuthLevel] required authentication level required to
  #   invoke the target command.
  # @param instr [Procedure] lambda defining the invoked command instuction.
  def initialize(auth_level=8, &instr)
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
    if user.level? @auth_level
      Command.sender = user
      @instr.call(args)
    end
  end

  def self.poke
    @bot.say_as_poke(Command.sender, "Hey, stop poking me!")
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
    if nicks.empty?
      UrlStore.all
    else
      users = nicks.map { |nick| User.find_by_nick(nick) }
      users.flat_map { |u| UrlStore.urls(u.id) }
    end.sort.each do |url|
      @bot.say_as_private(Command.sender, url.escaped)
    end
  end

  def self.crawl_for(keyword, amount)
    @bot.say_in_current_channel "Searching for random stuff..."
    crawler = keyword.empty? ? Crawler.new : Crawler.new(keyword.first)
    unless crawler.ok?
      @bot.say_in_current_channel("Sorry, nothing found...")
      return
    end
    crawler.links.first(amount).each do |result|
      @bot.say_in_current_channel("https://reddit.com"+result.last, true)
    end
  end

  def self.crawl_img
    @bot.say_in_current_channel "Searching for random stuff..."
    crawler = RedditImgCrawler.new
    results = crawler.links
    random_idx = rand(0..results.count-1)
    @bot.say_in_current_channel(results.values[random_idx], true)
  end

  def self.crawl_wtf
    @bot.say_in_current_channel "Searching for wtf stuff..."
    crawler = WtfCrawler.new
    results = crawler.links
    random_idx = rand(0..results.count-1)
    @bot.say_in_current_channel(results.values[random_idx], true)
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

