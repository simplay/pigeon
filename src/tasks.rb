require 'thread'

class Tasks

  def initialize
    @tasks = []
    @mutex = Mutex.new
    @resource = ConditionVariable.new
    @has_data = false
    @idx = -1
  end

  def append(task)
    t = task
    @mutex.synchronize do
      while @tasks.count > 10
        @resource.wait(@mutex)
      end
      @idx = @idx + 1
      add(t)
      puts "AAA info => #{@tasks.inspect}"
      @resource.broadcast
    end
  end

  def add(task)
    @tasks << task
  end

  # returns oldest task stored on the task list.
  def deque
    @mutex.synchronize do
      puts "BBB consuming => #{@tasks.inspect}"
      while @tasks.empty?
        @resource.wait(@mutex)
      end
      val = @tasks.shift
      #t = @tasks[@idx]
      #@tasks.delete(t)
      #@tasks
      @resource.broadcast
      return val
    end
  end

  def empty?
    @mutex.synchronize do
      @tasks.empty?
    end
  end

end
