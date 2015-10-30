require 'java'
require 'lib/teamspeak3-api-1.0.12.jar'
java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
class Bot

  def initialize(config)
    @query = TS3Query.new(config.data)
    @is_started = false
  end

  def start
    unless started?
      @is_started = true
      @query.connect
      @api = @query.getApi
      @api.selectVirtualServerById(1)
      @api.setNickname("Sir Pigeon")
    end
  end

  def started?
    @is_started
  end

  def shut_down
    if started?
      @is_started = false
      @query.exit
    end
  end

  def say_in_current_channel(msg)
    @api.sendChannelMessage(msg)
  end
end
