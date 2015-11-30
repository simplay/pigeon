require 'thread'

java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
java_import "com.github.theholywaffle.teamspeak3.api.event.TS3Listener"

class Bot
  def initialize(config, name="Sir Pigeon")
    Server.instance(config)
    @name = name
    @is_started = false
    @tasks = Tasks.new
    @command_processor = CommandProcessor.new(@tasks)
  end

  def start
    unless started?
      Command.prepare(self)
      @is_started = true
      Server.start
      api.setNickname(@name)
      api.registerAllEvents
      @bot_id = api.whoAmI.getId
      attach_listeners
      @command_processor.start
      Mailbox.subscribe(self)
      @req_listener = RequestListener.new(self)
      @req_listener.start
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
      @command_processor.shut_down
      api.removeTS3Listeners(@ts3_listener)
      Server.stop
    end
  end

  def handle_event(message)
    say_to_server(message)
  end

  # Move a given user into a target channel.
  #
  # @param user [User] target user that should be moved into given channel.
  # @param channel_id [Integer] an id of an existing channel.
  def move_target(user, channel_id)
    api.move_client(user.id, channel_id)
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
  def say_as_private(user, msg, is_url=false)
    msg = "[URL]#{msg}[\/URL]" if is_url
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
    api.send_server_message(message)
  end

  protected

  # Append a new CommandTask fetched by pigeon's channel chat
  # listener.
  #
  # @param user [User] sender
  # @param message [String] instruction given by sender.
  def append_task(user, message)
    @tasks.append(CommandTask.new(user, message))
  end

  # @info: Every message that is was not send by the bot will be appended to the task list.
  #   When a client joins the server: the bot sends that client a private message
  #   if the user is contained in the OtList and is priviliged.
  def attach_listeners
    @ts3_listener = TS3Listener.impl {|name, event|
      if started?
        unless event.get_invoker_id == @bot_id
          case name.to_s
          when 'onTextMessage'
            sender_name = event.get_invoker_name
            user = User.find_by_nick(sender_name)
            message = event.get_message
            append_task(user, message)
          when 'onClientJoin'
            joining_client_nick = event.get_client_nickname
            user = User.find_by_nick(joining_client_nick)
            append_task(user, "!ot") if user.in_ot_list?
          end
        end
      end
    }
    api.addTS3Listeners(@ts3_listener)
  end
end


