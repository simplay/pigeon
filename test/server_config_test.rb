require_relative 'test_helper'

class ServerConfigTest < MiniTest::Test
  def setup
    ENV['P_IP_ADDRESS'] = "localhost"
    ENV['P_PORT'] = "10011"
    ENV['P_USER'] = "serveradmin"
    ENV['P_PASSWORD'] = "password"
  end

  def test_setting_correct_credentials
    config = ServerConfig.new
    assert_equal(config.data.class, TS3Config)
  end
end
