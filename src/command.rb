class Command

  def self.all
    @all ||= {
      :poke => Command.new { poke },
      :bb => Command.new { leave_server }, # bybye
      :ll => Command.new { |nicks| list_urls(nicks) }, # list links
      :rs => Command.new { |keyword| crawl_for(keyword, 1) }, # random shit
      :rsi => Command.new { crawl_img },
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

  def invoke_by(user, args)
    if user.level? @auth_level
      @instr.call(args)
    end
  end

  def self.poke
    @bot.say_in_current_channel("Hey, stop poking me!")
  end

  # list all available help files
  def self.help
    @bot.say_in_current_channel("Available commands")
    @all.keys.each do |cmd|
      @bot.say_in_current_channel("!#{cmd.to_s}")
    end
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
      @bot.say_in_current_channel url.escaped
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

  def self.prepare(bot)
    @bot ||= bot
  end

end

