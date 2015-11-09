require_relative 'test_helper'

class BotTest < MiniTest::Test
  def test_bot_foobar
    b = Bot.new ServerConfig.new
    b.start
    assert !b.api.nil?
  end
end
