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

# @example
#   BoldText.new("very bold text")
#   #=> #<BoldText:0x6933b6c6 @content="[b]very bold text[/b]">
class BoldText < TextBlock
  def parse(message)
    "[b]#{message.to_s}[\/b]"
  end
end

# @example
#   ColorText.new("foobar", 'red').to_s
#   #=> "[color=red]foobar[/color]""
class ColorText < TextBlock

  def initialize(content, color)
    @color = color
    super(content)
  end

  def parse(message)
    "[color=#{@color}]#{message.to_s}[\/color]"
  end
end

# @example
#   LinkText.new("www.google.coom").to_s
#   #=> "[URL]www.google.coom[/URL]"
class LinkText < TextBlock

  def parse(message)
    "[URL]#{message.to_s}[\/URL]"
  end

end

# @example
#   LinedText.new(["1","2","3"]).to_s
#   #=> "[b]1[/b] \n[b]2[/b] \n[b]3[/b] \n""
#
#   LinedText.new("3").to_s
#   #=> "3"
#
#   LinedText.new("3").to_s
#   #=> "3"
class LinedText < TextBlock

  def parse(message)
    return process_item(message) if message.is_a?(String)
    return process_list(message) if message.is_a? Array
    process_item(message)
  end

  protected

  def process_list(msgs)
    list = msgs.map do |msg|
      split_msg = msg.split(" ")
      "#{BoldText.new(split_msg[0]).to_s} #{split_msg[1..-1].join(" ")}\n"
    end
    "#{list.join}"
  end

  def process_item(msg)
    "#{msg.to_s}"
  end
end

# @example
#   ListText.new("Item").to_s
#   # => "[list][*]Item[/list]"
#
#   ListText.new([1,2,3]).to_s
#   #=> "[list]\n[*]1[*]2[*]3[/list]"
#
#   ListText.new(["foo","bar","baz"]).to_s
#   #=> "[list]\n[*]foo[*]bar[*]baz[/list]"
#
#   t1 = LabeledLinkText.new("www.pow.coom", "foobar")
#   t2 = LabeledLinkText.new("www.pew.coom", "baz")
#   ListText.new([t1,t2]).to_s
#   #=> "[list]\n[*][b]foobar[/b]:[URL]www.pew.coom[/URL][*][b]baz[/b]:[URL]www.pew.coom[/URL][/list]"]"
class ListText < LinedText

  def process_list(msgs)
    list = msgs.map do |msg|
      "[*]#{msg.to_s}"
    end
    "[list]\n#{list.join}[\/list]"
  end

  def process_item(msg)
    "[list][*]#{msg.to_s}[\/list]"
  end

end

# @example
#   LabeledLinkText.new("www.google.coom", "foobar").to_s
#   #=> "[b]foobar[/b]:[URL]www.google.coom[/URL]""
class LabeledLinkText < LinkText
  def initialize(content, header, delimiter=":")
    @header = BoldText.new(header).to_s
    @delimiter = delimiter
    super(content)
  end

  def parse(message)
    "#{@header}#{@delimiter}#{super(message)}"
  end

end
