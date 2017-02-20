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

class SimpleAction < Action
  def initialize
    super { run } 
  end
end

class WithArgumentsAction < Action
  def initialize
    super { |with_message| run(with_message) }
  end

  def run(with_message)
    raise "Not implemented yet."
  end
end
