java_import 'com.github.theholywaffle.teamspeak3.api.ChannelProperty'

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
    return nil if chan_hash.empty?
    Channel.new(chan_hash.keys.first, chan_hash.values.first)
  end

  def initialize(id, name)
    @id = id
    @name = name
  end

  # Checks whether a channel with a given name already exists.
  #
  # @example: Channel.exist?("Minecraft")
  # @param channel_name [String] name of channel
  # @return [Boolean] true if channel already exists, false otherwise.
  def self.exist?(channel_name)
    !find_by_name(name).nil?
  end

  # Create a new channel having a given talkpower value.
  #
  # @example:
  #   Channel.create("a_new_channel_everyone_can_talk", '0')
  #   Channel.create("an_afk_channel")
  #
  # @info: A talkpower value of 0 means, that everyone can talk in the given
  #   channel, otherwise a guest client needs the assigned talkpower to
  #   talk.
  # @param name [String] name of new created channel
  # @param needed_talkpower [Interger] required talkpower in this channel.
  #   default value is 1000.
  def self.create(name, needed_talkpower=1000)
    options = {
      ChannelProperty::CHANNEL_NEEDED_TALK_POWER => needed_talkpower.to_s,
      ChannelProperty::CHANNEL_FLAG_PERMANENT => '1'
    }
    @bot.api.create_channel(name, options)
  end

end
