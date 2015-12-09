class DescriptionLayout

  def initialize
    @text_blocks = []
    @text_links = []
  end

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
