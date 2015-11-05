class Command

  def self.all(bot)
    @all ||= {
      :poke => Command.new { bot.say_in_current_channel("Hey, stop poking me!") },
      :bb => Command.new { bot.leave_server },
      :ll => Command.new { |nicks| bot.list_urls(nicks) }
    }
  end

  # @param identifier [Symbol] name of invoked command.
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

end
