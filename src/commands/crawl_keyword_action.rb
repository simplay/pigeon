# Crawl an arbitrary multimedia item (article, image, video, sound, ...) from reddit
# that matches a given keyword.
class CrawlKeywordAction < WithArgumentsAction

  # @param keyword [Array<String>] keyword as a joined string.
  def run(keyword)
    amount = 1
    Bot.say_in_current_channel("Searching for wtf stuff...")
    # search words are + separated
    search_word = keyword.join("+")
    crawler = keyword.empty? ? Crawler.new : Crawler.new(search_word)
    unless crawler.ok?
      Bot.say_as_private(Command.sender, "Sorry, nothing found...")
      return
    end
    crawler.links.first(amount).each do |result|
      Bot.say_as_private(Command.sender, "https://reddit.com" + result.last, true)
    end
  end
end
