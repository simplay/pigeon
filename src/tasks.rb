
class Tasks

  def initialize
    @tasks = []
    @mutex = Mutex.new
    @resource = ConditionVariable.new
    @has_data = false
  end

  def append(task)
    @mutex.synchronize do
      @tasks << task
      @has_data = true
      @resource.signal
    end
  end

  # returns oldest task stored on the task list.
  def deque
    @mutex.synchronize do
      while @has_data == false
        @resource.wait(@mutex)
      end
      @has_data = false if @tasks.count == 1
      @resource.signal
      @tasks.shift
    end
  end

  def empty?
    @mutex.synchronize do
      @tasks.empty?
    end
  end

end
