require 'thread'
require 'digest/sha1'

java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
java_import "com.github.theholywaffle.teamspeak3.api.event.TS3Listener"
java_import 'com.github.theholywaffle.teamspeak3.api.ChannelProperty'

# A Bot, the so called Sir Pigeon, is a concurrent event handler,
# used for administering and entertaining TS3 clients and channels.
#
# It acts as an automated Server Query Admin (SQA) TS3 client.
#
# Sir Pigeon is able to handle external and internal events.
# Internal events are either fired due to ts3 listeners,
# such as onTextMessage or onClientJoin, or due to TimedTask tasks.
# External events are a result of receiving valid messages from foreign services.
# E.g. status information received by the minecraft server.
#
# Sir Pigeon can be started and stopped and keeps a reference to the ts3 api.
# The bot has implemented several text sending methods, implemented as say methods
# and a method to edit the description of a target channel.
#
# @info: In order to run this bot, configure all relevant ENV variables
#   as described in the README.
# Please notice that SQA authentication credentials are required to run the bot.
class Bot

  VERSION = "0.1.0"

  def self.instance
    @instance ||= Bot.new(ServerConfig.new)
  end

  def self.start
    instance.start
  end

  def self.shut_down
    instance.shut_down
  end

  def initialize(config, name="Sir Pigeon")
    Server.instance(config)
    @name = name
    @is_started = false
    @tasks = Tasks.new
    @command_processor = CommandProcessor.new(@tasks)
    @req_listener = RequestListener.new
    @telegram_bot = TelegramBotBinding.new
  end

  def timed_tasks
    tasks ||= [
      TimedTask.new(60.0, MoveAfkUsers.new),
      TimedTask.new(10.0, CheckMcServer.new),
      TimedTask.new(3600.0, RollTheDice.new),
      TimedTask.new(3600.0, DayChecker.new)
    ]
  end

  # Return the current user id of this Bot instance.
  #
  # @return [Integer] id uniquely identifying the bot.
  def id
    @bot_id
  end

  def self.id
    instance.id
  end

  # Start the bot and its services if not already running.
  # 
  # @info: The ORDER of method invocations MATTERS!
  #   first assign all relevant setup information
  #   then start establish a connection to the TS3 server
  #   then determine the bots user id (used for checking bot's identity)
  #     used for ignoring messages sent by the bot in the handlers.
  #   then register the internal ts3 event handlers
  #   then start the command processor
  #   then the subscribe to the mailbox
  #   then start the external event listener.
  def start
    unless started?
      @is_started = true
      @telegram_bot.start
      Server.start
      api.set_nickname(@name)
      api.register_all_events
      @bot_id = api.who_am_i.get_id
      attach_listeners
      @command_processor.start
      Mailbox.subscribe(self)
      @req_listener.start
    end
  end

  # Notify all users in the Ot list that pigeon is online again.
  #
  # @info this method is used to inform that
  #   the bot is back online again.
  #   Is used whenever pigeon was updated and restarted in order to
  #   keep the tab reference (from the previous Sir Pigeon) up-to-date
  def reestablish_connection_to_ot_users
    User.ot_users.each do |user|
      say_as_private(user, "Hey, I am back again. :) ")
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
      @req_listener.stop
      api.removeTS3Listeners(@ts3_listener)
      timed_tasks.each(&:stop)
      Server.stop
      @telegram_bot.shutdown
    end
  end

  # Methods invoked here are run before after pigeon
  # has set up all its services but before a user
  # could enter any command.
  def run_after_startup
    Session.reload
    reestablish_connection_to_ot_users
    timed_tasks.each(&:start)
  end

  def handle_event(message)
    case message.name
    when 'mss'
      begin
        channel_name = message.content[:channel_name]
        description = message.content[:description]
        channel = Channel.find_by_name(channel_name)
        edit_channel_description(channel, description)
      rescue Exception
      end
    when 'else'
      say_to_server(message.content)
    end
  end

  # Move a given user into a target channel.
  #
  # @param user [User] target user that should be moved into given channel.
  # @param channel_id [Integer] an id of an existing channel.
  def move_target(user, channel_id)
    api.move_client(user.id, channel_id)
  end

  def self.move_target(user, channel_id)
    instance.move_target(user, channel_id)
  end

  # Edits the description text of a target channel.
  #
  # @example
  #   minecraft_channel = Channel.find_by_name("Minecraft")
  #   some_description = "this is the minecraft channel"
  #   edit_channel_description(minecraft_channel, some_description)
  #
  # @param channel [Channel] target channel that should be edited.
  # @param description [String] formatted text that should be used
  #   for target's channel new description.
  def edit_channel_description(channel, description)
    options = { ChannelProperty::CHANNEL_DESCRIPTION => description }
    api.edit_channel(channel.id, options)
  end

  def self.edit_channel_description(channel, description)
    instance.edit_channel_description(channel, description)
  end

  # Send a given message into the channel in which the bot
  # pigeon is currently located. This message can be read by
  # all client that are currently in this channel.
  #
  # @info: An url message is parsed as a clickable-hyperlink
  # @param msg [String, TextBlock] message that should be broadcasted
  #   into the current channel.
  # @param is_url [Boolean] should message interpreted as an url?
  def say_in_current_channel(msg, is_url=false)
    msg = (!is_url) ? TextBlock.new(msg) : LinkText.new(msg)
    api.send_channel_message(msg.to_s)
  end

  def self.say_in_current_channel(msg, is_url=false)
    instance.say_in_current_channel(msg, is_url)
  end

  # Register a telegram user. A registered user may invoke ts commands
  def login_as_telegram_user(username, password)
    Settings.telegram_login_secret.eql? (Digest::SHA1.hexdigest(password))
  end

  def self.login_as_telegram_user(username, password)
    instance.login_as_telegram_user(username, password)
  end

  # Send a poke message to a target user.
  #
  # @param user [User] the user we want to poke
  # @param msg [String] poke message that is sent to user.
  def say_as_poke(user, msg)
    api.poke_client(user.id, msg)
  end

  def self.say_as_poke(user, msg)
    instance.say_as_poke(user, msg)
  end

  # Send a private message to a target user.
  #
  # @example: Send a pm to some user.
  #
  #   # Retrieve the first user
  #   first_user = User.all.first
  #
  #   # send "hello world" message as a pm to the first user
  #   say_as_private(first_user, "hello world")
  #
  #   # Send a clickable link to the first user
  #   say_as_private(first_user, "www.somefancyaddress.org", true)
  #
  # @info: Private means that a separate chat-tab
  #   between pigeon and the user is opened in which
  #   all messages are send to.
  #
  # @param user [User] the user we want to send a private message.
  # @param msg [String, TextBlock] private message that is sent to user.
  def say_as_private(user, msg, is_url=false)
    msg = LinkText.new(msg) if is_url
    api.send_private_message(user.id, msg.to_s)
  end

  def self.say_as_private(user, msg, is_url=false)
    instance.say_as_private(user, msg, is_url)
  end

  # Send an offline message to a target user.
  #
  # @param user [User] the user we want to send an offline message.
  # @param msg [String] the offline message that is sent to user.
  def say_as_offline_message(user, msg)
    api.send_offline_message(user.id, msg)
  end

  def self.say_as_offline_message(user, msg)
    instance.say_as_offline_message(user, msg)
  end

  # Send a message to the virual server the bot is currently logged in.
  #
  # @info: Such a message can be read globally in the server message channel.
  # @param message [String] a message that is sent to the server channel.
  def say_to_server(message)
    api.send_server_message(message)
  end

  def self.say_to_server(message)
    instance.say_to_server(message)
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

  # Defines the ts3 event listener handlers and runs the after startup hooks.
  #
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
            Session.append_to_userlist(user)
            append_task(user, "!ot") if user.in_ot_list?
          when 'onClientLeave'
            leaving_client_id = event.get_client_id
            Session.remove_from_userlist(leaving_client_id)
          end
        end
      end
    }
    api.addTS3Listeners(@ts3_listener)
    run_after_startup
  end
end

