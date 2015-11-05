class User
  attr_reader :id, :nick

  def self.fetch_all
    api = Server.api
    scg = server_groups
    @users = api.getClients.map do |client|
      cg_ids = client.server_groups.map &:to_i
      cg_names = scg.values_at(*cg_ids)
      levels = cg_ids.zip(cg_names)
      levels = Hash[*levels.flatten]
      User.new(client.get_id, client.get_nickname, levels)
    end
  end

  def self.find_by_nick(nick)
    users = fetch_all
    users.find {|user| user.nick==nick}
  end

  def self.server_groups
    api = Server.api
    scg = api.getServerGroups.map {|cg| [cg.getId(), cg.get_name]}
    Hash[*scg.flatten]
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
