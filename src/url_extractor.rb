class UrlExtractor
  attr_accessor :user, :message, :store

  URL_RGX = /https?:\/{2}\S+/

  def initialize(user, message)
    @user = user
    @message = message
  end

  # Scan message for urls and persist them for this user via UrlStore.
  def extract
    message.scan(URL_RGX).each do |url|
      UrlStore.add_url :user_id => user.id, :url => url.gsub('[/URL]', '')
    end
  end
end
