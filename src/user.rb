# A User models a ts3 client including its permission levels,
# the list of server groups a user belongs to, and his nickname.
# We use the notion of users to check for authorization when
# invoking a command. Furthermore it allows to map data to users
# E.g. the logic behing the '!ll' command.
class User

  attr_reader :id, :nick, :channel_id, :unique_id, :rtd_count
  attr_accessor :talking_to_bot

  # Threshold time [seconds] a user may be not performing
  # any action before identified as being idle.
  # Is set to 15 minutes.
  IDLE_TIME_THRESHOLD = 900

  UNMOVABLE_GROUP_NAME = "Pigeonator"

  # Returns a nil user used to represnt and fetch an incorrect user state.
  #
  # @hint: Such a user yields false when invoking User#exists? on it.
  # @return [User] sentinel user.
  def self.nil_user
    User.new(-1,"nil_user",[ServerGroup.nil_group],-1,"-1",true)
  end

  # List of all online users.
  #
  # @info: excludes the bot.
  # @return [Array<User>] list of all users currently online on this server.
  def self.all
    server_groups = Server.groups
    server_clients = Server.api.get_clients
    return [] if server_clients.nil?
    @users = server_clients.map do |client|
      group_ids = client.server_groups.map &:to_i
      groups_client_belongs_to = server_groups.select do |id, _|
        group_ids.include?(id)
      end

      permissions = ServerGroup.to_groups(groups_client_belongs_to)
      User.new(client.get_id, client.get_nickname, permissions, client.get_channel_id, client.get_unique_identifier)
    end
  end

  # Try to find a user with a given nick name.
  #
  # @param nick [String] target exact user's nickname.
  # @info: This query tries to fully match a user's nickname
  #   with a provided nick name string. Thus, partial matches will
  #   result in a missmatch.
  #   Note that the matcher is case-sensitive.
  # @example
  #   # say there is a user called Foo currently
  #   User.find_by_nick("Foo")
  #   #=> #<User:0x30c86ea3 @id=1, @levels={6=>"Server Admin"}, @nick="Foo">
  #
  #   User.find_by_nick("foo")
  #   #=> nil_user
  #
  # @return [User] user with given name
  #   or the nil_user, if no such could be found being online.
  def self.find_by_nick(nick)
    all_clients = all
    return nil_user if all_clients.empty?
    target_user = all_clients.find {|user| user.nick==nick}
    target_user.nil? ? nil_user : target_user
  end

  # Fetch all user that include fuzzily a given nickname.
  #
  # @info: in case of a mismatch the nil_user will be returned.
  # @param nick [String] fuzzy nick of target user.
  # @return [Array<User>] matching the given nickname.
  def self.try_find_all_by_nick(nick)
    all_clients = all
    return [nil_user] if all_clients.empty?
    found_users = all_clients.select {|user| user.nick.downcase.include? nick.downcase}
    found_users.empty? ? [nil_user] : found_users
  end

  # Fetch all users that are contained in the ot list
  # @info: a ot list user is a user that has subscribed himself
  #   via calling !s to pigeon. Such users will get a private message
  #   to pigeon whenever they connect to the server. Users can invoke
  #   commands in this private chat.
  def self.ot_users
    all.select do |user|
      user.in_ot_list?
    end
  end

  # List all fetched users previousely fetched via #all
  #
  # @info: in case User#all was not previousely invoked,
  #   it will return nil
  # @return [Array<User>, nil] list of users previousely fetched.
  def self.users
    @users
  end

  # @param id [Integer] corresponds to client id in ts3 db.
  # @param nick [String] corresponds to client nick name in ts3 db.
  # @param permissions [Array<ServerGroup>] list of groups the user belongs to.
  #   ts3 permissions.
  # @param channel_id [Integer] channel id this user is currently located at.
  # @param unique_id [String] unique client id present over ts3 installation.
  # @param is_nil_user [Boolean] is this user a sentinel object.
  def initialize(id, nick, permissions, channel_id, unique_id, is_nil_user=false)
    @id = id
    @nick = nick
    @levels = permissions
    @channel_id = channel_id
    @unique_id = unique_id
    @is_nil_user = is_nil_user
    @talking_to_bot = true
    @has_signed_in_telegram = false
    reset_rtd_count
  end

  # Increments the rtd counter of this user by 1.
  #
  # @info: The rtd (roll the dice) counter determines
  #   the number of random links a user may receive by the Bot
  #   a day.
  def inc_rtd
    @rtd_count = @rtd_count + 1
  end

  # Sets the rtd count equal to 0.
  #
  # @info: the rtd (roll the dice) counter denotes the number
  #   of random links a user has received on the current day.
  #   The notion of rtd count is used in order to limit the number
  #   of rtd messages a user may receive per day.
  #   This regularization behaviour is handled
  #   in Session and PeriodicTask.
  def reset_rtd_count
    @rtd_count = 0
  end

  # Checks whether this user the bot?
  #
  # @return [Boolean] true if this user is the bot
  #   otherwise false.
  def bot?
    id == Bot.id
  end

  # Toggle the state of flag talking_to_bot.
  #
  # @example
  #   assume: @talking_to_bot == true
  #   toggle_talking_to_bot
  #   #=> @talking_to_bot == false
  #   toggle_talking_to_bot
  #   #=> @talking_to_bot == true
  def toggle_talking_to_bot
    @talking_to_bot = !@talking_to_bot
  end

  # Checks whether this user is currently talking to a bot.
  #
  # @return [Boolean] true in case the user is chatting to cleverbot,
  #   otherwise false.
  def talking_to_bot?
    @talking_to_bot
  end

  # Does this user belong to a group having a given name
  # @param group_name [String] name of group we want to check whether the user
  #   belongs to.
  def in_group?(group_name)
    @levels.find do |group|
      group.name == group_name
    end
  end

  # Checks whether this user belongs to the unmovable users.
  #
  # @info: Unmovable users will not moved to the afk channel
  #   after being idle for too long.
  #   A user is unmovable in case he belongs to the server group 'Pigeonator'
  # @return [Boolean] true if this user belongs to the unmovable group
  #   otherwise false.
  def unmovable?
    in_group?(UNMOVABLE_GROUP_NAME)
  end

  # Get the idle time of this user.
  #
  # @info: Being idle means, that the user has neither talked, nor
  #   performed any other action such as chatting or moving channels.
  # @return [Float] number of seconds the client is idle.
  #   If no client was found, then return -1.
  def idle_time
    client = Server.api.get_clients.find do |client|
      client.get_id == @id
    end
    return -1.0 if client.nil?
    client.get_idle_time / 1000.0
  end

  # Checks whether the current user is afk.
  #
  # @info: if a user is idle for at least IDLE_TIME_THRESHOLD seconds,
  #   he is identified as being afk.
  #   Such users will be moved to the afk channel.
  def afk?
    idle_time >= IDLE_TIME_THRESHOLD
  end

  # Checks whether this user the required permissings.
  #
  # @param required_level [Integer] minimal required permission level.
  # @return [Boolean] true if this user's permission level is
  #   meets the required permission level.
  def level?(required_level)
    top_lvl = levels.max
    required_level.any? {|req_lvl| top_lvl >= req_lvl}
  end

  # Checks whether this user included in the ot list?
  #
  # @info: A user is supposed to be contained in this list, if he has
  #   subscribed himself via sending Sir Pigeon the command `!s`.
  #   Assumption: A user's uniqueness is determined by its nickname.
  # @return [Boolean] true if user is in this list, otherwise false.
  def in_ot_list?
    OtList.include?(self)
  end

  # List of user's permissons.
  #
  # @info: the lower the server group id, the higher the permission level.
  # @return [Hash{ServerGroupId=>ServerGroupName}] list of user's
  def levels
    @levels
  end

  # Try to login
  def login_telegram(secret)
    @has_signed_in_telegram = password.eql? ""
  end

  def signed_in_telegram?
    @has_signed_in_telegram
  end

end
