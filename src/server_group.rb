class ServerGroup

  attr_reader :id, :name

  def self.all
    @all ||= fetch_groups
  end

  def initialize(args)
    @id = args[0].to_i
    @name = args[1]
  end

  def self.sudo
    all.min do |group|
      group.id
    end
  end

  def self.fetch_groups
    Server.groups.to_a.map do |item|
      ServerGroup.new(item)
    end
  end

end
