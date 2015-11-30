# Allows to register observers to receive pretty string versions of external messages.
#
# Messages are parsed based on their header.
class Mailbox

  def self.instance
    @instance ||= Mailbox.new
  end

  # @param subscriber [#handle_event] can handle the fired event.
  def self.subscribe(subscriber)
    instance.subscribe(subscriber)
  end

  def self.append(message)
    instance.notify_all_with(message)
  end

  # @param subscriber [#handle_event] can handle the fired event.
  def subscribe(subscriber)
    @subscribers << subscriber
  end

  def notify_all_with(message)
    msg = parse(message)
    @subscribers.each do |subscriber|
      subscriber.handle_event(msg)
    end
  end

  def initialize
    @subscribers = []
  end

  def parse(message)
    case message.msg_header
    when 'mss'
      "mc: " + message.msg_content
    else
      "foobar: " + message.msg_content
    end
  end

end
