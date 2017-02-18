# TextBlock instances are chained structures containing formatted texts.
#
# Every TextBlock has some kind of content, that is parsed during initialization
# and an optional successor.
# A text block responds to #to_s which recursively triggers the
# to_s on self and its successor.
#
# Every text element managed, edited or created by the bot
# is supposed to be a TextBlock
#
# @example
#   t = TextBlock.new("foo")
#   t.to_s #=> "foo"
#   tt = TextBlock.new("bar")
#   tt.to_s #=> "bar"
#   t.append_successor(tt)
#   t.to_s #=> "foobar"
#   tt.to_s #=> "bar"
#
class TextBlock

  attr_accessor :predecessor, :successor

  def initialize(content)
    @content = parse(content)
  end

  # Append a successor block.
  #
  # @info: When rendering text block instances, the successor block is rendered
  #   right after this one.
  # @param block [< TextBlock] the successor block of this one.
  def append_successor(block)
    @successor = block
    block.predecessor = self
  end

  # Does this block exhibit a successor block?
  #
  # @return [Boolean] true if it has a successor, otherwise false.
  def successor?
    !@successor.nil?
  end

  # Expand recursively the content of this text block
  def to_s
    if successor?
      return @content + @successor.to_s
    else
      return @content
    end
  end

  protected

  # Make a printable String from the given input message.
  def parse(message)
    message.to_s
  end
end
