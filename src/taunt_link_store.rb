class TauntLinkStore

  class TauntLink

    def initialize(link, from_time=nil, to_time=nil)
      raise ArgumentError.new("No youtube link provided.") unless link.include?("www.youtube.com")
      @link = link.gsub(/\[(\/){0,1}(URL)\]/ ,"")
      @from_time = from_time
      @to_time = to_time
    end

    def parsed_link
      base = @link.split("watch?v=").last
      "https://www.youtube.com/v/#{base}?"
    end

    def to_s
      extension = "version=3&autoplay=1"
      url = if !@from_time.nil? && !@to_time.nil?
        "#{parsed_link}start=#{@from_time}&end=#{@to_time}&#{extension}"
      elsif !@from_time.nil?
        "#{parsed_link}start=#{@from_time}&#{extension}"
      else
        "#{parsed_link}#{extension}"
      end
      LinkText.new(url, "this").to_s
    end

  end

  def self.instance
    @instance ||= TauntLinkStore.new
  end

  def self.next_random
    all = instance.all_stored
    n = all.count
    return "" if n == 0
    idx = rand(0..n-1)
    all[idx].last
  end

  def self.write(id, link, from_time=nil, to_time=nil)
    instance.write(id, link, from_time=nil, to_time=nil)
  end

  def self.delete(id)
    instance.delete(id)
  end

  def self.all_links
    instance.all_links
  end

  def all_links
    links = all_stored.map do |item|
      ":#{item.first.to_s} - #{item.last.to_s} \n"
    end
    links.each_slice(6).to_a.map do |item|
      item.join("\n")
    end
  end

  # Return every stored entity.
  #
  # @return [Array<ID, Array<TauntLink>>] list of entities.
  def all_stored
    store.transaction do
      store.roots.map do |link|
        [link, store.fetch(link, [])]
      end
    end
  end

  def write(id, link, from_time=nil, to_time=nil)
    store.transaction do
      store[id] = TauntLink.new(link, from_time, to_time)
      store.commit
    end
  end

  # Delete a link by id.
  def delete(id)
    store.transaction do
      store.delete(id)
      store.commit
    end
  end

  # Fetch a entity by its identifier.
  #
  # @return [TauntLink, nil] returns a stored link in case it exists.
  def find(id)
    store.transaction do
      begin
        store.fetch(id)
      rescue
        nil
      end
    end
  end

  # Returns the file db.
  def store
    @file_db ||= PStore.new('data/taunt_links.pstore')
  end

end
