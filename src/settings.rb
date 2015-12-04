require 'yaml'

class Settings

  CONFIG_FILE_PATH = "data/pigeon_config.yml"

  def self.instance
    @instance ||= Settings.new
  end

  def self.exist?
    instance.exist?
  end

  def self.use_config_credentials?
    instance.use_config_credentials?
  end

  def self.prod_user
    instance.prod_user
  end

  def self.prod_password
    instance.prod_password
  end

  def self.prod_ip
    instance.prod_ip
  end

  def self.prod_port
    instance.prod_port
  end

  def self.server_path
    instance.server_path
  end

  def self.secret
    instance.secret
  end

  def use_config_credentials?
    return false unless exist?
    @config.fetch('use_config')
  end

  def prod_user
    guarded_config_env_value('prod_user', 'P_USER')
  end

  def prod_password
    guarded_config_env_value('prod_password', 'P_PASSWORD')
  end

  def prod_ip
    guarded_config_env_value('prod_ip', 'P_IP_ADDRESS')
  end

  def prod_port
    guarded_config_env_value('prod_port', 'P_PORT')
  end

  def server_path
    guarded_config_env_value('server_path', 'P_SERVER_PATH')
  end

  def secret
    guarded_config_env_value('prod_secret', 'P_SECRET')
  end

  def exist?
    @does_config_exist
  end

  protected

  # Obtain the guarded Setting value from either 'pigeon_config.yml' or from the
  # ENV variables. Guarded means, we try to use the config values if a config file exists
  # and the option 'use_config' is set to true. Otherwise we assume that the setting
  # value is defined in an appropriate ENV variable.
  #
  # @example
  #   guarded_config_env_value('prod_port', 'P_PORT')
  #   # => "10011" # default ts3 server query admin port.
  #
  # @info: the pigeon config 'pigeon_config.yml' is located in 'data/'
  #   and the ENV variables are supposed to be defined in a user's bash profile.
  #
  # @param config_id [String] identifier of target config parameter
  # @param env_id [String] identifier of target ENV variable.
  # @return [String, nil] Corresponding Setting value. Can be nil
  #   in case in neither the setting nor an ENV variable contains
  #   and appropriate value.
  def guarded_config_env_value(config_id, env_id)
    use_config_credentials? ? @config.fetch(config_id)
                            : ENV[env_id]
  end

  # Load the pigeon config file in case it exists.
  def initialize
    @does_config_exist = File.exists? CONFIG_FILE_PATH
    @config = YAML.load_file(CONFIG_FILE_PATH) if exist?
  end

end
