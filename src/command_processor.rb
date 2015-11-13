class CommandProcessor
  def initialize(tasks, bot)
    @tasks = tasks
    @bot = bot
  end

  def start
    Thread.new do
      loop do
        perform_next_action
      end
    end
  end

  def perform_next_action
    begin
      task = @tasks.deque
    rescue Exception => e
      puts "#{e}"
    end
    command?(task.message) ? perform_command(task.sender, task.message)
                           : parse_message(task.sender, task.message)
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
    UrlExtractor.new(user, message).extract
  end
end
