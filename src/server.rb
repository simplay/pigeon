java_import 'com.github.theholywaffle.teamspeak3.TS3Query'
java_import 'com.github.theholywaffle.teamspeak3.TS3Api'
java_import "com.github.theholywaffle.teamspeak3.api.event.TS3Listener"
class Server

  # @param config [ServerConfig] minimal data to
  #   establish a "Admin Server Query" connection a ts3 server.
  def self.instance(config=nil)
    @instance ||= Server.new(config)
  end

  # Start this server.
  def self.start
    instance.start
  end

  # Stop running this server.
  def self.stop
    instance.stop
  end

  # Get remote api to this server.
  def self.api
    instance.api
  end

  # Retrive a list of all available server groups.
  #
  # @return [Hash{ServerGroupId => ServerGroupName}] list of all server groups.
  def self.groups
    server_groups = api.get_server_groups
    return {} if server_groups.nil?
    scg = server_groups.map {|cg| [cg.get_id, cg.get_name]}
    Hash[*scg.flatten]
  end

  # @param config [ServerConfig]
  def initialize(config)
    @query = TS3Query.new(config.data)
  end

  # Start this server.
  def start
    @query.connect
    @api = @query.get_api
    @api.select_virtual_server_by_id(1)
  end

  # Stop running this server.
  def stop
    @query.exit
  end

  # Get remote api to this server.
  def api
    @api
  end

end
