class Channel
  attr_reader :id, :name

  def self.all
    Server.channels
  end

  def self.find_by_name(name)
    chan_hash = all.select do |c_id, c_name|
      c_name == name
    end
    Channel.new(chan_hash.keys.first, chan_hash.values.first)
  end

  def initialize(id, name)
    @id = id
    @name = name
  end

end
