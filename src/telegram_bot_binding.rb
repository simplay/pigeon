class TelegramBotBinding

  def initialize
    @has_terminated = false
    @token = Settings.telegram_token
    @priviliged_users = []
  end

  # TODO: Use conditional locking instead of busy-wait spinning loop.
  def start
    Thread.new do
      loop do
        Telegram::Bot::Client.run(@token) do |bot|
          bot.listen do |message|
            case message.text
            when /\/login/
              secret = message.text.split("/login ").last.strip
              status = Bot.login_as_telegram_user("", secret)
              status_message = status ? "Passord correct" : "Incorrect Passowrd"
              bot.api.send_message(chat_id: message.chat.id, text: status_message)
              append_user(message.from.username) if (status)
            when /^\//
              if user_has_signed_in?(message.from.username)
                cmd = message.text.split(/^\//).last.strip
                process_command(bot, message.chat.id, cmd)
              end
            end
          end
        end
        break if @has_terminated
        sleep 2
      end
    end
  end

  # Shut this thread down.
  def shutdown
    @has_terminated = true
  end

  # Checks whether a user already has signed in.
  #
  # @param user [String] nickanme of a successfully
  #   signed in user. User gets appended to the list once.
  # @return [Boolean] true if a given user aleardy has signed in, otherwise false.
  def user_has_signed_in?(user)
    @priviliged_users.include? user
  end

  # Add the a nickname of a signed in user
  # to the collection of signed in users.
  #
  # @param user [String] nickanme of a successfully
  #   signed in user. User gets appended to the list once.
  def append_user(user)
    unless user_has_signed_in?(user)
      @priviliged_users << user
    end
  end

  # Process the received command
  #
  # @param bot [TelegramBot] current telegram bot instance.
  # @param sender_id [Integer] id of telegram chat between bot and the sender.
  # @param cmd [String] received command
  def process_command(bot, sender_id, cmd)
    bot.api.send_message(chat_id: sender_id, text: "Command `#{cmd}`")
  end

end
