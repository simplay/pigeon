class DescriptionLayout

  def initialize
    @text_blocks = []
    @text_links = []
  end

  def append_text(item)
    @text_blocks << item
  end

  def append_link(link)
    @text_links << link
  end

  def merge
    append_text(ListText.new @text_links)
    return @text_blocks.first if count == 1
    @text_blocks.each_with_index do |item, idx|
      if idx < count-1
        item.append_successor(@text_blocks[idx+1])
      end
    end
    @text_blocks.first
  end

  def count
    @text_blocks.count
  end

end
