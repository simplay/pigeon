require 'socket'

# Interface to let external sources communicate with Sir Pigeon.
#
# This interface is used to let pigeon update certain channel information based on
# external sources. E.g. our minecraft server tool send pigeon periodically
# status information (how many player are currently online, who is only, etc.)
# Pigeon will make use of this data and updates the corresponding minecraft channel
# description accordingly.
#
# @example: Running this process will send pigeon the message foobar.
#   pigeon will process this message.
#
#   require 'socket'
#
#   hostname = "localhost"
#   port = 21337
#
#   socket = TCPSocket.open(hostname, port)
#   socket.puts("foobar")
#
#   socket.close
#
class RequestListener

  def initialize(bot)
    @hostname = "localhost"
    @port = 21337
    @bot = bot
  end

  def start
    @is_running = true
    server = TCPServer.open(@port)
    loop do
      Thread.start(server.accept) do |client|
        while message = client.gets
          # notify bot by message
          @bot.say_in_current_channel(message.chop)
        end
        client.close
      end
      break unless @is_running
    end
  end

  def stop
    @is_running = false
  end

end

