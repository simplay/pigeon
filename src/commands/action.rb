class Action

  def initialize(&action)
    @action = action
  end

  def execute(*args)
    @action.call(*args)
  end

  def run
    raise "Not implemented yet."
  end
  
  def let_bot_say(sender, msg)
    Bot.say_as_poke(sender, msg)
  end
end
