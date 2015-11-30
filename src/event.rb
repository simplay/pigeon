class Event

  attr_reader :name, :content

  # @param name [String] event name
  # @param content [Object]
  def initialize(name, content)
    @name = name
    @content = content
  end
end
