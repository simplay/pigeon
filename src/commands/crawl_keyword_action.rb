class CrawlKeywordAction < WithArgumentsAction
  def run(keyword)
    amount = 1
    Bot.say_in_current_channel "Searching for wtf stuff..."
    crawler = keyword.empty? ? Crawler.new : Crawler.new(keyword.first)
    unless crawler.ok?
      Bot.say_as_private(Command.sender, "Sorry, nothing found...")
      return
    end
    crawler.links.first(amount).each do |result|
      Bot.say_as_private(Command.sender, "https://reddit.com"+result.last, true)
    end
  end
end
