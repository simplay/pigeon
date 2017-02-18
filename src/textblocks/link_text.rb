# @example
#   LinkText.new("www.google.coom").to_s
#   #=> "[URL]www.google.coom[/URL]"
class LinkText < TextBlock

  def initialize(content, ank="")
    @ank = ank.to_s
    super(content)
  end

  def parse(message)
    if @ank.empty?
      "[URL]#{message.to_s}[\/URL]"
    else
      "[URL=#{message.to_s}]#{@ank}[\/URL]"
    end
  end
end
