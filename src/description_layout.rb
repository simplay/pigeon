# A description layout is a ordered set of TextBlock instances determining
# the look and the content of a channel description
#
# @example
#   layout = DescriptionLayout.new
#   layout.append_text(BoldText.new("Playerlist:"))
#   layout.append_text(ListText.new(newlined_msg)) unless newlined_msg.empty?
#   layout.append_text(BoldText.new("Additional Sources:"))
#   mc_link_bullets = DescriptionLinkStore.find_all_including_key("mc")
#   layout.append_text(ListText.new mc_link_bullets)
#   msg = layout.merge.to_s
class DescriptionLayout

  def initialize
    @text_blocks = []
  end

  # Append a text block to this layout.
  #
  # @info: The order of appending a block determines the order of rendering in a layout.
  # @param [< TextBlock] a textblock item that belongs to this layout.
  def append_text(item)
    @text_blocks << item
  end

  # Merges all included Textblocks defining this Layout.
  #
  # @info: Apply #to_s obtain the raw formatted description text.
  # @return [TextBlock] head text element.
  def merge
    return @text_blocks.first if count == 1
    @text_blocks.each_with_index do |item, idx|
      if idx < count-1
        item.append_successor(@text_blocks[idx+1])
      end
    end
    @text_blocks.first
  end

  private

  # Number of included text blocks.
  #
  # @return [Integer] text item count in this layout.
  def count
    @text_blocks.count
  end

end
