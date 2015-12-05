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

  def self.flush
    @instance = nil
  end

  # Retrive a list of all available server groups.
  #
  # @return [Hash{ServerGroupId => [ServerGroupName, SortId]}] list of all server groups.
  def self.groups
    server_groups = api.get_server_groups
    return {} if server_groups.nil?
    g_keys = server_groups.map {|cg| cg.get_id}
    g_values = server_groups.map {|cg| [cg.get_name, cg.get_sort_id]}
    scg = g_keys.zip(g_values)
    Hash[scg]
  end

  # Retrive a list of all available server channels.
  #
  # @return [Hash{ServerChannels=> ServerChannelName}] list of all server channel.
  def self.channels
    server_channels = api.get_channels
    sc = server_channels.map {|sc| [sc.get_id, sc.get_name]}
    Hash[*sc.flatten]
  end

  # @param config [ServerConfig]
  def initialize(config)
    @query = TS3Query.new(config.data)
  end

  # Try to establish a connection to a ts3 server.
  def start
    begin
      @query.connect
    rescue Exception => e
      puts "#{e}. Could not connect to Teamspeak server. No server is running or you provided incorrect login data in your config/ENV vars."
      exit(1)
    end

    @api = @query.get_api
    @api.select_virtual_server_by_id(1)
    $has_sort_values = Server.groups.values.any? do |group|
      group[1] > 0
    end
    info = $has_sort_values ? "SORT IDS" : "IDS"
    puts "Pigeon Info: Use group #{info} for determing permissions."
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
