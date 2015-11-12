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
      Command.prepare(self)
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
      api.removeTS3Listeners(@ts3_listener)
      Server.stop
    end
  end

  # Send a given message into the channel in which the bot
  # pigeon is currently located. This message can be read by
  # all client that are currently in this channel.
  #
  # @info: An url message is parsed as a clickable-hyperlink
  # @param msg [String] message that should be broadcasted
  #   into the current channel.
  # @param is_url [Boolean] should message interpreted as an url?
  def say_in_current_channel(msg, is_url=false)
    msg = "[URL]#{msg}[\/URL]" if is_url
    api.sendChannelMessage(msg)
  end

  # Send a poke message to a target user.
  #
  # @param user [User] the user we want to poke
  # @param msg [String] poke message that is sent to user.
  def say_as_poke(user, msg)
    api.poke_client(user.id, msg)
  end

  # Send a private message to a target user.
  #
  # @info: Private means that a separate chat-tab
  #   between pigeon and the user is opened in which
  #   all messages are send to.
  # @param user [User] the user we want to send a private message.
  # @param msg [String] private message that is sent to user.
  def say_as_private(user, msg)
    api.send_private_message(user.id, msg)
  end

  # Send an offline message to a target user.
  #
  # @param user [User] the user we want to send an offline message.
  # @param msg [String] the offline message that is sent to user.
  def say_as_offline_message(user, msg)
    api.send_offline_message(user.id, msg)
  end

  # Send a message to the virual server the bot is currently logged in.
  #
  # @info: Such a message can be read globally in the server message channel.
  # @param message [String] a message that is sent to the server channel.
  def say_to_server(message)
    api.send_server_message
  end

  protected

  def perform_command(sender, message)
    command_id, *args = message.strip.split
    return if command_id.nil?

    command_id = command_id.tr('!', '').to_sym
    Command.all[command_id].invoke_by(sender, args)
  end

  def command?(message)
    !(message =~/^\!(.)+/).nil?
  end

  def parse_message(user, message)
    UrlExtractor.new(user, message).extract
  end

  def attach_listeners
    @ts3_listener = TS3Listener.impl {|name, event|
      if started?
        sender_name = event.getInvokerName
        user = User.find_by_nick(sender_name)
        if user.human?
          case name.to_s
          when 'onTextMessage'
            message = event.getMessage
            command?(message) ? perform_command(user, message)
                              : parse_message(user, message)
          end
        end
      end
    }
    api.addTS3Listeners(@ts3_listener)
  end
end
