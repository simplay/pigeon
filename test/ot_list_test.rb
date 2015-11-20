require_relative 'test_helper'

class OtListTest < MiniTest::Test
  def setup
    @usr = User.new(1,"peter", nil, 1)
  end

  def test_can_append_new_user
    refute OtList.include? @usr
    OtList.append(@usr)
    assert OtList.include? @usr
    OtList.instance.flush
  end

  def test_can_remove_user
    refute OtList.include? @usr
    OtList.append(@usr)
    assert OtList.include? @usr
    OtList.remove(@usr)
    refute OtList.include? @usr
    OtList.instance.flush
  end

end
