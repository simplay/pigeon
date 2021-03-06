require 'pstore'
require 'url'
require 'singleton'

# Persists urls per user on file system. Can be used to keep track of what urls
# users posted in chat.
#
# @example
#
#   # adding urls
#   UrlStore.add_url(
#     :user_id => 2,
#     :url => "http://definitely-not-porn.com"
#   )
#
#   # retrieving urls
#   UrlStore.urls(2)
#   urls.first.user_id # => 2
#   urls.first.url # => "http://definitely-not-porn.com"
class UrlStore
  include Singleton

  # How many urls to persist per user.
  MAX_URLS_PER_USER = 50

  class << self
    def all
      instance.all
    end

    def add_url(args)
      instance.add_url(args)
    end

    def urls(user_id)
      instance.urls(user_id)
    end
  end

  # @return [Array<Url>]
  def all
    store.transaction do
      store.roots.flat_map do |user_id|
        store.fetch(user_id, [])
      end
    end
  end

  # @param [Hash] args url attributes.
  # @option args [Integer] :user_id a user's unique id.
  # @option args [String] :url url to persist, e.g. 'foo.bar.net'
  # @option args [Time] :created_at when the entry was created, defaults to
  #   now.
  def add_url(args)
    user_id = args.fetch(:user_id)
    url = args.fetch(:url)
    created_at = args.fetch(:created_at, Time.now)

    store.transaction do
      urls = store[user_id] ||= []
      urls << Url.new(user_id, url, created_at)
      urls.shift if urls.count > max_urls_per_user
    end
  end

  # @param [Integer]
  # @return [Array<Url>] list of Urls stored for user_id.
  def urls(user_id)
    store.transaction do
      store.fetch(user_id, [])
    end
  end

  private

  def max_urls_per_user
    MAX_URLS_PER_USER
  end

  def store
    @store ||= PStore.new('data/urls.pstore')
  end
end
