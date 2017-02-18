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
