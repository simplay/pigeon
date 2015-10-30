require 'java'
require 'pry'
require 'lib/teamspeak3-api-1.0.12.jar'
java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
java_import "com.github.theholywaffle.teamspeak3.api.event.TS3Listener"
class Bot
  MASTER_NAME = "simplay"
  def initialize(config, name="Sir Pigeon")
    @query = TS3Query.new(config.data)
    @name = name
    @is_started = false
  end

  def start
    unless started?
      @is_started = true
      @query.connect
      @api = @query.getApi
      @api.selectVirtualServerById(1)
      @api.setNickname(@name)
      attach_listeners
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

  protected

  def attach_listeners
    @api.registerAllEvents
    @api.addTS3Listeners TS3Listener.impl {|name, event|
      unless event.getInvokerName.include?(@name)
        case name.to_s
        when 'onTextMessage'
          sender_name = event.getInvokerName
          if sender_name.downcase.include?(MASTER_NAME)
            if event.getMessage == "!bb"
              say_in_current_channel("I'm leaving now - cu <3")
              shut_down
            end
          end
          if event.getMessage == "!poke"
            say_in_current_channel("Hey, stop poking me!")
          end
        end
      end
    }
  end
end
