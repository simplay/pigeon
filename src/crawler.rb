require 'net/http'
require 'uri'
require "json"

# Reddit content crawler
class Crawler

  REDDIT_ADDRESS = "https://www.reddit.com/"

  # @param keyword [String] a target keyword interpreted
  #   as a certain subreddit r/keyword
  # @example
  #   Crawler.new # fetch links in https://www.reddit.com/new.json
  #   Crawler.new("cute") # fetch links in https://www.reddit.com/r/cute
  def initialize(keyword='new')
    base_address = (keyword == 'new') ? REDDIT_ADDRESS : "#{REDDIT_ADDRESS}r/"
    url = "#{base_address}#{keyword}/.json"
    page_as_json = open_as_json(url)
    @links = extract_images(page_as_json) unless page_as_json.empty?
  end

  # Checks whether the crawler could fetch and store meanungfu data in links.
  #
  # @return [Boolean] true if fetching web-content yield status 200,
  #   otherwise false.
  def ok?
    !@links.nil?
  end

  # Retrieve a hash containing a crawler's fetched data.
  #
  # @info: links are randomly re-sorted.
  # @return [Hash{PostTitle => PostUrl}] fetched crawler links with their title
  def links
    randomly_sorted_links = @links.shuffle
    Hash[*randomly_sorted_links.flatten]
  end

  protected

  # Extract content of posts from target reddit/subreddit.
  #
  # @info: The title and the relevant link to the post is
  #   extracted.
  # @param json_hash [Hash] json hash of a target reddit page.
  # @return [Array<Array[String]] a list containing the extracted
  #   title and links of a particular reddit post.
  def extract_images(json_hash)
    json_hash['data']['children'].map do |node|
      post = node['data']
      title = post['title']
      [title, fetched_content_of(post)]
    end
  end

  # Extract youtube link or permalink from current post.
  def fetched_content_of(post)
    case post['domain']
    when 'youtube'
      post["secure_media"]['oembed']["url"]
    else
      post['permalink']
    end
  end

  # Get json representation of target url.
  #
  # @param json_url [String] url to json response of target reddit page.
  # @info: corresponds to the crawler's url concatinated with ".json"
  # @return [Hash] containing the requested json object.
  def open_as_json(json_url)
    uri = URI.parse(json_url)
    response = Net::HTTP.get_response(uri)
    return {} unless response.code == "200"
    JSON.parse(response.body)
  end

end

# Fetches image links from /r/pics
class RedditImgCrawler < Crawler
  def initialize
    super('pics')
  end

  protected

  def fetched_content_of(post)
    post['url']
  end

end
