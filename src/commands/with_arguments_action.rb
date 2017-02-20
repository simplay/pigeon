class WithArgumentsAction < Action
  def initialize
    super { |with_message| run(with_message) }
  end

  def run(with_message)
    raise "Not implemented yet."
  end
end
