# Linked Datastructure to concatinate text blocks
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

  attr_accessor :predecessor

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
class TextLink < TextBlock

  def parse(message)
    "[URL]#{message}[\/URL]"
  end

end

# @example
#   LabeledTextLink.new("www.google.coom", "foobar").to_s
#   #=> "foobar: [URL]www.google.coom[/URL]"
class LabeledTextLink < TextLink
  def initialize(content, header, delimiter=":")
    @header = BoldText.new(header).to_s
    @delimiter = delimiter
    super(content)
  end

  def parse(message)
    "#{@header}#{@delimiter}#{super(message)}"
  end

end
