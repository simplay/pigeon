# Linked Datastructure to concatinate text blocks
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

  def append_successor(block)
    @successor = block
    block.predecessor = self
  end

  def successor?
    !@successor.nil?
  end

  def to_s
    if successor?
      return @content + @successor.to_s
    else
      return @content
    end
  end

  protected

  def parse(message)
    message
  end

end

class BoldText < TextBlock
  def parse(message)
    "[b]#{message}[\/b]"
  end
end

# @example
#   TextLink.new("www.google.coom").to_s
#   #=> "[URL]www.google.coom[/URL]"
class LinkText < TextBlock

  def parse(message)
    "[URL]#{message}[\/URL]"
  end

end

class LinedText < TextBlock

  def parse(message)
    return process_item(message) if message.is_a?(String)
    (message.count > 1) ? process_list(message) : process_item(message)
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
    "#{msg}"
  end
end

class ListText < LinedText

  def process_list(msgs)
    list = msgs.map do |msg|
      "[*]#{msg.to_s}"
    end
    "[list]\n#{list.join}[\/list]"
  end

  def process_item(msg)
    txt = (msg.count == 1)? msg.first : msg
    "[list][*]#{txt.to_s}[\/list]"
  end

end

# @example
#   LabeledTextLink.new("www.google.coom", "foobar").to_s
#   #=> "foobar: [URL]www.google.coom[/URL]"
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
