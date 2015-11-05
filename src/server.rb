java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
java_import "com.github.theholywaffle.teamspeak3.api.event.TS3Listener"
class Server

  def self.instance(config=nil)
    @instance ||= Server.new(config)
  end

  def self.start
    instance.start
  end

  def self.stop
    instance.stop
  end

  def self.api
    instance.api
  end

  def self.groups
    scg = api.getServerGroups.map {|cg| [cg.getId(), cg.get_name]}
    Hash[*scg.flatten]
  end

  # @param config [ServerConfig]
  def initialize(config)
    @query = TS3Query.new(config.data)
  end

  def start
    @query.connect
    @api = @query.getApi
    @api.selectVirtualServerById(1)
  end

  def stop
    @query.exit
  end

  def api
    @api
  end

end
