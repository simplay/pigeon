# Allows to register observers to receive pretty string versions of external messages.
#
# Messages are parsed based on their header.
class Mailbox

  # Mailbo Singleton
  def self.instance
    @instance ||= Mailbox.new
  end

  # @param subscriber [#handle_event] can handle the fired event.
  def self.subscribe(subscriber)
    instance.subscribe(subscriber)
  end

  # Append a foreign message to the mailbox.
  #
  # @info: results in firing an mailbox event.
  #   all mailbox' subscribers get notified accordingly.
  # @param message [String] trusted foreign message reiceived by RequestListener
  def self.append(message)
    instance.notify_all_with(message)
  end

  # @param subscriber [#handle_event] can handle the fired event.
  def subscribe(subscriber)
    @subscribers << subscriber unless included?(subscriber)
  end

  # @param sub [#handle_event] subscriber listening to fired Mailbox events.
  def included?(sub)
    @subscribers.find do |s|
      s == sub
    end
  end

  # Notify every subscriber of this mailbox.
  #
  # @param message [Event] event the subscribers all supposed to handle.
  def notify_all_with(message)
    msg = parse(message)
    @subscribers.each do |subscriber|
      subscriber.handle_event(msg)
    end
  end

  protected

  # Initializes an empty subscriber list.
  def initialize
    @subscribers = []
  end

  # Parse a passed foreign message received by an external service.
  #
  # @info: Applies a header specific parser.
  # @return [Event] parsed foreign message.
  def parse(message)
    case message.msg_header
    when 'mss'
      newlined_msg = message.msg_content.split(";").map do |item|
        item + "\n"
      end
      layout = DescriptionLayout.new
      layout.append_text(BoldText.new("Playerlist:"))
      layout.append_text(ListText.new(newlined_msg)) unless newlined_msg.empty?
      layout.append_text(BoldText.new("Additional Sources:\n"))
      layout.append_text(LabeledLinkText.new("www.foobar.com", "dummy"))
      msg = layout.merge.to_s
      Event.new("mss", {:channel_name => "Minecraft", :description => msg})
    else
      msg = "foobar: " + message.msg_content
      Event.new("else", msg)
    end
  end

end
