java_import 'java.util.logging.Level'
java_import 'com.github.theholywaffle.teamspeak3.TS3Config'

class ServerConfig

  def initialize
    @config = TS3Config.new
    @config.setDebugLevel(Level::ALL)
    @config.setHost(Settings.prod_ip)
    @config.setCommandTimeout(1000)
    @config.setQueryPort(Settings.prod_port.to_i)
    @config.setLoginCredentials(Settings.prod_user, Settings.prod_password);
  end

  # @return [TS3Config] a config to establish a connection to a ts3 server.
  def data
    @config
  end

end
