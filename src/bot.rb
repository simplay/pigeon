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

  def api
    @api
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

  def leave_server(silent=false)
    say_in_current_channel("I'm leaving now - cu <3") unless silent
    shut_down
  end

  protected

  def perform_command(sender, message)
    identifier = message.split("!").last.to_sym
    Command.all(self)[identifier].invoke_by(sender)
  end

  def command?(message)
    !(message =~/^\!(.)+/).nil?
  end

  def parse_message(a_message)
  end

  def attach_listeners
    @api.registerAllEvents
    @api.addTS3Listeners TS3Listener.impl {|name, event|
      unless event.getInvokerName.include?(@name)
        case name.to_s
        when 'onTextMessage'
          sender_name = event.getInvokerName
          user = User.find_by_name(@api, sender_name)
          message = event.getMessage
          command?(message) ? perform_command(user, message)
                            : parse_message(message)
        end
      end
    }
  end
end
