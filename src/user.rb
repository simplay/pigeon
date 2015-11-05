# A User models a ts3 client including its permission levels,
# the list of server groups a user belongs to, and his nickname.
# We use the notion of users to check for authorization when
# invoking a command. Furthermore it allows to map data to users
# E.g. the logic behing the '!ll' command.
class User

  attr_reader :id, :nick

  # Returns a nil user used to represnt and fetch an incorrect user state.
  #
  # @hint: Such a user yields false when invoking User#exists? on it.
  # @return [User] sentinel user.
  def self.nil_user
    User.new(-1,"nil_user",{},true)
  end

  # List all online users.
  #
  # @return [Array<User>] list of all users currently online on this server.
  def self.all
    server_groups = Server.groups
    server_clients = Server.api.get_clients
    return [] if server_clients.nil?
    @users = server_clients.map do |client|
      group_ids = client.server_groups.map &:to_i
      group_names = server_groups.values_at(*group_ids)
      permission_levels = group_id_names_hash(group_ids, group_names)
      User.new(client.get_id, client.get_nickname, permission_levels)
    end
  end

  # Try to find a user with a given nick name.
  #
  # @param nick [String] target user's nickname.
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
  #   #=> nil
  #
  # @return [User, nil] user with given name
  #   or nil, if no such user is online.
  def self.find_by_nick(nick)
    all_clients = all
    return nil_user if all_clients.empty?
    all_clients.find {|user| user.nick==nick}
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
  # @param lvls [Hash{ServerGroupId=>ServerGroupName}] list of user's
  #   ts3 permissions.
  def initialize(id, nick, permissions, is_nil_user=false)
    @id = id
    @nick = nick
    @levels = permissions
    @is_nil_user = is_nil_user
  end

  # Checks whether this user the required permissings.
  #
  # @info: TS3 convention: Lower level values mean higher permission levels.
  #   This means that a low level value corresponds to a very priviliged user
  #   and a high user level corresponds to a low user level
  #   (i.e. a user with only a few rights).
  # @param required_level [Integer] minimal required permission level.
  # @return [Boolean] true if this user's permission level is
  #   meets the required permission level.
  def level?(required_level)
    top_lvl = levels.keys.min
    top_lvl <= required_level
  end

  # List of user's permissons.
  #
  # @info: the lower the server group id, the higher the permission level.
  # @return [Hash{ServerGroupId=>ServerGroupName}] list of user's
  def levels
    @levels
  end

  # Checks whether this user is a bot.
  #
  # @info: Every user that belongs to the server group
  #   "Admin Server Query" represents a Bot.
  # @return [Boolean] true if bot otherwise false.
  def bot?
    @levels.values.include?("Admin Server Query")
  end

  # Check whether this user is neither a bot nor the nil_user.
  #
  # @info: User instances that yield true correspond to real human clients.
  # @return [Boolean] true if user is a human client otherwise false.
  def human?
    return false if @is_nil_user
    !bot?
  end

  protected

  # Forms a Hash from two given equally sized arrays.
  #
  # @info: First array depicts the list of hash keys,
  #   and the second array the hash values.
  # @param ids [Array<Integer>] server group ids.
  # @param names [Array<String>] server group names.
  # @return [Hash{ServerGroupId=>ServerGroupName}] permission list.
  def self.group_id_names_hash(ids, names)
      levels = ids.zip(names)
      Hash[*levels.flatten]
  end

end
