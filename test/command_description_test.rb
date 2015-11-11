require_relative 'test_helper'

class CommandDescriptionTest < MiniTest::Test

  def test_parsing_known_command_works_for_strings
    command_names = CommandDescription.instance.descriptions
    cmd_ids = command_names.keys
    cmd_ids.each do |cmd_id|
      refute CommandDescription.parse(cmd_id).empty?
    end
  end

  def test_parsing_known_command_works_for_symbols
    command_names = CommandDescription.instance.descriptions
    cmd_ids = command_names.keys.map(&:to_sym)
    cmd_ids.each do |cmd_id|
      refute CommandDescription.parse(cmd_id).empty?
    end
  end

  def test_parsing_yields_empty_string_for_unknown_cmd_ids
    random_id = "poke"+rand(10**20).to_s(16)
    assert_equal(CommandDescription.parse(random_id), "")
    assert_equal(CommandDescription.parse(random_id.to_sym), "")
    assert_equal(CommandDescription.parse(nil), "")
    assert_equal(CommandDescription.parse(rand(100)), "")
    assert_equal(CommandDescription.parse(Object.new), "")
  end

end
