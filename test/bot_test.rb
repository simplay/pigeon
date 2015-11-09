require_relative 'test_helper'

class BotTest < MiniTest::Test
  def setup
    @bot = Bot.new ServerConfig.new
    @bot.start
  end

  def teardown
    @bot.shut_down unless @bot.started?
  end

  def test_can_access_to_api
    assert @bot.started?
    assert !@bot.api.nil?
  end

  def test_can_be_shut_down
    @bot.shut_down
    assert_equal(@bot.started?, false)
  end

end
