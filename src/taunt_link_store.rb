# A taunt link is a funny video collected by users.
# Such videos are randomly sent to random users every hour.
# This feature is supposed to entertain the ts3 community.
class TauntLinkStore

  class TauntLink

    def initialize(link)
      @link = parsed_input_link(link)
    end

    def parsed_input_link(link)
      link.to_s
    end

    def parsed_link
      @link
    end

    def to_s
      LinkText.new(parsed_link, "this").to_s
    end
  end

  # A TauntLink is the respresentation of a TauntLinkStore instance.
  # It's the an anked youtube video that can have a timestamp interval.
  class YoutubeTauntLink < TauntLink

    # Carries a youtube video
    #
    # @raises: ArgumentError in case no youtube video was passed.
    # @param link [String] a youtube video link
    # @param from_time [String, nil] time from which the video should be played.
    #   in seconds, is optional.
    # @param to_time [String, nil] time till the video should be played.
    #   in seconds, is optional.
    def initialize(link, from_time=nil, to_time=nil)
      @from_time = from_time
      @to_time = to_time
      super(link)
    end

    # Extracts the youtube link from the passed source
    # and parses it to a embedded yoututbe video.
    def parsed_link
      base = @link.split("watch?v=").last
      "https://www.youtube.com/v/#{base}?"
    end

    # Parsable yoututbe link representation as a anked Linked text.
    # @info: Can have a defined time interval, an upperbound
    #   or be a complete youttube video.
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

    protected

    def parse_input_link(link)
      link.gsub(/\[(\/){0,1}(URL)\]/ ,"")
    end

  end


  def self.instance
    @instance ||= TauntLinkStore.new
  end

  # Fetches a random link.
  #
  # @info: Link is either from the taunt link db or a random z0mg url.
  # @return [TauntLink] random taunt link
  def self.next_random
    if rand(0..1) % 2 == 0
      random_rtd_link
    else
      url = "http://z0r.de/#{rand(1..7350)}"
      LinkText.new(url, "this")
    end
  end

  def self.random_rtd_link
    all = instance.all_stored
    n = all.count
    return "" if n == 0
    idx = rand(0..n-1)
    all[idx].last
  end

  def self.write(id, link, from_time=nil, to_time=nil)
    instance.write(id, link, from_time, to_time)
  end

  def self.delete(id)
    instance.delete(id)
  end

  def self.all_links
    instance.all_links
  end

  # List all linked stored in the file db
  #
  # @info: returns the link id and its TauntLink instance.
  # @return [Array<Array<String, TauntLink>] list of TauntLink,id pairs.
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

  # Stores a given link in the file db.
  #
  # @example
  #   write(:foo, https://www.youtube.com/watch?v=nGOv39628Tw, 10, 20)
  #
  # @param id [Symbol] unique identifier of this link
  #   used as lookup index in the db.
  # @param link [String] a youtube video link
  # @param from_time [String, nil] time from which the video should be played.
  #   in seconds, is optional.
  # @param to_time [String, nil] time till the video should be played.
  #   in seconds, is optional.
  def write(id, link, from_time=nil, to_time=nil)
    store.transaction do
      link_to_store = link.include?("www.youtube.com") ? YoutubeTauntLink.new(link, from_time, to_time)
                                                       : TauntLink.new(link)
      store[id] = link_to_store
      store.commit
    end
  end

  # Delete a link by id.
  def delete(id)
    a_id = id.to_s
    store.transaction do
      store.delete(a_id)
      store.commit
    end
  end

  # Fetch a entity by its identifier.
  #
  # @return [TauntLink, nil] returns a stored link in case it exists.
  def find(id)
    a_id = id.to_s
    store.transaction do
      begin
        store.fetch(a_id)
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
