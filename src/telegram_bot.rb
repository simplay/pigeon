require 'telegram_bot'
require 'pp'
require 'logger'

class TelegramBot

  def self.instance
    @instance ||= self.new
  end

  def self.start
    instance
  end

  def initialize

    #  logger = Logger.new(STDOUT, Logger::DEBUG)
    Thread.new do

      bot = TelegramBot.new(token: '313282135:AAGh7BtOiRjDu1bzRsGRUVyen1HM0Le34SQ')
      # logger.debug "starting telegram bot"

      bot.get_updates(fail_silently: true) do |message|
        # logger.info "@#{message.from.username}: #{message.text}"
        command = message.get_command_for(bot)

        message.reply do |reply|
          case command
          when /greet/i
            reply.text = "Hello, #{message.from.first_name}!"
          else
            reply.text = "#{message.from.first_name}, have no idea what #{command.inspect} means."
          end
          # logger.info "sending #{reply.text.inspect} to @#{message.from.username}"
          reply.send_with(bot)
        end
      end
    end
  end
end
