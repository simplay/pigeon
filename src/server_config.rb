java_import 'java.util.logging.Level'
java_import 'com.github.theholywaffle.teamspeak3.TS3Config'

class ServerConfig

  def initialize
    @config = TS3Config.new
    @config.setDebugLevel(Level::ALL)
    @config.setHost(ENV['P_IP_ADDRESS'])
    @config.setCommandTimeout(1000)
    @config.setQueryPort(ENV['P_PORT'].to_i)
    @config.setLoginCredentials(ENV['P_USER'], ENV['P_PASSWORD']);
  end

  # @return [TS3Config] a config to establish a connection to a ts3 server.
  def data
    @config
  end

end
