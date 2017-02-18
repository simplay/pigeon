# @example
#   ColorText.new("foobar", 'red').to_s
#   #=> "[color=red]foobar[/color]"
class ColorText < TextBlock

  def initialize(content, color)
    @color = color
    super(content)
  end

  def parse(message)
    "[color=#{@color}]#{message.to_s}[\/color]"
  end
end
