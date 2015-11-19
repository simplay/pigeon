class UrlExtractor
  attr_accessor :user, :message, :store

  URL_RGX = /\[URL\](.+)\[\/URL\]/

  def initialize(user, message)
    @user = user
    @message = message
  end

  # Scan message for urls and persist them for this user via UrlStore.
  def extract
    message.scan(URL_RGX).each do |url|
      UrlStore.add_url :user_id => user.id, :url => url.first#gsub(/\[|\]/, "")
    end
  end
end
