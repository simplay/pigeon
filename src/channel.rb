class Channel
  attr_reader :id, :name

  # Remember running pigeon bot instance.
  #
  # @param bot [Bot] running Pigeon instance listening to clients on server.
  def self.prepare(bot)
    @bot ||= bot
  end

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

  # @param name [String] name of new created channel
  # @param options [Map<ChannelProperty, String>] containing channel options.
  def self.create(name, options={})
    @bot.api.create_channel(name, options)
  end

end
