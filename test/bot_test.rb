require_relative 'test_helper'

class BotTest < MiniTest::Test

  def setup
    Server.flush
    @bot = Bot.new ServerConfig.new
    @bot.start
  end

  def teardown
    @bot.shut_down if @bot.started?
  end

  def test_can_access_to_api
    assert @bot.started?
    refute @bot.api.nil?
  end

  def test_can_be_shut_down
    @bot.shut_down
    refute @bot.started?
  end

  def test_foobar
    assert true
  end

end
