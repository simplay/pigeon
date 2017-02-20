# An Action models logic / the body of a command.
# Hence, every command has a certain Action instance assigned to.
# An action gets executed, whenever its parent command was successfully invoked (by a priviliged user). 
# To define a new Action, we have to inherit from the appropriate Action subclass and implement the run method.
class Action

  # @param action [Proc] Action's logic
  def initialize(&action)
    @action = action
  end

  # Execute this action
  def execute(*args)
    @action.call(*args)
  end

  # Defines the Action's logic.
  def run
    raise "Not implemented yet."
  end
  
  # Utility function
  def let_bot_say(sender, msg)
    Bot.say_as_poke(sender, msg)
  end
end
