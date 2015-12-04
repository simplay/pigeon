require 'yaml'
require 'fileutils'

# Settings contains all relevant Pigeon runtime parameters,
# such as server credentials or some secrets defined as tokens.
# Setting values can either be specified via a config file,
# that is supposed to be located at '#{CONFIG_FILE_PATH}' or
# by defining the corresponding ENV variables.
class Settings

  CONFIG_FILE_PATH = "data/pigeon_config.yml"

  def self.instance
    @instance ||= Settings.new
  end

  def self.config_file_path
    CONFIG_FILE_PATH
  end

  # Generates a new config file '#{CONFIG_FILE_PATH}'.
  # @info: invoked if a config file is expected but none does exist.
  #   Copy the example config file 'data/pigeon_config.example.yml' and
  #   rename it to 'data/pigeon_config.yml'.
  def self.generate_config
    FileUtils.cp("data/pigeon_config.example.yml", CONFIG_FILE_PATH)
  end

  def self.usable?
    instance.usable?
  end

  def self.config_exist?
    instance.exist?
  end

  def self.env_vars_set?
    instance.env_vars_set?
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

  # Checks whether the settings are valid and thus usable.
  #
  # @info: Settings are usable if either a valid config file could be read
  #   or all corresponding ENV vars are specified.
  # @return [Boolean] true if we can use the Settings otherwise false.
  def usable?
    config_exist? or env_vars_set?
  end

  # Checks whether a config file '#{CONFIG_FILE_PATH}' exists.
  def config_exist?
    @does_config_exist
  end

  # Checks whether all required ENV variables are specified.
  def env_vars_set?
    env_var_ids = [
      'P_USER',
      'P_PASSWORD',
      'P_IP_ADDRESS',
      'P_PORT',
      'P_SERVER_PATH',
      'P_SECRET'
    ]
    env_var_ids.all? { |env_id| !ENV[env_id].nil? }
  end

  # Checks whehter we should use the config file given the config file.
  #
  # @info: It is possible to diable using the config by the config itself
  #   by setting the attribute 'use_config' equals false.
  def use_config_credentials?
    return false unless config_exist?
    @config.fetch('use_config')
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
  #   guarded_config_env_value('prod_port', 'P_FOOBAR')
  #   # => "ENV variable 'P_FOOBAR' not specified."
  #
  # @info: the pigeon config 'pigeon_config.yml' is located in 'data/'
  #   and the ENV variables are supposed to be defined in a user's bash profile.
  #
  # @raises: Exception
  #   No value could be fetched, report which setting or ENV variable could not
  #   be retrieved.
  #
  # @param config_id [String] identifier of target config parameter
  # @param env_id [String] identifier of target ENV variable.
  # @return [String, nil] Corresponding Setting value. Can be nil
  #   in case in neither the setting nor an ENV variable contains
  #   and appropriate value.
  def guarded_config_env_value(config_id, env_id)
    param = use_config_credentials? ? @config.fetch(config_id)
                                    : ENV[env_id]
    if param.nil?
      error_msg = use_config_credentials? ? "Config param '#{config_id}'"
                                          : "ENV variable '#{env_id}'"
      raise "#{error_msg} not specified."
    end
    param
  end

  # Load the pigeon config file in case it exists.
  def initialize
    @does_config_exist = File.exists? CONFIG_FILE_PATH
    @config = YAML.load_file(CONFIG_FILE_PATH) if config_exist?
  end

end
