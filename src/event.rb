# Events are used to handle different types of fetched foreign messages.
#
# @example
#   Event.new("mss", {:channel_name => "Minecraft", :description => msg})
#   Event.new("else", msg)
#
class Event

  attr_reader :name, :content

  # @param name [String] event name
  # @param content [Object]
  def initialize(name, content)
    @name = name
    @content = content
  end
end
