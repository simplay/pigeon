class Command

  # @return [Hash] of all available commands
  def self.all
    @all ||= {
      :poke => Command.new(PokeAction),
      :bb   => Command.new(ServerGroup.server_admin, ShutdownBotAction),
      :ll   => Command.new(ServerGroup.normal, ListUrlAction),
      :rs   => Command.new(ServerGroup.normal, CrawlKeywordAction),
      :rsi  => Command.new(ServerGroup.normal, CrawlImage),
      :pm   => Command.new(ServerGroup.normal, SendPmAction),
      :rsw  => Command.new(ServerGroup.normal, CrawlWtfAction),
      :ot   => Command.new(ServerGroup.normal, OpenChatWithBotAction),
      :dd   => Command.new(ServerGroup.server_admin, MoveUserAction),
      :s    => Command.new(ServerGroup.normal, SubscribeAction),
      :us   => Command.new(ServerGroup.normal, UnsubscribeAction),
      :cb   => Command.new(ServerGroup.normal, ChatToCleverbotAction),
      :tcbm => Command.new(ServerGroup.normal, ToggleBotChatAction),
      :pb   => Command.new(ServerGroup.normal, ChatToPandorabotAction),
      :adl  => Command.new(ServerGroup.server_admin, SaveLinkAction),
      :ddl  => Command.new(ServerGroup.server_admin, DeleteLinkAction),
      :bc   => Command.new(ServerGroup.server_admin, BroadcastAction),
      :rtd  => Command.new(ServerGroup.superuser, RollTheDiceAction),
      :who => Command.new(ServerGroup.normal, WhoAction),
      :h   => Command.new(HelpAction)
    }
  end

  # @param auth_level [AuthLevel] required authentication level required to
  #   invoke the target command.
  # @param action_klass [class < Action] definition of target action.
  def initialize(auth_level=ServerGroup.lowest, action_klass)
    @auth_level = auth_level
    @action = action_klass.new
  end

  # Try to invoke a given command by a user.
  #
  # @info: Invoking commands is guarded. A particular command
  #   can only be invoked if the invoking user has enough priviliges
  #   to invoe that command.
  # @param user [User] sender of command
  # @param args [Array] command name and its arguments
  def invoke_by(user, args)
    Command.sender = user
    if user.level? @auth_level
      @action.execute(args)
    else
      msg = "You do not have permission to use this command!"
      Command.let_bot_say(Command.sender, msg)
    end
  end

  # Return sender of current command
  #
  # @return [User] user who sent last message to Bot.
  def self.sender
    @sender
  end

  # Remember sender of last message
  #
  # @param sender [User] user who sent last message to Bot.
  def self.sender=(sender)
    @sender = sender
  end
end
