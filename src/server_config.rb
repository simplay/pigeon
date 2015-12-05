java_import 'java.util.logging.Level'
java_import 'com.github.theholywaffle.teamspeak3.TS3Config'

class ServerConfig

  def initialize
    load_settings
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

  private

  def load_settings
    begin
      handle_config_setup
    rescue Exception => e
      puts e.to_s
      generate_config
      abort("Program has terminated")
    end
  end

  def generate_config
      Settings.generate_config
      puts "Generated default config '#{Settings::CONFIG_FILE_PATH}'."
      puts "Please fill in the corresponding credentials."
  end

  def handle_config_setup
    if SystemInfo.running_on_windows? and !Settings.config_exist?
      raise "No config '#{Settings::CONFIG_FILE_PATH}' exists."
    else
      raise "Neither config '#{Settings::CONFIG_FILE_PATH}' nor ENV vars were found." unless Settings.usable?
    end
  end

end
