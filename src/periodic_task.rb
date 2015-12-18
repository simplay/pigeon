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
  def initialize(bot)
    @bot = bot
    @afk_channel = Channel.find_by_name("AFK")
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
        @bot.move_target(user, @afk_channel.id)
        @bot.say_as_poke(user, "Sorry, but I moved you to the AFK channel.")
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

# Sends a random link, stored in TauntLinkStore to a random user.
class RollTheDice < PeriodicTask
  def task
    user = Session.random_user
    taunt_link = TauntLinkStore.next_random.to_s
    return if taunt_link.empty? or user.nil?
    msg = "Hey, check #{taunt_link} out."
    @bot.say_as_private(user, msg)
  end
end
