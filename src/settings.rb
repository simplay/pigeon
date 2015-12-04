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
    @config.fetch('use_config')
  end

  def prod_user
    use_config_credentials? ? @config.fetch('prod_user')
                            : ENV['P_USER']
  end

  def prod_password
    use_config_credentials? ? @config.fetch('prod_password')
                            : ENV['P_PASSWORD']
  end

  def prod_ip
    use_config_credentials? ? @config.fetch('prod_ip')
                            : ENV['P_IP_ADDRESS']
  end

  def prod_port
    use_config_credentials? ? @config.fetch('prod_port')
                            : ENV['P_PORT']
  end

  def server_path
    use_config_credentials? ? @config.fetch('server_path')
                            : ENV['P_SERVER_PATH']
  end

  def secret
    use_config_credentials? ? @config.fetch('prod_secret')
                            : ENV['P_SECRET']
  end

  def exist?
    @does_config_exist
  end

  protected

  def initialize
    @does_config_exist = File.exists? CONFIG_FILE_PATH
    @config = YAML.load_file(CONFIG_FILE_PATH) if exist?
  end

end
