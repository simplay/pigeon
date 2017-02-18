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
