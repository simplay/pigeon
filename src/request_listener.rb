require 'socket'

# Interface to let external sources communicate with Sir Pigeon.
#
# This interface is used to let pigeon update certain channel information based on
# external sources. E.g. our minecraft server tool send pigeon periodically
# status information (how many player are currently online, who is only, etc.)
# Pigeon will make use of this data and updates the corresponding minecraft channel
# description accordingly.
#
# @example: Running this process will send pigeon the message "1 #{ARGV[0].to_s}".
#   pigeon will process this message. Assumption SECRET is pigeon's secret.
#
#   require 'socket'
#   require 'digest/sha1'
#   require 'json'
#   hostname = "localhost"
#   port = 21337
#   SECRET = "pew"
#
#   socket = TCPSocket.open(hostname, port)
#   1.times do |i|
#     content = "#{i.to_s}: #{ARGV[0].to_s}"
#     msg = {
#       :header => :text,
#       :secret => Digest::SHA1.hexdigest(SECRET),
#       :content => content
#     }
#     j_msg = msg.to_json
#     puts j_msg
#     socket.puts(j_msg)
#     sleep 0.2
#   end
#   socket.close
#
class RequestListener

  # Default Pigeon port
  P_EXT_PORT = 21337

  # Create a new TCP Server listening on a given port and ip
  # for foreign (trusted) messages.
  #
  # @example
  #   RequestListener.new
  #   => #<RequestListener:0x463fd068 @hostname="localhost", @port=21337>
  #   RequestListener.new("127.0.0.1")
  #   => #<RequestListener:0x463fd068 @hostname="127.0.0.1", @port=21337>
  #   RequestListener.new("192.168.1.113", 1234)
  #   => #<RequestListener:0x463fd068 @hostname="192.168.1.113", @port=1234>
  #
  # @param ip [String] ip or hostname of tcp socket server
  # @param port [Integer] port the server is listening to.
  def initialize(ip="localhost", port=P_EXT_PORT)
    @hostname = ip
    @port = port
  end

  # Start a concurrent tcp socket listener.
  # Received messages are processed any further if they are valid,
  # i.e. include the pigeon secret and are in the pigeon message format.
  def start
    @server = TCPServer.open(@hostname, @port)
    loop do
      Thread.new(@server.accept) do |client|
        while message = client.gets
          fmp = ForeignMessageParser.new(message)
          Mailbox.append(fmp.to_event) if fmp.got_valid_message?
        end
        client.close
      end
    end
  end

  # Forces the server socket listener to close and shuts down its spawned threads.
  # Whithout calling this method, Pigeon cannot shut down properly.
  def stop
    @server.close
  end

end
