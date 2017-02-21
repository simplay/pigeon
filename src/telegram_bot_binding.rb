class TelegramBotBinding

  def initialize
    @has_terminated = false
    @token = Settings.telegram_token
  end

  # TODO: Use conditional locking instead of busy-wait spinning loop.
  def start
    Thread.new do
      loop do
        Telegram::Bot::Client.run(@token) do |bot|
          bot.listen do |message|
            case message.text
            when '/start'
              bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
            when /\/login/
              secret = message.text.split("/login ").last.strip
              status = Bot.login_as_telegram_user("", secret)
              status_message = status ? "Passord correct" : "Incorrect Passowrd"
              bot.api.send_message(chat_id: message.chat.id, text: status_message)
            else
              bot.api.send_message(chat_id: message.chat.id, text: "Sorry, I do not understand your message `#{message}`.")
            end
          end
        end
        break if @has_terminated
        sleep 2
      end
    end
  end

  def shutdown
    @has_terminated = true
  end

end
