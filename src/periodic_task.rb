# A ConditionalTask acts as a prodcedure that can be used by a TimedTask.
#
# @example
#   bot = Bot.new(config)
#   period_len = 90
#   tt = TimedTask.new(period_len) { MoveAfkUsers.new(bot).run }
#   tt.start
#   ...
#   tt.stop
class PeriodicTask

  def initialize
    @afk_channel = Channel.find_by_name("AFK")
    $mss_msg = Time.now-100
  end

  # Start the task.
  #
  # @info: This method is run by to start this periodic task
  #   in a TimedTask.
  def run
    task
  end

  protected

  # Logic of a periodic task.
  #
  # @info: A descendant class is supposed to implement this method.
  def task
    raise "Not implemented yet."
  end

end

# Check the afk state of every user that is online.
# If they are afk and not already located at the AFK channel,
# then move them to the AFK channel.
class MoveAfkUsers < PeriodicTask
  def task
    afk_users = User.all.select(&:afk?)
    afk_users.each do |user|
      unless (user.channel_id == @afk_channel.id) or user.unmovable?
        Bot.move_target(user, @afk_channel.id)
        Bot.say_as_poke(user, "Sorry, but I moved you to the AFK channel.")
      end
    end
  end
end

# Periodically check the time sincee we received a message from the mss server.
# In case the last message is older than 20 seconds, we asssume that the server
# is offline.
class CheckMcServer < PeriodicTask
  REACHABLE_THRESHOLD = 20.0
  def task
    dt = Time.now-$mss_msg
    $server_reachable = (dt < REACHABLE_THRESHOLD) ? ColorText.new("online", 'green')
                                                   : ColorText.new("offline", 'red')
    Mailbox.instance.notify_all_with(Event.new("mss", 'reachable_update'))
  end
end

class DayChecker < PeriodicTask
  def task
    Session.update_day
  end
end

# Sends a random link, stored in TauntLinkStore to a random user.
class RollTheDice < PeriodicTask

  # Min. time (hours) that should be passed until bot rolls the dice.
  MIN_TIME = 1

  # Rate in hours one user requires.
  TIME_RATE_ONE_USER = 4

  def initialize
    @tic = 0
    super
  end

  # Rolls periodically the dice.
  #
  # Send a random taunt link to a random user included in the session.
  def task
    user = Session.random_user
    taunt_link = TauntLinkStore.next_random.to_s
    return if taunt_link.empty? or user.nil?
    if may_roll_the_dice
      msg = "Hey, check #{taunt_link} out!"
      Bot.say_as_private(user, msg)
    end
    inc_tic
  end

  private

  # Checks if enough time has passed allowing to let pigeon roll the dice again.
  #
  # @info: Rolling the dice means sending a random user a random link.
  # @return [Boolean] is pigeon allowed to roll the dice.
  def may_roll_the_dice
    current_tic_interval >= tic_threshold
  end

  # Normalized tic value
  #
  # @info: Values are in between [1, MIN_TIME+TIME_ONE_USER]
  def current_tic_interval
    @tic + 1
  end

  # get the interval length of time units that should pass until pigeon
  # may roll the dice once again.
  #
  # @return [Integer] temporal threshold.
  def tic_threshold
    user_count = Session.users.count
    (TIME_RATE_ONE_USER/user_count + MIN_TIME)
  end

  def inc_tic
    @tic = (@tic + 1) % (MIN_TIME + TIME_RATE_ONE_USER)
  end
end
