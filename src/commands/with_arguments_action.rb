# A WithArgumentsAction defines an action with a message.
class WithArgumentsAction < Action
  def initialize
    super { |with_message| run(with_message) }
  end

  # This method has to be implemented by a descendent.
  def run(with_message)
    raise "Not implemented yet."
  end
end
