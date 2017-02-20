class CrawlImage < SimpleAction
  def run
    Bot.say_as_private(Command.sender, "Searching for random stuff...")
    crawler = RedditImgCrawler.new
    results = crawler.links
    random_idx = rand(0..results.count-1)
    Bot.say_as_private(Command.sender, results.values[random_idx], true)
  end
end
