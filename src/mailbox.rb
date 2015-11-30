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
    @subscribers << subscriber unless included?(subscriber)
  end

  def included?(sub)
    @subscribers.find do |s|
      s == sub
    end
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
      newlined_msg = message.msg_content.split(";").map do |item|
        item + "\n"
      end
      msg = "Playerlist:\n" + newlined_msg.join
      Event.new("mss", {:channel_name => "Minecraft", :description => msg})
    else
      msg = "foobar: " + message.msg_content
      Event.new("else", msg)
    end
  end

end
