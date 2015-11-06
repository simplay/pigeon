require 'net/http'
require 'uri'
require "json"

# Reddit content crawler
class Crawler

  # A list Array<String> of fetched links.
  attr_reader :links

  REDDIT_ADDESS = "https://www.reddit.com/"

  # @param keyword [String] a target keyword interpreted
  #   as a certain subreddit r/keyword
  # @info: The url should end by a '/' character.
  # @example
  #   Crawler.new # fetch links in https://www.reddit.com/new.json
  #   Crawler.new("cute") # fetch links in https://www.reddit.com/r/cute
  def initialize(keyword='new')
    base_address = (keyword == 'new') ? REDDIT_ADDRESS : "#{REDDIT_ADDRESS}r/"
    url = "#{base_address}#{keyword}/.json"
    page_as_json = open_as_json(url)
    @links = extract_images(page_as_json)
  end

  protected

  # @param json_hash [Hash] json hash of a target reddit page.
  def extract_images(json_hash)
    json_hash['data']['children'].map do |node|
      title = node['data']['title']
      [title, fetched_content_of(node)]
    end
  end

  def fetched_content_of(node)
    link = node['data']['selftext_html']
    return link unless link.nil?
    case node['data']['domain']
    when 'youtube'
      node['data']["secure_media"]['oembed']["url"]
    else
      node['data']['permalink']
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
    JSON.parse(response.body)
  end

end

class RedditImgCrawler < Crawler
  def initialize
    super('pics')
  end

  protected

  def fetched_content_of(node)
    node['data']['url']
  end

end
