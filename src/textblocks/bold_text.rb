# @example
#   BoldText.new("very bold text")
#   #=> #<BoldText:0x6933b6c6 @content="[b]very bold text[/b]">
class BoldText < TextBlock
  def parse(message)
    "[b]#{message.to_s}[\/b]"
  end
end
