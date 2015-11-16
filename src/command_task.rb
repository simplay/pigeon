class CommandTask
  attr_reader :sender, :message

  # @param sender [User]
  # @param message [String]
  def initialize(sender, message)
    @sender = sender
    @message = message
  end
end
