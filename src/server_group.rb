# @info: TS3 convention: Lower level values mean higher permission levels.
#   This means that a low level value corresponds to a very priviliged user
#   and a high user level corresponds to a low user level
#   (i.e. a user with only a few rights).
class ServerGroup

  attr_reader :id, :name

  include Comparable

  def self.all
    @all ||= fetch_groups
  end

  def initialize(args)
    @id = args[0].to_i
    @name = args[1]
  end

  # @info: the lover the id, the higher the server grouo level.
  #   this is why we have to use the times -1.
  # @param other [ServerGroup]
  def <=>(other)
    -id <=> -other.id
  end

  def self.sudo
    all.min do |group|
      group.id
    end
  end

  def self.lowest
    all.max do |group|
      group.id
    end
  end

  def self.nil_group
    @nil_group ||= ServerGroup.new([10000, "nil_group"])
  end

  def self.fetch_groups
    to_groups(Server.groups)
  end

  def self.to_groups(list)
    list.to_a.map do |item|
      ServerGroup.new(item)
    end
  end

end
