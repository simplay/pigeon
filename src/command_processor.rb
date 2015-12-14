# Worker thread processing pigeon commands contained in a task queue.
# Each element included in that queue is supposed to be of type CommandTask.
# A command Processor can be started and shut down.
class CommandProcessor

  # @param tasks [Tasks] task queue containing all received client commands.
  def initialize(tasks)
    @tasks = tasks
    @has_terminated = false
  end

  # Start this CommandProcessor's internal thread.
  #
  # @info: Allows to scheudle the starting process.
  def start
    Thread.new do
      loop do
        perform_next_action
        break if @has_terminated
      end
    end
  end

  # Shut down this CommandProcessor
  #
  # @hint: Use this command when shutting down pigeon.
  def shut_down
    @has_terminated = true
  end

  def perform_next_action
    begin
      task = @tasks.deque
      command?(task.message) ? perform_command(task.sender, task.message)
                             : parse_message(task.sender, task.message)
    rescue Exception => e
      puts "#{e}"
    end
  end

  def perform_command(sender, message)
    command_id, *args = message.strip.split
    return if command_id.nil?

    command_id = command_id.tr('!', '').to_sym
    Command.all[command_id].invoke_by(sender, args)
  end

  def command?(message)
    !(message =~/^\!(.)+/).nil?
  end

  def parse_message(user, message)
    sender_in_session = Session.find_user_in_userlist(user.id)
    if sender_in_session.talking_to_cb?
      Command.all[:cb].invoke_by(sender_in_session, message.split(" "))
    end
    UrlExtractor.new(user, message).extract
  end

end
