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
