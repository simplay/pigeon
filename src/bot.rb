java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
java_import "com.github.theholywaffle.teamspeak3.api.event.TS3Listener"

class Bot
  def initialize(config, name="Sir Pigeon")
    Server.instance(config)
    @name = name
    @is_started = false
  end

  def start
    unless started?
      @is_started = true
      Server.start
      api.setNickname(@name)
      api.registerAllEvents
      attach_listeners
    end
  end

  def api
    Server.api
  end

  def started?
    @is_started
  end

  def shut_down
    if started?
      @is_started = false
      Server.stop
    end
  end

  def say_in_current_channel(msg)
    api.sendChannelMessage(msg)
  end

  def leave_server(silent=false)
    say_in_current_channel("I'm leaving now - cu <3") unless silent
    shut_down
  end

  def list_urls(nicks)
    if nicks.empty?
      UrlStore.all
    else
      users = nicks.map { |nick| User.find_by_nick api, nick }
      users.flat_map { |u| UrlStore.urls(u.id) }
    end.sort.each do |url|
      say_in_current_channel url.escaped
    end
  end

  protected

  def perform_command(sender, message)
    command_id, *args = message.strip.split
    return if command_id.nil?

    command_id = command_id.tr('!', '').to_sym
    Command.all(self)[command_id].invoke_by(sender, args)
  end

  def command?(message)
    !(message =~/^\!(.)+/).nil?
  end

  def parse_message(user, message)
    UrlExtractor.new(user, message).extract
  end

  def attach_listeners
    api.addTS3Listeners TS3Listener.impl {|name, event|
      if started?
        sender_name = event.getInvokerName
        user = User.find_by_nick(sender_name)
        unless user.bot?
          case name.to_s
          when 'onTextMessage'
            message = event.getMessage
            command?(message) ? perform_command(user, message)
                              : parse_message(user, message)
          end
        end
      end
    }
  end
end
