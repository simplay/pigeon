java_import 'java.util.Timer'
java_import 'java.util.TimerTask'

# TimedTask wrapes java's timer and timed task.
# It calls a given block at a fixed rate in a own thread.
#
# @example: print "foo" every 2 seconds
#
#   # make a new timed task and keep a reference to it.
#   tt = TimedTask.new(2){puts "foo"}}
#
#   # start the timed task
#   tt.start
#
#   # stop the timed task
#   tt.stop
#
class TimedTask

  # TimerTask wrapper to workaround using anonymous classes
  # @example
  #   Timer timer = new Timer(true);
  #   timer.scheduleAtFixedRate(
  #     new TimerTask() {
  #	  public void run() {
  #	    // do something
  #	  }
  #	}, 0, 10 * 1000);
  #
  class PigeonTimerTask < TimerTask

    # Assing a block that should be invoked periodically.
    #
    # @info: Unfortunately, a block can not be passed during runtime
    #   since we inherit from a Java Class.
    # @param block [Procedure] task.
    def task=(task)
      @task = task
    end

    def run
      @task.run
    end
  end

  # @param interval [Float] amount of seconds one update period takes.
  def initialize(interval, periodic_task)
    @interval = interval
    @timer = Timer.new(true)
    @periodic_task = periodic_task
  end

  # Invokes the provided block at a given fixed rate.
  def start
    task = PigeonTimerTask.new
    task.task = @periodic_task

    @timer.schedule_at_fixed_rate(task, 0, @interval*1000)
  end

  # Cancels the timer
  #
  # @info: A canceled timer cannot re-started again.
  def stop
    @timer.cancel
  end

end
