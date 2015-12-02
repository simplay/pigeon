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

  def run
    task
  end

  protected

  def task
    raise "Not implemented yet"
  end

end

# Check the afk state of every online user.
class MoveAfkUsers < PeriodicTask
  def task
    afk_users = User.all.select(&:afk?)
    afk_users.each do |user|
      @bot.move_target(user, @afk_channel.id)
      @bot.say_as_poke(user, "Sorry, but I moved you to the AFK channel.")
    end
  end
end
