# Allows to register observers to receive pretty string versions of external messages.
#
# Messages are parsed based on their header.
class Mailbox

  # Mailbox Singleton
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
  # @param message [Event] trusted foreign message reiceived by RequestListener
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
    $server_reachable = "offline"
    @bot_update_msg = ""
    @newlined_msg = ""
  end

  # Parse a passed foreign message received by an external service.
  #
  # @info: Applies a header specific parser.
  # @return [Event] parsed foreign message.
  def parse(message)
    case message.name
    when 'mss'
        build_mc_layout(message.content)
      Event.new("mss", {:channel_name => "Minecraft", :description => @bot_update_msg})
    else
      msg = "foobar: " + message.content
      Event.new("else", msg)
    end
  end


  def build_mc_layout(content)
    unless content == "reachable_update"
      $mss_msg = Time.now
      @newlined_msg = content.split(";").map do |item|
        item + "\n"
      end
    end
    layout = DescriptionLayout.new
    layout.append_text(BoldText.new("Server status:"))
    layout.append_text(TextBlock.new(" #{$server_reachable}\n"))
    unless @newlined_msg.empty?
      layout.append_text(BoldText.new("Playerlist:"))
      layout.append_text(ListText.new(@newlined_msg))
    else
      layout.append_text(BoldText.new("No players currently online.\n"))
    end
    mc_link_bullets = DescriptionLinkStore.find_all_including_key("mc")
    unless mc_link_bullets.empty?
      layout.append_text(BoldText.new("Additional Sources:"))
      layout.append_text(ListText.new mc_link_bullets)
    end
    to_regex = Regexp.new "Server status: #{$server_reachable}"
    if @bot_update_msg.include?("Server status: online")
      Regexp.new "Server status: #{$server_reachable}"
      @bot_update_msg.gsub(/Server status: online/, to_regex)
    elsif @bot_update_msg.include?("Server status: offline")
      @bot_update_msg.gsub(/Server status: offline/, to_regex)
    end
    @bot_update_msg = layout.merge.to_s
  end

end
