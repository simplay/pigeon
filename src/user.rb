require_relative 'auth_level'

class User

  def initialize(name, params={})
    @name = name
    @level = 0
    @id = next_id
  end

  def level
    @level
  end

  def try_run_command(invoking_command)
    invoking_command.invoke_by(self)
  end

  protected

  # Obtain a unique user id
  # @info: first id value is equal zero.
  #   id values are increased by one,
  #   whenever this method is called.
  # @return [Integer] unique user id.
  def next_id
    @@global_u_id ||= 0
    @@global_u_id = @@global_u_id + 1
  end
end
