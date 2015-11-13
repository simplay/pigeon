class Tasks

  def initialize
    @tasks = []
  end

  def append(task)
    @tasks << task
  end

  def count
    @tasks.count
  end

  # returns oldest task stored on the task list.
  def deque
    @tasks.shift unless empty?
  end

  def empty?
    @tasks.empty?
  end

end
