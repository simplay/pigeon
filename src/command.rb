class Command

  # @param identifier [Symbol] name of invoked command.
  # @param instr [Procedure] lambda defining the invoked command instuction.
  # @param auth_level [AuthLevel] required authentication level required to
  #   invoke the target command.
  def initialize(identifier, instr, auth_level)
    @identifier = indentifier
    @instr = instr
    @auth_level = auth_level
  end

  def invoke_by(user)
    if user.level == @auth_level
      instr.call
    end
  end

end
