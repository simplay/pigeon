class User
  attr_reader :id, :nick

  def self.all
    server_groups = Server.groups
    @users = Server.api.get_clients.map do |client|
      group_ids = client.server_groups.map &:to_i
      group_names = server_groups.values_at(*group_ids)
      permission_levels = group_id_names_hash(group_ids, group_names)
      User.new(client.get_id, client.get_nickname, permission_levels)
    end
  end

  def self.find_by_nick(nick)
    all.find {|user| user.nick==nick}
  end

  def self.users
    @users
  end

  def initialize(id, nick, lvls)
    @nick = nick
    @levels = lvls
    @id = id
  end

  def level?(cmp_lvl)
    top_lvl = levels.keys.min
    top_lvl <= cmp_lvl
  end

  def levels
    @levels
  end

  def bot?
    @levels.values.include?("Admin Server Query")
  end

  def try_run_command(invoking_command)
    invoking_command.invoke_by(self)
  end

  protected

  def self.group_id_names_hash(ids, names)
      levels = ids.zip(names)
      Hash[*levels.flatten]
  end

  # Obtain a unique user id
  # @info: first id value is equal zero.
  #   id values are increased by one,
  #   whenever this method is called.
  # @return [Integer] unique user id.
  def next_id
    @@global_u_id ||= 0
    @@global_u_id = @@global_u_id + 1
  end
end
