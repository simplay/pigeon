class Url
  include Comparable

  attr_accessor :user_id, :url, :created_at

  def initialize(user_id, url, created_at)
    @user_id, @url, @created_at = user_id, url, created_at
  end

  def <=>(other)
    created_at <=> other.created_at
  end

  # @return [String] the url with teamspeak url escape tags.
  def escaped
    "[URL]#{url.gsub("/", "\/")}[\/URL]"
  end
end
