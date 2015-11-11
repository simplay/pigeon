class Command

  def self.all
    @all ||= {
      :poke => Command.new { @bot.say_in_current_channel("Hey, stop poking me!") },
      :bb => Command.new { @bot.leave_server }, # bybye
      :ll => Command.new { |nicks| @bot.list_urls(nicks) }, # list links
      :rs => Command.new {|keyword| @bot.crawl_for(keyword, 1)}, # random shit
      :rsi => Command.new {@bot.crawl_img}
    }
  end

  # @param description [String] purpose of command
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

  def self.help
  end

  def self.prepare(bot)
    @bot ||= bot
  end

end

