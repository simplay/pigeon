require 'yaml'

# Singleton to fetch command descriptions.
class CommandDescription

  def self.instance
    @instance ||= CommandDescription.new
  end

  # Fetch the description of a target command.
  #
  # @param identifier [Symbol, String] identifier in command list.
  # @info: The Identifier is associated with a key in the yaml file 'command_descriptions'
  #   containing the command's description. If an invalid identifier is provided
  #   the empty string will be returned.
  # @return [String] command description of target command.
  def self.parse(identifier)
    target = identifier.to_s
    cmd_descriptions = instance.descriptions
    begin
      cmd_descriptions.fetch(target).to_s
    rescue KeyError
      return ""
    end
  end

  def initialize
    @descriptions = YAML.load_file('data/command_descriptions.yml')
  end

  def descriptions
    @descriptions
  end

end
