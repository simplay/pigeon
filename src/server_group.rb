java_import 'com.github.theholywaffle.teamspeak3.api.PermissionGroupDatabaseType'

# @info: TS3 convention: Lower level values mean higher permission levels.
#   This means that a low level value corresponds to a very priviliged user
#   and a high user level corresponds to a low user level
#   (i.e. a user with only a few rights).
class ServerGroup

  attr_reader :id, :name, :rank

  include Comparable

  # Remember running pigeon bot instance.
  #
  # @param bot [Bot] running Pigeon instance listening to clients on server.
  def self.prepare(bot)
    @bot ||= bot
  end

  def self.all
    @all ||= fetch_groups
  end

  def self.update
    @all = fetch_groups
  end

  def self.create(name)
    @bot.api.add_server_group(name, PermissionGroupDatabaseType::REGULAR)
  end

  # Delete a group by its id value.
  #
  # @example
  #   groups = ServerGroup.find_by_name("foobar")
  #   ServerGroup.delete(g.first.id) unless g.empty?
  # @param group_id [Integer] id of target group.
  def self.delete(group_id)
    @bot.api.delete_server_group(group_id)
  end

  def self.edit_group_permission(group_id, permission_name, value, negated=false, skipped=false)
    @bot.api.add_server_group_permission(group_id, permission_name, value, negated, skipped)
  end

  def initialize(args)
    @id = args[0]
    @name = args[1]
    @rank = args[2]
  end

  def sort_value
    $has_sort_values ? rank : id
  end

  def self.find_by_name(a_name)
    findings = all.select do |group|
      pretty_name = group.name.downcase.gsub(" ", "_")
      pretty_name == a_name
    end
  end

  class << self

    def method_missing(method_sym, *arguments, &block)
      if contains_group?(method_sym)
        find_by_name(method_sym.to_s)
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if contains_group?(method_sym)
        true
      else
        super
      end
    end

    def contains_group?(a_group)
      pretty_group_names.any? {|name| a_group.to_s == name}
    end

    def pretty_group_names
      all.map(&:name).map(&:downcase).map do |name|
        name.gsub(" ", "_")
      end
    end

  end

  # @info: the lover the id, the higher the server grouo level.
  #   this is why we have to use the times -1.
  # @param other [ServerGroup]
  def <=>(other)
    -sort_value <=> -other.sort_value
  end

  def self.highest
    [all.max]
  end

  def self.lowest
    [all.min]
  end

  def self.nil_group
    @nil_group ||= ServerGroup.new([10000, "nil_group", 10000])
  end

  def self.fetch_groups
    to_groups(Server.groups)
  end

  def self.to_groups(list)
    list.to_a.map do |item|
      ServerGroup.new(item.flatten)
    end
  end

end
