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

  def self.find_by_name(a_name)
    findings = all.select do |group|
      pretty_name = group.name.downcase.gsub(" ","_")
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
    -id <=> -other.id
  end

  def self.highest
    [all.max]
  end

  def self.lowest
    [all.min]
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
